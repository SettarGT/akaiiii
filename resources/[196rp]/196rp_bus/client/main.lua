-- 196 RP | Avtobus sistemi — müştəri tərəfi
-- Dayanacaqlar, avtobus tətbiqi (/avtobus), avtovağzal, taksi çağırışı

local taxiCallActive = false
local taxiCallEnds = 0

-- ==================== KÖMƏKÇİLƏR ====================

local function GetRoutesAtStop(stopCoords)
    local list = {}
    for i = 1, #Config.Routes do
        local route = Config.Routes[i]
        for j = 1, #route.stops do
            if #(route.stops[j].coords - stopCoords) < 20.0 then
                list[#list + 1] = route
                break
            end
        end
    end
    return list
end

local function TeleportTo(coords, heading)
    local ped = PlayerPedId()
    DoScreenFadeOut(600)
    Wait(650)

    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    if heading then
        SetEntityHeading(ped, heading)
    end

    local found, groundZ = GetGroundZFor_3DCoord(coords.x, coords.y, coords.z + 2.0, false)
    if found then
        SetEntityCoords(ped, coords.x, coords.y, groundZ, false, false, false, false)
    end

    Wait(400)
    DoScreenFadeIn(600)
end

-- ==================== BLİPLƏR ====================

CreateThread(function()
    -- Dayanacaq blipləri
    local added = {}
    for i = 1, #Config.Routes do
        local route = Config.Routes[i]
        for j = 1, #route.stops do
            local s = route.stops[j]
            local key = ('%.0f_%.0f'):format(s.coords.x, s.coords.y)
            if not added[key] then
                added[key] = true
                local blip = AddBlipForCoord(s.coords.x, s.coords.y, s.coords.z)
                SetBlipSprite(blip, 513)
                SetBlipColour(blip, route.blipColor)
                SetBlipScale(blip, 0.7)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentString(('Avtobus dayanacağı (marşrut %s)'):format(route.number))
                EndTextCommandSetBlipName(blip)
            end
        end
    end

    -- Avtovağzal blipi
    local t = Config.Terminal
    local tblip = AddBlipForCoord(t.coords.x, t.coords.y, t.coords.z)
    SetBlipSprite(tblip, 546)
    SetBlipColour(tblip, 5)
    SetBlipScale(tblip, 0.9)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(t.label)
    EndTextCommandSetBlipName(tblip)
end)

-- ==================== AVTOBUS TƏTBİQİ (/avtobus) ====================

local function OpenBusApp()
    local menu = {
        { icon = 'fas fa-bus', title = '🚌 196 Avtobus Tətbiqi', unselectable = true },
        { icon = 'fas fa-info-circle', title = 'Hansı nömrə hara gedir:', unselectable = true },
    }

    for i = 1, #Config.Routes do
        local route = Config.Routes[i]
        local path = {}
        for j = 1, #route.stops do
            path[#path + 1] = route.stops[j].label
        end

        menu[#menu + 1] = {
            icon = 'fas fa-route',
            title = ('~y~%s nömrə~s~ — %s'):format(route.number, route.name),
            description = table.concat(path, '  →  '),
            name = 'route_' .. i,
        }
    end

    exports['esx_context']:Open('right', menu, function(selected)
        local idx = tonumber(selected.name:match('^route_(%d+)$'))
        if not idx then
            return
        end

        local route = Config.Routes[idx]
        local stopsMenu = {
            { icon = 'fas fa-bus', title = ('%s nömrə — %s'):format(route.number, route.name), unselectable = true },
        }
        for j = 1, #route.stops do
            stopsMenu[#stopsMenu + 1] = {
                icon = 'fas fa-map-marker-alt',
                title = route.stops[j].label,
                name = 'stop_' .. j,
            }
        end

        exports['esx_context']:Open('right', stopsMenu, function(sel)
            local si = tonumber(sel.name:match('^stop_(%d+)$'))
            if si then
                ESX.ShowNotification(('Marşrut ~y~%s~s~: %s'):format(route.number, route.stops[si].label), 'info')
            end
        end)
    end)
end

RegisterCommand('avtobus', function()
    OpenBusApp()
end, false)

RegisterKeyMapping('avtobus', 'Avtobus tətbiqi', 'keyboard', '')

-- ==================== GEDİŞ (şəhərdaxili) ====================

local function RideRoute(route, stopIndex)
    local dest = route.stops[stopIndex]
    if not dest then
        return
    end

    ESX.TriggerServerCallback('196rp_bus:payFare', function(ok, msg)
        if not ok then
            ESX.ShowNotification(msg or 'Gediş haqqı ödənilmədi!', 'error')
            return
        end

        ESX.Progressbar(('Avtobus %s nömrə — %s'):format(route.number, dest.label), 6000, {
            FreezePlayer = true,
            animation = { type = 'Scenario', Scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
            onFinish = function()
                TeleportTo(dest.coords)
                ESX.ShowNotification(('~g~%s~s~ dayanacağına çatdınız. (Marşrut %s)')
                    :format(dest.label, route.number), 'success')
            end
        })
    end, 'city')
end

local function OpenStopMenu(stopCoords)
    local routes = GetRoutesAtStop(stopCoords)

    if #routes == 0 then
        ESX.ShowNotification('Buradan heç bir marşrut keçmir!', 'error')
        return
    end

    local menu = {
        { icon = 'fas fa-bus', title = ('🚌 Dayanacaq — gediş haqqı ~g~%s$~s~'):format(Config.CityFare), unselectable = true },
    }

    for i = 1, #routes do
        local r = routes[i]
        local last = r.stops[#r.stops].label
        menu[#menu + 1] = {
            icon = 'fas fa-bus-alt',
            title = ('~y~%s nömrə~s~ — %s'):format(r.number, r.name),
            description = ('Son dayanacaq: %s'):format(last),
            name = 'r_' .. i,
        }
    end

    exports['esx_context']:Open('right', menu, function(selected)
        local idx = tonumber(selected.name:match('^r_(%d+)$'))
        if not idx then
            return
        end

        local route = routes[idx]
        local stopsMenu = {
            { icon = 'fas fa-map-marker-alt', title = ('Haraya gedirsiniz? (%s nömrə)'):format(route.number), unselectable = true },
        }
        for j = 1, #route.stops do
            local d = #(route.stops[j].coords - stopCoords)
            if d > 20.0 then
                stopsMenu[#stopsMenu + 1] = {
                    icon = 'fas fa-location-arrow',
                    title = route.stops[j].label,
                    name = 'd_' .. j,
                }
            end
        end

        exports['esx_context']:Open('right', stopsMenu, function(sel)
            local si = tonumber(sel.name:match('^d_(%d+)$'))
            if si then
                RideRoute(route, si)
            end
        end)
    end)
end

-- ==================== AVTOVAĞZAL (şəhərlərarası) ====================

local function OpenTerminalMenu()
    local menu = {
        { icon = 'fas fa-bus', title = '🛫 196 Avtovağzal', unselectable = true },
    }

    for i = 1, #Config.Terminal.destinations do
        local d = Config.Terminal.destinations[i]
        menu[#menu + 1] = {
            icon = 'fas fa-globe',
            title = ('%s — ~g~%s$~s~'):format(d.label, d.price),
            name = 'dest_' .. i,
        }
    end

    exports['esx_context']:Open('right', menu, function(selected)
        local idx = tonumber(selected.name:match('^dest_(%d+)$'))
        if not idx then
            return
        end

        local dest = Config.Terminal.destinations[idx]

        ESX.TriggerServerCallback('196rp_bus:payIntercity', function(ok, msg)
            if not ok then
                ESX.ShowNotification(msg or 'Bilet alına bilmədi!', 'error')
                return
            end

            ESX.Progressbar(('Şəhərlərarası avtobus: %s'):format(dest.label), 8000, {
                FreezePlayer = true,
                animation = { type = 'Scenario', Scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
                onFinish = function()
                    TeleportTo(dest.coords)
                    ESX.ShowNotification(('~g~%s~s~ şəhərinə çatdınız!'):format(dest.label), 'success')
                end
            })
        end, dest.label, dest.price)
    end)
end

-- ==================== TAKSİ ÇAĞIRIŞI ====================

RegisterCommand('taksi', function()
    if taxiCallActive then
        ESX.ShowNotification('Taksi çağırışı artıq aktivdir!', 'error')
        return
    end

    ESX.TriggerServerCallback('196rp_bus:callTaxi', function(ok, msg)
        ESX.ShowNotification(msg, ok and 'success' or 'error')
        if ok then
            taxiCallActive = true
            taxiCallEnds = GetGameTimer() + (Config.Taxi.callDuration * 1000)
        end
    end)
end, false)

-- ==================== ƏSAS DÖVRƏ ====================

CreateThread(function()
    while true do
        local wait = 750
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        -- Dayanacaqlar
        for i = 1, #Config.Routes do
            local route = Config.Routes[i]
            for j = 1, #route.stops do
                local s = route.stops[j]
                local dist = #(coords - s.coords)

                if dist < 25.0 then
                    wait = 0
                    DrawMarker(1, s.coords.x, s.coords.y, s.coords.z - 1.0, 0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0, 1.4, 1.4, 0.5,
                        route.color.r, route.color.g, route.color.b, 110, false, true, 2, nil, nil, false)
                end

                if dist < 2.0 and not IsPedInAnyVehicle(ped, false) then
                    ESX.TextUI(('[E] — Dayanacaq (marşrut %s və digərləri)'):format(route.number), 'info')
                    if IsControlJustPressed(0, 38) then
                        ESX.HideUI()
                        OpenStopMenu(s.coords)
                    end
                end
            end
        end

        -- Avtovağzal
        local tDist = #(coords - Config.Terminal.coords)
        if tDist < 25.0 then
            wait = 0
            DrawMarker(21, Config.Terminal.coords.x, Config.Terminal.coords.y, Config.Terminal.coords.z - 0.5,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8, 0.8, 0.5, 255, 190, 30, 150, false, true, 2, nil, nil, false)
        end

        if tDist < 2.0 and not IsPedInAnyVehicle(ped, false) then
            ESX.TextUI('[E] — 196 Avtovağzal (şəhərlərarası)', 'info')
            if IsControlJustPressed(0, 38) then
                ESX.HideUI()
                OpenTerminalMenu()
            end
        end

        -- Taksi gözləyirsinizsə: yaxındakı oyunçu maşınına minmək
        if taxiCallActive then
            if GetGameTimer() > taxiCallEnds then
                taxiCallActive = false
                ESX.ShowNotification('Taksi çağırışı bitdi.', 'info')
            else
                local veh = ESX.Game.GetClosestVehicle(coords, 8.0)
                if veh and veh ~= 0 then
                    local driverPed = GetPedInVehicleSeat(veh, -1)
                    if driverPed ~= 0 and IsPedAPlayer(driverPed) then
                        local driverServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(driverPed))
                        ESX.TextUI('[E] — Taksidə otur')
                        if IsControlJustPressed(0, 38) then
                            ESX.HideUI()
                            ESX.TriggerServerCallback('196rp_bus:taxiBoard', function(ok, msg)
                                if ok then
                                    TaskWarpPedIntoVehicle(ped, veh, 0)
                                    taxiCallActive = false
                                end
                                ESX.ShowNotification(msg, ok and 'success' or 'error')
                            end, driverServerId)
                        end
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

-- Taksi sürücülərinə gələn çağırış üçün blip
RegisterNetEvent('196rp_bus:taxiCallBlip', function(callerId, coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 280)
    SetBlipColour(blip, 5)
    SetBlipScale(blip, 0.9)
    SetBlipFlashes(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(('Taksi çağırışı — ID %s'):format(callerId))
    EndTextCommandSetBlipName(blip)

    SetTimeout(Config.Taxi.callDuration * 1000, function()
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end)
end)
