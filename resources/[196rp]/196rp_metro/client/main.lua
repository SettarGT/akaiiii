local QBCore = exports['qb-core']:GetCoreObject()
local riding = false

local function GetStationById(id)
    for _, s in ipairs(Config.Stations) do
        if s.id == id then return s end
    end
end

local function NearestStation()
    local coords = GetEntityCoords(PlayerPedId())
    local best, bestD
    for _, s in ipairs(Config.Stations) do
        local d = #(coords - s.coords)
        if not bestD or d < bestD then
            best, bestD = s, d
        end
    end
    return best
end

local function OpenStation()
    local current = NearestStation()
    local menu = { { header = '🚇 ' .. current.label .. ' Stansiyası', isMenuHeader = true, icon = 'fas fa-train-subway' } }
    for _, s in ipairs(Config.Stations) do
        if s.id ~= current.id then
            menu[#menu + 1] = {
                header = s.label,
                txt = string.format('Bilet: ₣%d · ~%d saniyə gediş', Config.TicketPrice, Config.TravelTime),
                icon = 'fas fa-arrow-right',
                params = { target = s.id },
            }
        end
    end
    exports['qb-menu']:openMenu(menu, function(selected)
        if selected and selected.params and selected.params.target then
            TriggerServerEvent('196rp_metro:server:start', selected.params.target)
        end
    end)
end

-- ── Gediş (NUI) ──
RegisterNetEvent('196rp_metro:client:ride', function(targetId, targetLabel, seconds)
    riding = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'ride', id = targetId, label = targetLabel, seconds = seconds })
end)

-- ── Gəliş: teleport ──
RegisterNetEvent('196rp_metro:client:arrive', function(targetCoords, heading)
    riding = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'arrive' })
    DoScreenFadeOut(500)
    Wait(800)
    local ped = PlayerPedId()
    SetEntityCoords(ped, targetCoords.x, targetCoords.y, targetCoords.z)
    SetEntityHeading(ped, heading)
    SetPedCoordsKeepVehicle(ped, targetCoords.x, targetCoords.y, targetCoords.z)
    DoScreenFadeIn(800)
    QBCore.Functions.Notify('🚇 Xoş gəldiniz!', 'success')
end)

RegisterNUICallback('done', function(data, cb)
    TriggerServerEvent('196rp_metro:server:arrive', data.target or '')
    cb({})
    return true
end)

CreateThread(function()
    for _, s in ipairs(Config.Stations) do
        local blip = AddBlipForCoord(s.coords)
        SetBlipSprite(blip, 618)
        SetBlipColour(blip, 5)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName('Metro: ' .. s.label)
        EndTextCommandSetBlipName(blip)

        exports['qb-target']:AddBoxZone('196metro_' .. s.id, s.coords, 3.0, 3.0, {
            name = '196metro_' .. s.id, heading = s.heading, debugPoly = false,
            minZ = s.coords.z - 1, maxZ = s.coords.z + 3,
        }, { options = { { label = '[E] Metro — ' .. s.label, icon = 'fas fa-train-subway', action = OpenStation } } })
    end
end)
