-- ESX | Server-dən gələn entity hadisələri
-- Bu native-lər server tərəfdə mövcud deyil (client-only), ona görə server
-- hadisə göndərir və tətbiq hər oyunçunun öz client-ində baş verir.

RegisterNetEvent('esx:setEntityHeading', function(heading)
    SetEntityHeading(PlayerPedId(), tonumber(heading) or 0.0)
end)

RegisterNetEvent('esx:setPlateText', function(netId, plate)
    local veh = NetworkGetEntityFromNetworkId(tonumber(netId) or 0)
    if veh ~= 0 then
        SetVehicleNumberPlateText(veh, plate)
    end
end)

RegisterNetEvent('esx:warpIntoVehicle', function(netId, seat)
    local veh = NetworkGetEntityFromNetworkId(tonumber(netId) or 0)
    if veh == 0 then
        return
    end
    seat = tonumber(seat) or -1
    CreateThread(function()
        local tries = 0
        while GetVehiclePedIsIn(PlayerPedId(), false) ~= veh and tries < 50 do
            Wait(50)
            TaskWarpPedIntoVehicle(PlayerPedId(), veh, seat)
            tries = tries + 1
        end
    end)
end)
