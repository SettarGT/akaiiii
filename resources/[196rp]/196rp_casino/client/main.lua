local QBCore = exports['qb-core']:GetCoreObject()
local casinoOpen = false

local function OpenCasino()
    casinoOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open' })
    TriggerServerEvent('196rp_casino:server:getBalance')
end

RegisterNetEvent('196rp_casino:client:balance', function(cash, chips)
    SendNUIMessage({ action = 'balance', cash = cash, chips = chips or 0 })
end)

RegisterNetEvent('196rp_casino:client:rouletteResult', function(data)
    SendNUIMessage({ action = 'rouletteResult', data = data })
end)
RegisterNetEvent('196rp_casino:client:diceResult', function(data)
    SendNUIMessage({ action = 'diceResult', data = data })
end)
RegisterNetEvent('196rp_casino:client:slotsResult', function(data)
    SendNUIMessage({ action = 'slotsResult', data = data })
end)
RegisterNetEvent('196rp_casino:client:blackjackState', function(data)
    SendNUIMessage({ action = 'blackjackState', data = data })
end)
RegisterNetEvent('196rp_casino:client:blackjackResult', function(data)
    SendNUIMessage({ action = 'blackjackResult', data = data })
end)

RegisterNUICallback('roulette', function(data, cb)
    TriggerServerEvent('196rp_casino:server:roulette', data.betType, data.betValue, data.amount)
    cb({})
    return true
end)
RegisterNUICallback('dice', function(data, cb)
    TriggerServerEvent('196rp_casino:server:dice', data.choice, data.amount)
    cb({})
    return true
end)
RegisterNUICallback('slots', function(data, cb)
    TriggerServerEvent('196rp_casino:server:slots', data.amount)
    cb({})
    return true
end)
RegisterNUICallback('blackjack', function(data, cb)
    if data.action == 'start' then
        TriggerServerEvent('196rp_casino:server:blackjackStart', data.amount)
    elseif data.action == 'hit' then
        TriggerServerEvent('196rp_casino:server:blackjackHit')
    elseif data.action == 'stand' then
        TriggerServerEvent('196rp_casino:server:blackjackStand')
    end
    cb({})
    return true
end)
RegisterNUICallback('buyChips', function(data, cb)
    TriggerServerEvent('196rp_casino:server:buyChips', data.amount)
    cb({})
    return true
end)
RegisterNUICallback('sellChips', function(data, cb)
    TriggerServerEvent('196rp_casino:server:sellChips', data.amount)
    cb({})
    return true
end)

RegisterNUICallback('getBalance', function(_, cb)
    TriggerServerEvent('196rp_casino:server:getBalance')
    cb({})
    return true
end)

RegisterNUICallback('close', function(_, cb)
    casinoOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    cb({})
    return true
end)

CreateThread(function()
    local loc = Config.Location
    local blip = AddBlipForCoord(loc.coords)
    SetBlipSprite(blip, 617)
    SetBlipColour(blip, 1)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(loc.label)
    EndTextCommandSetBlipName(blip)

    exports['qb-target']:AddBoxZone('196casino', loc.coords, 4.0, 4.0, {
        name = '196casino', heading = loc.heading, debugPoly = false,
        minZ = loc.coords.z - 1, maxZ = loc.coords.z + 4,
    }, { options = { { label = '[E] ' .. loc.label .. ' — Oyuna başla', icon = 'fas fa-dice', action = OpenCasino } } })
end)
