local QBCore = exports['qb-core']:GetCoreObject()

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

local function ValidAmount(amount)
    amount = tonumber(amount) or 0
    if amount <= 0 or amount > Config.Limits.MaxTransaction then return nil end
    return math.floor(amount)
end

-- ── Balans ──
RegisterNetEvent('196rp_atm:server:getBalance', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    TriggerClientEvent('196rp_atm:client:balance', src, {
        cash = Player.PlayerData.money.cash or 0,
        bank = Player.PlayerData.money.bank or 0,
    })
end)

-- ── Çıxarış ──
RegisterNetEvent('196rp_atm:server:withdraw', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    amount = ValidAmount(amount)
    if not amount then
        Notify(src, 'Məbləğ 1 ₣ - 250 000 ₣ arası olmalıdır.', 'error')
        return
    end
    if (Player.PlayerData.money.bank or 0) < amount then
        Notify(src, 'Bankda kifayət qədər pul yoxdur.', 'error')
        return
    end
    Player.Functions.RemoveMoney('bank', amount, 'atm-withdraw')
    Player.Functions.AddMoney('cash', amount, 'atm-withdraw')
    Notify(src, ('💵 Çıxarıldı: ₣%d'):format(amount), 'success')
    TriggerClientEvent('196rp_atm:client:refresh', src)
end)

-- ── Yatırma ──
RegisterNetEvent('196rp_atm:server:deposit', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    amount = ValidAmount(amount)
    if not amount then
        Notify(src, 'Məbləğ 1 ₣ - 250 000 ₣ arası olmalıdır.', 'error')
        return
    end
    if (Player.PlayerData.money.cash or 0) < amount then
        Notify(src, 'Cibinizdə kifayət qədər pul yoxdur.', 'error')
        return
    end
    Player.Functions.RemoveMoney('cash', amount, 'atm-deposit')
    Player.Functions.AddMoney('bank', amount, 'atm-deposit')
    Notify(src, ('🏦 Yatırıldı: ₣%d'):format(amount), 'success')
    TriggerClientEvent('196rp_atm:client:refresh', src)
end)

-- ── Köçürmə ──
RegisterNetEvent('196rp_atm:server:transfer', function(targetSrc, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local Target = QBCore.Functions.GetPlayer(tonumber(targetSrc))
    if not Target then
        Notify(src, 'Hədəf oyunçu tapılmadı!', 'error')
        return
    end
    if tonumber(targetSrc) == src then
        Notify(src, 'Özünüzə köçürə bilməzsiniz.', 'error')
        return
    end
    amount = ValidAmount(amount)
    if not amount then
        Notify(src, 'Məbləğ 1 ₣ - 250 000 ₣ arası olmalıdır.', 'error')
        return
    end
    if (Player.PlayerData.money.bank or 0) < amount then
        Notify(src, 'Bankda kifayət qədər pul yoxdur.', 'error')
        return
    end
    Player.Functions.RemoveMoney('bank', amount, 'atm-transfer')
    Target.Functions.AddMoney('bank', amount, 'atm-transfer')
    Notify(src, ('📤 Köçürüldü: ₣%d → %s'):format(amount, Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname), 'success')
    Notify(Target.PlayerData.source, ('📥 %s sizə ₣%d köçürdü.'):format(Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname, amount), 'success')
end)
