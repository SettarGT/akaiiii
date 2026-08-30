local QBCore = exports['qb-core']:GetCoreObject()
local open = false

RegisterCommand('twatter', function(_, args)
    TriggerServerEvent('196rp_social:server:post', 'twatter', table.concat(args, ' '))
end, false)

RegisterCommand('gram', function(_, args)
    TriggerServerEvent('196rp_social:server:post', 'gram', table.concat(args, ' '))
end, false)

RegisterCommand('social', function()
    open = not open
    if open then
        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'open' })
        TriggerServerEvent('196rp_social:server:get', 'twatter')
    else
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'hide' })
    end
end, false)

RegisterNetEvent('196rp_social:client:feed', function(app, feed)
    SendNUIMessage({ action = 'feed', app = app, feed = feed })
end)

RegisterNUICallback('switch', function(data, cb)
    TriggerServerEvent('196rp_social:server:get', data.app or 'twatter')
    cb({})
    return true
end)

RegisterNUICallback('like', function(data, cb)
    TriggerServerEvent('196rp_social:server:like', data.app, data.id)
    cb({})
    return true
end)

RegisterNUICallback('close', function(_, cb)
    open = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hide' })
    cb({})
    return true
end)
