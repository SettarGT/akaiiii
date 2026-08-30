local QBCore = exports['qb-core']:GetCoreObject()

local rentals = {}

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

-- ── İcarə ──
RegisterNetEvent('196rp_aviation:server:rent', function(model)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local plane
    for _, p in ipairs(Config.Planes) do
        if p.model == model then plane = p end
    end
    if not plane then return end

    if Config.RequireLicense and not (Player.PlayerData.metadata.drivinglicense or Player.PlayerData.metadata.driving_license) then
        Notify(src, 'Sürücülük lisenziyanız yoxdur — Bələdiyyəyə gedin!', 'error')
        return
    end
    if rentals[src] and rentals[src].expires > os.time() then
        Notify(src, 'Artıq icarədə təyyarə var! (/planqaytar)', 'error')
        return
    end

    if (Player.PlayerData.money.cash or 0) < plane.price then
        Notify(src, ('Kifayət qədər pul yoxdur — icarə ₣%d'):format(plane.price), 'error')
        return
    end
    Player.Functions.RemoveMoney('cash', plane.price, 'plane-rent')
    rentals[src] = { model = plane.model, expires = os.time() + plane.time }

    TriggerClientEvent('196rp_aviation:client:spawn', src, plane.model, plane.time)
    Notify(src, ('✈️ %s icarə olundu (-₣%d, %d dəq). İcazə: /planqaytar'):format(plane.label, plane.price, math.floor(plane.time / 60)), 'success')
end)

-- ── Qaytarma ──
RegisterNetEvent('196rp_aviation:server:return', function()
    local src = source
    if not rentals[src] then
        Notify(src, 'İcarədə təyyarə yoxdur.', 'primary')
        return
    end
    rentals[src] = nil
    TriggerClientEvent('196rp_aviation:client:despawn', src)
end)

-- Qaytarılmamış təyyarələrin yoxlanışı
CreateThread(function()
    while true do
        Wait(60000)
        local now = os.time()
        for src, r in pairs(rentals) do
            if r.expires <= now then
                rentals[src] = nil
                TriggerClientEvent('196rp_aviation:client:despawn', src)
                Notify(src, '⏱ İcarə müddəti bitdi — təyyarə qaytarıldı.', 'primary')
            end
        end
    end
end)
