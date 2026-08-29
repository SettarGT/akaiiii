-- 196 RP | Şəhər canlılığı — müştəri tərəfi
--
-- Mülki avtomobil trafiki söndürülüb. Onun əvəzinə yalnız icazə verilən
-- xidmət/iş maşınları (taksi, avtobus, tikinti, kommunal, çatdırılma)
-- NPC sürücülərlə yaradılır. Piyadalar aktiv qalır.

local serviceVehicles = {}   -- { veh = entity, ped = entity }

-- ==================== KÖMƏKÇİLƏR ====================

local function PickPool()
    local total = 0
    for i = 1, #Config.VehiclePools do
        total = total + (Config.VehiclePools[i].weight or 10)
    end

    local roll = math.random(1, total)
    local acc = 0
    for i = 1, #Config.VehiclePools do
        acc = acc + (Config.VehiclePools[i].weight or 10)
        if roll <= acc then
            return Config.VehiclePools[i]
        end
    end

    return Config.VehiclePools[1]
end

local function FindRoadNode(center, radius)
    for i = 1, 12 do
        -- radius daxilində təsadüfi nöqtə seç, orada yol düyünü axtar
        local angle = math.rad(math.random(0, 360))
        local dist = math.random(math.floor(radius * 0.4), math.floor(radius))
        local x = center.x + math.cos(angle) * dist
        local y = center.y + math.sin(angle) * dist
        local z = center.z

        local found, pos, heading = GetNthClosestVehicleNode(x, y, z, 1, 1, 0.0, 0.0, 0.0)
        if found and pos then
            return pos, heading or 0.0
        end
    end
    return nil, nil
end

local function LoadModel(model)
    local hash = type(model) == 'number' and model or GetHashKey(model)
    RequestModel(hash)

    local t = 0
    while not HasModelLoaded(hash) and t < 60 do
        Wait(25)
        t = t + 1
    end

    return HasModelLoaded(hash) and hash or nil
end

local function SpawnServiceVehicle()
    if #serviceVehicles >= Config.ServiceVehicles.maxVehicles then
        return
    end

    local ped = PlayerPedId()
    local center = GetEntityCoords(ped)

    local nodePos, heading = FindRoadNode(center, Config.ServiceVehicles.spawnRadius)
    if not nodePos then
        return
    end

    -- Oyunçunun gözünün önündə yaranmasın
    if #(nodePos - center) < 60.0 then
        return
    end

    local pool = PickPool()
    local vehModel = LoadModel(pool.models[math.random(1, #pool.models)])
    if not vehModel then
        return
    end

    local pedModel = LoadModel(pool.ped)
    if not pedModel then
        SetModelAsNoLongerNeeded(vehModel)
        return
    end

    local veh = CreateVehicle(vehModel, nodePos.x, nodePos.y, nodePos.z, heading, true, false)
    SetModelAsNoLongerNeeded(vehModel)

    if not veh or veh == 0 then
        SetModelAsNoLongerNeeded(pedModel)
        return
    end

    local driver = CreatePedInsideVehicle(veh, 26, pedModel, -1, true, false)
    SetModelAsNoLongerNeeded(pedModel)

    if not driver or driver == 0 then
        SetEntityAsMissionEntity(veh, true, true)
        DeleteVehicle(veh)
        return
    end

    -- NPC sürücünün davranışı
    SetEntityAsMissionEntity(veh, true, true)
    SetEntityAsMissionEntity(driver, true, true)
    SetVehicleOnGroundProperly(veh)
    SetVehicleEngineOn(veh, true, true, false)
    SetVehicleDoorsLocked(veh, 2)
    SetVehicleDoorsLockedForAllPlayers(veh, true)
    SetVehicleNumberPlateText(veh, ('196%s%02d'):format(pool.id:sub(1, 3):upper(), math.random(0, 99)))
    SetVehicleHasBeenOwnedByPlayer(veh, true)

    if pool.color then
        SetVehicleCustomPrimaryColour(veh, pool.color[1], pool.color[2], pool.color[3])
        SetVehicleCustomSecondaryColour(veh, pool.color[1], pool.color[2], pool.color[3])
    end

    SetPedKeepTask(driver, true)
    SetBlockingOfNonTemporaryEvents(driver, true)
    SetPedCanBeDraggedOut(driver, false)
    SetPedCanRagdoll(driver, false)
    SetPedFleeAttributes(driver, 0, false)
    SetDriverAbility(driver, 0.9)
    SetDriverAggressiveness(driver, 0.1)
    SetEntityHealth(driver, 200)

    -- Yol boyunca sürsün
    local speed = pool.speed or Config.ServiceVehicles.minSpeed
    TaskVehicleDriveWander(driver, veh, speed + math.random(-2, 2), 786603)

    serviceVehicles[#serviceVehicles + 1] = { veh = veh, ped = driver, pool = pool.id }
end

local function RemoveServiceVehicle(index)
    local entry = serviceVehicles[index]
    if not entry then
        return
    end

    if DoesEntityExist(entry.ped) then
        SetEntityAsMissionEntity(entry.ped, true, true)
        DeleteEntity(entry.ped)
    end
    if DoesEntityExist(entry.veh) then
        SetEntityAsMissionEntity(entry.veh, true, true)
        DeleteVehicle(entry.veh)
    end

    table.remove(serviceVehicles, index)
end

-- ==================== PİYADALAR (şəhər boş qalmasın) ====================

CreateThread(function()
    SetPedPopulationBudget(Config.PedBudget)
    -- Mülki maşın populyasiyası büdcəsi minimuma endirilir
    SetVehiclePopulationBudget(1)
end)

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        local distFromCenter = #(coords - vector3(0.0, -900.0, 30.0))
        local m = distFromCenter > Config.RemoteDistance and Config.RemoteMultiplier or 1.0

        -- Piyadalar aktiv
        SetPedDensityMultiplierThisFrame(Config.PedDensity * m)
        SetScenarioPedDensityMultiplierThisFrame(Config.ScenarioPedDensity * m, false)

        -- MÜLKİ avtomobil trafiki söndürülüb
        if not Config.AmbientVehicles then
            SetVehicleDensityMultiplierThisFrame(0.0)
            SetRandomVehicleDensityMultiplierThisFrame(0.0)
            SetParkedVehicleDensityMultiplierThisFrame(0.0)
            SetNumberOfParkedVehicles(0)
        else
            SetVehicleDensityMultiplierThisFrame(0.6 * m)
            SetRandomVehicleDensityMultiplierThisFrame(0.6 * m)
            SetParkedVehicleDensityMultiplierThisFrame(0.4 * m)
        end

        SetGarbageTrucks(false)
        SetCreateRandomCops(false)
        SetCreateRandomCopsNotOnScenarios(false)
        SetCreateRandomCopsOnScenarios(false)

        Wait(0)
    end
end)

-- ==================== NPC XİDMƏT MAŞINLARI ====================

CreateThread(function()
    if not Config.ServiceVehicles.enabled then
        return
    end

    -- Başlanğıcda bir neçə maşın
    Wait(4000)
    for _ = 1, 6 do
        SpawnServiceVehicle()
        Wait(400)
    end

    while true do
        Wait(Config.ServiceVehicles.spawnInterval)

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        -- Uzaqlaşanları sil
        for i = #serviceVehicles, 1, -1 do
            local entry = serviceVehicles[i]
            local gone = true

            if DoesEntityExist(entry.veh) and DoesEntityExist(entry.ped) then
                local d = #(GetEntityCoords(entry.veh) - coords)
                if d <= Config.ServiceVehicles.despawnRadius then
                    gone = false
                end
            end

            if gone then
                RemoveServiceVehicle(i)
            end
        end

        -- Sayı tamamla
        local distFromCenter = #(coords - vector3(0.0, -900.0, 30.0))
        local limit = Config.ServiceVehicles.maxVehicles
        if distFromCenter > Config.RemoteDistance then
            limit = math.max(3, math.floor(limit * Config.RemoteMultiplier))
        end

        while #serviceVehicles < limit do
            SpawnServiceVehicle()
            Wait(250)
        end
    end
end)

-- Təmizlik
AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then
        return
    end
    for i = #serviceVehicles, 1, -1 do
        RemoveServiceVehicle(i)
    end
end)

exports('GetServiceVehicleCount', function()
    return #serviceVehicles
end)
