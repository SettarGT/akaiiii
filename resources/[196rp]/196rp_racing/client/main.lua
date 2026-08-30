local QBCore = exports['qb-core']:GetCoreObject()
local racing = false
local leagueOpen = false

-- ── Başlanğıc menyusu ──
local function OpenStartMenu()
    local menu = { { header = '🏁 196 Yarış Liqası', isMenuHeader = true, icon = 'fas fa-flag-checkered' } }
    for _, t in ipairs(Config.Tracks) do
        menu[#menu + 1] = {
            header = t.label,
            txt = string.format('%s — giriş ₣%d', t.desc, t.entryFee),
            icon = 'fas fa-route',
            params = { track = t.id },
        }
    end
    exports['qb-menu']:openMenu(menu, function(selected)
        if selected and selected.params and selected.params.track then
            TriggerServerEvent('196rp_racing:server:start', selected.params.track)
        end
    end)
end

-- ── Yarış: nəzarət nöqtələri ──
RegisterNetEvent('196rp_racing:client:startRace', function(track)
    if racing then return end
    racing = true
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        local driver = GetPedInVehicleSeat(veh, -1)
        if driver ~= ped then
            QBCore.Functions.Notify('Sürücü oturacağında olmalısınız!', 'error')
            racing = false
            return
        end
    else
        QBCore.Functions.Notify('Avtomobildə olmalısınız!', 'error')
        racing = false
        return
    end

    local next = 1
    local startMs = 0
    local finishMs = 0
    QBCore.Functions.Notify(('🏁 %s başladı! 1-ci nəzarət nöqtəsinə gedin.'):format(track.label), 'primary')

    CreateThread(function()
        while racing do
            local coords = GetEntityCoords(ped)
            local point = track.checkpoints[next]
            if point then
                DrawMarker(1, point.x, point.y, point.z - 1.2, 0, 0, 0, 0, 0, 0, 2.6, 2.6, 1.2, 247, 183, 51, 190, false, true, 2, false, nil, nil, false)
                DrawText3D(point.x, point.y, point.z + 0.4, ('NÖQTƏ %d/%d'):format(next, #track.checkpoints))
                if #(coords - point) < Config.CheckpointRadius then
                    if next == 1 then
                        startMs = GetGameTimer()
                        QBCore.Functions.Notify('🏁 Vaxt başladı!', 'success')
                    end
                    next = next + 1
                    if next <= #track.checkpoints then
                        local p2 = track.checkpoints[next]
                        SetNewWaypoint(p2.x, p2.y)
                        QBCore.Functions.Notify(('✅ Nöqtə keçildi — növbəti: %d/%d'):format(next, #track.checkpoints), 'success')
                    end
                end
            else
                finishMs = GetGameTimer() - startMs
                racing = false
                SetNewWaypoint(0.0, 0.0)
                TriggerServerEvent('196rp_racing:server:finish', track.id, finishMs)
            end
            Wait(0)
        end
    end)
end)

function DrawText3D(x, y, z, text)
    SetTextScale(0.4, 0.4)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextCentre(true)
    SetTextColour(255, 217, 122, 220)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y, z)
end

-- ── Liqa NUI ──
RegisterCommand('liqa', function()
    TriggerServerEvent('196rp_racing:server:openLeague')
end, false)

RegisterNetEvent('196rp_racing:client:league', function(list)
    leagueOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', standings = list })
end)

RegisterNUICallback('close', function(_, cb)
    leagueOpen = false
    SetNuiFocus(false, false)
    cb({})
    return true
end)

-- ── Məkanlar ──
CreateThread(function()
    for _, t in ipairs(Config.Tracks) do
        local start = t.checkpoints[1]
        local blip = AddBlipForCoord(start)
        SetBlipSprite(blip, 1)
        SetBlipColour(blip, 5)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(t.label)
        EndTextCommandSetBlipName(blip)

        exports['qb-target']:AddBoxZone('196race_' .. t.id, start, 4.0, 4.0, {
            name = '196race_' .. t.id, heading = 0.0, debugPoly = false,
            minZ = start.z - 2, maxZ = start.z + 4,
        }, { options = { { label = '[E] ' .. t.label .. ' — Yarışa başla', icon = 'fas fa-flag-checkered', action = OpenStartMenu } } })
    end
end)
