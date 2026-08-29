-- 196 RP | Avtobus sistemi — client simulasiyası
-- Server entity yarada bilmədiyi üçün NPC avtobuslar bir "sahib" client-də yaradılır
-- və şəbəkə üzərindən bütün oyunçulara görünür. Sahib çıxanda server yenisini təyin edir.

local isOwner = false
local simRunning = false
local buses = {} -- [routeNumber] = { veh, ped, targetIndex }

local function CreateBus(route)
    local start = route.stops[1].coords
    local vehModel = GetHashKey(Config.BusModel)
    local pedModel = GetHashKey('a_m_m_busker_01')

    RequestModel(vehModel)
    RequestModel(pedModel)

    local t = 0
    while (not HasModelLoaded(vehModel) or not HasModelLoaded(pedModel)) and t < 120 do
        Wait(50)
        t = t + 1
    end

    if not HasModelLoaded(vehModel) or not HasModelLoaded(pedModel) then
        return nil
    end

    local veh = CreateVehicle(vehModel, start.x, start.y, start.z, 0.0, true, false)
    if not veh or veh == 0 then
        return nil
    end

    local ped = CreatePedInsideVehicle(veh, 26, pedModel, -1, true, false)

    SetEntityAsMissionEntity(veh, true, true)
    SetEntityInvincible(veh, true)
    SetVehicleDoorsLocked(veh, 4)
    SetVehicleDoorsLockedForAllPlayers(veh, true)
    SetVehicleCanBeUsedByFleeingPeds(veh, false)
    SetVehicleEngineOn(veh, true, true, false)
    SetVehicleOnGroundProperly(veh)
    SetVehicleNumberPlateText(veh, ('196BUS%02d'):format(route.number))
    SetVehicleCustomPrimaryColour(veh, route.color.r, route.color.g, route.color.b)
    SetVehicleCustomSecondaryColour(veh, route.color.r, route.color.g, route.color.b)

    if ped and ped ~= 0 then
        SetEntityInvincible(ped, true)
        SetPedKeepTask(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedCanBeDraggedOut(ped, false)
        SetPedCanRagdoll(ped, false)
        SetDriverAbility(ped, 1.0)
        SetDriverAggressiveness(ped, 0.0)
    end

    SetModelAsNoLongerNeeded(vehModel)
    SetModelAsNoLongerNeeded(pedModel)

    local vehNet = VehToNet(veh)
    SetNetworkIdExistsOnAllMachines(vehNet, true)
    if ped and ped ~= 0 then
        local pedNet = PedToNet(ped)
        SetNetworkIdExistsOnAllMachines(pedNet, true)
    end

    return { veh = veh, ped = ped or 0, targetIndex = 2 }
end

local function DeleteBus(bus)
    if bus then
        if bus.ped and bus.ped ~= 0 and DoesEntityExist(bus.ped) then
            DeleteEntity(bus.ped)
        end
        if bus.veh and bus.veh ~= 0 and DoesEntityExist(bus.veh) then
            DeleteEntity(bus.veh)
        end
    end
end

local function StopSim()
    simRunning = false
    for number, bus in pairs(buses) do
        DeleteBus(bus)
        buses[number] = nil
    end
end

local function StartSim()
    if simRunning then
        return
    end
    simRunning = true

    CreateThread(function()
        Wait(2000)
        for i = 1, #Config.Routes do
            if not simRunning then return end
            local route = Config.Routes[i]
            buses[route.number] = CreateBus(route)
            if buses[route.number] then
                print(('[196rp_bus] %s nömrəli marşrut işə düşdü: %s'):format(route.number, route.name))
            end
            Wait(500)
        end

        local reportTick = 0
        while simRunning do
            Wait(1000)

            for i = 1, #Config.Routes do
                local route = Config.Routes[i]
                local bus = buses[route.number]

                if not bus or not DoesEntityExist(bus.veh) or not DoesEntityExist(bus.ped) then
                    DeleteBus(bus)
                    buses[route.number] = CreateBus(route)
                else
                    local target = route.stops[bus.targetIndex]
                    if target then
                        TaskVehicleDriveToCoordLongrange(bus.ped, bus.veh,
                            target.coords.x, target.coords.y, target.coords.z,
                            Config.BusSpeed, 786603, 15.0)

                        local dist = #(GetEntityCoords(bus.veh) - target.coords)
                        if dist < 25.0 then
                            bus.targetIndex = bus.targetIndex + 1
                            if bus.targetIndex > #route.stops then
                                bus.targetIndex = 1
                            end
                        end
                    end
                end
            end

            -- Mövqeləri serverə göndər (3 san-dən bir)
            reportTick = reportTick + 1
            if reportTick >= 3 then
                reportTick = 0
                local list = {}
                for number, bus in pairs(buses) do
                    if bus and DoesEntityExist(bus.veh) then
                        local c = GetEntityCoords(bus.veh)
                        list[number] = { x = c.x, y = c.y, z = c.z }
                    end
                end
                TriggerServerEvent('196rp_bus:positions', list)
            end
        end
    end)
end

RegisterNetEvent('196rp_bus:setSimOwner', function(on)
    on = on == true
    if on == isOwner then
        return
    end
    isOwner = on
    if on then
        StartSim()
    else
        StopSim()
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        StopSim()
    end
end)
