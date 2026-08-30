local QBCore = exports['qb-core']:GetCoreObject()
local hackOpen = false
local chance = 45

RegisterCommand('hack', function()
    TriggerServerEvent('196rp_cyber:server:startHack')
end, false)

RegisterNetEvent('196rp_cyber:client:startHack', function()
    TriggerServerEvent('196rp_cyber:server:getChance')
end)

RegisterNetEvent('196rp_cyber:client:chance', function(c)
    chance = c
    hackOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', chance = c })
end)

RegisterNUICallback('result', function(data, cb)
    TriggerServerEvent('196rp_cyber:server:hackResult', data.success == true)
    hackOpen = false
    SetNuiFocus(false, false)
    cb({})
    return true
end)

RegisterNUICallback('close', function(_, cb)
    hackOpen = false
    SetNuiFocus(false, false)
    cb({})
    return true
end)

-- DarkWeb kiosk
local function OpenDarkWeb()
    exports['qb-menu']:openMenu({
        { header = '🌐 DarkWeb', isMenuHeader = true, icon = 'fas fa-user-secret' },
        { header = '💻 Kiber dəst al', txt = string.format('₣%d — hack şansı +%d%%', Config.Hack.KitCost, Config.Hack.KitBonus), icon = 'fas fa-microchip', params = { act = 'kit' } },
        { header = '🕵️ Hack et', txt = '/hack əmri ilə istənilən yerdə', icon = 'fas fa-terminal', isDisabled = true },
    }, function(selected)
        if selected and selected.params and selected.params.act == 'kit' then
            TriggerServerEvent('196rp_cyber:server:buyKit')
        end
    end)
end

CreateThread(function()
    local loc = Config.DarkWeb
    local blip = AddBlipForCoord(loc.coords)
    SetBlipSprite(blip, 566)
    SetBlipColour(blip, 46)
    SetBlipScale(blip, 0.7)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(loc.label)
    EndTextCommandSetBlipName(blip)

    exports['qb-target']:AddBoxZone('196darkweb', loc.coords, 2.5, 2.5, {
        name = '196darkweb', heading = loc.heading, debugPoly = false,
        minZ = loc.coords.z - 1, maxZ = loc.coords.z + 2,
    }, { options = { { label = '[E] ' .. loc.label, icon = 'fas fa-user-secret', action = OpenDarkWeb } } })
end)
