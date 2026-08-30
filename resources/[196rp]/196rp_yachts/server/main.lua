local QBCore = exports['qb-core']:GetCoreObject()

local rentals = {}   -- src -> { model, expires }
local active = {}    -- src -> netId (hazırda suda olan yaxta)

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

local function GetYacht(model)
    for _, y in ipairs(Config.Yachts) do
        if y.model == model then return y end
    end
end

local function OwnedYachts(cid, cb)
    MySQL.query('SELECT model FROM 196_yachts WHERE citizenid = ?', { cid }, function(rows)
        local list = {}
        for _, r in ipairs(rows or {}) do list[#list + 1] = r.model end
        cb(list)
    end)
end

-- ── İcarə ──
RegisterNetEvent('196rp_yachts:server:rent', function(model)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local y = GetYacht(model)
    if not y then return end

    if rentals[src] and rentals[src].expires > os.time() then
        Notify(src, 'Artıq icarədə yaxta var! Qaytarma: /yaxtaqaytar', 'error')
        return
    end
    if active[src] then
        Notify(src, 'Əvvəlcə hazırkı yaxtanı qaytarın!', 'error')
        return
    end
    if (Player.PlayerData.money.cash or 0) < y.rentPrice then
        Notify(src, ('Kifayət qədər pul yoxdur — icarə ₣%d'):format(y.rentPrice), 'error')
        return
    end

    Player.Functions.RemoveMoney('cash', y.rentPrice, 'yacht-rent')
    rentals[src] = { model = y.model, expires = os.time() + y.rentTime }
    TriggerClientEvent('196rp_yachts:client:spawn', src, y.model)
    Notify(src, ('🛥 %s icarə olundu (-₣%d, %d dəq)'):format(y.label, y.rentPrice, math.floor(y.rentTime / 60)), 'success')
end)

-- ── Alış ──
RegisterNetEvent('196rp_yachts:server:buy', function(model)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local y = GetYacht(model)
    if not y then return end

    if (Player.PlayerData.money.bank or 0) < y.buyPrice then
        Notify(src, ('Kifayət qədər bank balansı yoxdur — qiymət ₣%d'):format(y.buyPrice), 'error')
        return
    end
    OwnedYachts(Player.PlayerData.citizenid, function(list)
        for _, m in ipairs(list) do
            if m == model then
                Notify(src, 'Bu yaxta artıq sizə məxsusdur.', 'error')
                return
            end
        end
        Player.Functions.RemoveMoney('bank', y.buyPrice, 'yacht-buy')
        MySQL.insert('INSERT INTO 196_yachts (citizenid, model, bought_at) VALUES (?, ?, NOW())', {
            Player.PlayerData.citizenid, model,
        })
        Notify(src, ('✅ %s satın alındı (-₣%d)! /yaxta ilə çağırın.'):format(y.label, y.buyPrice), 'success')
    end)
end)

-- ── Yaxtanı çağır ──
RegisterNetEvent('196rp_yachts:server:call', function(model)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local y = GetYacht(model)
    if not y then return end

    local owned = false
    OwnedYachts(Player.PlayerData.citizenid, function(list)
        for _, m in ipairs(list) do
            if m == model then owned = true end
        end
        if not owned then
            Notify(src, 'Bu yaxta sizə məxsus deyil.', 'error')
            return
        end
        if active[src] then
            Notify(src, 'Hazırkı yaxtanı əvvəlcə qaytarın.', 'error')
            return
        end
        active[src] = src
        TriggerClientEvent('196rp_yachts:client:spawn', src, model)
        Notify(src, ('🛥 %s limana gətirildi!'):format(y.label), 'success')
    end)
end)

-- ── Qaytarma ──
local function ReturnYacht(src)
    if not active[src] and not rentals[src] then
        Notify(src, 'Suda yaxtası yoxdur.', 'primary')
        return
    end
    rentals[src] = nil
    active[src] = nil
    TriggerClientEvent('196rp_yachts:client:despawn', src)
    Notify(src, '🛥 Yaxta qaytarıldı.', 'success')
end

RegisterNetEvent('196rp_yachts:server:return', function()
    ReturnYacht(source)
end)

-- İcarə müddəti bitənlər
CreateThread(function()
    while true do
        Wait(30000)
        local now = os.time()
        for src, r in pairs(rentals) do
            if r.expires <= now then
                rentals[src] = nil
                TriggerClientEvent('196rp_yachts:client:despawn', src)
                Notify(src, '⏱ İcarə müddəti bitdi — yaxta qaytarıldı.', 'primary')
            end
        end
    end
end)

-- Sahib olduğu yaxtalar (callback)
QBCore.Functions.CreateCallback('196rp_yachts:server:getOwned', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb({}) end
    OwnedYachts(Player.PlayerData.citizenid, cb)
end)

-- Əmr
RegisterCommand('yaxtaqaytar', function(source)
    if source and source ~= 0 then
        ReturnYacht(source)
    end
end, false)
