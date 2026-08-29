local onDuty = false
local showingUI = false
local dutyVehicle = 0
local isCuffed = false

local function HideUI()
    if showingUI then
        showingUI = false
        ESX.HideUI()
    end
end

-- Bliplər
CreateThread(function()
    for i = 1, #Config.Stations do
        local station = Config.Stations[i]
        local blip = AddBlipForCoord(station.coords.x, station.coords.y, station.coords.z)
        SetBlipSprite(blip, 60)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 38)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(station.name)
        EndTextCommandSetBlipName(blip)
    end
end)

-- ==================== NÖVBƏ ====================

local function ToggleDuty()
    ESX.TriggerServerCallback('196rp_police:toggleDuty', function(ok, msg)
        if ok then
            onDuty = not onDuty
        end
        ESX.ShowNotification(msg, ok and 'success' or 'error')
    end)
end

-- ==================== HƏDƏF TAPMA ====================

local function GetTargetPlayer(args)
    if args and args[1] then
        return tonumber(args[1])
    end
    local players = ESX.Game.GetPlayersInArea(GetEntityCoords(PlayerPedId()), 3.5)
    for i = 1, #players do
        if players[i] ~= PlayerId() then
            return GetPlayerServerId(players[i])
        end
    end
    return nil
end

-- ==================== QANDALLAR ====================

RegisterCommand('qandalli', function(_, args)
    local target = GetTargetPlayer(args)
    if not target then
        ESX.ShowNotification('Yaxınlıqda oyunçu yoxdur!', 'error')
        return
    end
    TriggerServerEvent('196rp_police:cuff', target)
end, false)

RegisterCommand('cuff', function(_, args)
    local target = GetTargetPlayer(args)
    if not target then
        ESX.ShowNotification('Yaxınlıqda oyunçu yoxdur!', 'error')
        return
    end
    TriggerServerEvent('196rp_police:cuff', target)
end, false)

-- ==================== CƏRİMƏ ====================

RegisterCommand('cerime', function(_, args)
    local target = GetTargetPlayer(args)
    if not target then
        ESX.ShowNotification('Yaxınlıqda oyunçu yoxdur!', 'error')
        return
    end

    local amount = tonumber(args and args[2])
    if not amount or amount <= 0 then
        ESX.ShowNotification('İstifadə: /cerime [id] [məbləğ]', 'error')
        return
    end

    TriggerServerEvent('196rp_police:fine', target, math.floor(amount))
end, false)

-- ==================== HƏBSXANA ====================

RegisterCommand('hebsxana', function(_, args)
    local target = GetTargetPlayer(args)
    if not target then
        ESX.ShowNotification('Yaxınlıqda oyunçu yoxdur!', 'error')
        return
    end

    local minutes = tonumber(args and args[2])
    if not minutes or minutes <= 0 then
        ESX.ShowNotification('İstifadə: /hebsxana [id] [dəqiqə]', 'error')
        return
    end

    TriggerServerEvent('196rp_police:jail', target, math.floor(minutes))
end, false)

-- ==================== MÜSAFİRƏ (IMPOUNT) ====================

RegisterCommand('impound', function()
    local coords = GetEntityCoords(PlayerPedId())
    local vehicle = ESX.Game.GetClosestVehicle(coords, 10.0)

    if not vehicle or vehicle == 0 then
        ESX.ShowNotification('Yaxınlıqda maşın yoxdur!', 'error')
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    if plate:sub(1, 5) ~= '196RP' then
        ESX.ShowNotification('Bu maşın qeydiyyatda deyil (196RP nömrəsi yoxdur)!', 'error')
        return
    end

    TriggerServerEvent('196rp_police:impound', plate)
end, false)

-- ==================== POLİS MAŞINI ====================

local function SpawnPoliceVehicle(station, model)
    ESX.TriggerServerCallback('196rp_police:spawnVehicle', function(netId)
        if not netId then
            ESX.ShowNotification('Maşın yaradıla bilmədi!', 'error')
            return
        end

        local vehicle = NetworkGetEntityFromNetworkId(netId)
        if not vehicle or vehicle == 0 then
            return
        end

        dutyVehicle = vehicle
        SetVehicleNumberPlateText(vehicle, ('POL%s'):format(math.random(100, 999)))
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetVehicleOnGroundProperly(vehicle)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)

        ESX.ShowNotification('~b~Polis maşını hazırdır!~s~', 'success')
    end, station.id, model)
end

-- ==================== HƏBS OLUNMA (client) ====================

RegisterNetEvent('196rp_police:setCuffed', function(cuffed)
    isCuffed = cuffed
    local ped = PlayerPedId()

    if cuffed then
        ESX.Streaming.RequestAnimDict('mp_arresting', function()
            TaskPlayAnim(ped, 'mp_arresting', 'idle', 8.0, -8.0, -1, 49, 0, 0, 0, 0)
        end)
        SetEnableHandcuffs(ped, true)
        SetPedCanPlayAmbientAnims(ped, false)
        ESX.ShowNotification('~r~Əlləriniz qandallandı!~s~', 'error')
    else
        ClearPedTasksImmediately(ped)
        SetEnableHandcuffs(ped, false)
        SetPedCanPlayAmbientAnims(ped, true)
        ESX.ShowNotification('~g~Qandallar açıldı.~s~', 'success')
    end
end)

-- Qandallı oyunçu hərəkət edə bilməz
CreateThread(function()
    while true do
        Wait(100)
        if isCuffed then
            DisableControlAction(0, 21, true)  -- qaç
            DisableControlAction(0, 22, true)  -- maşına min
            DisableControlAction(0, 24, true)  -- hücum
            DisableControlAction(0, 25, true)  -- nişan
            DisableControlAction(0, 36, true)  -- içəri gir
            DisableControlAction(0, 37, true)  -- yıxıl
        end
    end
end)

-- ==================== HƏBSXANA (client) ====================

RegisterNetEvent('196rp_police:jailed', function(minutes)
    local ped = PlayerPedId()
    DoScreenFadeOut(500)
    ESX.SetTimeout(600, function()
        SetEntityCoords(ped, Config.Jail.coords.x, Config.Jail.coords.y, Config.Jail.coords.z, false, false, false, true)
        SetEntityHeading(ped, Config.Jail.heading)
        DoScreenFadeIn(600)
        ESX.ShowNotification(('~r~Həbsxanadasınız!~s~ Cəza müddəti: ~y~%s dəqiqə~s~'):format(minutes), 'error', 8000)
    end)
end)

RegisterNetEvent('196rp_police:released', function()
    local ped = PlayerPedId()
    DoScreenFadeOut(500)
    ESX.SetTimeout(600, function()
        SetEntityCoords(ped, Config.ReleaseSpawn.x, Config.ReleaseSpawn.y, Config.ReleaseSpawn.z, false, false, false, true)
        DoScreenFadeIn(600)
        ESX.ShowNotification('~g~Azadsınız!~s~ Cəzanız bitdi. Yaxşı davranın!', 'success', 8000)
    end)
end)

-- ==================== ƏSAS DÖVRƏ ====================

CreateThread(function()
    while true do
        local wait = 750
        local coords = GetEntityCoords(PlayerPedId())
        local nearStation = nil
        local nearStationDist = 99.0

        for i = 1, #Config.Stations do
            local station = Config.Stations[i]
            local dist = #(coords - station.coords)
            if dist < 3.5 and dist < nearStationDist then
                nearStationDist = dist
                nearStation = station
            end
        end

        if nearStation then
            wait = 0
            showingUI = true

            if not onDuty then
                ESX.TextUI(('[E] — Polis növbəsinə başla (~y~%s~s~)'):format(nearStation.name), 'info')
                if IsControlJustPressed(0, 38) then
                    ToggleDuty()
                end
            else
                ESX.TextUI(('[E] — Polis menyusu (~y~%s~s~)'):format(nearStation.name), 'info')
                if IsControlJustPressed(0, 38) then
                    -- Menyu: növbəni bitir və ya maşın götür
                    local elements = {
                        { label = 'Növbəni bitir', value = 'offduty' },
                        { label = 'Polis maşını götür', value = 'vehicle' },
                    }

                    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pd_station_menu', {
                        title = nearStation.name,
                        align = 'top-left',
                        elements = elements
                    }, function(data, menu)
                        menu.close()
                        if data.current.value == 'offduty' then
                            ToggleDuty()
                        else
                            local vehElements = {}
                            for i = 1, #Config.PoliceVehicles do
                                local model = Config.PoliceVehicles[i]
                                local label = model == 'police2' and 'Patrul maşını' or model == 'policeb' and 'Patrul motosikleti' or 'Patrul SUV'
                                vehElements[#vehElements + 1] = { label = label, value = model }
                            end

                            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pd_vehicle_menu', {
                                title = 'Polis maşını seçin',
                                align = 'top-left',
                                elements = vehElements
                            }, function(vehData, vehMenu)
                                vehMenu.close()
                                SpawnPoliceVehicle(nearStation, vehData.current.value)
                            end, function(vehData, vehMenu)
                                vehMenu.close()
                            end)
                        end
                    end, function(data, menu)
                        menu.close()
                    end)
                end
            end
        else
            HideUI()
        end

        Wait(wait)
    end
end)

-- Növbə vəziyyəti
RegisterNetEvent('196rp_police:setDuty', function(duty)
    onDuty = duty
end)

AddEventHandler('esx:onPlayerLogout', function()
    onDuty = false
    if dutyVehicle and DoesEntityExist(dutyVehicle) then
        ESX.Game.DeleteVehicle(dutyVehicle)
    end
    dutyVehicle = 0
end)
