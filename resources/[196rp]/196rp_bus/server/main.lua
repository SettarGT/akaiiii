-- 196 RP | Avtobus sistemi — server tərəfi
-- NPC sürücülü avtobuslar marşrutla hərəkət edir + gediş haqqı + taksi çağırışı

local ESX = exports['es_extended']:getSharedObject()

-- [routeNumber] = { veh = entity, ped = entity, targetIndex = n }
local buses = {}

-- ==================== NPC AVTOBUSLAR ====================

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

    SetEntityInvincible(ped, true)
    SetPedKeepTask(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanBeDraggedOut(ped, false)
    SetPedCanRagdoll(ped, false)
    SetDriverAbility(ped, 1.0)
    SetDriverAggressiveness(ped, 0.0)

    SetModelAsNoLongerNeeded(vehModel)
    SetModelAsNoLongerNeeded(pedModel)

    return { veh = veh, ped = ped, targetIndex = 2 }
end

-- Hər marşrut üçün bir avtobus
CreateThread(function()
    Wait(5000)

    for i = 1, #Config.Routes do
        local route = Config.Routes[i]
        local bus = CreateBus(route)
        if bus then
            buses[route.number] = bus
            print(('[196rp_bus] %s nömrəli marşrut işə düşdü: %s'):format(route.number, route.name))
        end
    end

    -- Marşrut üzrə hərəkət
    while true do
        Wait(1000)

        for i = 1, #Config.Routes do
            local route = Config.Routes[i]
            local bus = buses[route.number]

            if not bus or not DoesEntityExist(bus.veh) or not DoesEntityExist(bus.ped) then
                -- Maşın məhv edilibsə yenidən yarat
                if bus then
                    if DoesEntityExist(bus.ped) then DeleteEntity(bus.ped) end
                    if DoesEntityExist(bus.veh) then DeleteEntity(bus.veh) end
                end
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
    end
end)

-- ==================== GEDİŞ HAQQI ====================

ESX.RegisterServerCallback('196rp_bus:payFare', function(source, cb, kind)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local price = Config.CityFare

    if xPlayer.getMoney() < price then
        return cb(false, ('Gediş haqqı ~y~%s$~s~-dır. Nağd pulunuz yoxdur!'):format(price))
    end

    xPlayer.removeMoney(price)
    cb(true, ('~g~Gediş haqqı ödənildi: %s$~s~'):format(price))
end)

ESX.RegisterServerCallback('196rp_bus:payIntercity', function(source, cb, destLabel, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    price = tonumber(price) or Config.IntercityFare

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
    else
        local bank = xPlayer.getAccount('bank')
        if bank and bank.money >= price then
            xPlayer.removeAccountMoney('bank', price)
        else
            return cb(false, ('Bilet ~y~%s$~s~-dır. Pulunuz kifayət etmir!'):format(price))
        end
    end

    cb(true, ('~g~%s~s~ üçün bilet alındı.'):format(destLabel))
end)

-- ==================== TAKSİ ÇAĞIRIŞI ====================

ESX.RegisterServerCallback('196rp_bus:callTaxi', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)

    local notified = 0
    for _, pid in pairs(ESX.GetPlayers()) do
        local xTarget = ESX.GetPlayerFromId(pid)
        if xTarget and xTarget.job.name == 'taxi' then
            TriggerClientEvent('196rp_bus:taxiCallBlip', pid, source, coords)
            TriggerClientEvent('esx:showNotification', pid,
                ('~y~🚕 Taksi çağırışı!~s~ ID %s sizi gözləyir (xəritədə işarələndi)'):format(source), 'info')
            notified = notified + 1
        end
    end

    if notified == 0 then
        return cb(false, 'Hal-hazırda növbədə taksi sürücüsü yoxdur! Bir az sonra cəhd edin.')
    end

    cb(true, ('~g~%s taksi sürücüsünə çağırış göndərildi!~s~'):format(notified))
end)

ESX.RegisterServerCallback('196rp_bus:taxiBoard', function(source, cb, driverId)
    local xPassenger = ESX.GetPlayerFromId(source)
    local xDriver = ESX.GetPlayerFromId(tonumber(driverId) or 0)

    if not xPassenger then
        return cb(false, 'Xəta baş verdi!')
    end

    if not xDriver then
        return cb(false, 'Sürücü tapılmadı!')
    end

    if xDriver.job.name ~= 'taxi' then
        return cb(false, 'Bu maşının sürücüsü taksi işçisi deyil!')
    end

    -- Yaxınlıq yoxlaması
    local pPed, dPed = GetPlayerPed(source), GetPlayerPed(xDriver.source)
    if #(GetEntityCoords(pPed) - GetEntityCoords(dPed)) > 12.0 then
        return cb(false, 'Taksiyə çox uzaqsınız!')
    end

    local fare = Config.Taxi.fare
    if xPassenger.getMoney() < fare then
        return cb(false, ('Gediş ~y~%s$~s~-dır. Nağd pulunuz yoxdur!'):format(fare))
    end

    xPassenger.removeMoney(fare)
    xDriver.addMoney(Config.Taxi.driverShare)

    TriggerClientEvent('esx:showNotification', xDriver.source,
        ('~g~Sərnişin mindi!~s~ +%s$'):format(Config.Taxi.driverShare), 'success')

    cb(true, '~g~Taksidə oturursunuz.~s~')
end)

-- ==================== DİGƏR ====================

exports('GetBusPositions', function()
    local list = {}
    for number, bus in pairs(buses) do
        if DoesEntityExist(bus.veh) then
            list[number] = GetEntityCoords(bus.veh)
        end
    end
    return list
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then
        return
    end
    for _, bus in pairs(buses) do
        if DoesEntityExist(bus.ped) then DeleteEntity(bus.ped) end
        if DoesEntityExist(bus.veh) then DeleteEntity(bus.veh) end
    end
end)
