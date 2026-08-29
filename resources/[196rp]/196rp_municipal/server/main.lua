-- 196 RP | Bələdiyyə işləri — server tərəfi
-- Günün saatına uyğun iş növü seçilir, yer təsadüfi təyin olunur

local ESX = exports['es_extended']:getSharedObject()

-- Hazırkı aktiv iş: { workId = n, location = n }
local active = nil
local activeUntil = 0

-- Günün saatına uyğun iş növünü seç
local function PickWorkTypeForHour(hour)
    local candidates = {}
    for i = 1, #Config.WorkTypes do
        local w = Config.WorkTypes[i]
        local from, to = w.hours[1], w.hours[2]
        local inRange
        if from <= to then
            inRange = hour >= from and hour <= to
        else
            inRange = hour >= from or hour <= to
        end
        if inRange then
            candidates[#candidates + 1] = i
        end
    end

    if #candidates == 0 then
        return math.random(1, #Config.WorkTypes)
    end

    return candidates[math.random(1, #candidates)]
end

local function StartEvent()
    local hour = GetClockHours()
    local workId = PickWorkTypeForHour(hour)
    local locId = math.random(1, #Config.Locations)

    active = { workId = workId, location = locId }
    activeUntil = os.time() + math.floor(Config.EventLifetime / 1000)

    local work = Config.WorkTypes[workId]
    local loc = Config.Locations[locId]

    TriggerClientEvent('196rp_municipal:sync', -1, active, activeUntil)

    -- Bütün onlayn oyunçulara şəhər elanı
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 190, 30 },
        multiline = true,
        args = { '196 Bələdiyyəsi', ('%s %s — %s ərazisində iş elan olunub. Kömək edən hər kəsə ödəniş: %s$')
            :format(work.icon, work.label, loc.label, work.pay) }
    })

    print(('[196rp_municipal] %s — %s (saat %02d:00)'):format(work.label, loc.label, hour))
end

-- Dövriyyə
CreateThread(function()
    Wait(20000)
    StartEvent()

    while true do
        Wait(Config.EventInterval)
        if #ESX.GetPlayers() > 0 then
            StartEvent()
        end
    end
end)

-- Yeni qoşulanlara hazırkı hadisəni göndər
AddEventHandler('esx:playerLoaded', function(source)
    if active and os.time() < activeUntil then
        TriggerClientEvent('196rp_municipal:sync', source, active, activeUntil)
    end
end)

-- ==================== İŞİN GÖRÜLMƏSİ ====================

ESX.RegisterServerCallback('196rp_municipal:doWork', function(source, cb, workId, locId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    if not active or os.time() >= activeUntil then
        return cb(false, 'Hazırda aktiv bələdiyyə işi yoxdur!')
    end

    if tonumber(workId) ~= active.workId or tonumber(locId) ~= active.location then
        return cb(false, 'Bu iş artıq bağlanıb!')
    end

    local work = Config.WorkTypes[active.workId]
    local loc = Config.Locations[active.location]

    -- İş tələbi
    if Config.RequireJob and xPlayer.job.name ~= Config.RequireJob then
        return cb(false, ('Bu iş yalnız %s əməkdaşları üçündür!'):format(Config.RequireJob))
    end

    -- Yerə yaxınlıq
    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - loc.coords) > 8.0 then
        return cb(false, 'İş yerinə yaxın deyilsiniz!')
    end

    -- Ödəniş
    xPlayer.addMoney(work.pay)

    -- İş bağlanır
    active = nil
    activeUntil = 0
    TriggerClientEvent('196rp_municipal:sync', -1, nil, 0)

    TriggerClientEvent('chat:addMessage', -1, {
        color = { 120, 220, 120 },
        multiline = true,
        args = { '196 Bələdiyyəsi', ('%s işi %s ərazisində tamamlandı. Şəhər sizə təşəkkür edir!')
            :format(work.label, loc.label) }
    })

    local msg = work.messages[math.random(1, #work.messages)]
    cb(true, ('~g~%s~s~ +%s$'):format(msg, work.pay))
end)

-- Hazırkı işi öyrənmək (digər resurslar üçün)
exports('GetActiveWork', function()
    if active and os.time() < activeUntil then
        return active
    end
    return nil
end)
