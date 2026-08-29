-- 196 RP | Nəqliyyat — müştəri tərəfi
-- Maşın açarları, dönmə işıqları, icarə (avtomobil/velosiped/skuter/qayıq), motodeliver

local lockStates = {}     -- plate → true (kilidli)
local myKeys = {}         -- plate → true
local rentedPlate = nil
local rentedReturn = nil
local activeOrder = nil
local lastKeyAction = 0

-- ==================== KÖMƏKÇİLƏR ====================

local function GetPlate(veh)
    if not veh or not DoesEntityExist(veh) then
        return nil
    end
    return (GetVehicleNumberPlateText(veh):gsub('%s+', '')):upper()
end

local function GetClosestVehicle(maxDist)
    local coords = GetEntityCoords(PlayerPedId())
    local veh = GetClosestVehicle(coords.x, coords.y, coords.z, maxDist, 0, 71)
    if veh and veh ~= 0 and DoesEntityExist(veh) then
        return veh
    end
    return nil
end

local function GetVehicleLabel(veh)
    return GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(veh)))
end

-- ==================== 46. DÖNMƏ İŞIQLARI ====================

local signal = { left = false, right = false }

CreateThread(function()
    while true do
        Wait(0)

        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)

            if GetPedInVehicleSeat(veh, -1) == ped then
                local changed = false

                -- SOL (←)
                if IsControlJustPressed(0, Config.TurnSignals.leftControl) then
                    signal.right = false
                    signal.left = not signal.left
                    changed = true
                end

                -- SAĞ (→)
                if IsControlJustPressed(0, Config.TurnSignals.rightControl) then
                    signal.left = false
                    signal.right = not signal.right
                    changed = true
                end

                -- HAVARİ
                if IsControlJustPressed(0, Config.TurnSignals.hazardControl) then
                    local on = not (signal.left and signal.right)
                    signal.left = on
                    signal.right = on
                    changed = true
                end

                if changed then
                    SetVehicleIndicatorLights(veh, 1, signal.left)
                    SetVehicleIndicatorLights(veh, 0, signal.right)
                    if Config.TurnSignals.sound then
                        PlaySound(-1, 'TOGGLE_ON', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false, 0, true)
                    end
                end
            end
        else
            signal.left = false
            signal.right = false
        end
    end
end)

-- ==================== 45. MAŞIN AÇARLARI ====================

RegisterNetEvent('196rp_vehicle:lockState', function(plate, locked)
    if plate then
        lockStates[plate] = locked and true or nil
    end
end)

RegisterNetEvent('196rp_vehicle:keysChanged', function(keys)
    myKeys = {}
    if type(keys) == 'table' then
        for i = 1, #keys do
            myKeys[keys[i]] = true
        end
    end
end)

-- Kilidli maşına minəndə — siqnal + çöldə atılır
CreateThread(function()
    local warnedPlate = nil

    while true do
        Wait(300)

        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            local plate = GetPlate(veh)

            if plate and lockStates[plate] and GetPedInVehicleSeat(veh, -1) == ped then
                -- Açar yoxdursa mühərrik işə düşməsin
                if Config.Keys.engineRequireKey and not myKeys[plate] then
                    SetVehicleEngineOn(veh, false, true, true)
                    SetVehicleUndriveable(veh, true)
                end

                if not myKeys[plate] then
                    if Config.Keys.alarmSound then
                        StartVehicleHorn(veh, 1400, 'HELDDOWN', true)
                        SetVehicleIndicatorLights(veh, 0, true)
                        SetVehicleIndicatorLights(veh, 1, true)
                        SetTimeout(1400, function()
                            if DoesEntityExist(veh) then
                                SetVehicleIndicatorLights(veh, 0, false)
                                SetVehicleIndicatorLights(veh, 1, false)
                            end
                        end)
                    end

                    if warnedPlate ~= plate then
                        warnedPlate = plate
                        ESX.ShowNotification('~r~Bu maşın kilidlidir!~s~ Sizdə açar yoxdur.', 'error', 5000)
                        TaskLeaveVehicle(ped, veh, 16)
                    end
                end
            else
                warnedPlate = nil
            end
        end
    end
end)

-- Kilid vizual effekti
local function LockFX(veh, locked)
    if not DoesEntityExist(veh) then
        return
    end

    SetVehicleDoorsLocked(veh, locked and 2 or 1)
    SetVehicleDoorsLockedForAllPlayers(veh, locked)
    SetVehicleIndicatorLights(veh, 0, true)
    SetVehicleIndicatorLights(veh, 1, true)

    SetTimeout(700, function()
        if DoesEntityExist(veh) then
            SetVehicleIndicatorLights(veh, 0, false)
            SetVehicleIndicatorLights(veh, 1, false)
        end
    end)
end

local function ToggleLock()
    local now = GetGameTimer()
    if now - lastKeyAction < 500 then
        return
    end
    lastKeyAction = now

    local veh = GetClosestVehicle(Config.Keys.maxDistance)
    if not veh then
        ESX.ShowNotification('Yaxınlıqda maşın yoxdur!', 'error')
        return
    end

    local plate = GetPlate(veh)
    if not plate then
        return
    end

    ESX.TriggerServerCallback('196rp_vehicle:toggleLock', function(ok, msg, locked)
        ESX.ShowNotification(msg, ok and 'info' or 'error', 4000)
        if ok then
            lockStates[plate] = locked and true or nil
            LockFX(veh, locked)
        end
    end, plate)
end

RegisterCommand(Config.Keys.lockCommand, ToggleLock, false)

RegisterCommand(Config.Keys.listCommand, function()
    ESX.TriggerServerCallback('196rp_vehicle:getKeyList', function(list)
        local menu = {
            { icon = 'fas fa-key', title = ('🔑 Açarlarınız (%s)'):format(#list), unselectable = true },
        }

        if #list == 0 then
            menu[#menu + 1] = {
                icon = 'fas fa-info-circle',
                title = 'Sizdə heç bir açar yoxdur',
                description = 'Maşın alın və ya /acarver ilə açar istəyin.',
                unselectable = true,
            }
        else
            for i = 1, #list do
                menu[#menu + 1] = {
                    icon = 'fas fa-car',
                    title = ('%s — %s'):format(list[i].plate, list[i].label or 'Maşın'),
                    description = list[i].owner and 'Sahibsiniz' or 'Açar sizdədir',
                    name = 'key_' .. list[i].plate,
                }
            end
        end

        exports['esx_context']:Open('right', menu, function(selected)
            local plate = selected.name:match('^key_(.+)$')
            if not plate then
                return
            end

            local veh = GetClosestVehicle(60.0)
            if not veh or GetPlate(veh) ~= plate then
                ESX.ShowNotification('Bu maşın yaxınlıqda deyil!', 'error')
                return
            end

            ESX.TriggerServerCallback('196rp_vehicle:toggleLock', function(ok, msg, locked)
                ESX.ShowNotification(msg, ok and 'info' or 'error', 4000)
                if ok then
                    lockStates[plate] = locked and true or nil
                    LockFX(veh, locked)
                end
            end, plate)
        end)
    end)
end, false)

RegisterCommand(Config.Keys.giveCommand, function(_, args)
    local target = tonumber(args[1])
    if not target then
        ESX.ShowNotification('İstifadə: /acarver [server ID]', 'info')
        return
    end

    local veh = GetClosestVehicle(Config.Keys.maxDistance)
    if not veh then
        ESX.ShowNotification('Yaxınlıqda maşın yoxdur!', 'error')
        return
    end

    local plate = GetPlate(veh)
    if not plate then
        return
    end

    ESX.TriggerServerCallback('196rp_vehicle:giveKey', function(ok, msg)
        ESX.ShowNotification(msg, ok and 'success' or 'error', 6000)
    end, plate, target)
end, false)

-- ==================== 47/48/49/52. İCARƏ ====================

local prefixByKind = {
    car = 'KR',
    bike = 'BV',
    scooter = 'SK',
    boat = 'QT',
}

local function OpenRentalMenu(station, stationIndex)
    local menu = {
        { icon = station.icon, title = ('🚗 %s'):format(station.label), unselectable = true },
        {
            icon = 'fas fa-info-circle',
            title = ('Qiymət: ~g~%s$~s~ / gün (1 gün = %s dəq.)'):format(station.pricePerDay, Config.RentalDayMinutes),
            description = ('Depozit: ~y~%s$~s~ — qaytaranda geri alırsınız.'):format(
                math.floor(station.pricePerDay * Config.RentalDepositMult)),
            unselectable = true,
        },
    }

    for i = 1, #station.vehicles do
        menu[#menu + 1] = {
            icon = 'fas fa-car',
            title = station.vehicles[i].label,
            description = station.vehicles[i].model,
            name = 'rent_' .. i,
        }
    end

    exports['esx_context']:Open('right', menu, function(selected)
        local idx = tonumber(selected.name:match('^rent_(%d+)$'))
        if not idx then
            return
        end

        ESX.TriggerServerCallback('196rp_vehicle:rent', function(ok, plate, msg)
            ESX.ShowNotification(msg, ok and 'success' or 'error', 7000)

            if ok and plate then
                ESX.Game.SpawnVehicle(station.vehicles[idx].model, station.spawn, station.heading, function(veh)
                    if not veh or veh == 0 then
                        return
                    end

                    SetVehicleNumberPlateText(veh, plate)
                    SetVehicleFuelLevel(veh, 100.0)
                    SetVehicleEngineOn(veh, true, true, false)
                    SetVehicleDirtLevel(veh, 0.0)
                    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)

                    rentedPlate = plate
                    rentedReturn = station.returnCoords

                    local blip = AddBlipForEntity(veh)
                    SetBlipSprite(blip, 225)
                    SetBlipColour(blip, 3)
                    BeginTextCommandSetBlipName('STRING')
                    AddTextComponentSubstringPlayerName(('İcarə: %s'):format(station.vehicles[idx].label))
                    EndTextCommandSetBlipName(blip)

                    ESX.ShowNotification(
                        ('~g~%s~s~ icarəyə götürüldü.\nNömrə: ~y~%s~s~\nQaytarmaq üçün stansiyaya gəlin.'):format(
                            station.vehicles[idx].label, plate), 'success', 9000)
                end)
            end
        end, stationIndex, idx, (prefixByKind[station.kind] or 'KR'))
    end)
end

-- İcarəni qaytarma
local function ReturnRental(station)
    ESX.TriggerServerCallback('196rp_vehicle:returnRental', function(ok, msg, refund)
        ESX.ShowNotification(msg, ok and 'success' or 'error', 8000)

        if ok then
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)

            if veh and veh ~= 0 then
                TaskLeaveVehicle(ped, veh, 16)
            end

            Wait(1500)

            -- Yaxınlıqdakı icarə maşınını sil
            local coords = GetEntityCoords(PlayerPedId())
            local vehs = GetGamePool('CVehicle')
            for i = 1, #vehs do
                local plate = GetPlate(vehs[i])
                if plate == rentedPlate then
                    DeleteEntity(vehs[i])
                    break
                end
            end

            rentedPlate = nil
            rentedReturn = nil
        end
    end)
end

CreateThread(function()
    while true do
        local wait = 750
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for i = 1, #Config.Rentals do
            local station = Config.Rentals[i]
            local dist = #(coords - station.coords)

            if dist < 40.0 then
                wait = 0
                DrawMarker(1, station.coords.x, station.coords.y, station.coords.z - 1.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 0.6, 40, 180, 90, 120, false, true, 2, nil, nil, false)
            end

            if dist < 2.5 then
                ESX.TextUI(('[E] — %s'):format(station.label), 'info')
                if IsControlJustPressed(0, 38) then
                    ESX.HideUI()
                    OpenRentalMenu(station, i)
                end
            end

            -- Qaytarma
            if rentedPlate and #(coords - station.returnCoords) < station.returnRadius then
                local veh = GetVehiclePedIsIn(ped, false)
                if veh and veh ~= 0 and GetPlate(veh) == rentedPlate then
                    ESX.TextUI('[E] — İcarə maşınını qaytar', 'info')
                    if IsControlJustPressed(0, 38) then
                        ESX.HideUI()
                        ReturnRental(station)
                    end
                end
            end
        end

        if wait == 750 then
            ESX.HideUI()
        end

        Wait(wait)
    end
end)

-- İcarə nöqtələrinə blip
CreateThread(function()
    for i = 1, #Config.Rentals do
        local s = Config.Rentals[i]
        local blip = AddBlipForCoord(s.coords.x, s.coords.y, s.coords.z)
        SetBlipSprite(blip, Config.Blips.rental.sprite)
        SetBlipColour(blip, Config.Blips.rental.colour)
        SetBlipAsShortRange(blip, true)
        SetBlipScale(blip, Config.Blips.rental.scale)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(s.label)
        EndTextCommandSetBlipName(blip)
    end
end)

-- ==================== 50. MOTODELİVER ====================

local function StartOrder()
    ESX.TriggerServerCallback('196rp_vehicle:startOrder', function(ok, order, msg)
        ESX.ShowNotification(msg, ok and 'success' or 'error', 7000)

        if ok and order then
            activeOrder = order

            ESX.Game.SpawnVehicle(Config.Delivery.bike, Config.Delivery.spawn, Config.Delivery.heading, function(veh)
                if not veh or veh == 0 then
                    return
                end

                SetVehicleNumberPlateText(veh, ('196MD%03d'):format(math.random(1, 999)))
                SetVehicleFuelLevel(veh, 100.0)
                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)

                ESX.ShowNotification('~g~Sifariş alındı!~s~ Xəritədəki ünvana çatdırın.', 'success')
            end)

            local blip = AddBlipForCoord(order.coords.x, order.coords.y, order.coords.z)
            SetBlipSprite(blip, Config.Blips.delivery.sprite)
            SetBlipColour(blip, Config.Blips.delivery.colour)
            SetBlipRoute(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(('Çatdırılma: %s'):format(order.label))
            EndTextCommandSetBlipName(blip)

            CreateThread(function()
                while activeOrder do
                    Wait(500)

                    local ped = PlayerPedId()
                    local c = GetEntityCoords(ped)

                    if #(c - vector3(order.coords.x, order.coords.y, order.coords.z)) < 5.0 then
                        ESX.TextUI('[E] — Sifarişi çatdır', 'info')
                        if IsControlJustPressed(0, 38) then
                            ESX.HideUI()
                            ESX.Progressbar('Sifariş çatdırılır...', 4000, {
                                FreezePlayer = true,
                                animation = { type = 'Scenario', Scenario = 'WORLD_HUMAN_CLIPBOARD' },
                                onFinish = function()
                                    ESX.TriggerServerCallback('196rp_vehicle:finishOrder', function(done, pay, tip, m)
                                        ESX.ShowNotification(m, done and 'success' or 'error', 8000)
                                        if done then
                                            RemoveBlip(blip)
                                            activeOrder = nil
                                        end
                                    end)
                                end,
                                onCancel = function()
                                    ESX.ShowNotification('Çatdırılma ləğv edildi.', 'info')
                                end
                            })
                        end
                    else
                        ESX.HideUI()
                    end

                    if not activeOrder then
                        RemoveBlip(blip)
                        break
                    end
                end
            end)
        end
    end)
end

CreateThread(function()
    while true do
        local wait = 750
        local coords = GetEntityCoords(PlayerPedId())
        local dist = #(coords - Config.Delivery.depot)

        if dist < 40.0 then
            wait = 0
            DrawMarker(1, Config.Delivery.depot.x, Config.Delivery.depot.y, Config.Delivery.depot.z - 1.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 0.6, 255, 140, 40, 120, false, true, 2, nil, nil, false)
        end

        if dist < 2.5 then
            ESX.TextUI('[E] — Motodeliver: sifariş götür', 'info')
            if IsControlJustPressed(0, 38) then
                ESX.HideUI()
                StartOrder()
            end
        end

        if wait == 750 then
            ESX.HideUI()
        end

        Wait(wait)
    end
end)

CreateThread(function()
    local blip = AddBlipForCoord(Config.Delivery.depot.x, Config.Delivery.depot.y, Config.Delivery.depot.z)
    SetBlipSprite(blip, Config.Blips.delivery.sprite)
    SetBlipColour(blip, Config.Blips.delivery.colour)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, Config.Blips.delivery.scale)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('196 Motodeliver Mərkəzi')
    EndTextCommandSetBlipName(blip)
end)

exports('GetRentedPlate', function()
    return rentedPlate
end)
