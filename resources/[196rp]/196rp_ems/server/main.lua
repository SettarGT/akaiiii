-- 196 RP | Təcili yardım (TİB) — server tərəfi
-- Ölüm vəziyyəti, canlandırma, müalicə, növbə, təcili yardım maşını

local ESX = exports['es_extended']:getSharedObject()

local onDuty = {}      -- [source] = true
local deadPlayers = {} -- [source] = { coords = vector3, time = os.time() }

local function IsEMS(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer and xPlayer.job.name == 'ambulance'
end

local function IsOnDuty(source)
    return IsEMS(source) and onDuty[source] == true
end

-- ==================== ÖLÜM VƏZİYYƏTİ ====================

RegisterNetEvent('196rp_ems:setDead', function(state)
    local src = source
    if state then
        local ped = GetPlayerPed(src)
        deadPlayers[src] = { coords = GetEntityCoords(ped), time = os.time() }
        TriggerClientEvent('chat:addMessage', -1, {
            color = { 200, 40, 40 },
            multiline = true,
            args = { 'TİB', 'Bir vətəndaş yaralandı! Növbədəki həkimlər xəritədə görsün.' }
        })
    else
        deadPlayers[src] = nil
    end
end)

-- Yaralıların siyahısı
ESX.RegisterServerCallback('196rp_ems:getDeadPlayers', function(source, cb)
    if not IsOnDuty(source) then
        return cb({})
    end

    local list = {}
    for src, data in pairs(deadPlayers) do
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            list[#list + 1] = {
                id = src,
                name = ('%s %s'):format(xPlayer.get('firstName') or '?', xPlayer.get('lastName') or '?'),
                coords = data.coords,
                waiting = os.time() - data.time
            }
        end
    end

    cb(list)
end)

-- ==================== CANLANDIRMA ====================

RegisterNetEvent('196rp_ems:revive', function(target)
    local src = source
    if not IsOnDuty(src) then
        TriggerClientEvent('esx:showNotification', src, 'Yalnız növbədəki həkim canlandıra bilər!', 'error')
        return
    end

    target = tonumber(target)
    local targetPed = target and GetPlayerPed(target)
    if not targetPed or targetPed == 0 then
        return
    end

    local dist = #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(targetPed))
    if dist > 5.0 then
        TriggerClientEvent('esx:showNotification', src, 'Xəstəyə çox uzaqsınız!', 'error')
        return
    end

    deadPlayers[target] = nil
    TriggerClientEvent('196rp_ems:revived', target)

    local xMedic = ESX.GetPlayerFromId(src)
    if xMedic then
        xMedic.addMoney(250)
        TriggerClientEvent('esx:showNotification', src,
            '~g~Xəstə canlandırıldı!~s~ +250$', 'success')
    end
end)

-- ==================== MÜALİCƏ ====================

RegisterNetEvent('196rp_ems:heal', function(target)
    local src = source
    if not IsOnDuty(src) then
        TriggerClientEvent('esx:showNotification', src, 'Yalnız növbədəki həkim müalicə edə bilər!', 'error')
        return
    end

    target = tonumber(target)
    local targetPed = target and GetPlayerPed(target)
    if not targetPed or targetPed == 0 then
        return
    end

    if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(targetPed)) > 5.0 then
        TriggerClientEvent('esx:showNotification', src, 'Xəstəyə çox uzaqsınız!', 'error')
        return
    end

    TriggerClientEvent('196rp_ems:healed', target)

    local xMedic = ESX.GetPlayerFromId(src)
    if xMedic then
        xMedic.addMoney(100)
    end
end)

-- ==================== NÖVBƏ ====================

ESX.RegisterServerCallback('196rp_ems:toggleDuty', function(source, cb)
    if not IsEMS(source) then
        return cb(false, 'Siz TİB işçisi deyilsiniz!')
    end

    onDuty[source] = not onDuty[source]
    TriggerClientEvent('196rp_ems:setDuty', source, onDuty[source])

    if onDuty[source] then
        cb(true, '~g~Növbəyə başladınız!~s~ 196 TİB forması geyinildi.')
    else
        cb(true, '~r~Növbəni bitirdiniz.~s~')
    end
end)

-- ==================== TƏCİLİ YARDIM MAŞINI ====================

ESX.RegisterServerCallback('196rp_ems:spawnVehicle', function(source, cb)
    if not IsOnDuty(source) then
        return cb(false, nil)
    end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)

    local spawn, heading = nil, 0.0
    local best = math.huge
    for i = 1, #Config.Hospitals do
        local d = #(coords - Config.Hospitals[i].coords)
        if d < best then
            best = d
            spawn = Config.Hospitals[i].vehicleSpawn
            heading = Config.Hospitals[i].vehicleHeading or 0.0
        end
    end

    if not spawn or best > 80.0 then
        TriggerClientEvent('esx:showNotification', source, 'Maşın almaq üçün xəstəxanaya gedin!', 'error')
        return cb(false, nil)
    end

    local netId = exports['196rp_spawner']:SpawnVehicleAwait(source, {
        model = 'ambulance',
        coords = { x = spawn.x, y = spawn.y, z = spawn.z },
        heading = heading,
        plate = ('196EMS%02d'):format(math.random(0, 99)),
    })

    if netId == 0 then
        return cb(false, nil)
    end

    cb(true, netId)
end)

-- ==================== DİGƏR RESURSLAR ÜÇÜN ====================

exports('IsPlayerOnDuty', function(source)
    return IsOnDuty(source)
end)

exports('GetMedicCount', function()
    local n = 0
    for _, pid in pairs(ESX.GetPlayers()) do
        if IsOnDuty(pid) then
            n = n + 1
        end
    end
    return n
end)

AddEventHandler('playerDropped', function()
    local src = source
    onDuty[src] = nil
    deadPlayers[src] = nil
end)
