local QBCore = exports['qb-core']:GetCoreObject()
local panelOpen = false

local function OpenPanel()
    panelOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open' })
    TriggerServerEvent('196rp_hybrid:server:status')
end

RegisterNetEvent('196rp_hybrid:client:status', function(list)
    SendNUIMessage({ action = 'status', list = list })
end)

RegisterNUICallback('close', function(_, cb)
    panelOpen = false
    SetNuiFocus(false, false)
    cb({})
    return true
end)

RegisterCommand('nobvet', function()
    OpenPanel()
end, false)

CreateThread(function()
    for _, panel in ipairs(Config.Panels) do
        exports['qb-target']:AddBoxZone('196panel_' .. panel.label, panel.coords, 2.2, 1.6, {
            name = '196panel_' .. panel.label, heading = panel.heading, debugPoly = false,
            minZ = panel.coords.z - 1, maxZ = panel.coords.z + 2,
        }, { options = { { label = '[E] ' .. panel.label, icon = 'fas fa-users', action = OpenPanel } } })
    end
end)
