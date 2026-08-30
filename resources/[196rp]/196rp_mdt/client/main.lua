local QBCore = exports['qb-core']:GetCoreObject()
local mdtOpen = false
local reqId = 0
local pending = {}

-- Kiçik RPC: client → server → client (callback qaytarır)
local function RPC(action, payload, cb)
    reqId = reqId + 1
    pending[reqId] = cb
    TriggerServerEvent('196rp_mdt:server:request', reqId, action, payload)
end

RegisterNetEvent('196rp_mdt:client:response', function(id, data)
    if pending[id] then
        pending[id](data)
        pending[id] = nil
    end
end)

-- F6 düyməsi ilə MDT aç
RegisterKeyMapping('mdt', 'MDT (Polis bazası)', 'keyboard', 'F6')
RegisterCommand('mdt', function()
    TriggerServerEvent('196rp_mdt:server:open')
end, false)

RegisterCommand('mdtqapat', function()
    if mdtOpen then
        mdtOpen = false
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'close' })
    end
end, false)

RegisterNetEvent('196rp_mdt:client:open', function()
    mdtOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open' })
end)

RegisterNUICallback('searchPlayer', function(data, cb)
    RPC('searchPlayer', { query = data.query or '' }, cb)
    return true
end)

RegisterNUICallback('searchVehicle', function(data, cb)
    RPC('searchVehicle', { query = data.query or '' }, cb)
    return true
end)

RegisterNUICallback('getRecords', function(data, cb)
    RPC('getRecords', { citizenid = data.citizenid or '' }, cb)
    return true
end)

RegisterNUICallback('addFine', function(data, cb)
    TriggerServerEvent('196rp_mdt:server:addFine', data.target, data.amount, data.reason)
    cb({ ok = true })
    return true
end)

RegisterNUICallback('addRecord', function(data, cb)
    TriggerServerEvent('196rp_mdt:server:addRecord', data.target, data.type, data.title, data.details)
    cb({ ok = true })
    return true
end)

RegisterNUICallback('close', function(_, cb)
    mdtOpen = false
    SetNuiFocus(false, false)
    cb({})
    return true
end)
