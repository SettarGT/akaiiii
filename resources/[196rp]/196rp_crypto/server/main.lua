local QBCore = exports['qb-core']:GetCoreObject()

local history = {}   -- { { t = epoch, p = price }, ... }
local price = Config.StartPrice

-- ── Bazar simulyasiyası ──
local function InitHistory()
    local now = os.time()
    for i = Config.Sim.HistorySize, 1, -1 do
        history[#history + 1] = { t = now - i * Config.Sim.Interval, p = price }
    end
end
InitHistory()

CreateThread(function()
    while true do
        Wait(Config.Sim.Interval * 1000)
        local drift = (math.random() - 0.48) * Config.Sim.Volatility
        price = math.max(10, math.floor(price * (1 + drift)))
        history[#history + 1] = { t = os.time(), p = price }
        while #history > Config.Sim.HistorySize do table.remove(history, 1) end
        MySQL.insert('INSERT INTO 196_crypto_history (price, created_at) VALUES (?, NOW())', { price })
    end
end)

local function GetBalance(cid, cb)
    MySQL.query('SELECT amount FROM 196_crypto WHERE citizenid = ?', { cid }, function(r)
        cb(r and #r > 0 and r[1].amount or 0)
    end)
end

local function SetBalance(cid, amount)
    MySQL.update('INSERT INTO 196_crypto (citizenid, amount, updated_at) VALUES (?, ?, NOW()) ON DUPLICATE KEY UPDATE amount = VALUES(amount), updated_at = NOW()', {
        cid, amount,
    })
end

-- ── Panel aç ──
RegisterNetEvent('196rp_crypto:server:open', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    GetBalance(Player.PlayerData.citizenid, function(balance)
        TriggerClientEvent('196rp_crypto:client:open', src, {
            price = price,
            balance = balance,
            history = history,
            cash = Player.PlayerData.money.cash or 0,
            bank = Player.PlayerData.money.bank or 0,
        })
    end)
end)

-- ── Al ──
RegisterNetEvent('196rp_crypto:server:buy', function(cashAmount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    cashAmount = math.floor(tonumber(cashAmount) or 0)
    if cashAmount < Config.Limits.MinTrade or cashAmount > Config.Limits.MaxTrade then
        TriggerClientEvent('QBCore:Notify', src, ('Məbləğ ₣%d - ₣%d arası olmalıdır.'):format(Config.Limits.MinTrade, Config.Limits.MaxTrade), 'error')
        return
    end
    if (Player.PlayerData.money.cash or 0) < cashAmount then
        TriggerClientEvent('QBCore:Notify', src, 'Kifayət qədər nağd pul yoxdur!', 'error')
        return
    end
    Player.Functions.RemoveMoney('cash', cashAmount, 'crypto-buy')
    local coins = (cashAmount / price) * (1 - Config.Limits.Fee / 100)
    GetBalance(Player.PlayerData.citizenid, function(bal)
        SetBalance(Player.PlayerData.citizenid, bal + coins)
        TriggerClientEvent('QBCore:Notify', src, ('🪙 %s 196COIN aldınız (-₣%d)'):format(('%.4f'):format(coins), cashAmount), 'success')
        TriggerClientEvent('196rp_crypto:client:refresh', src)
    end)
end)

-- ── Sat ──
RegisterNetEvent('196rp_crypto:server:sell', function(coinsAmount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    coinsAmount = tonumber(coinsAmount) or 0
    if coinsAmount <= 0 then return end
    GetBalance(Player.PlayerData.citizenid, function(bal)
        if bal < coinsAmount then
            TriggerClientEvent('QBCore:Notify', src, 'Kifayət qədər 196COIN yoxdur!', 'error')
            return
        end
        local payout = math.floor(coinsAmount * price * (1 - Config.Limits.Fee / 100))
        if payout < 1 then return end
        SetBalance(Player.PlayerData.citizenid, bal - coinsAmount)
        Player.Functions.AddMoney('cash', payout, 'crypto-sell')
        TriggerClientEvent('QBCore:Notify', src, ('💵 %s 196COIN satıldı (+₣%d)'):format(('%.4f'):format(coinsAmount), payout), 'success')
        TriggerClientEvent('196rp_crypto:client:refresh', src)
    end)
end)

-- ── Admin: qiymət təyin et ──
RegisterCommand('kriptoprice', function(source, args)
    local src = source
    if src > 0 and not IsPlayerAceAllowed(src, 'command') then
        TriggerClientEvent('QBCore:Notify', src, 'Admin deyilsiniz!', 'error')
        return
    end
    local p = tonumber(args[1])
    if not p or p < 1 then return end
    price = math.floor(p)
    if src > 0 then TriggerClientEvent('QBCore:Notify', src, ('✅ 196COIN qiyməti: ₣%d'):format(price), 'success') end
end, false)
