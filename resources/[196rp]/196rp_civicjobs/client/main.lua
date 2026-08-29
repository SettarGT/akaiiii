-- 196 RP | Şəhər işləri — müştəri tərəfi
-- Marşrut işləri (pizza, kuryer, yük), sahə işləri (jurnalist, elektrik, santexnik, bağban),
-- sabit nöqtə işləri (yanacaqçı, rəqqasə, arıçı, əczaçı, həkim, stomatoloq, veterinar,
-- gözəllik, masaj, detallinq, əmlak agenti, bilet satıcısı)

local playerJob = nil
local activeRoute = nil     -- { job, label, coords, index }
local activeField = nil     -- { job, label, coords, index }
local routeBlip = nil
local fieldBlip = nil
local lastWork = {}         -- job → GetGameTimer()

-- ==================== KÖMƏKÇİLƏR ====================

local function Notify(msg, typ, len)
    ESX.ShowNotification(msg, typ or 'info', len or 6000)
end

local function SetRouteBlip(coords, text, sprite)
    if routeBlip then
        RemoveBlip(routeBlip)
    end

    routeBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(routeBlip, sprite or Config.RouteBlip.sprite)
    SetBlipColour(routeBlip, Config.RouteBlip.colour)
    SetBlipScale(routeBlip, Config.RouteBlip.scale)
    SetBlipRoute(routeBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandSetBlipName(routeBlip)
end

local function SetFieldBlip(coords, text)
    if fieldBlip then
        RemoveBlip(fieldBlip)
    end

    fieldBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(fieldBlip, Config.RouteBlip.sprite)
    SetBlipColour(fieldBlip, Config.RouteBlip.colour)
    SetBlipScale(fieldBlip, Config.RouteBlip.scale)
    SetBlipRoute(fieldBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandSetBlipName(fieldBlip)
end

local function JobCooldown(job)
    if not lastWork[job] then
        return false
    end
    return (GetGameTimer() - lastWork[job]) < 3000
end

-- ==================== OYUNÇU MƏLUMATI ====================

CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Wait(250)
    end

    local data = ESX.GetPlayerData()
    playerJob = data.job and data.job.name or nil
end)

-- ==================== A) MARŞRUT İŞLƏRİ ====================

local function StartRoute(routeJob, routeIndex)
    ESX.TriggerServerCallback('196rp_civicjobs:startRoute', function(ok, order, msg)
        Notify(msg, ok and 'success' or 'error', 7000)

        if ok and order then
            activeRoute = {
                job = routeJob.job,
                label = order.label,
                coords = order.coords,
                index = routeIndex,
            }

            ESX.Game.SpawnVehicle(routeJob.vehicle, routeJob.spawn, routeJob.heading, function(veh)
                if not veh or veh == 0 then
                    return
                end

                SetVehicleNumberPlateText(veh, ('196%s%02d'):format(routeJob.platePrefix, math.random(1, 99)))
                SetVehicleFuelLevel(veh, 100.0)
                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
            end)

            SetRouteBlip(order.coords, ('Çatdırılma: %s'):format(order.label))
        end
    end, routeIndex)
end

local function FinishRoute()
    if not activeRoute then
        return
    end

    ESX.Progressbar('Sifariş çatdırılır...', 4000, {
        FreezePlayer = true,
        animation = { type = 'Scenario', Scenario = 'WORLD_HUMAN_CLIPBOARD' },
        onFinish = function()
            ESX.TriggerServerCallback('196rp_civicjobs:finishRoute', function(done, msg)
                Notify(msg, done and 'success' or 'error', 8000)

                if done then
                    if routeBlip then
                        RemoveBlip(routeBlip)
                        routeBlip = nil
                    end
                    activeRoute = nil
                end
            end, activeRoute.index)
        end,
        onCancel = function()
            Notify('Çatdırılma ləğv edildi.', 'info')
        end,
    })
end

-- ==================== B) SAHƏ İŞLƏRİ ====================

local function StartField(fieldJob, fieldIndex)
    ESX.TriggerServerCallback('196rp_civicjobs:startField', function(ok, assignment, msg)
        Notify(msg, ok and 'success' or 'error', 7000)

        if ok and assignment then
            activeField = {
                job = fieldJob.job,
                label = assignment.label,
                coords = assignment.coords,
                index = fieldIndex,
            }

            SetFieldBlip(assignment.coords, ('Tapşırıq: %s'):format(assignment.label))
        end
    end, fieldIndex)
end

local function FinishField(fieldJob)
    if not activeField then
        return
    end

    if JobCooldown(activeField.job) then
        Notify('Bir az gözləyin.', 'info', 3000)
        return
    end

    ESX.Progressbar(('%s...'):format(fieldJob.task), fieldJob.time, {
        FreezePlayer = true,
        animation = { type = 'Scenario', Scenario = fieldJob.scenario },
        onFinish = function()
            ESX.TriggerServerCallback('196rp_civicjobs:finishField', function(done, msg)
                Notify(msg, done and 'success' or 'error', 8000)

                if done then
                    lastWork[activeField.job] = GetGameTimer()
                    if fieldBlip then
                        RemoveBlip(fieldBlip)
                        fieldBlip = nil
                    end
                    activeField = nil
                end
            end, activeField.index)
        end,
        onCancel = function()
            Notify('İş yarımçıq qaldı.', 'info')
        end,
    })
end

-- ==================== C) SABİT NÖQTƏ İŞLƏRİ ====================

local function DoStation(station)
    if JobCooldown(station.job) then
        Notify('Bir az gözləyin.', 'info', 3000)
        return
    end

    ESX.Progressbar(('%s...'):format(station.task), station.time, {
        FreezePlayer = true,
        animation = { type = 'Scenario', Scenario = station.scenario },
        onFinish = function()
            ESX.TriggerServerCallback('196rp_civicjobs:doStation', function(ok, msg)
                Notify(msg, ok and 'success' or 'error', 7000)
                if ok then
                    lastWork[station.job] = GetGameTimer()
                end
            end, station.job)
        end,
        onCancel = function()
            Notify('Xidmət yarımçıq qaldı.', 'info')
        end,
    })
end

-- ==================== MARKER DÖVRƏSİ ====================

CreateThread(function()
    while true do
        local wait = 750
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local shown = false

        if playerJob then
            -- Marşrut işləri
            for i = 1, #Config.RouteJobs do
                local r = Config.RouteJobs[i]

                if r.job == playerJob then
                    local dist = #(coords - r.depot)

                    if dist < 40.0 then
                        wait = 0
                        DrawMarker(1, r.depot.x, r.depot.y, r.depot.z - 1.0, 0.0, 0.0, 0.0,
                            0.0, 0.0, 0.0, 2.0, 2.0, 0.6, 255, 200, 40, 120, false, true, 2, nil, nil, false)
                    end

                    if dist < Config.MarkerRadius and not activeRoute then
                        shown = true
                        ESX.TextUI(('[E] — %s %s: sifariş götür'):format(r.icon, r.label), 'info')
                        if IsControlJustPressed(0, 38) then
                            ESX.HideUI()
                            StartRoute(r, i)
                        end
                    end

                    if activeRoute and activeRoute.index == i then
                        local c = vector3(activeRoute.coords.x, activeRoute.coords.y, activeRoute.coords.z)
                        if #(coords - c) < Config.MarkerRadius then
                            shown = true
                            ESX.TextUI('[E] — Sifarişi çatdır', 'info')
                            if IsControlJustPressed(0, 38) then
                                ESX.HideUI()
                                FinishRoute()
                            end
                        end
                    end
                end
            end

            -- Sahə işləri
            for i = 1, #Config.FieldJobs do
                local f = Config.FieldJobs[i]

                if f.job == playerJob then
                    local dist = #(coords - f.depot)

                    if dist < 40.0 then
                        wait = 0
                        DrawMarker(1, f.depot.x, f.depot.y, f.depot.z - 1.0, 0.0, 0.0, 0.0,
                            0.0, 0.0, 0.0, 2.0, 2.0, 0.6, 120, 200, 255, 120, false, true, 2, nil, nil, false)
                    end

                    if dist < Config.MarkerRadius and not activeField then
                        shown = true
                        ESX.TextUI(('[E] — %s %s: tapşırıq götür'):format(f.icon, f.label), 'info')
                        if IsControlJustPressed(0, 38) then
                            ESX.HideUI()
                            StartField(f, i)
                        end
                    end

                    if activeField and activeField.index == i then
                        local c = vector3(activeField.coords.x, activeField.coords.y, activeField.coords.z)
                        if #(coords - c) < Config.MarkerRadius then
                            shown = true
                            ESX.TextUI(('[E] — %s'):format(f.task), 'info')
                            if IsControlJustPressed(0, 38) then
                                ESX.HideUI()
                                FinishField(f)
                            end
                        end
                    end
                end
            end

            -- Sabit nöqtə işləri
            for i = 1, #Config.StationJobs do
                local s = Config.StationJobs[i]

                if s.job == playerJob then
                    local dist = #(coords - s.coords)

                    if dist < 30.0 then
                        wait = 0
                        DrawMarker(1, s.coords.x, s.coords.y, s.coords.z - 1.0, 0.0, 0.0, 0.0,
                            0.0, 0.0, 0.0, 1.5, 1.5, 0.5, 120, 255, 160, 120, false, true, 2, nil, nil, false)
                    end

                    if dist < Config.MarkerRadius then
                        shown = true
                        ESX.TextUI(('[E] — %s %s (+%s$)'):format(s.icon, s.label, s.pay), 'info')
                        if IsControlJustPressed(0, 38) then
                            ESX.HideUI()
                            DoStation(s)
                        end
                    end
                end
            end
        end

        if not shown then
            ESX.HideUI()
        end

        Wait(wait)
    end
end)

-- ==================== BLİPLƏR ====================

local jobBlips = {}

local function ClearJobBlips()
    for i = 1, #jobBlips do
        RemoveBlip(jobBlips[i])
    end
    jobBlips = {}
end

local function AddJobBlip(coords, text)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, Config.Blip.sprite)
    SetBlipColour(blip, Config.Blip.colour)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, Config.Blip.scale)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandSetBlipName(blip)
    jobBlips[#jobBlips + 1] = blip
end

local function RefreshJobBlips()
    ClearJobBlips()

    if not playerJob then
        return
    end

    for i = 1, #Config.RouteJobs do
        local r = Config.RouteJobs[i]
        if r.job == playerJob then
            AddJobBlip(r.depot, ('%s %s'):format(r.icon, r.label))
        end
    end

    for i = 1, #Config.FieldJobs do
        local f = Config.FieldJobs[i]
        if f.job == playerJob then
            AddJobBlip(f.depot, ('%s %s'):format(f.icon, f.label))
        end
    end

    for i = 1, #Config.StationJobs do
        local s = Config.StationJobs[i]
        if s.job == playerJob then
            AddJobBlip(s.coords, ('%s %s'):format(s.icon, s.label))
        end
    end
end

CreateThread(function()
    while not playerJob do
        Wait(500)
    end
    RefreshJobBlips()
end)

-- İş dəyişəndə: blipləri və aktiv tapşırıqları sıfırla
RegisterNetEvent('esx:setJob', function(job)
    playerJob = job and job.name or nil

    if routeBlip then
        RemoveBlip(routeBlip)
        routeBlip = nil
    end
    if fieldBlip then
        RemoveBlip(fieldBlip)
        fieldBlip = nil
    end
    activeRoute = nil
    activeField = nil

    RefreshJobBlips()
end)

-- Tapşırıq ləğv əmri
RegisterCommand('legvet', function()
    if activeRoute then
        ESX.TriggerServerCallback('196rp_civicjobs:cancelRoute', function()
            activeRoute = nil
            if routeBlip then
                RemoveBlip(routeBlip)
                routeBlip = nil
            end
            Notify('Sifariş ləğv edildi.', 'info', 4000)
        end)
        return
    end

    if activeField then
        ESX.TriggerServerCallback('196rp_civicjobs:cancelField', function()
            activeField = nil
            if fieldBlip then
                RemoveBlip(fieldBlip)
                fieldBlip = nil
            end
            Notify('Tapşırıq ləğv edildi.', 'info', 4000)
        end)
        return
    end

    Notify('Aktiv tapşırığınız yoxdur.', 'info', 4000)
end, false)
