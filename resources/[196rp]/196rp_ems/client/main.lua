local onDuty = false
local showingUI = false
local deadBlips = {}
local isDead = false

local function HideUI()
    if showingUI then
        showingUI = false
        ESX.HideUI()
    end
end

-- Bliplər
CreateThread(function()
    for i = 1, #Config.Hospitals do
        local hospital = Config.Hospitals[i]
        local blip = AddBlipForCoord(hospital.coords.x, hospital.coords.y, hospital.coords.z)
        SetBlipSprite(blip, 61)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 1)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(hospital.name)
        EndTextCommandSetBlipName(blip)
    end
end)

-- ==================== CANLANDIRMA / MÜALİCƏ ====================

local function ReviveSelf()
    local ped = PlayerPedId()
    SetEntityHealth(ped, 200)
    ClearPedTasksImmediately(ped)
    SetPlayerControl(PlayerId(), true, 0)
    ESX.SetPlayerData('dead', false)
    isDead = false
    TriggerServerEvent('196rp_ems:setDead', false)
end

RegisterNetEvent('196rp_ems:revived', function()
    ReviveSelf()
    ESX.ShowNotification('~g~Həkim sizi xilas etdi!~s~ Sağlamlığınız bərpa olundu.', 'success', 7000)
end)

RegisterNetEvent('196rp_ems:healed', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, 200)
    SetPedArmour(ped, 50)
    ESX.ShowNotification('~g~Həkim sizi müalicə etdi!~s~ Sağlamlığınız tam bərpa olundu.', 'success')
end)

local function RespawnAtHospital()
    local ped = PlayerPedId()
    local hospital = Config.Hospitals[1]

    -- Ən yaxın xəstəxana
    local coords = GetEntityCoords(ped)
    local nearestDist = 99999.0
    for i = 1, #Config.Hospitals do
        local dist = #(coords - Config.Hospitals[i].respawn)
        if dist < nearestDist then
            nearestDist = dist
            hospital = Config.Hospitals[i]
        end
    end

    ReviveSelf()
    DoScreenFadeOut(400)
    ESX.SetTimeout(500, function()
        SetEntityCoords(ped, hospital.respawn.x, hospital.respawn.y, hospital.respawn.z, false, false, false, true)
        SetEntityHeading(ped, hospital.vehicleHeading)
        DoScreenFadeIn(600)
        ESX.ShowNotification(('~b~%s~s~ — sağlamlığınız bərpa olundu. Çıxışda sizi yeni gün gözləyir!'):format(hospital.name), 'info', 6000)
    end)
end

-- ==================== ÖLÜM SİSTEMİ ====================

RegisterNetEvent('esx:onPlayerDeath', function()
    isDead = true
    TriggerServerEvent('196rp_ems:setDead', true)
end)

AddEventHandler('esx:onPlayerSpawn', function()
    if isDead then
        isDead = false
    end
end)

CreateThread(function()
    local deathStart = 0
    local deathShown = false

    while true do
        Wait(500)

        if isDead then
            if not deathShown then
                deathShown = true
                deathStart = GetGameTimer()
            end

            showingUI = true
            local remaining = math.ceil((Config.RespawnTimer * 1000 - (GetGameTimer() - deathStart)) / 1000)

            if remaining <= 0 then
                deathShown = false
                RespawnAtHospital()
            else
                ESX.TextUI(('~r~Siz yaralısınız!~s~ Təcili yardım sizi xilas edə bilər.\n[E] — Xəstəxanaya yollan (~w~%s san~s~)'):format(remaining), 'error')

                if IsControlJustPressed(0, 38) then -- E
                    deathShown = false
                    RespawnAtHospital()
                end
            end
        else
            deathShown = false
            HideUI()
        end
    end
end)

-- ==================== EMS ƏMRLƏRİ ====================

RegisterCommand('dirilt', function(_, args)
    local target = nil
    if args and args[1] then
        target = tonumber(args[1])
    else
        -- Ölən oyunçuların siyahısını göstər
        ESX.TriggerServerCallback('196rp_ems:getDeadPlayers', function(deadPlayers)
            if not deadPlayers or #deadPlayers == 0 then
                ESX.ShowNotification('Hal-hazırda yaralı oyunçu yoxdur.', 'info')
                return
            end

            local elements = {}
            for i = 1, #deadPlayers do
                elements[#elements + 1] = {
                    label = ('%s — %s'):format(deadPlayers[i].name, deadPlayers[i].id),
                    value = deadPlayers[i].id
                }
            end

            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'ems_revive', {
                title = 'Yaralı oyunçular',
                align = 'top-left',
                elements = elements
            }, function(data, menu)
                menu.close()
                TriggerServerEvent('196rp_ems:revive', data.current.value)
            end, function(data, menu)
                menu.close()
            end)
        end)
        return
    end

    TriggerServerEvent('196rp_ems:revive', target)
end, false)

RegisterCommand('mualice', function(_, args)
    local target = nil
    if args and args[1] then
        target = tonumber(args[1])
    else
        local players = ESX.Game.GetPlayersInArea(GetEntityCoords(PlayerPedId()), 3.5)
        for i = 1, #players do
            if players[i] ~= PlayerId() then
                target = GetPlayerServerId(players[i])
                break
            end
        end
    end

    if not target then
        ESX.ShowNotification('Yaxınlıqda oyunçu yoxdur!', 'error')
        return
    end

    TriggerServerEvent('196rp_ems:heal', target)
end, false)

-- ==================== NÖVBƏ ====================

local function ToggleDuty()
    ESX.TriggerServerCallback('196rp_ems:toggleDuty', function(ok, msg)
        if ok then
            onDuty = not onDuty
        end
        ESX.ShowNotification(msg, ok and 'success' or 'error')
    end)
end

-- Ölən oyunçuların blipləri (növbədə olan həkimlər üçün)
CreateThread(function()
    while true do
        Wait(5000)

        if onDuty then
            ESX.TriggerServerCallback('196rp_ems:getDeadPlayers', function(deadPlayers)
                -- Köhnə blipləri sil
                for i = 1, #deadBlips do
                    if deadBlips[i] and DoesBlipExist(deadBlips[i]) then
                        RemoveBlip(deadBlips[i])
                    end
                end
                deadBlips = {}

                if deadPlayers then
                    for i = 1, #deadPlayers do
                        local blip = AddBlipForCoord(deadPlayers[i].coords.x, deadPlayers[i].coords.y, deadPlayers[i].coords.z)
                        SetBlipSprite(blip, 161)
                        SetBlipColour(blip, 1)
                        SetBlipScale(blip, 0.9)
                        SetBlipAsShortRange(blip, true)
                        BeginTextCommandSetBlipName('STRING')
                        AddTextComponentString(('YARALI: %s'):format(deadPlayers[i].name))
                        EndTextCommandSetBlipName(blip)
                        deadBlips[#deadBlips + 1] = blip
                    end
                end
            end)
        end
    end
end)

-- Əsas dövrə (xəstəxana)
CreateThread(function()
    while true do
        local wait = 750
        local coords = GetEntityCoords(PlayerPedId())
        local nearHospital = nil
        local nearDist = 99.0

        for i = 1, #Config.Hospitals do
            local hospital = Config.Hospitals[i]
            local dist = #(coords - hospital.coords)
            if dist < 3.5 and dist < nearDist then
                nearDist = dist
                nearHospital = hospital
            end
        end

        if nearHospital then
            wait = 0
            showingUI = true

            if not onDuty then
                ESX.TextUI(('[E] — Həkim növbəsinə başla (~y~%s~s~)'):format(nearHospital.name), 'info')
                if IsControlJustPressed(0, 38) then
                    ToggleDuty()
                end
            else
                ESX.TextUI(('[E] — Həkim menyusu (~y~%s~s~)'):format(nearHospital.name), 'info')
                if IsControlJustPressed(0, 38) then
                    local elements = {
                        { label = 'Növbəni bitir', value = 'offduty' },
                        { label = 'Təcili yardım maşını götür', value = 'vehicle' },
                    }

                    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'ems_station_menu', {
                        title = nearHospital.name,
                        align = 'top-left',
                        elements = elements
                    }, function(data, menu)
                        menu.close()
                        if data.current.value == 'offduty' then
                            ToggleDuty()
                        else
                            ESX.TriggerServerCallback('196rp_ems:spawnVehicle', function(netId)
                                if not netId then
                                    ESX.ShowNotification('Maşın yaradıla bilmədi!', 'error')
                                    return
                                end
                                local vehicle = NetworkGetEntityFromNetworkId(netId)
                                if vehicle and vehicle ~= 0 then
                                    SetVehicleNumberPlateText(vehicle, ('AMB%s'):format(math.random(100, 999)))
                                    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
                                    SetVehicleOnGroundProperly(vehicle)
                                    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                                    ESX.ShowNotification('~g~Təcili yardım maşını hazırdır!~s~', 'success')
                                end
                            end, nearHospital.id)
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

RegisterNetEvent('196rp_ems:setDuty', function(duty)
    onDuty = duty
end)
