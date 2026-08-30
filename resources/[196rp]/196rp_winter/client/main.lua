local QBCore = exports['qb-core']:GetCoreObject()
local winter = false
local knownTires = {}

local function ApplyVehicleEffect(veh)
    if not winter or veh == 0 then return end
    local plate = GetVehicleNumberPlateText(veh):upper()
    if not knownTires[plate] then
        -- serverdən soruş (bir dəfə)
        knownTires[plate] = 'ask'
        TriggerServerEvent('196rp_winter:server:hasTires', plate)
    elseif knownTires[plate] ~= true then
        -- qış təkəri yoxdur: buz üzərində sürüşmə → sürət həddi ~70 km/s
        SetVehicleMaxSpeed(veh, (70 * Config.NoTiresFactor) / 3.6)
    else
        SetVehicleMaxSpeed(veh, 140 / 3.6)
    end
end

RegisterNetEvent('196rp_winter:client:tires', function(data)
    knownTires[data.plate] = data.has
end)

CreateThread(function()
    Wait(3000)
    TriggerServerEvent('196rp_winter:server:getState')
end)

RegisterNetEvent('196rp_winter:client:state', function(data)
    winter = data and data.winter or false
end)

-- Havalar: qış rejimində dəyişir (qb-weathersync üstünə)
CreateThread(function()
    local idx = 1
    while true do
        if winter then
            SetWeatherTypeNowPersist(Config.Weathers[idx])
            idx = idx % #Config.Weathers + 1
        end
        Wait(30000)
    end
end)

-- Avtomobil effekti (qış + yağış)
local RAIN_HASH = GetHashKey('RAIN')
local THUNDER_HASH = GetHashKey('THUNDER')
local BLIZZARD_HASH = GetHashKey('BLIZZARD')

local function IsWetWeather()
    local _, nextHash = GetNextWeatherTypeHashName()
    if nextHash == RAIN_HASH or nextHash == THUNDER_HASH or nextHash == BLIZZARD_HASH then return true end
    local _, prevHash = GetPrevWeatherTypeHashName()
    if prevHash == RAIN_HASH or prevHash == THUNDER_HASH then return true end
    return false
end

CreateThread(function()
    while true do
        Wait(5000)
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            if winter then
                ApplyVehicleEffect(veh)
            elseif IsWetWeather() then
                -- yağışda traksiya azalır: sürət həddi ~110 km/s
                SetVehicleMaxSpeed(veh, 110 / 3.6)
            end
        end
    end
end)

-- Mexanik: /qisteker
RegisterCommand('qisteker', function()
    local pData = QBCore.Functions.GetPlayerData()
    if pData.job.name ~= 'mechanic' then
        return QBCore.Functions.Notify('Bu əmr yalnız mexanik üçündür.', 'error')
    end
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then
        return QBCore.Functions.Notify('Avtomobildə oturun.', 'primary')
    end
    QBCore.Functions.Progressbar('wintertires', '❄ Qış təkərləri quraşdırılır...', 8000, false, true, {
        disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true,
    }, {}, {}, {}, function()
        TriggerServerEvent('196rp_winter:server:setTires', GetVehicleNumberPlateText(veh))
    end, function() end)
end, false)
