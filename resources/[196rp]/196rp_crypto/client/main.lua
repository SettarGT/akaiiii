local QBCore = exports['qb-core']:GetCoreObject()
local cryOpen = false

local function OpenCrypto()
    cryOpen = true
    TriggerServerEvent('196rp_crypto:server:open')
end

RegisterNetEvent('196rp_crypto:client:open', function(data)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', data = data })
end)

RegisterNetEvent('196rp_crypto:client:refresh', function()
    TriggerServerEvent('196rp_crypto:server:open')
end)

RegisterNUICallback('buy', function(data, cb)
    TriggerServerEvent('196rp_crypto:server:buy', data.amount)
    cb({})
    return true
end)

RegisterNUICallback('sell', function(data, cb)
    TriggerServerEvent('196rp_crypto:server:sell', data.amount)
    cb({})
    return true
end)

RegisterNUICallback('close', function(_, cb)
    cryOpen = false
    SetNuiFocus(false, false)
    cb({})
    return true
end)

CreateThread(function()
    local loc = Config.Location
    local blip = AddBlipForCoord(loc.coords)
    SetBlipSprite(blip, 505)
    SetBlipColour(blip, 5)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(loc.label)
    EndTextCommandSetBlipName(blip)

    exports['qb-target']:AddBoxZone('196crypto', loc.coords, 3.0, 3.0, {
        name = '196crypto', heading = loc.heading, debugPoly = false,
        minZ = loc.coords.z - 1, maxZ = loc.coords.z + 3,
    }, { options = { { label = '[E] ' .. loc.label .. ' — Bazar', icon = 'fas fa-chart-line', action = OpenCrypto } } })
end)
