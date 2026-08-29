-- 196 RP | Əlavə vəsiqələr — müştəri tərəfi
-- Motosiklet, yük maşını, təyyarə və qayıq imtahanları

local activeTest = nil      -- { type, label, target, radius, blip, deadline }
local testVehicle = nil

-- ==================== KÖMƏKÇİLƏR ====================

local function Notify(msg, typ, len)
    ESX.ShowNotification(msg, typ or 'info', len or 6000)
end

local function EndTest(reason)
    if activeTest and activeTest.blip then
        RemoveBlip(activeTest.blip)
    end

    if testVehicle and DoesEntityExist(testVehicle) then
        DeleteEntity(testVehicle)
    end

    testVehicle = nil

    if reason then
        Notify(reason, 'error', 7000)
    end

    activeTest = nil
end

-- ==================== İMTAHAN ====================

local function StartTest(lic)
    ESX.TriggerServerCallback('196rp_licenses:startTest', function(ok, msg)
        Notify(msg, ok and 'success' or 'error', 7000)

        if not ok then
            return
        end

        ESX.Game.SpawnVehicle(lic.vehicle, lic.spawn, lic.heading, function(veh)
            if not veh or veh == 0 then
                return
            end

            testVehicle = veh
            SetVehicleNumberPlateText(veh, ('196IM%03d'):format(math.random(1, 999)))
            SetVehicleFuelLevel(veh, 100.0)
            SetVehicleEngineOn(veh, true, true, false)
            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        end)

        local blip = AddBlipForCoord(lic.target.x, lic.target.y, lic.target.z)
        SetBlipSprite(blip, 225)
        SetBlipColour(blip, 5)
        SetBlipRoute(blip, true)
        SetBlipScale(blip, 1.0)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(('İmtahan: %s'):format(lic.targetLabel))
        EndTextCommandSetBlipName(blip)

        activeTest = {
            type = lic.type,
            label = lic.label,
            target = lic.target,
            radius = lic.targetRadius,
            blip = blip,
            deadline = GetGameTimer() + (lic.timeLimit * 1000),
        }

        Notify(('~y~%s~s~ imtahanı başladı!\nHədəf: ~b~%s~s~\nVaxt: %s saniyə'):format(
            lic.label, lic.targetLabel, lic.timeLimit), 'info', 10000)
    end, lic.type)
end

local function FinishTest()
    if not activeTest then
        return
    end

    ESX.Progressbar('Nəticə yoxlanılır...', 5000, {
        FreezePlayer = true,
        animation = { type = 'Scenario', Scenario = 'WORLD_HUMAN_CLIPBOARD' },
        onFinish = function()
            local t = activeTest.type

            ESX.TriggerServerCallback('196rp_licenses:finishTest', function(ok, msg)
                Notify(msg, ok and 'success' or 'error', 8000)
                if ok then
                    EndTest(nil)
                end
            end, t)
        end,
        onCancel = function()
            Notify('İmtahan yarımçıq dayandırıldı.', 'info')
        end,
    })
end

-- ==================== MENYU ====================

local function OpenMenu()
    ESX.TriggerServerCallback('196rp_licenses:getStatus', function(list)
        local elements = {}

        for i = 1, #list do
            local row = list[i]
            local label

            if row.owned then
                label = ('%s — ~g~VAR~s~'):format(row.label)
            elseif not row.canTake then
                label = ('%s — ~r~%s tələb olunur~s~'):format(row.label, row.requiresLabel or 'başqa vəsiqə')
            else
                label = ('%s — ~y~%s$~s~'):format(row.label, row.price)
            end

            elements[#elements + 1] = { label = label, value = row.type, disabled = row.owned or not row.canTake }
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'license_menu', {
            title = Config.DMV.label,
            align = 'top-left',
            elements = elements,
        }, function(data, menu)
            local licType = data.current.value
            local lic = Config.GetLicense(licType)

            if not lic then
                return
            end

            if activeTest then
                Notify('Artıq imtahandasınız! Əvvəlcə onu bitirin.', 'error')
                return
            end

            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'license_confirm', {
                title = ('%s imtahanına başlamaq üçün ~y~%s$~s~ ödəniləcək.\n(hə / yox)'):format(lic.label, lic.price)
            }, function(data2, menu2)
                menu2.close()
                menu.close()

                local val = string.lower(tostring(data2.value or ''))
                if val == 'hə' or val == 'he' then
                    StartTest(lic)
                end
            end)
        end, function(data, menu)
            menu.close()
        end)
    end)
end

-- ==================== DÖVRƏ ====================

CreateThread(function()
    local blip = AddBlipForCoord(Config.DMV.coords.x, Config.DMV.coords.y, Config.DMV.coords.z)
    SetBlipSprite(blip, Config.DMV.blip.sprite)
    SetBlipColour(blip, Config.DMV.blip.colour)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, Config.DMV.blip.scale)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('🎓 Əlavə vəsiqələr (moto, yük, təyyarə, qayıq)')
    EndTextCommandSetBlipName(blip)
end)

CreateThread(function()
    while true do
        local wait = 750
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        if not activeTest then
            local dist = #(coords - Config.DMV.coords)

            if dist < 30.0 then
                wait = 0
                DrawMarker(1, Config.DMV.coords.x, Config.DMV.coords.y, Config.DMV.coords.z - 1.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 0.5, 90, 160, 240, 120, false, true, 2, nil, nil, false)
            end

            if dist < Config.DMV.markerDist then
                ESX.TextUI('[E] — Əlavə vəsiqə imtahanları', 'info')
                if IsControlJustPressed(0, 38) then
                    ESX.HideUI()
                    OpenMenu()
                end
            else
                ESX.HideUI()
            end
        else
            wait = 0
            local targetDist = #(coords - activeTest.target)

            DrawMarker(1, activeTest.target.x, activeTest.target.y, activeTest.target.z - 1.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                activeTest.radius * 0.6, activeTest.radius * 0.6, 1.0, 90, 240, 120, 100, false, true, 2, nil, nil, false)

            if GetGameTimer() > activeTest.deadline then
                EndTest('~r~Vaxt bitdi!~s~ İmtahan uğursuz oldu.')
            elseif targetDist < activeTest.radius then
                ESX.TextUI('[E] — İmtahanı bitir', 'info')
                if IsControlJustPressed(0, 38) then
                    ESX.HideUI()
                    FinishTest()
                end
            else
                ESX.HideUI()
            end
        end

        Wait(wait)
    end
end)

-- ==================== ƏMRLƏR ====================

RegisterCommand('vesiqeler', function()
    ESX.TriggerServerCallback('196rp_licenses:getStatus', function(list)
        local msg = '🎓 VƏSİQƏLƏR:\n'

        for i = 1, #list do
            msg = msg .. ('• %s — %s\n'):format(list[i].label, list[i].owned and '~g~VAR~s~' or '~r~YOX~s~')
        end

        Notify(msg, 'info', 10000)
    end)
end, false)

RegisterCommand('imtahandayandır', function()
    if not activeTest then
        Notify('Aktiv imtahan yoxdur.', 'info', 4000)
        return
    end

    ESX.TriggerServerCallback('196rp_licenses:cancelTest', function()
        EndTest('İmtahan ləğv edildi. Ödəniş geri qaytarılmır.')
    end)
end, false)
