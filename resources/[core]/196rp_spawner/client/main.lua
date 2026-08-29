-- 196 RP | Spawner — client tərəfi
-- Server-dən gələn spawn istəklərini burada (client-də) yaradırıq.

local function LoadModel(model)
    if type(model) == 'string' then
        model = GetHashKey(model)
    end
    RequestModel(model)
    local t = 0
    while not HasModelLoaded(model) and t < 100 do
        Wait(50)
        t = t + 1
    end
    return HasModelLoaded(model), model
end

local function SpawnVehicle(p)
    local ok, model = LoadModel(p.model)
    if not ok then return 0 end

    local c = p.coords or { x = 0.0, y = 0.0, z = 0.0 }
    local veh = CreateVehicle(model, c.x, c.y, c.z, p.heading or 0.0, true, false)
    SetModelAsNoLongerNeeded(model)
    if not veh or veh == 0 then return 0 end

    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleOnGroundProperly(veh)
    if p.plate then SetVehicleNumberPlateText(veh, p.plate) end
    if p.engineOn ~= false then SetVehicleEngineOn(veh, true, true, false) end
    if p.owned then SetVehicleHasBeenOwnedByPlayer(veh, true) end
    if p.doorsLocked then SetVehicleDoorsLocked(veh, p.doorsLocked) end
    if p.lockForAll then SetVehicleDoorsLockedForAllPlayers(veh, true) end
    if p.invincible then SetEntityInvincible(veh, true) end
    if p.noFleePeds then SetVehicleCanBeUsedByFleeingPeds(veh, false) end
    if p.color1 then SetVehicleColours(veh, p.color1, p.color2 or p.color1) end
    if p.customColor then
        SetVehicleCustomPrimaryColour(veh, p.customColor[1], p.customColor[2], p.customColor[3])
        SetVehicleCustomSecondaryColour(veh, p.customColor[1], p.customColor[2], p.customColor[3])
    end
    if p.pearlescent then SetVehicleExtraColours(veh, p.pearlescent, p.wheelColor or 0) end

    if p.pedModel then
        local pok, pmodel = LoadModel(p.pedModel)
        if pok then
            local ped = CreatePedInsideVehicle(veh, p.pedSeat or 26, pmodel, -1, true, false)
            SetModelAsNoLongerNeeded(pmodel)
            if ped and ped ~= 0 then
                SetEntityAsMissionEntity(ped, true, true)
                SetEntityInvincible(ped, true)
                SetPedKeepTask(ped, true)
                SetBlockingOfNonTemporaryEvents(ped, true)
                SetPedCanBeDraggedOut(ped, false)
                SetPedCanRagdoll(ped, false)
                SetDriverAbility(ped, 1.0)
                SetDriverAggressiveness(ped, 0.0)
                local pedNet = PedToNet(ped)
                SetNetworkIdExistsOnAllMachines(pedNet, true)
            end
        end
    end

    local netId = VehToNet(veh)
    SetNetworkIdExistsOnAllMachines(netId, true)
    return netId
end

local function SpawnPed(p)
    local ok, model = LoadModel(p.model)
    if not ok then return 0 end

    local c = p.coords or { x = 0.0, y = 0.0, z = 0.0 }
    local ped = CreatePed(0, model, c.x, c.y, c.z, p.heading or 0.0, true, false)
    SetModelAsNoLongerNeeded(model)
    if not ped or ped == 0 then return 0 end

    SetEntityAsMissionEntity(ped, true, true)
    if p.invincible ~= false then SetEntityInvincible(ped, true) end
    SetBlockingOfNonTemporaryEvents(ped, true)

    local netId = PedToNet(ped)
    SetNetworkIdExistsOnAllMachines(netId, true)
    return netId
end

local function SpawnObject(p)
    local ok, model = LoadModel(p.model)
    if not ok then return 0 end

    local c = p.coords or { x = 0.0, y = 0.0, z = 0.0 }
    local obj = CreateObject(model, c.x, c.y, c.z, true, true, false)
    SetModelAsNoLongerNeeded(model)
    if not obj or obj == 0 then return 0 end

    SetEntityHeading(obj, p.heading or 0.0)
    SetEntityAsMissionEntity(obj, true, true)

    local netId = ObjToNet(obj)
    SetNetworkIdExistsOnAllMachines(netId, true)
    return netId
end

local function SpawnPedInVehicle(p)
    local veh = NetworkGetEntityFromNetworkId(p.vehNetId or 0)
    if veh == 0 then return 0 end

    local ok, model = LoadModel(p.model)
    if not ok then return 0 end

    local ped = CreatePedInsideVehicle(veh, 1, model, p.seat or 0, true, false)
    SetModelAsNoLongerNeeded(model)
    if not ped or ped == 0 then return 0 end

    SetEntityAsMissionEntity(ped, true, true)
    local netId = PedToNet(ped)
    SetNetworkIdExistsOnAllMachines(netId, true)
    return netId
end

RegisterNetEvent('196rp_spawner:spawn', function(reqId, kind, p)
    local netId = 0
    if kind == 'vehicle' then
        netId = SpawnVehicle(p or {})
    elseif kind == 'ped' then
        netId = SpawnPed(p or {})
    elseif kind == 'object' then
        netId = SpawnObject(p or {})
    elseif kind == 'pedInVehicle' then
        netId = SpawnPedInVehicle(p or {})
    end
    TriggerServerEvent('196rp_spawner:ack', reqId, netId)
end)
