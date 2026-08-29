local blips = {}
local playerJob = nil

-- Oyuncunun işini izləyək (bəzi məkanlar yalnız müəyyən iş üçün görünə bilər)
RegisterNetEvent('esx:setPlayerData', function(key, val)
    if key == 'job' then
        playerJob = val
    end
end)

-- Blipləri yarat
CreateThread(function()
    for i = 1, #Config.Locations do
        local loc = Config.Locations[i]
        if loc.blip then
            local blip = AddBlipForCoord(loc.coords.x, loc.coords.y, loc.coords.z)
            SetBlipSprite(blip, loc.blip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, loc.blip.scale or 0.8)
            SetBlipColour(blip, loc.blip.color or 66)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(loc.name)
            EndTextCommandSetBlipName(blip)
            blips[i] = blip
        end
    end
end)

-- Markerlar və interaksiya
CreateThread(function()
    while true do
        local wait = 750
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local closest = nil
        local closestDist = 999.0

        for i = 1, #Config.Locations do
            local loc = Config.Locations[i]
            local dist = #(coords - loc.coords)

            if dist < 60.0 then
                wait = 0
                if loc.marker then
                    DrawMarker(loc.marker, loc.coords.x, loc.coords.y, loc.coords.z - 0.95, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                        loc.size or 1.0, loc.size or 1.0, 0.5, loc.color[1], loc.color[2], loc.color[3], 160, false, true, 2, nil, nil, false)
                end
            end

            if dist < (loc.size or 1.0) + 1.5 and dist < closestDist then
                closestDist = dist
                closest = loc
            end
        end

        if closest then
            ESX.TextUI(('[E] — ~y~%s~s~'):format(closest.name), 'info')
            if IsControlJustPressed(0, 38) then -- E düyməsi
                ESX.ShowNotification(('~y~%s~s~\n~w~%s'):format(closest.name, closest.desc), 'info', 8000, closest.name)
            end
        else
            ESX.HideUI()
        end

        Wait(wait)
    end
end)

-- Admin köməkçi komandası: /mekan <id> — həmin məkana teleport ol
RegisterCommand('mekan', function(_, args)
    if not IsAceAllowed('command.mekan') then
        ESX.ShowNotification('Buna icazəniz yoxdur!', 'error')
        return
    end

    if not args[1] then
        ESX.ShowNotification('İstifadə: /mekan <id> — məs: /mekan belediye_bina', 'error')
        return
    end

    for i = 1, #Config.Locations do
        local loc = Config.Locations[i]
        if loc.id == args[1] then
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            local entity = vehicle ~= 0 and vehicle or ped
            SetEntityCoords(entity, loc.coords.x, loc.coords.y, loc.coords.z, false, false, false, true)
            ESX.ShowNotification(('~y~%s~s~ məkanına teleport olundunuz!'):format(loc.name), 'success')
            return
        end
    end

    ESX.ShowNotification('Belə bir məkan tapılmadı!', 'error')
end, false)

-- /mekanlar — bütün məkanların siyahısı (chat-da)
RegisterCommand('mekanlar', function()
    local names = {}
    for i = 1, #Config.Locations do
        names[#names + 1] = ('[%s] %s'):format(Config.Locations[i].id, Config.Locations[i].name)
    end
    TriggerEvent('chat:addMessage', {
        color = { 245, 185, 66 },
        args = { '196 RP', ('Ümumi məkan sayı: %d\n%s'):format(#names, table.concat(names, ', ')) }
    })
end, false)
