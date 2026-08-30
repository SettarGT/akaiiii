local QBCore = exports['qb-core']:GetCoreObject()
local dealerOpen = false

local function GetList()
    local list = {}
    for _, v in ipairs(Config.Vehicles) do
        local base = QBCore.Shared.Vehicles[v.model]
        if base then
            list[#list + 1] = {
                model = v.model,
                label = base.name or v.label,
                brand = base.brand or '196',
                class = v.class,
                price = v.price,
            }
        end
    end
    return list
end

local function OpenDealer()
    dealerOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', vehicles = GetList() })
end

CreateThread(function()
    local loc = Config.Location
    local blip = AddBlipForCoord(loc.coords)
    SetBlipSprite(blip, 226)
    SetBlipColour(blip, 5)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(loc.label)
    EndTextCommandSetBlipName(blip)

    exports['qb-target']:AddBoxZone('196dealer', loc.coords, 4.0, 4.0, {
        name = '196dealer', heading = loc.heading, debugPoly = false,
        minZ = loc.coords.z - 1, maxZ = loc.coords.z + 4,
    }, { options = { { label = '[E] ' .. loc.label .. ' — Salona bax', icon = 'fas fa-car-side', action = OpenDealer } } })
end)

RegisterNUICallback('buy', function(data, cb)
    TriggerServerEvent('196rp_dealer:server:buy', data.model)
    cb({ ok = true })
    return true
end)

RegisterNUICallback('testdrive', function(data, cb)
    TriggerServerEvent('196rp_dealer:server:testdrive', data.model)
    dealerOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    cb({ ok = true })
    return true
end)

RegisterNUICallback('close', function(_, cb)
    dealerOpen = false
    SetNuiFocus(false, false)
    cb({})
    return true
end)

RegisterNetEvent('196rp_dealer:client:testdrive', function(model, plate, seconds)
    local ped = PlayerPedId()
    local coords = Config.Delivery[1].coords
    RequestModel(model)
    local t = 0
    while not HasModelLoaded(model) and t < 200 do Wait(20) t = t + 1 end
    if HasModelLoaded(model) then
        local veh = CreateVehicle(model, coords.x, coords.y, coords.z, 0.0, true, false)
        SetVehicleNumberPlateText(veh, plate)
        SetVehicleFuelLevel(veh, 100.0)
        SetEntityHeading(veh, 0.0)
        TaskWarpPedIntoVehicle(ped, veh, -1)
        SetTimeout(seconds * 1000, function()
            if DoesEntityExist(veh) then
                local driver = GetPedInVehicleSeat(veh, -1)
                if driver ~= 0 then
                    TaskLeaveVehicle(driver, veh, 0)
                end
                DeleteVehicle(veh)
            end
            TriggerEvent('QBCore:Notify', 'Sınaq sürüşü bitdi — avtomobil geri qaytarıldı.', 'primary')
        end)
    end
end)
