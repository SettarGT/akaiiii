-- 196 RP | Şəhər işləri — server tərəfi
-- Marşrut, sahə və sabit nöqtə işlərinin yoxlanması, ödənişi və cooldown-u

local ESX = exports['es_extended']:getSharedObject()

local routes = {}      -- source → { index, job, label, coords, dist, startedAt }
local fields = {}      -- source → { index, job, label, coords, startedAt }
local cooldowns = {}   -- source → { [job] = os.time() }

-- ==================== KÖMƏKÇİLƏR ====================

local function Notify(src, msg, typ)
    TriggerClientEvent('esx:showNotification', src, msg, typ or 'info', 6000)
end

local function OnCooldown(src, job, seconds)
    local t = cooldowns[src]
    if not t or not t[job] then
        return false
    end

    local left = seconds - (os.time() - t[job])
    if left > 0 then
        Notify(src, ('~r~Gözləyin:~s~ %s saniyə'):format(left), 'error')
        return true
    end

    return false
end

local function SetCooldown(src, job)
    if not cooldowns[src] then
        cooldowns[src] = {}
    end
    cooldowns[src][job] = os.time()
end

local function GiveItem(xPlayer, item, count)
    if not item or not count or count < 1 then
        return true
    end

    if not xPlayer.canCarryItem(item, count) then
        Notify(xPlayer.source, '~r~Çantanızda yer yoxdur!~s~ Məhsul verilə bilmədi.', 'error')
        return false
    end

    xPlayer.addInventoryItem(item, count)
    return true
end

local function FindByName(list, jobName)
    for i = 1, #list do
        if list[i].job == jobName then
            return list[i], i
        end
    end
    return nil
end

-- ==================== ÇIXIŞ ====================

AddEventHandler('playerDropped', function()
    local src = source
    routes[src] = nil
    fields[src] = nil
    cooldowns[src] = nil
end)

-- ==================== A) MARŞRUT İŞLƏRİ ====================

ESX.RegisterServerCallback('196rp_civicjobs:startRoute', function(source, cb, routeIndex)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, nil, 'Xəta baş verdi!')
    end

    local r = Config.RouteJobs[tonumber(routeIndex) or 0]
    if not r then
        return cb(false, nil, 'Belə bir iş yoxdur!')
    end

    if xPlayer.job.name ~= r.job then
        return cb(false, nil, 'Bu iş sizin ixtisasınız deyil!')
    end

    if routes[source] then
        return cb(false, nil, 'Sizdə artıq aktiv sifariş var! /legvet ilə ləğv edin.')
    end

    if OnCooldown(source, r.job, r.cooldown) then
        return cb(false, nil, 'Bir az gözləyin.')
    end

    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - r.depot) > 20.0 then
        return cb(false, nil, 'Depodan uzaqdasınız!')
    end

    local dest = r.destinations[math.random(1, #r.destinations)]
    local dist = #(dest.coords - r.depot)
    local now = os.time()

    routes[source] = {
        index = tonumber(routeIndex),
        job = r.job,
        label = dest.label,
        coords = { x = dest.coords.x, y = dest.coords.y, z = dest.coords.z },
        dist = dist,
        startedAt = now,
    }
    SetCooldown(source, r.job)

    cb(true, routes[source], ('~g~Sifariş:~s~ %s (%s m)'):format(dest.label, math.floor(dist)))
end)

ESX.RegisterServerCallback('196rp_civicjobs:finishRoute', function(source, cb, routeIndex)
    local xPlayer = ESX.GetPlayerFromId(source)
    local data = routes[source]

    if not xPlayer or not data then
        return cb(false, 'Aktiv sifariş yoxdur!')
    end

    if tonumber(routeIndex) ~= data.index then
        return cb(false, 'Sifariş uyğun gəlmir!')
    end

    local r = Config.RouteJobs[data.index]
    if not r then
        routes[source] = nil
        return cb(false, 'İş konfiqurasiyası tapılmadı!')
    end

    if os.time() - data.startedAt > r.timeout then
        routes[source] = nil
        return cb(false, '~r~Vaxt bitdi!~s~ Sifariş ləğv olundu.')
    end

    local ped = GetPlayerPed(source)
    local target = vector3(data.coords.x, data.coords.y, data.coords.z)
    if #(GetEntityCoords(ped) - target) > 15.0 then
        return cb(false, 'Çatdırılma ünvanından uzaqdasınız!')
    end

    local pay = math.floor(r.basePay + (data.dist / 1000) * r.payPerKm)
    local tip = 0

    if r.tipChance and math.random(1, 100) <= r.tipChance then
        tip = r.tipAmount or 0
    end

    xPlayer.addAccountMoney('bank', pay + tip)
    routes[source] = nil
    SetCooldown(source, r.job)

    cb(true, ('~g~%s tamamlandı!~s~ Ödəniş: ~y~%s$~s~%s'):format(
        r.label, pay, tip > 0 and (' + məsləhət ~y~%s$~s~'):format(tip) or ''))
end)

ESX.RegisterServerCallback('196rp_civicjobs:cancelRoute', function(source, cb)
    routes[source] = nil
    cb(true)
end)

-- ==================== B) SAHƏ İŞLƏRİ ====================

ESX.RegisterServerCallback('196rp_civicjobs:startField', function(source, cb, fieldIndex)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, nil, 'Xəta baş verdi!')
    end

    local f = Config.FieldJobs[tonumber(fieldIndex) or 0]
    if not f then
        return cb(false, nil, 'Belə bir iş yoxdur!')
    end

    if xPlayer.job.name ~= f.job then
        return cb(false, nil, 'Bu iş sizin ixtisasınız deyil!')
    end

    if fields[source] then
        return cb(false, nil, 'Sizdə artıq aktiv tapşırıq var! /legvet ilə ləğv edin.')
    end

    if OnCooldown(source, f.job, f.cooldown) then
        return cb(false, nil, 'Bir az gözləyin.')
    end

    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - f.depot) > 20.0 then
        return cb(false, nil, 'İş mərkəzindən uzaqdasınız!')
    end

    local loc = f.locations[math.random(1, #f.locations)]

    fields[source] = {
        index = tonumber(fieldIndex),
        job = f.job,
        label = loc.label,
        coords = { x = loc.coords.x, y = loc.coords.y, z = loc.coords.z },
        startedAt = os.time(),
    }

    cb(true, fields[source], ('~g~Tapşırıq:~s~ %s'):format(loc.label))
end)

ESX.RegisterServerCallback('196rp_civicjobs:finishField', function(source, cb, fieldIndex)
    local xPlayer = ESX.GetPlayerFromId(source)
    local data = fields[source]

    if not xPlayer or not data then
        return cb(false, 'Aktiv tapşırıq yoxdur!')
    end

    if tonumber(fieldIndex) ~= data.index then
        return cb(false, 'Tapşırıq uyğun gəlmir!')
    end

    local f = Config.FieldJobs[data.index]
    if not f then
        fields[source] = nil
        return cb(false, 'İş konfiqurasiyası tapılmadı!')
    end

    local ped = GetPlayerPed(source)
    local target = vector3(data.coords.x, data.coords.y, data.coords.z)
    if #(GetEntityCoords(ped) - target) > 15.0 then
        return cb(false, 'Tapşırıq yerindən uzaqdasınız!')
    end

    GiveItem(xPlayer, f.giveItem, f.giveCount)
    xPlayer.addAccountMoney('bank', f.pay)

    fields[source] = nil
    SetCooldown(source, f.job)

    cb(true, ('~g~%s tamamlandı!~s~ Ödəniş: ~y~%s$~s~%s'):format(
        f.label, f.pay, f.giveItem and (' + %sx%s'):format(f.giveCount, f.giveItem) or ''))
end)

ESX.RegisterServerCallback('196rp_civicjobs:cancelField', function(source, cb)
    fields[source] = nil
    cb(true)
end)

-- ==================== C) SABİT NÖQTƏ İŞLƏRİ ====================

ESX.RegisterServerCallback('196rp_civicjobs:doStation', function(source, cb, jobName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local s = FindByName(Config.StationJobs, tostring(jobName or ''))
    if not s then
        return cb(false, 'Belə bir iş nöqtəsi yoxdur!')
    end

    if xPlayer.job.name ~= s.job then
        return cb(false, 'Bu iş sizin ixtisasınız deyil!')
    end

    if OnCooldown(source, s.job, s.cooldown) then
        return cb(false, 'Bir az gözləyin.')
    end

    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - s.coords) > 8.0 then
        return cb(false, 'İş nöqtəsindən uzaqdasınız!')
    end

    GiveItem(xPlayer, s.giveItem, s.giveCount)
    GiveItem(xPlayer, s.giveItem2, s.giveCount2)

    local pay = s.pay
    local tip = 0

    if s.tipChance and math.random(1, 100) <= s.tipChance then
        tip = s.tipAmount or 0
    end

    xPlayer.addAccountMoney('bank', pay + tip)
    SetCooldown(source, s.job)

    cb(true, ('~g~Xidmət göstərildi!~s~ Ödəniş: ~y~%s$~s~%s'):format(
        pay, tip > 0 and (' + məsləhət ~y~%s$~s~'):format(tip) or ''))
end)

-- ==================== DİGƏR RESURSLAR ÜÇÜN ====================

exports('GetActiveTask', function(source)
    return routes[source] or fields[source] or nil
end)
