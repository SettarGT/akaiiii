-- 196 RP | Yanğınsöndürən — server tərəfi
-- Təsadüfi yanğınlar, növbə, maşın, söndürmə

local ESX = exports['es_extended']:getSharedObject()

local onDuty = {}   -- [source] = true
local fires = {}    -- [id] = { coords = vector3, createdAt = os.time() }
local nextFireId = 1

local function IsFirefighter(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer and xPlayer.job.name == 'firefighter'
end

-- ==================== NÖVBƏ ====================

ESX.RegisterServerCallback('196rp_fire:toggleDuty', function(source, cb)
    if not IsFirefighter(source) then
        TriggerClientEvent('esx:showNotification', source, 'Siz yanğınsöndürən deyilsiniz!', 'error')
        return cb(false)
    end

    onDuty[source] = not onDuty[source]
    cb(onDuty[source])
end)

-- ==================== YANĞIN MAŞINI ====================

ESX.RegisterServerCallback('196rp_fire:spawnVehicle', function(source, cb)
    if not onDuty[source] then
        return cb(false, nil)
    end

    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - Config.Station.coords) > 60.0 then
        TriggerClientEvent('esx:showNotification', source, 'Maşın almaq üçün stansiyaya gedin!', 'error')
        return cb(false, nil)
    end

    local model = GetHashKey(Config.FireTruck)
    RequestModel(model)
    local t = 0
    while not HasModelLoaded(model) and t < 100 do
        Wait(50)
        t = t + 1
    end
    if not HasModelLoaded(model) then
        return cb(false, nil)
    end

    local coords = Config.Station.coords
    local veh = CreateVehicle(model, coords.x + 4.0, coords.y, coords.z, 0.0, true, false)
    SetModelAsNoLongerNeeded(model)

    if not veh or veh == 0 then
        return cb(false, nil)
    end

    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleOnGroundProperly(veh)
    SetVehicleNumberPlateText(veh, ('%s%03d'):format(Config.FireTruckPlatePrefix or 'YAN', math.random(0, 999)))
    SetVehicleEngineOn(veh, true, true, false)

    cb(true, NetworkGetNetworkIdFromEntity(veh))
end)

-- ==================== YANĞINLAR ====================

local function SpawnFire()
    local spawn = Config.FireSpawns[math.random(1, #Config.FireSpawns)]
    local id = nextFireId
    nextFireId = nextFireId + 1

    fires[id] = { coords = spawn, createdAt = os.time() }

    TriggerClientEvent('196rp_fire:newFire', -1, id, spawn)

    -- Yanğınsöndürənlərə bildiriş
    for src in pairs(onDuty) do
        TriggerClientEvent('esx:showNotification', src,
            ('~r~🔥 YANĞIN!~s~ Xəritədə işarələndi (%s m aralı)'):format(
                math.floor(#(GetEntityCoords(GetPlayerPed(src)) - spawn))), 'error')
    end

    if Config.NotifyEMS then
        for _, pid in pairs(ESX.GetPlayers()) do
            local xPlayer = ESX.GetPlayerFromId(pid)
            if xPlayer and xPlayer.job.name == 'ambulance' then
                TriggerClientEvent('esx:showNotification', pid,
                    '~r~🔥 Yanğın hadisəsi!~s~ Yaralılar ola bilər.', 'error')
            end
        end
    end

    -- Yanğının ömrü
    SetTimeout(Config.FireLifetime or 300000, function()
        if fires[id] then
            fires[id] = nil
            TriggerClientEvent('196rp_fire:fireExtinguished', -1, id)
        end
    end)
end

ESX.RegisterServerCallback('196rp_fire:getFires', function(source, cb)
    local list = {}
    for id, fire in pairs(fires) do
        list[#list + 1] = { id = id, coords = fire.coords }
    end
    cb(list)
end)

ESX.RegisterServerCallback('196rp_fire:extinguish', function(source, cb)
    if not onDuty[source] then
        return cb(false)
    end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)

    -- Ən yaxın yanğını tap
    local foundId, best = nil, 12.0
    for id, fire in pairs(fires) do
        local d = #(coords - fire.coords)
        if d < best then
            foundId, best = id, d
        end
    end

    if not foundId then
        return cb(false)
    end

    fires[foundId] = nil
    TriggerClientEvent('196rp_fire:fireExtinguished', -1, foundId)

    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addMoney(Config.PayPerFire or 250)
    end

    cb(true)
end)

-- Təsadüfi yanğın dövriyyəsi
CreateThread(function()
    while true do
        local interval = math.random(Config.FireInterval.min, Config.FireInterval.max)
        Wait(interval)

        -- Yalnız onlayn oyunçu varsa yanğın çıxır
        if #ESX.GetPlayers() > 0 then
            SpawnFire()
        end
    end
end)

-- ==================== DİGƏR ====================

exports('IsPlayerOnDuty', function(source)
    return onDuty[source] == true
end)

exports('GetActiveFires', function()
    local n = 0
    for _ in pairs(fires) do
        n = n + 1
    end
    return n
end)

AddEventHandler('playerDropped', function()
    onDuty[source] = nil
end)
