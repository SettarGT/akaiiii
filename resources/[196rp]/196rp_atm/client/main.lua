local QBCore = exports['qb-core']:GetCoreObject()
local atmOpen = false

local function OpenATM()
    atmOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open' })
    TriggerServerEvent('196rp_atm:server:getBalance')
end

RegisterNetEvent('196rp_atm:client:balance', function(data)
    SendNUIMessage({ action = 'balance', data = data })
end)

RegisterNetEvent('196rp_atm:client:refresh', function()
    TriggerServerEvent('196rp_atm:server:getBalance')
end)

RegisterNUICallback('withdraw', function(data, cb)
    TriggerServerEvent('196rp_atm:server:withdraw', data.amount)
    cb({})
    return true
end)

RegisterNUICallback('deposit', function(data, cb)
    TriggerServerEvent('196rp_atm:server:deposit', data.amount)
    cb({})
    return true
end)

RegisterNUICallback('transfer', function(data, cb)
    TriggerServerEvent('196rp_atm:server:transfer', data.target, data.amount)
    cb({})
    return true
end)

RegisterNUICallback('close', function(_, cb)
    atmOpen = false
    SetNuiFocus(false, false)
    cb({})
    return true
end)

CreateThread(function()
    for i, loc in ipairs(Config.Locations) do
        local blip = AddBlipForCoord(loc.coords)
        SetBlipSprite(blip, 108)
        SetBlipColour(blip, 5)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(loc.label)
        EndTextCommandSetBlipName(blip)

        exports['qb-target']:AddBoxZone('196atm_' .. i, loc.coords, 2.0, 1.2, {
            name = '196atm_' .. i, heading = loc.heading, debugPoly = false,
            minZ = loc.coords.z - 1, maxZ = loc.coords.z + 2,
        }, { options = { { label = '[E] ' .. loc.label .. ' — Bankomat', icon = 'fas fa-money-bill-wave', action = OpenATM } } })
    end
end)
