-- 196 RP | İqtisadiyyat mərkəzi — server
-- Dinamik qiymət, vergilər, dövlət xəzinəsi və dupe qorunması.

local ESX = exports['es_extended']:getSharedObject()

local priceIndex = Config.BaseIndex
local treasury = Config.Treasury.startBalance
local transfers = {}      -- [src] = { count = n, windowStart = os.time(), daily = n }

-- ==================== YÜKLƏMƏ ====================

CreateThread(function()
    local row = MySQL.single.await('SELECT price_index, treasury FROM `196rp_economy` WHERE id = 1')

    if row then
        priceIndex = Economy.ClampIndex(row.price_index)
        treasury = math.min(row.treasury or treasury, Config.Treasury.maxBalance)
    else
        MySQL.insert.await(
            'INSERT INTO `196rp_economy` (id, price_index, treasury, updated_at) VALUES (1, ?, ?, NOW())',
            { priceIndex, treasury })
    end

    print(('[196rp_economy] hazır — index: %.1f, xəzinə: %s'):format(priceIndex, treasury))
end)

-- Saatlıq normallaşma + vəziyyətin bazaya yazılması
CreateThread(function()
    while true do
        Wait(3600000)

        priceIndex = Economy.Decay(priceIndex, 1)

        MySQL.update.await(
            'UPDATE `196rp_economy` SET price_index = ?, treasury = ?, updated_at = NOW() WHERE id = 1',
            { priceIndex, treasury })
    end
end)

-- ==================== DUPE QORUNMASI ====================

local function CheckLimits(src, amount)
    if not Config.DupeGuard.enabled then
        return true
    end

    local now = os.time()
    local rec = transfers[src]

    if not rec then
        rec = { count = 0, windowStart = now, daily = 0 }
        transfers[src] = rec
    end

    -- dəqiqəlik pəncərə
    if now - rec.windowStart > 60 then
        rec.count = 0
        rec.windowStart = now
    end

    if rec.count >= Config.DupeGuard.maxTransfersPerMinute then
        return false, 'Çox sürətli köçürmə. Bir dəqiqə gözləyin.'
    end

    if rec.daily + amount > Config.DupeGuard.maxDailyTotal then
        return false, 'Gündəlik köçürmə limitiniz dolub.'
    end

    return true
end

local function RegisterTransfer(src, amount)
    local rec = transfers[src]

    if rec then
        rec.count = rec.count + 1
        rec.daily = rec.daily + amount
    end
end

local function LogTransaction(kind, fromId, toId, amount, note)
    if not Config.DupeGuard.logAll then
        return
    end

    MySQL.insert.await(
        'INSERT INTO `196rp_transactions` (kind, from_id, to_id, amount, note, created_at) VALUES (?, ?, ?, ?, ?, NOW())',
        { kind, fromId, toId, amount, note or '' })
end

-- ==================== İXRACLAR ====================

-- Cari qiymət index-i
exports('GetIndex', function()
    return priceIndex
end)

-- Baza qiymətdən cari bazar qiymətini hesablayır
exports('Price', function(basePrice)
    return Economy.Price(basePrice, priceIndex)
end)

-- Alış: vergi tutur, xəzinəyə yazır, index-i yeniləyir
exports('Charge', function(src, baseAmount, reason)
    local withTax = Economy.WithTax(Economy.Price(baseAmount, priceIndex))

    if withTax <= 0 then
        return 0
    end

    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        xPlayer.removeMoney(withTax, reason or 'alis')
    end

    local taxPart = withTax - Economy.Price(baseAmount, priceIndex)
    treasury = math.min(treasury + taxPart, Config.Treasury.maxBalance)

    priceIndex = Economy.NextIndex(priceIndex, withTax)

    LogTransaction('purchase', tostring(src), 'treasury', withTax, reason or 'alis')

    return withTax
end)

-- Ödəniş: gəlir vergisi tutur, qalanı oyunçuya verir
exports('Pay', function(src, grossAmount, reason)
    local net = Economy.AfterTax(grossAmount)

    if net <= 0 then
        return 0
    end

    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        xPlayer.addMoney(net, reason or 'gelir')
    end

    local taxPart = grossAmount - net
    treasury = math.min(treasury + taxPart, Config.Treasury.maxBalance)

    LogTransaction('income', 'treasury', tostring(src), net, reason or 'gelir')

    return net
end)

-- Oyunçular arası köçürmə (dupe qorunması ilə)
exports('Transfer', function(fromSrc, toSrc, amount, note)
    local valid, err = Economy.ValidAmount(amount)

    if not valid then
        return false, err or 'Yanlış məbləğ.'
    end

    if Config.DupeGuard.blockSelf and fromSrc == toSrc then
        return false, 'Özünüzə pul göndərə bilməzsiniz.'
    end

    local ok, limitMsg = CheckLimits(fromSrc, amount)

    if not ok then
        if Config.DupeGuard.alertAdminOnBreach then
            print(('[196rp_economy] DUPE ŞÜBHƏSİ: src=%s amount=%s (%s)'):format(
                tostring(fromSrc), tostring(amount), limitMsg))
        end

        return false, limitMsg
    end

    local from = ESX.GetPlayerFromId(fromSrc)
    local to = ESX.GetPlayerFromId(toSrc)

    if not from or not to then
        return false, 'Oyunçu tapılmadı.'
    end

    local fee = Economy.TransferFee(amount)
    local total = amount + fee

    if from.getMoney() < total then
        return false, 'Kifayət qədər pulunuz yoxdur (komissiya daxil).'
    end

    from.removeMoney(total, 'kocurme')
    to.addMoney(amount, 'kocurme')
    treasury = math.min(treasury + fee, Config.Treasury.maxBalance)

    RegisterTransfer(fromSrc, amount)
    LogTransaction('transfer', from.identifier, to.identifier, amount, note or '')

    return true, ('%s ₼ göndərildi (komissiya: %s ₼)'):format(amount, fee)
end)

-- Money sink: pulu sistemdən çıxarır (icra/kirayə/cərimə)
exports('Sink', function(src, sinkName, customAmount)
    local amount = customAmount or Config.Sinks[sinkName]

    if not amount or amount <= 0 then
        return false, 'Belə ödəniş növü yoxdur.'
    end

    local total = Economy.WithTax(amount)
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return false, 'Oyunçu tapılmadı.'
    end

    if xPlayer.getMoney() < total then
        return false, 'Kifayət qədər pulunuz yoxdur.'
    end

    xPlayer.removeMoney(total, 'sink_' .. tostring(sinkName))
    treasury = math.min(treasury + total, Config.Treasury.maxBalance)

    LogTransaction('sink', xPlayer.identifier, 'treasury', total, tostring(sinkName))

    return true, total
end)

-- İqtisadi vəziyyət (admin/UI üçün)
exports('GetStatus', function()
    return {
        index = priceIndex,
        treasury = treasury,
        inflation = math.floor((priceIndex - 100.0) * 10) / 10,
    }
end)

-- ==================== ƏMR ====================

RegisterCommand('iqtisadiyyat', function(source)
    local status = exports(GetCurrentResourceName()):GetStatus()

    TriggerClientEvent('esx:showNotification', source,
        ('📊 Bazar indeksi: ~b~%.1f~s~ (%+.1f%%)\n🏛️ Dövlət xəzinəsi: ~g~%s ₼~s~'):format(
            status.index, status.inflation, status.treasury), 'info', 10000)
end, false)

-- ==================== TƏMİZLƏMƏ ====================

AddEventHandler('playerDropped', function()
    transfers[source] = nil
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    MySQL.update.await(
        'UPDATE `196rp_economy` SET price_index = ?, treasury = ?, updated_at = NOW() WHERE id = 1',
        { priceIndex, treasury })
end)
