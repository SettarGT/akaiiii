-- 196 RP | Polis — server tərəfi
-- Növbə, qandallar, cərimə, həbsxana, müsadirə, polis maşını

local ESX = exports['es_extended']:getSharedObject()

local onDuty = {}     -- [source] = true
local cuffed = {}     -- [source] = true
local jailed = {}     -- [source] = { releaseAt = os.time()+n, minutes = n }

local function IsPolice(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer and xPlayer.job.name == 'police'
end

local function IsOnDuty(source)
    return IsPolice(source) and onDuty[source] == true
end

local function Distance(a, b)
    if not a or not b then
        return math.huge
    end
    return #(GetEntityCoords(a) - GetEntityCoords(b))
end

-- ==================== NÖVBƏ ====================

ESX.RegisterServerCallback('196rp_police:toggleDuty', function(source, cb)
    if not IsPolice(source) then
        return cb(false, 'Siz polis işçisi deyilsiniz!')
    end

    onDuty[source] = not onDuty[source]
    TriggerClientEvent('196rp_police:setDuty', source, onDuty[source])

    if onDuty[source] then
        cb(true, '~g~Növbəyə başladınız!~s~ 196 Polis forması geyinildi.')
    else
        cb(true, '~r~Növbəni bitirdiniz.~s~')
    end
end)

-- ==================== QANDALLAR ====================

RegisterNetEvent('196rp_police:cuff', function(target)
    local src = source
    if not IsOnDuty(src) then
        TriggerClientEvent('esx:showNotification', src, 'Yalnız növbədə olan polis qandal vura bilər!', 'error')
        return
    end

    target = tonumber(target)
    local targetPed = target and GetPlayerPed(target)
    if not targetPed or targetPed == 0 then
        return
    end

    if Distance(GetPlayerPed(src), targetPed) > 4.0 then
        TriggerClientEvent('esx:showNotification', src, 'Oyunçuya çox uzaqsınız!', 'error')
        return
    end

    cuffed[target] = not cuffed[target]
    TriggerClientEvent('196rp_police:setCuffed', target, cuffed[target])

    TriggerClientEvent('esx:showNotification', target,
        cuffed[target] and '~r~Polis sizi qandalladı!~s~' or '~g~Qandallar açıldı.~s~',
        cuffed[target] and 'error' or 'success')
end)

-- ==================== CƏRİMƏ ====================

RegisterNetEvent('196rp_police:fine', function(target, amount)
    local src = source
    if not IsOnDuty(src) then
        TriggerClientEvent('esx:showNotification', src, 'Yalnız növbədə olan polis cərimə yaza bilər!', 'error')
        return
    end

    target = tonumber(target)
    amount = math.floor(tonumber(amount) or 0)

    if amount < 1 or amount > 25000 then
        TriggerClientEvent('esx:showNotification', src, 'Cərimə 1$ - 25.000$ arası ola bilər!', 'error')
        return
    end

    local xTarget = ESX.GetPlayerFromId(target)
    local xCop = ESX.GetPlayerFromId(src)
    if not xTarget or not xCop then
        return
    end

    if Distance(GetPlayerPed(src), GetPlayerPed(target)) > 8.0 then
        TriggerClientEvent('esx:showNotification', src, 'Oyunçuya çox uzaqsınız!', 'error')
        return
    end

    -- Əvvəl nağd, sonra bank
    local fromCash = math.min(xTarget.getMoney(), amount)
    if fromCash > 0 then
        xTarget.removeMoney(fromCash)
    end

    local remaining = amount - fromCash
    if remaining > 0 then
        local bank = xTarget.getAccount('bank')
        local fromBank = math.min(bank and bank.money or 0, remaining)
        if fromBank > 0 then
            xTarget.removeAccountMoney('bank', fromBank)
        end
        remaining = remaining - fromBank
    end

    local collected = amount - remaining

    -- Cərimənin yarısı polis cəmiyyətinə, yarısı məmura
    local officerShare = math.floor(collected / 2)
    xCop.addMoney(officerShare)

    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_police', function(account)
        if account then
            account.addMoney(collected - officerShare)
        end
    end)

    local copName = ('%s %s'):format(xCop.get('firstName') or '?', xCop.get('lastName') or '?')
    TriggerClientEvent('esx:showNotification', target,
        ('~r~Cərimə: %s$~s~\nSəbəb: yol hərəkəti qaydalarının pozulması\nMəmurl: %s'):format(collected, copName), 'error')
    TriggerClientEvent('esx:showNotification', src,
        ('~g~Cərimə yazıldı: %s$~s~ (sizin payınız: %s$)'):format(collected, officerShare), 'success')
end)

-- ==================== HƏBSXANA ====================

RegisterNetEvent('196rp_police:jail', function(target, minutes)
    local src = source
    if not IsOnDuty(src) then
        TriggerClientEvent('esx:showNotification', src, 'Yalnız növbədə olan polis həbs edə bilər!', 'error')
        return
    end

    target = tonumber(target)
    minutes = math.floor(tonumber(minutes) or 0)

    if minutes < 1 or minutes > 120 then
        TriggerClientEvent('esx:showNotification', src, 'Həbs müddəti 1-120 dəqiqə arası ola bilər!', 'error')
        return
    end

    local targetPed = target and GetPlayerPed(target)
    if not targetPed or targetPed == 0 then
        return
    end

    if Distance(GetPlayerPed(src), targetPed) > 6.0 then
        TriggerClientEvent('esx:showNotification', src, 'Oyunçuya çox uzaqsınız!', 'error')
        return
    end

    -- Qandalları aç, həbsxanaya göndər
    cuffed[target] = nil
    TriggerClientEvent('196rp_police:setCuffed', target, false)

    jailed[target] = { releaseAt = os.time() + (minutes * 60), minutes = minutes }
    TriggerClientEvent('196rp_police:jailed', target, minutes)
end)

-- Həbs müddətinin bitməsi
CreateThread(function()
    while true do
        Wait(5000)
        local now = os.time()
        for src, data in pairs(jailed) do
            if now >= data.releaseAt then
                jailed[src] = nil
                TriggerClientEvent('196rp_police:released', src)
            end
        end
    end
end)

-- ==================== MÜSAFİRƏ ====================

RegisterNetEvent('196rp_police:impound', function(plate)
    local src = source
    if not IsOnDuty(src) then
        TriggerClientEvent('esx:showNotification', src, 'Yalnız növbədə olan polis maşını müsadirə edə bilər!', 'error')
        return
    end

    if type(plate) ~= 'string' then
        return
    end

    local ok = exports['196rp_garage']:ImpoundVehicle(plate)
    if ok then
        TriggerClientEvent('esx:showNotification', src,
            ('~g~%s nömrəli maşın mühafizə meydançasına aparıldı.~s~'):format(plate), 'success')
    else
        TriggerClientEvent('esx:showNotification', src,
            'Bu maşın heç kimə məxsus deyil (şəxsi maşın deyil)!', 'error')
    end
end)

-- ==================== POLİS MAŞINI ====================

ESX.RegisterServerCallback('196rp_police:spawnVehicle', function(source, cb)
    if not IsOnDuty(source) then
        return cb(nil)
    end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)

    -- Ən yaxın stansiyanı tap
    local spawn, heading = nil, 0.0
    local best = math.huge
    for i = 1, #Config.Stations do
        local d = #(coords - Config.Stations[i].coords)
        if d < best then
            best = d
            spawn = Config.Stations[i].vehicleSpawn
            heading = Config.Stations[i].vehicleHeading or 0.0
        end
    end

    if not spawn or best > 60.0 then
        TriggerClientEvent('esx:showNotification', source, 'Polis maşını almaq üçün stansiyaya gedin!', 'error')
        return cb(nil)
    end

    local netId = exports['196rp_spawner']:SpawnVehicleAwait(source, {
        model = Config.PoliceVehicles[math.random(1, #Config.PoliceVehicles)],
        coords = { x = spawn.x, y = spawn.y, z = spawn.z },
        heading = heading,
        plate = ('196PD%02d'):format(math.random(0, 99)),
        owned = true,
    })

    if netId == 0 then
        return cb(nil)
    end

    cb(netId)
end)

-- ==================== DİGƏR RESURSLAR ÜÇÜN ====================

exports('IsPlayerOnDuty', function(source)
    return IsOnDuty(source)
end)

exports('IsPlayerCuffed', function(source)
    return cuffed[source] == true
end)

exports('IsPlayerJailed', function(source)
    return jailed[source] ~= nil
end)

-- Onlayn polislərin sayı
exports('GetCopCount', function()
    local n = 0
    for _, pid in pairs(ESX.GetPlayers()) do
        if IsOnDuty(pid) then
            n = n + 1
        end
    end
    return n
end)

-- ==================== TEMİZLİK ====================

AddEventHandler('playerDropped', function()
    local src = source
    onDuty[src] = nil
    cuffed[src] = nil
    jailed[src] = nil
end)
