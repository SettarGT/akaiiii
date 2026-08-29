-- 196 RP | Dövlət qüvvələri (əlavə) — müştəri tərəfi
-- Qərargah, radar, yol polisi, K9 iti, SWAT, helikopter, fövqəladə elan

local playerJob = nil
local playerGrade = 0
local inHQ = false
local k9Dog = nil
local swatOn = false
local shieldProp = nil

-- ==================== KÖMƏKÇİLƏR ====================

local function Notify(msg, typ, len)
    ESX.ShowNotification(msg, typ or 'info', len or 6000)
end

local function IsJob(name)
    return playerJob == name
end

local function HasGrade(min)
    return (playerGrade or 0) >= (min or 0)
end

local function GetPlate(veh)
    if not veh or not DoesEntityExist(veh) then
        return nil
    end
    return (GetVehicleNumberPlateText(veh):gsub('%s+', '')):upper()
end

local function GetClosestVehicle(dist)
    local c = GetEntityCoords(PlayerPedId())
    local veh = GetClosestVehicle(c.x, c.y, c.z, dist, 0, 71)
    if veh and veh ~= 0 and DoesEntityExist(veh) then
        return veh
    end
    return nil
end

local function GetClosestPlayer(dist)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local closestId, closestDist = -1, dist

    local players = GetActivePlayers()
    for i = 1, #players do
        local other = GetPlayerPed(players[i])
        if other ~= ped then
            local d = #(coords - GetEntityCoords(other))
            if d < closestDist then
                closestId = GetPlayerServerId(players[i])
                closestDist = d
            end
        end
    end

    return closestId
end

-- ==================== OYUNÇU MƏLUMATI ====================

CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Wait(250)
    end

    local data = ESX.GetPlayerData()
    playerJob = data.job and data.job.name or nil
    playerGrade = data.job and data.job.grade or 0
end)

RegisterNetEvent('esx:setJob', function(job)
    playerJob = job and job.name or nil
    playerGrade = job and job.grade or 0
end)

-- ==================== 81. QƏRARGAH ====================

local function FadeTo(dest, heading)
    DoScreenFadeOut(500)
    Wait(600)
    SetEntityCoords(PlayerPedId(), dest.x, dest.y, dest.z, false, false, false, false)
    SetEntityHeading(PlayerPedId(), heading or 0.0)
    DoScreenFadeIn(500)
end

local function OpenArmory()
    ESX.TriggerServerCallback('196rp_policeadv:armory', function(ok, msg)
        Notify(msg, ok and 'success' or 'error', 6000)

        if ok then
            local ped = PlayerPedId()
            for i = 1, #Config.HQ.armoryWeapons do
                local w = Config.HQ.armoryWeapons[i]
                GiveWeaponToPed(ped, GetHashKey(w.weapon), w.ammo, false, true)
            end
            SetPedArmour(ped, 100)
        end
    end)
end

local function OpenComputer()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'hq_computer', {
        title = '💻 Axtarış: nömrə və ya server ID yazın'
    }, function(data, menu)
        menu.close()
        local query = tostring(data.value or ''):gsub('%s+', '')

        if query == '' then
            return Notify('Sorğu boş ola bilməz!', 'error')
        end

        ESX.TriggerServerCallback('196rp_policeadv:computerSearch', function(ok, msg)
            Notify(msg, ok and 'success' or 'error', 10000)
        end, query)
    end)
end

-- ==================== 82. RADAR / 83. YOL POLİSİ ====================

RegisterCommand('radar', function()
    if not IsJob(Config.Jobs.police) then
        return Notify('Bu əmr yalnız polis üçündür.', 'error')
    end

    local veh = GetClosestVehicle(Config.Radar.maxDistance)
    if not veh then
        return Notify('Yaxınlıqda maşın yoxdur!', 'error')
    end

    local plate = GetPlate(veh)
    local speed = math.floor(GetEntitySpeed(veh) * 3.6)

    ESX.TriggerServerCallback('196rp_policeadv:radarCheck', function(ok, msg)
        Notify(msg, ok and 'success' or 'error', 9000)
    end, plate, speed)
end, false)

RegisterCommand('yolyoxla', function()
    if not IsJob(Config.Jobs.police) then
        return Notify('Bu əmr yalnız polis üçündür.', 'error')
    end

    local target = GetClosestPlayer(Config.RoadPolice.checkDistance)
    if target == -1 then
        return Notify('Yaxınlıqda sürücü yoxdur!', 'error')
    end

    ESX.TriggerServerCallback('196rp_policeadv:checkDriver', function(ok, msg)
        Notify(msg, ok and 'success' or 'error', 12000)
    end, target)
end, false)

-- ==================== 84. K9 İTİ ====================

RegisterCommand('it', function()
    if not IsJob(Config.Jobs.police) or not HasGrade(Config.K9.minGrade) then
        Notify('K9 yalnız polis üçün və kifayət qədər rütbə ilə mümkündür.', 'error')
        return
    end

    if k9Dog and DoesEntityExist(k9Dog) then
        DeleteEntity(k9Dog)
        k9Dog = nil
        return Notify('İt geri göndərildi.', 'info')
    end

    local model = GetHashKey(Config.K9.model)
    RequestModel(model)

    local tries = 0
    while not HasModelLoaded(model) and tries < 60 do
        Wait(50)
        tries = tries + 1
    end

    if not HasModelLoaded(model) then
        return Notify('İt modeli yüklənmədi!', 'error')
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    k9Dog = CreatePed(28, model, coords.x + 1.0, coords.y, coords.z, 0.0, true, false)

    SetModelAsNoLongerNeeded(model)
    SetPedAsGroupMember(k9Dog, GetPedGroupIndex(ped))
    SetPedNeverLeavesGroup(k9Dog, true)
    SetEntityInvincible(k9Dog, true)
    SetBlockingOfNonTemporaryEvents(k9Dog, true)
    TaskFollowToOffsetOfEntity(k9Dog, ped, 0.0, -1.2, 0.0, 2.0, -1, 1.5, true)

    Notify('~g~K9 iti çağırıldı.~s~ /axtar ilə axtarış aparın.', 'success')
end, false)

RegisterCommand('axtar', function()
    if not IsJob(Config.Jobs.police) or not HasGrade(Config.K9.minGrade) then
        return Notify('Bu əmr K9 üçün nəzərdə tutulub.', 'error')
    end

    local target = GetClosestPlayer(Config.K9.searchDistance)
    if target == -1 then
        return Notify('Yaxınlıqda şəxs yoxdur!', 'error')
    end

    if k9Dog and DoesEntityExist(k9Dog) then
        TaskGoToEntity(k9Dog, GetPlayerPed(GetPlayerFromServerId(target)), -1, 1.0, 2.0, 1073741824, 0)
        TaskPlayAnim(k9Dog, 'creatures@rottweiler@amb@sleep_in_kennel@', 'sleep_in_kennel', 8.0, -8.0, 3000, 1, 0, false, false, false)
    end

    ESX.TriggerServerCallback('196rp_policeadv:k9Search', function(ok, msg)
        Notify(msg, ok and 'success' or 'error', 9000)
    end, target)
end, false)

-- ==================== 85. SWAT ====================

RegisterCommand('swat', function()
    if not IsJob(Config.Jobs.police) or not HasGrade(Config.SWAT.minGrade) then
        return Notify('SWAT yalnız yüksək rütbəli polis üçündür.', 'error')
    end

    local ped = PlayerPedId()

    if swatOn then
        swatOn = false
        SetPedArmour(ped, 0)

        if shieldProp and DoesEntityExist(shieldProp) then
            DeleteEntity(shieldProp)
        end
        shieldProp = nil
        ClearPedSecondaryTask(ped)

        return Notify('SWAT rejimi söndürüldü.', 'info')
    end

    ESX.TriggerServerCallback('196rp_policeadv:swat', function(ok, msg)
        Notify(msg, ok and 'success' or 'error', 6000)

        if not ok then
            return
        end

        swatOn = true
        SetPedArmour(ped, Config.SWAT.armour)

        for i = 1, #Config.SWAT.weapons do
            local w = Config.SWAT.weapons[i]
            GiveWeaponToPed(ped, GetHashKey(w.weapon), w.ammo, false, true)
        end

        local model = GetHashKey(Config.SWAT.shieldProp)
        RequestModel(model)

        local tries = 0
        while not HasModelLoaded(model) and tries < 60 do
            Wait(50)
            tries = tries + 1
        end

        if HasModelLoaded(model) then
            shieldProp = CreateObject(model, 0.0, 0.0, 0.0, true, true, false)
            AttachEntityToEntity(shieldProp, ped, GetPedBoneIndex(ped, 24818),
                0.0, -0.05, -0.20, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            SetModelAsNoLongerNeeded(model)
        end

        Notify('~g~SWAT rejimi aktivləşdi.~s~ Qalxan və silahlar verildi.', 'success')
    end)
end, false)

-- ==================== 87. TİB HELİKOPTERİ ====================

RegisterCommand('helikopter', function()
    if not IsJob(Config.Jobs.ambulance) or not HasGrade(Config.AirAmbulance.minGrade) then
        return Notify('Helikopter yalnız yüksək rütbəli TİB işçisi üçündür.', 'error')
    end

    ESX.TriggerServerCallback('196rp_policeadv:spawnHelicopter', function(ok, msg)
        Notify(msg, ok and 'success' or 'error', 6000)

        if not ok then
            return
        end

        ESX.Game.SpawnVehicle(Config.AirAmbulance.model, Config.AirAmbulance.spawn,
            Config.AirAmbulance.heading, function(veh)
                if not veh or veh == 0 then
                    return
                end

                SetVehicleNumberPlateText(veh, Config.AirAmbulance.plate)
                SetVehicleFuelLevel(veh, 100.0)
                SetVehicleEngineOn(veh, true, true, false)
                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
            end)
    end)
end, false)

-- ==================== 88. YANĞINSÖNDÜRƏN DƏRƏCƏLƏRİ ====================

RegisterCommand('ruhbeler', function()
    ESX.TriggerServerCallback('196rp_policeadv:getRanks', function(msg)
        Notify(msg, 'info', 12000)
    end)
end, false)

-- ==================== 89. MÜLKİ MÜDAFİƏ ====================

RegisterCommand('fovqelade', function(_, args)
    local message = table.concat(args, ' ')

    if message == '' then
        return Notify('İstifadə: /fovqelade [mesaj]', 'info')
    end

    ESX.TriggerServerCallback('196rp_policeadv:civilDefence', function(ok, msg)
        Notify(msg, ok and 'success' or 'error', 7000)
    end, message)
end, false)

-- Fövqəladə xəbərdarlıq bütün oyunçulara
RegisterNetEvent('196rp_policeadv:alert', function(message, sender)
    ESX.ShowNotification(('~r~🚨 MÜLKİ MÜDAFİƏ XƏBƏRDARLIĞI~s~\n~y~%s~s~\n~b~%s~s~'):format(message, sender), 'error', 15000)
    PlaySound(-1, 'Event_Start_Text', 'GTAO_FM_Events_Soundset', false, 0, true)
end)

-- ==================== MARKERLƏR ====================

CreateThread(function()
    while true do
        local wait = 750
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        if not IsJob(Config.Jobs.police) then
            Wait(1500)
        else
            local shown = false

            if not inHQ then
                local dist = #(coords - Config.HQ.entrance)

                if dist < 25.0 then
                    wait = 0
                    DrawMarker(1, Config.HQ.entrance.x, Config.HQ.entrance.y, Config.HQ.entrance.z - 1.0,
                        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 0.5, 40, 90, 200, 120, false, true, 2, nil, nil, false)
                end

                if dist < 1.8 then
                    shown = true
                    ESX.TextUI('[E] — Polis Qərargahına gir', 'info')
                    if IsControlJustPressed(0, 38) then
                        ESX.HideUI()
                        FadeTo(Config.HQ.interior, 90.0)
                        inHQ = true
                    end
                end
            else
                wait = 0

                DrawMarker(1, Config.HQ.exit.x, Config.HQ.exit.y, Config.HQ.exit.z - 1.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 0.5, 200, 90, 90, 120, false, true, 2, nil, nil, false)

                if #(coords - Config.HQ.exit) < 1.8 then
                    shown = true
                    ESX.TextUI('[E] — Qərargahdan çıx', 'info')
                    if IsControlJustPressed(0, 38) then
                        ESX.HideUI()
                        FadeTo(Config.HQ.exit, 260.0)
                        inHQ = false
                    end
                end

                local pts = {
                    { p = Config.HQ.points.computer, label = '[E] — ' .. Config.HQ.points.computer.label, action = OpenComputer },
                    { p = Config.HQ.points.armory, label = '[E] — ' .. Config.HQ.points.armory.label, action = OpenArmory },
                }

                for i = 1, #pts do
                    DrawMarker(1, pts[i].p.coords.x, pts[i].p.coords.y, pts[i].p.coords.z - 1.0,
                        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.4, 220, 200, 80, 120, false, true, 2, nil, nil, false)

                    if #(coords - pts[i].p.coords) < 1.6 then
                        shown = true
                        ESX.TextUI(pts[i].label, 'info')
                        if IsControlJustPressed(0, 38) then
                            ESX.HideUI()
                            pts[i].action()
                        end
                    end
                end
            end

            if not shown then
                ESX.HideUI()
            end
        end

        Wait(wait)
    end
end)

-- İt sahibdən uzaqlaşmasın
CreateThread(function()
    while true do
        Wait(3000)

        if k9Dog and DoesEntityExist(k9Dog) then
            local ped = PlayerPedId()
            local d = #(GetEntityCoords(k9Dog) - GetEntityCoords(ped))

            if d > 15.0 then
                SetEntityCoords(k9Dog, GetEntityCoords(ped).x + 1.0, GetEntityCoords(ped).y, GetEntityCoords(ped).z,
                    false, false, false, false)
            end
        end
    end
end)
