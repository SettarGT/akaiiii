local QBCore = exports['qb-core']:GetCoreObject()
local billOpen = false

RegisterNetEvent('196rp_billing:client:showBill', function(data)
    billOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'show', data = data })
end)

RegisterNUICallback('accept', function(data, cb)
    TriggerServerEvent('196rp_billing:server:accept', data.id)
    billOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hide', data = {} })
    cb({})
end)

RegisterNUICallback('decline', function(data, cb)
    TriggerServerEvent('196rp_billing:server:decline', data.id)
    billOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hide', data = {} })
    cb({})
end)

-- Bildiriş səsi
CreateThread(function()
    while true do
        if billOpen then
            PlaySoundFrontend(-1, 'Text_Arrive_Tone', 'GTAO_FM_Events_Soundset', true)
        end
        Wait(2000)
    end
end)
