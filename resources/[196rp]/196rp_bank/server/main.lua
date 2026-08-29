-- 196 RP | Bank — server tərəfi
-- Balans / pul qoyma / çıxarma / köçürmə

local ESX = exports['es_extended']:getSharedObject()

local function BankMoney(xPlayer)
    local acc = xPlayer.getAccount('bank')
    return acc and acc.money or 0
end

-- ==================== BALANS ====================

ESX.RegisterServerCallback('196rp_bank:getBalance', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(nil)
    end

    cb({
        cash = xPlayer.getMoney(),
        bank = BankMoney(xPlayer),
        name = ('%s %s'):format(xPlayer.get('firstName') or '?', xPlayer.get('lastName') or '?')
    })
end)

-- ==================== PUL QOYMA ====================

ESX.RegisterServerCallback('196rp_bank:deposit', function(source, cb, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then
        return cb(false, 'Düzgün məbləğ daxil edin!')
    end

    if amount > 1000000 then
        return cb(false, 'Bir dəfəyə ən çox 1.000.000$ qoymaq olar!')
    end

    if xPlayer.getMoney() < amount then
        return cb(false, 'Nağd pulunuz kifayət etmir!')
    end

    xPlayer.removeMoney(amount)
    xPlayer.addAccountMoney('bank', amount)

    cb(true, ('~g~%s$~s~ banka qoyuldu.'):format(amount))
end)

-- ==================== PUL ÇIXARMA ====================

ESX.RegisterServerCallback('196rp_bank:withdraw', function(source, cb, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then
        return cb(false, 'Düzgün məbləğ daxil edin!')
    end

    if BankMoney(xPlayer) < amount then
        return cb(false, 'Bank hesabınızda kifayət qədər pul yoxdur!')
    end

    xPlayer.removeAccountMoney('bank', amount)
    xPlayer.addMoney(amount)

    cb(true, ('~g~%s$~s~ nağdlaşdırıldı.'):format(amount))
end)

-- ==================== KÖÇÜRMƏ ====================

ESX.RegisterServerCallback('196rp_bank:transfer', function(source, cb, targetId, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    amount = math.floor(tonumber(amount) or 0)
    targetId = tonumber(targetId)

    if not targetId or amount <= 0 then
        return cb(false, 'Düzgün ID və məbləğ daxil edin!')
    end

    if targetId == source then
        return cb(false, 'Özünüzə pul köçürə bilməzsiniz!')
    end

    local target = ESX.GetPlayerFromId(targetId)
    if not target then
        return cb(false, 'Bu ID-li oyunçu onlayn deyil!')
    end

    if BankMoney(xPlayer) < amount then
        return cb(false, 'Hesabınızda kifayət qədər pul yoxdur!')
    end

    xPlayer.removeAccountMoney('bank', amount)
    target.addAccountMoney('bank', amount)

    local targetName = ('%s %s'):format(target.get('firstName') or '?', target.get('lastName') or '?')
    TriggerClientEvent('esx:showNotification', targetId,
        ('~g~Hesabınıza %s$ köçürüldü~s~ (göndərən: %s)'):format(amount,
            ('%s %s'):format(xPlayer.get('firstName') or '?', xPlayer.get('lastName') or '?')), 'success')

    cb(true, ('~g~%s$~s~ %s adlı oyunçuya köçürüldü.'):format(amount, targetName))
end)
