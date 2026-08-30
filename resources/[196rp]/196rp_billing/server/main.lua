local QBCore = exports['qb-core']:GetCoreObject()

local bills = {} -- id → { from, to, amount, reason, expires }

-- ═══════════════════════════════════════════════════════════════
-- Yardımçılar
-- ═══════════════════════════════════════════════════════════════

local function SendWebhook(content, color, fields)
    if Config.Webhook == nil or Config.Webhook == '' or Config.Webhook:find('BURAYA') then return end
    local payload = {
        embeds = { {
            title = '🧾 Faktura | 196 RP',
            description = content,
            color = color or 3447003,
            fields = fields or {},
            footer = { text = 'Azerbaijan Role Play' },
            timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        } }
    }
    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST',
        json.encode(payload), { ['Content-Type'] = 'application/json' })
end

local function PayBill(target, amount)
    local Player = QBCore.Functions.GetPlayer(target)
    if not Player then return false, 'not_online' end

    if Config.PaymentMethod == 'bank' or Config.PaymentMethod == 'both' then
        if Player.PlayerData.money.bank >= amount then
            Player.Functions.RemoveMoney('bank', amount, 'faktura-ödəmə')
            return true, 'bank'
        end
    end
    if Config.PaymentMethod == 'cash' or Config.PaymentMethod == 'both' then
        if Player.PlayerData.money.cash >= amount then
            Player.Functions.RemoveMoney('cash', amount, 'faktura-ödəmə')
            return true, 'cash'
        end
    end
    return false, 'insufficient'
end

local function GiveMoney(target, amount)
    local Player = QBCore.Functions.GetPlayer(target)
    if not Player then return end
    Player.Functions.AddMoney('cash', amount, 'faktura-qəbuz')
end

-- ═══════════════════════════════════════════════════════════════
-- /faktura <id> <məbləğ> <səbəb>
-- ═══════════════════════════════════════════════════════════════

QBCore.Commands.Add('faktura', 'Oyunçuya faktura göndər (pul qəbuzu)', {
    { name = 'id', help = 'Oyunçunun ID-si' },
    { name = 'məbləğ', help = 'Məbləğ (₣)' },
    { name = 'səbəb', help = 'Faktura səbəbi' },
}, false, function(source, args)
    local target = tonumber(args[1])
    local amount = tonumber(args[2])
    if not target or not amount or amount <= 0 then
        TriggerClientEvent('QBCore:Notify', source, 'Düzgün istifadə: /faktura <id> <məbləğ> <səbəb>', 'error')
        return
    end
    if amount > Config.MaxAmount then
        TriggerClientEvent('QBCore:Notify', source, ('Maksimum məbləğ: ₣%s'):format(Config.MaxAmount), 'error')
        return
    end
    local reason = table.concat(args, ' ', 3)
    if reason == '' then reason = 'Faktura' end

    local Target = QBCore.Functions.GetPlayer(target)
    if not Target then
        TriggerClientEvent('QBCore:Notify', source, 'Oyunçu tapılmadı.', 'error')
        return
    end
    if target == source then
        TriggerClientEvent('QBCore:Notify', source, 'Özünə faktura yaza bilməzsən.', 'error')
        return
    end

    local fromName = GetPlayerName(source) or 'Şirkət'
    local billId = math.random(100000, 999999)
    bills[billId] = {
        from = source,
        to = target,
        amount = amount,
        reason = reason,
        expires = os.time() + Config.Expiry,
        fromName = fromName,
    }

    TriggerClientEvent('196rp_billing:client:showBill', target, {
        id = billId,
        from = fromName,
        amount = amount,
        reason = reason,
        expiry = Config.Expiry,
    })

    print(('^2[196RP BILLING]^7 #%d: %s → %s ₣%s (%s)'):format(billId, fromName, Target.PlayerData.charinfo.firstname, amount, reason))
end, false)

-- ═══════════════════════════════════════════════════════════════
-- Qəbul / imtina
-- ═══════════════════════════════════════════════════════════════

RegisterNetEvent('196rp_billing:server:accept', function(billId)
    local src = source
    local bill = bills[billId]
    if not bill then
        TriggerClientEvent('QBCore:Notify', src, 'Bu faktura mövcud deyil.', 'error')
        return
    end
    if bill.to ~= src then return end
    if os.time() > bill.expires then
        bills[billId] = nil
        TriggerClientEvent('QBCore:Notify', src, 'Faktura müddəti bitdi.', 'error')
        return
    end

    local ok, how = PayBill(src, bill.amount)
    if not ok then
        TriggerClientEvent('QBCore:Notify', src, 'Kifayət qədər pul yoxdur!', 'error')
        return
    end

    GiveMoney(bill.from, bill.amount)
    TriggerClientEvent('QBCore:Notify', src, ('✅ Faktura ödənildi: ₣%s (%s)'):format(bill.amount, bill.reason), 'success')
    TriggerClientEvent('QBCore:Notify', bill.from, ('✅ Faktura qəbul edildi: ₣%s (%s)'):format(bill.amount, bill.reason), 'success')

    SendWebhook('Faktura QƏBUL EDİLDİ ✅', 3066993, {
        { name = 'Faktura #', value = tostring(billId), inline = true },
        { name = 'Məbləğ', value = '₣' .. bill.amount, inline = true },
        { name = 'Ödəniş', value = how, inline = true },
        { name = 'Səbəb', value = bill.reason, inline = false },
        { name = 'Göndərən', value = bill.fromName, inline = true },
        { name = 'Ödəyən', value = GetPlayerName(src), inline = true },
    })
    bills[billId] = nil
end)

RegisterNetEvent('196rp_billing:server:decline', function(billId)
    local src = source
    local bill = bills[billId]
    if not bill or bill.to ~= src then return end
    bills[billId] = nil
    TriggerClientEvent('QBCore:Notify', src, '❌ Faktura imtina edildi.', 'error')
    SendWebhook('Faktura İMTİNA EDİLDİ ❌', 15158332, {
        { name = 'Məbləğ', value = '₣' .. bill.amount, inline = true },
        { name = 'Səbəb', value = bill.reason, inline = false },
    })
end)

-- Müddəti bitən fakturaları təmizlə
CreateThread(function()
    while true do
        local now = os.time()
        for id, bill in pairs(bills) do
            if now > bill.expires then
                bills[id] = nil
            end
        end
        Wait(30000)
    end
end)
