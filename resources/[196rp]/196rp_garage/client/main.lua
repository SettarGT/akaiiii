local garageBlips = {}
local showingUI = false
local currentVehicle = 0
local vehicleLockCache = {} -- plate -> { owned = boolean, locked = boolean }

local function HideUI()
    if showingUI then
        showingUI = false
        ESX.HideUI()
    end
end

-- Bliplər
CreateThread(function()
    for i = 1, #Config.Garages do
        local garage = Config.Garages[i]
        local blip = AddBlipForCoord(garage.coords.x, garage.coords.y, garage.coords.z)
        SetBlipSprite(blip, 357)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 66)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(garage.name)
        EndTextCommandSetBlipName(blip)
        garageBlips[i] = blip
    end

    -- Mühafizə blipi
    local impoundBlip = AddBlipForCoord(Config.Impound.coords.x, Config.Impound.coords.y, Config.Impound.coords.z)
    SetBlipSprite(impoundBlip, 357)
    SetBlipDisplay(impoundBlip, 4)
    SetBlipScale(impoundBlip, 0.8)
    SetBlipColour(impoundBlip, 1)
    SetBlipAsShortRange(impoundBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.Impound.name)
    EndTextCommandSetBlipName(impoundBlip)

    -- Servis blipləri
    for i = 1, #Config.Services do
        local service = Config.Services[i]
        local blip = AddBlipForCoord(service.coords.x, service.coords.y, service.coords.z)
        SetBlipSprite(blip, 72)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 66)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(service.name)
        EndTextCommandSetBlipName(blip)
    end
end)

-- ==================== QARAJ ====================

local function SpawnVehicleFromGarage(plate, garage)
    ESX.TriggerServerCallback('196rp_garage:spawnVehicle', function(data)
        if not data then
            return
        end

        local vehicle = NetworkGetEntityFromNetworkId(data.netId)
        if not vehicle or vehicle == 0 then
            ESX.ShowNotification('Maşın yaradıla bilmədi!', 'error')
            return
        end

        SetVehicleProperties(vehicle, data.props)
        SetVehicleNumberPlateText(vehicle, data.props.plate)
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetVehicleOnGroundProperly(vehicle)
        vehicleLockCache[data.props.plate] = { owned = true, locked = false }

        local ped = PlayerPedId()
        TaskWarpPedIntoVehicle(ped, vehicle, -1)

        ESX.ShowNotification('~g~Maşınınız hazırdır!~s~ Yola çıxa bilərsiniz.', 'success')
    end, plate, garage.type)
end

local function OpenGarageMenu(garage)
    ESX.TriggerServerCallback('196rp_garage:getGarageVehicles', function(vehicles)
        if not vehicles then
            return
        end

        if #vehicles == 0 then
            ESX.ShowNotification('Bu qarajda maşınınız yoxdur. ~y~Avtosalon~s~dan maşın ala bilərsiniz!', 'info')
            return
        end

        local elements = {}
        for i = 1, #vehicles do
            elements[#elements + 1] = {
                label = ('%s — ~b~%s~s~'):format(vehicles[i].label, vehicles[i].plate),
                value = vehicles[i].plate
            }
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'garage_menu', {
            title = garage.name,
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            menu.close()
            SpawnVehicleFromGarage(data.current.value, garage)
        end, function(data, menu)
            menu.close()
        end)
    end, garage.type)
end

local function ParkVehicle(garage)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if not vehicle or vehicle == 0 then
        vehicle = ESX.Game.GetClosestVehicle(GetEntityCoords(ped), 8.0)
    end

    if not vehicle or vehicle == 0 then
        ESX.ShowNotification('Yaxınlıqda maşın yoxdur!', 'error')
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    if plate:sub(1, 5) ~= '196RP' then
        ESX.ShowNotification('Bu maşın sizə məxsus deyil!', 'error')
        return
    end

    local props = GetVehicleProperties(vehicle)
    props.plate = plate

    ESX.TriggerServerCallback('196rp_garage:parkVehicle', function(ok, msg)
        if ok then
            ESX.Game.DeleteVehicle(vehicle)
        end
        ESX.ShowNotification(msg, ok and 'success' or 'error')
    end, plate, json.encode(props))
end

-- ==================== MÜHAFİZƏ (IMPOUNT) ====================

local function OpenImpoundMenu()
    ESX.TriggerServerCallback('196rp_garage:getImpoundedVehicles', function(vehicles)
        if not vehicles then
            return
        end

        if #vehicles == 0 then
            ESX.ShowNotification('Mühafizədə maşınınız yoxdur.', 'info')
            return
        end

        local elements = {}
        for i = 1, #vehicles do
            elements[#elements + 1] = {
                label = ('%s — ~b~%s~s~ (~y~%s$~s~)'):format(vehicles[i].label, vehicles[i].plate, Config.Impound.retrievePrice),
                value = vehicles[i].plate
            }
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'impound_menu', {
            title = Config.Impound.name,
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            menu.close()
            ESX.TriggerServerCallback('196rp_garage:retrieveVehicle', function(ok, msg, netId, props)
                if ok and netId then
                    local vehicle = NetworkGetEntityFromNetworkId(netId)
                    if vehicle and vehicle ~= 0 then
                        SetVehicleProperties(vehicle, props)
                        SetVehicleNumberPlateText(vehicle, props.plate)
                        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                    end
                end
                ESX.ShowNotification(msg, ok and 'success' or 'error')
            end, data.current.value)
        end, function(data, menu)
            menu.close()
        end)
    end)
end

-- ==================== QIFIL ====================

RegisterCommand('qifle', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if not vehicle or vehicle == 0 then
        vehicle = ESX.Game.GetClosestVehicle(GetEntityCoords(ped), 6.0)
    end

    if not vehicle or vehicle == 0 then
        ESX.ShowNotification('Yaxınlıqda maşın yoxdur!', 'error')
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    if plate:sub(1, 5) ~= '196RP' then
        ESX.ShowNotification('Bu maşın sizə məxsus deyil!', 'error')
        return
    end

    ESX.TriggerServerCallback('196rp_garage:toggleLock', function(locked)
        vehicleLockCache[plate] = { owned = true, locked = locked }
        SetVehicleDoorsLocked(vehicle, locked and 2 or 1)
        ESX.ShowNotification(locked and '~y~Maşın qıfıllandı.~s~' or '~g~Maşın açıldı.~s~', locked and 'info' or 'success')
    end, plate)
end, false)

-- Qıfıl vəziyyətini yoxla (maşın dəyişəndə)
CreateThread(function()
    while true do
        Wait(1200)

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= currentVehicle then
            currentVehicle = vehicle
            if vehicle and vehicle ~= 0 then
                local plate = GetVehicleNumberPlateText(vehicle)
                if plate:sub(1, 5) == '196RP' then
                    ESX.TriggerServerCallback('196rp_garage:getVehicleState', function(state)
                        if state then
                            vehicleLockCache[plate] = state
                            if state.owned then
                                SetVehicleDoorsLocked(vehicle, state.locked and 2 or 1)
                            end
                        end
                    end, plate)
                end
            end
        end

        -- Başqasının qıfıllı maşınında sürürsə, çıxart
        if vehicle and vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
            local plate = GetVehicleNumberPlateText(vehicle)
            local state = vehicleLockCache[plate]
            if state and not state.owned and state.locked then
                TaskLeaveVehicle(ped, vehicle, 0)
                ESX.ShowNotification('~r~Bu maşın qıfıllıdır!~s~', 'error')
            end
        end
    end
end)

-- ==================== SERVIS (TƏMİR + YUMA) ====================

local function OpenServiceMenu(service)
    local isWash = service.id:sub(1, 4) == 'wash'

    local elements = {}
    if not isWash then
        elements[#elements + 1] = { label = ('Tam təmir — ~y~%s$~s~'):format(Config.RepairPrice), value = 'repair' }
        elements[#elements + 1] = { label = 'Avtomobil yuma — ~y~50$~s~', value = 'wash' }
    else
        elements[#elements + 1] = { label = 'Avtomobil yuma — ~y~50$~s~', value = 'wash' }
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'service_menu', {
        title = service.name,
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        menu.close()
        ESX.TriggerServerCallback('196rp_garage:payService', function(ok, msg)
            if ok then
                local ped = PlayerPedId()
                local vehicle = GetVehiclePedIsIn(ped, false)
                if not vehicle or vehicle == 0 then
                    vehicle = ESX.Game.GetClosestVehicle(GetEntityCoords(ped), 10.0)
                end
                if vehicle and vehicle ~= 0 then
                    if data.current.value == 'repair' then
                        SetVehicleFixed(vehicle)
                        SetVehicleDeformationFixed(vehicle)
                        SetVehicleEngineHealth(vehicle, 1000.0)
                    end
                    SetVehicleDirtLevel(vehicle, 0.0)
                end
            end
            ESX.ShowNotification(msg, ok and 'success' or 'error')
        end, data.current.value)
    end, function(data, menu)
        menu.close()
    end)
end

-- ==================== ƏSAS DÖVRƏ ====================

CreateThread(function()
    while true do
        local wait = 750
        local coords = GetEntityCoords(PlayerPedId())
        local nearAnything = false

        -- Qarajlar
        for i = 1, #Config.Garages do
            local garage = Config.Garages[i]
            local dist = #(coords - garage.coords)
            if dist < 5.0 then
                nearAnything = true
                wait = 0
                ESX.TextUI(('[E] — Maşınlarım (~y~%s~s~)'):format(garage.name), 'info')
                if IsControlJustPressed(0, 38) then
                    OpenGarageMenu(garage)
                end
                break
            end
        end

        -- Mühafizə
        if not nearAnything then
            local dist = #(coords - Config.Impound.coords)
            if dist < 5.0 then
                nearAnything = true
                wait = 0
                ESX.TextUI(('[E] — Mühafizədəki maşınlar (~y~%s$/geri alma~s~)'):format(Config.Impound.retrievePrice), 'info')
                if IsControlJustPressed(0, 38) then
                    OpenImpoundMenu()
                end
            end
        end

        -- Servis
        if not nearAnything then
            for i = 1, #Config.Services do
                local service = Config.Services[i]
                local dist = #(coords - service.coords)
                if dist < 4.0 then
                    nearAnything = true
                    wait = 0
                    ESX.TextUI(('[E] — Xidmət: ~y~%s~s~'):format(service.name), 'info')
                    if IsControlJustPressed(0, 38) then
                        OpenServiceMenu(service)
                    end
                    break
                end
            end
        end

        -- Maşını qoy (yalnız qaraj yanında)
        local inOwned = false
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle and vehicle ~= 0 then
            local plate = GetVehicleNumberPlateText(vehicle)
            if plate:sub(1, 5) == '196RP' then
                inOwned = true
            end
        end

        if inOwned and not nearAnything then
            for i = 1, #Config.Garages do
                local garage = Config.Garages[i]
                if #(coords - garage.coords) < 8.0 then
                    nearAnything = true
                    wait = 0
                    ESX.TextUI('[E] — Maşını qoya (~y~qaraj~s~)', 'info')
                    if IsControlJustPressed(0, 38) then
                        ParkVehicle(garage)
                    end
                    break
                end
            end
        end

        if not nearAnything then
            HideUI()
        end

        Wait(wait)
    end
end)

-- ==================== QIFIL SINXRONIZASIYASI ====================
-- Server entity-yə vizual effekt verə bilməz — qıfılı hər client öz tərəfində tətbiq edir
RegisterNetEvent('196rp_garage:setLock', function(netId, locked)
    local veh = NetworkGetEntityFromNetworkId(tonumber(netId) or 0)
    if veh ~= 0 then
        SetVehicleDoorsLocked(veh, locked and 2 or 1)
        SetVehicleDoorsLockedForAllPlayers(veh, locked == true)
    end
end)
