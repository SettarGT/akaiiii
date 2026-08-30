local QBCore = exports['qb-core']:GetCoreObject()
local rides = {}

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

local function GetStation(id)
    for _, s in ipairs(Config.Stations) do
        if s.id == id then return s end
    end
end

-- ── Gediş başlat (bilet al) ──
RegisterNetEvent('196rp_metro:server:start', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local target = GetStation(targetId)
    if not target then return end

    if (Player.PlayerData.money.cash or 0) < Config.TicketPrice then
        Notify(src, ('Bilet ₣%d — kifayət qədər pul yoxdur.'):format(Config.TicketPrice), 'error')
        return
    end
    Player.Functions.RemoveMoney('cash', Config.TicketPrice, 'metro-ticket')
    rides[src] = { target = target.id, expires = os.time() + Config.TravelTime + 15 }
    TriggerClientEvent('196rp_metro:client:ride', src, target.id, target.label, Config.TravelTime)
end)

-- ── Gediş bitdi: teleport ──
RegisterNetEvent('196rp_metro:server:arrive', function(targetId)
    local src = source
    local ride = rides[src]
    if not ride or ride.target ~= targetId or ride.expires < os.time() then
        return
    end
    rides[src] = nil
    local target = GetStation(targetId)
    if not target then
        return
    end
    TriggerClientEvent('196rp_metro:client:arrive', src, target.coords, target.heading)
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function()
    rides[source] = nil
end)
