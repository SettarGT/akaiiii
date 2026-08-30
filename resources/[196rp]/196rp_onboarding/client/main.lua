local QBCore = exports['qb-core']:GetCoreObject()
local kioskEntity = nil
local inKioskZone = false
local myRent = nil -- { plate, vehicle, expires }

-- ═══════════════════════════════════════════════════════════════
-- NUI yardımçıları
-- ═══════════════════════════════════════════════════════════════

local function SendNUI(action, data)
    SendNUIMessage({ action = action, data = data or {} })
end

-- ═══════════════════════════════════════════════════════════════
-- Kinematik giriş + spawn aeroporta
-- ═══════════════════════════════════════════════════════════════

RegisterNetEvent('196rp_onboarding:client:start', function(spawn, waypoint)
    if not Config.Onboarding.enabled then return end

    -- Aeroporta köçür
    if Config.Onboarding.teleportToAirport then
        SetEntityCoords(PlayerPedId(), spawn.x, spawn.y, spawn.z)
        SetEntityHeading(PlayerPedId(), spawn.w or spawn.heading or 180.0)
    end

    -- Kinematik kamera (göydən eniş)
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(cam, spawn.x + 20.0, spawn.y - 30.0, spawn.z + 60.0)
    SetCamRot(cam, -55.0, 0.0, 0.0)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500)

    DoScreenFadeOut(500)
    Wait(1000)
    SendNUI('welcome', { title = Config.Welcome.title, subtitle = Config.Welcome.subtitle, title2 = Config.Welcome.title2 })
    PlaySoundFrontend(-1, 'Text_Arrive_Tone', 'GTAO_FM_Events_Soundset', true)

    -- Eniş hərəkəti
    local startCoord = GetCamCoord(cam)
    local steps = 40
    for i = 1, steps do
        local t = i / steps
        local x = startCoord.x + (spawn.x - startCoord.x) * t
        local y = startCoord.y + (spawn.y - startCoord.y) * t
        local z = startCoord.z + (spawn.z + 2.5 - startCoord.z) * t
        SetCamCoord(cam, x, y, z)
        Wait(Config.Onboarding.cinematicTime / steps)
    end

    DoScreenFadeIn(800)
    Wait(1500)
    SendNUI('welcome_hide', {})
    SetCamActive(cam, false)
    RenderScriptCams(false, true, 500)
    DestroyCam(cam, false)

    -- Tooltips ardıcıllığı
    for _, tip in ipairs(Config.Tips) do
        SetTimeout(tip.showAfter, function()
            SendNUI('tip', { icon = tip.icon, title = tip.title, text = tip.text })
            SetTimeout(tip.duration, function()
                SendNUI('tip_hide', {})
            end)
        end)
    end

    -- GPS → Bələdiyyə (qızılı ulduz)
    if Config.Onboarding.waypointToCityHall and waypoint then
        SetNewWaypoint(waypoint.x, waypoint.y)
        QBCore.Functions.Notify('🗺️ Bələdiyyə xəritədə qızılı ulduzla işarələndi — pasport və FİN üçün gedin.', 'primary')
    end

    -- Onboarding bitdi
    SetTimeout(Config.Onboarding.cinematicTime + 5000, function()
        TriggerServerEvent('196rp_onboarding:server:done')
    end)
end)

-- ═══════════════════════════════════════════════════════════════
-- Rentcar kiosk (aeroport)
-- ═══════════════════════════════════════════════════════════════

-- Kiosk obyektini yarat
CreateThread(function()
    if not Config.Kiosk.prop then return end
    local m = GetHashKey(Config.Kiosk.prop)
    RequestModel(m)
    while not HasModelLoaded(m) do Wait(100) end
    kioskEntity = CreateObject(m, Config.Kiosk.coords.x, Config.Kiosk.coords.y, Config.Kiosk.coords.z, true, true, false)
    SetEntityHeading(kioskEntity, Config.Kiosk.heading)
    FreezeEntityPosition(kioskEntity, true)

    exports['qb-target']:AddTargetEntity(kioskEntity, {
        options = {
            {
                label = ColorText(Config.Kiosk.label),
                icon = 'car',
                action = function()
                    TriggerServerEvent('196rp_onboarding:server:rentcar')
                end,
            },
        },
        distance = 2.5,
    })

    -- Sim Kart kiosk (TT-71)
    if Config.SimKiosk and Config.SimKiosk.prop then
        local simKiosk = CreateObject(GetHashKey(Config.SimKiosk.prop), Config.SimKiosk.coords.x, Config.SimKiosk.coords.y, Config.SimKiosk.coords.z, true, true, false)
        SetEntityHeading(simKiosk, Config.SimKiosk.heading)
        FreezeEntityPosition(simKiosk, true)
        exports['qb-target']:AddTargetEntity(simKiosk, {
            options = {
                {
                    label = ColorText(Config.SimKiosk.label),
                    icon = 'mobile-alt',
                    action = function()
                        TriggerServerEvent('196rp_onboarding:server:buysim')
                    end,
                },
            },
            distance = 2.5,
        })
    end
end)

function ColorText(text)
    return text
end

-- Qaytarma zonası (marker + 3D mətn)
CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local dist = #(GetEntityCoords(ped) - vector3(Config.RentCar.returnCoords.x, Config.RentCar.returnCoords.y, Config.RentCar.returnCoords.z))
        if dist < Config.RentCar.returnRadius then
            DrawMarker(1, Config.RentCar.returnCoords.x, Config.RentCar.returnCoords.y, Config.RentCar.returnCoords.z - 1.0, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 1.0, 255, 215, 0, 150, false, true, 2, false, nil, nil, false)
            DrawText3D(Config.RentCar.returnCoords.x, Config.RentCar.returnCoords.y, Config.RentCar.returnCoords.z + 0.2, '🎫 Rentcar qaytarma — /' .. Config.ReturnCommand)
            if IsControlJustReleased(0, 38) and myRent then
                TriggerServerEvent('196rp_onboarding:server:returnRent')
            end
        end
        Wait(dist < Config.RentCar.returnRadius + 10 and 0 or 500)
    end
end)

-- Spawn maşın
RegisterNetEvent('196rp_onboarding:client:spawnRent', function(model, returnCoords)
    if myRent then
        TriggerServerEvent('196rp_onboarding:server:returnRent')
        Wait(500)
    end
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(100) end

    local coords = Config.AirportSpawn.coords
    local vehicle = CreateVehicle(hash, coords.x + 2.0, coords.y, coords.z, coords.w or 180.0, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleFuelLevel(vehicle, 100.0)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetModelAsNoLongerNeeded(hash)

    local plate = QBCore.Functions.GetPlate(vehicle)
    myRent = { plate = plate, vehicle = vehicle, expires = os.time() + Config.RentCar.maxRentalMinutes * 60 }

    -- Açar ver
    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)

    TriggerServerEvent('196rp_onboarding:server:registerRent', plate)
    QBCore.Functions.Notify('🚗 Rentcar hazırdır! Açarlar sizə verildi. Qaytarma: /' .. Config.ReturnCommand, 'success')

    -- Müddət bitmə yoxlaması
    CreateThread(function()
        while myRent and myRent.vehicle do
            if os.time() > myRent.expires then
                QBCore.Functions.Notify('⏰ Rentcar müddəti bitdi! Qaytarmaq üçün aeroporta gəlin.', 'error')
                myRent.expires = os.time() + 3600 -- 1 saat əlavə cəza vaxtı
            end
            Wait(30000)
        end
    end)
end)

-- Maşını sil
RegisterNetEvent('196rp_onboarding:client:despawnRent', function(plate)
    if not myRent or myRent.plate ~= plate then return end
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == myRent.vehicle then
        TaskLeaveVehicle(PlayerPedId(), veh, 0)
        Wait(500)
    end
    if DoesEntityExist(veh) then
        DeleteEntity(veh)
    end
    myRent = nil
end)

-- ═══════════════════════════════════════════════════════════════
-- Yardımçılar
-- ═══════════════════════════════════════════════════════════════

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    AddTextComponentString(text)
    SetTextCentre(true)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end
