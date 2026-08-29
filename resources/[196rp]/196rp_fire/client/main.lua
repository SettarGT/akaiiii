-- 196 RP | Yanğınsöndürən — müştəri tərəfi

local onDuty = false
local fireTruck = 0
local fires = {}          -- [id] = { x, y, z }
local fireBlips = {}
local fireFx = {}         -- [id] = partikül efekt handle

local function StartFireFx(fireId, f)
    if fireFx[fireId] then return end
    if not HasNamedPtfxAssetLoaded('core') then
        RequestNamedPtfxAsset('core')
        local tries = 0
        while not HasNamedPtfxAssetLoaded('core') and tries < 50 do
            Wait(10)
            tries = tries + 1
        end
    end
    SetUseParticleFxAssetNextCall('core')
    fireFx[fireId] = StartParticleFxLoopedAtCoord('ent_amb_fire', f.x, f.y, f.z + 0.3, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
end

local function StopFireFx(fireId)
    if fireFx[fireId] then
        StopParticleFxLooped(fireFx[fireId], false)
        fireFx[fireId] = nil
    end
end

-- Növbə + stansiya menyusu
CreateThread(function()
    while true do
        local wait = 750
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local dist = #(coords - Config.Station.coords)

        if dist < 50.0 then
            wait = 0
            DrawMarker(1, Config.Station.coords.x, Config.Station.coords.y, Config.Station.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                1.2, 1.2, 0.6, 230, 60, 60, 170, false, true, 2, nil, nil, false)
        end

        if dist < 2.5 and ESX.PlayerData.job and ESX.PlayerData.job.name == 'firefighter' then
            ESX.TextUI(onDuty and '[E] — Növbəni bitir' or '[E] — Növbəyə başla', 'info')
            if IsControlJustPressed(0, 38) then
                ESX.TriggerServerCallback('196rp_fire:toggleDuty', function(duty)
                    onDuty = duty
                    ESX.ShowNotification(duty and '~g~Növbəyə başladınız!~s~' or '~r~Növbəni bitirdiniz.~s~', duty and 'success' or 'info')
                    if not duty and DoesEntityExist(fireTruck) then
                        ESX.Game.DeleteVehicle(fireTruck)
                        fireTruck = 0
                    end
                end)
            end
        elseif dist < 4.0 and onDuty then
            ESX.TextUI('[E] — Yanğın maşını götür', 'info')
            if IsControlJustPressed(0, 38) then
                ESX.TriggerServerCallback('196rp_fire:spawnVehicle', function(ok, netId)
                    if ok and netId then
                        fireTruck = NetToVeh(netId)
                        ESX.ShowNotification('~r~Yanğın maşını hazırdır!~s~', 'success')
                    end
                end)
            end
        else
            ESX.HideUI()
        end

        Wait(wait)
    end
end)

-- Yeni yanğın
RegisterNetEvent('196rp_fire:newFire', function(fireId, coords)
    fires[fireId] = coords
    if fireBlips[fireId] then
        RemoveBlip(fireBlips[fireId])
    end
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 436)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, 1)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Yanğın!')
    EndTextCommandSetBlipName(blip)
    fireBlips[fireId] = blip
end)

-- Yanğın söndü
RegisterNetEvent('196rp_fire:fireExtinguished', function(fireId)
    StopFireFx(fireId)
    fires[fireId] = nil
    if fireBlips[fireId] then
        RemoveBlip(fireBlips[fireId])
        fireBlips[fireId] = nil
    end
end)

-- Növbədə olarkən aktiv yanğınları yüklə
CreateThread(function()
    while true do
        Wait(5000)
        if onDuty then
            ESX.TriggerServerCallback('196rp_fire:getFires', function(list)
                local seen = {}
                for i = 1, #list do
                    local f = list[i]
                    seen[f.id] = true
                    if not fires[f.id] then
                        TriggerEvent('196rp_fire:newFire', f.id, f.coords)
                    end
                end
                for id in pairs(fires) do
                    if not seen[id] then
                        TriggerEvent('196rp_fire:fireExtinguished', id)
                    end
                end
            end)
        end
    end
end)

-- Yanğın yeri: alov + söndürmə
CreateThread(function()
    while true do
        local wait = 750
        if onDuty then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local nearestId = nil
            local nearestDist = 15.0

            for id, f in pairs(fires) do
                local dist = #(coords - vector3(f.x, f.y, f.z))
                if dist < 40.0 then
                    wait = 0
                    StartFireFx(id, f)
                    DrawMarker(6, f.x, f.y, f.z - 0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.5, 2.5, 1.0, 255, 90, 0, 160, false, true, 2, nil, nil, false)
                else
                    StopFireFx(id)
                end
                if dist < nearestDist then
                    nearestDist = dist
                    nearestId = id
                end
            end

            if nearestId then
                ESX.TextUI('[E] — Yanğını söndür', 'info')
                if IsControlJustPressed(0, 38) then
                    ESX.Progressbar('🚒 Yanğını söndürürsünüz...', Config.ExtinguishTime, {
                        FreezePlayer = true,
                        onFinish = function()
                            ESX.TriggerServerCallback('196rp_fire:extinguish', function(ok)
                                if ok then
                                    ESX.ShowNotification('~g~Yanğın söndürüldü! +$' .. Config.PayPerFire .. '~s~', 'success')
                                else
                                    ESX.ShowNotification('Yanğın söndürülə bilmədi!', 'error')
                                end
                            end, nearestId)
                        end
                    })
                end
            end
        end
        Wait(wait)
    end
end)
