-- 196 RP | Dövlət qüvvələri (əlavə) — server tərəfi
-- Qərargah icazələri, radar, yol yoxlaması, K9, SWAT, helikopter, maaş artımı,
-- yanğınsöndürən dərəcələri, mülki müdafiə elanı

local ESX = exports['es_extended']:getSharedObject()

local lastRadar = {}      -- source → os.time()
local lastAlert = {}      -- source → os.time()

-- ==================== KÖMƏKÇİLƏR ====================

local function Notify(src, msg, typ)
    TriggerClientEvent('esx:showNotification', src, msg, typ or 'info', 6000)
end

local function IsJob(xPlayer, jobName, minGrade)
    if not xPlayer or not xPlayer.job then
        return false
    end

    if xPlayer.job.name ~= jobName then
        return false
    end

    return (xPlayer.job.grade or 0) >= (minGrade or 0)
end

local function JobName(xPlayer)
    return xPlayer and xPlayer.job and xPlayer.job.name or nil
end

-- ==================== 81. QƏRARGAH ====================

ESX.RegisterServerCallback('196rp_policeadv:armory', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not IsJob(xPlayer, Config.Jobs.police, Config.HQ.minGradeArmory) then
        return cb(false, 'Cəbhəxana üçün kifayət qədər rütbəniz yoxdur!')
    end

    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - Config.HQ.points.armory.coords) > 6.0 then
        return cb(false, 'Cəbhəxanadan uzaqdasınız!')
    end

    cb(true, '~g~Cəbhəxanadan silah və jilet götürüldü.~s~')
end)

ESX.RegisterServerCallback('196rp_policeadv:computerSearch', function(source, cb, query)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not IsJob(xPlayer, Config.Jobs.police, 0) then
        return cb(false, 'Bu sistem yalnız polis üçündür!')
    end

    query = tostring(query or ''):upper():gsub('%s+', '')

    if query == '' then
        return cb(false, 'Sorğu boş ola bilməz!')
    end

    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - Config.HQ.points.computer.coords) > 6.0 then
        return cb(false, 'Kompüterin yanında deyilsiniz!')
    end

    -- 1) Nömrə axtarışı
    local vehicle = MySQL.single.await(
        'SELECT `owner`, `plate` FROM `owned_vehicles` WHERE `plate` = ?', { query })

    if vehicle then
        local owner = MySQL.single.await(
            'SELECT `firstname`, `lastname` FROM `users` WHERE `identifier` = ?', { vehicle.owner })

        local stolen = 'xeyr'
        if GetResourceState('196rp_illegal') == 'started' and exports['196rp_illegal']:IsVehicleStolen(query) then
            stolen = '~r~BƏLİ — oğurlanmış~s~'
        end

        return cb(true, ('🚗 ~y~%s~s~\nSahib: %s %s\nOğurluq: %s'):format(
            vehicle.plate,
            owner and owner.firstname or '?', owner and owner.lastname or '?',
            stolen))
    end

    -- 2) Oğurlanmış maşın siyahısından axtarış
    local stolenRow = MySQL.single.await(
        'SELECT `model`, `recovered` FROM `196rp_stolen_vehicles` WHERE `plate` = ?', { query })

    if stolenRow then
        return cb(true, ('🚨 ~y~%s~s~ — OĞURLANMIŞ MAŞIN\nModel: %s\nQaytarılıb: %s'):format(
            query, stolenRow.model, stolenRow.recovered == 1 and 'bəli' or '~r~xeyr~s~'))
    end

    -- 3) Server ID ilə şəxs axtarışı
    local targetId = tonumber(query)
    if targetId then
        local target = ESX.GetPlayerFromId(targetId)
        if target then
            local lics = MySQL.query.await(
                'SELECT `type` FROM `user_licenses` WHERE `owner` = ?', { target.identifier }) or {}
            local names = {}
            for i = 1, #lics do
                names[#names + 1] = lics[i].type
            end

            return cb(true, ('👤 ~y~%s~s~ (ID %s)\nİş: %s\nVəsiqələr: %s'):format(
                target.getName(), targetId,
                target.job and target.job.label or '?',
                #names > 0 and table.concat(names, ', ') or 'yoxdur'))
        end
    end

    cb(true, '❌ Sorğu üzrə heç bir nəticə tapılmadı.')
end)

-- ==================== 82. RADAR ====================

ESX.RegisterServerCallback('196rp_policeadv:radarCheck', function(source, cb, plate, speed)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not IsJob(xPlayer, Config.Jobs.police, 0) then
        return cb(false, 'Radar yalnız polis üçündür!')
    end

    local now = os.time()
    if lastRadar[source] and now - lastRadar[source] < Config.Radar.cooldown then
        return cb(false, 'Bir az gözləyin.')
    end
    lastRadar[source] = now

    plate = tostring(plate or ''):upper():gsub('%s+', '')
    speed = math.floor(tonumber(speed) or 0)

    local result = ('📡 ~y~%s~s~\nSürət: ~b~%s km/saat~s~'):format(plate, speed)

    if speed > Config.RoadPolice.speedWarn then
        result = result .. ('\n~r~Sürət həddi aşıldı!~s~')
    end

    local owner = MySQL.single.await(
        'SELECT `owner` FROM `owned_vehicles` WHERE `plate` = ?', { plate })

    if owner then
        local user = MySQL.single.await(
            'SELECT `firstname`, `lastname` FROM `users` WHERE `identifier` = ?', { owner.owner })
        result = result .. ('\nQeydiyyatda: ~g~bəli~s~ (%s %s)'):format(
            user and user.firstname or '?', user and user.lastname or '?')
    else
        result = result .. '\nQeydiyyatda: ~y~yoxdur~s~'
    end

    if GetResourceState('196rp_illegal') == 'started' and exports['196rp_illegal']:IsVehicleStolen(plate) then
        result = result .. '\n~r~🚨 OĞURLANMIŞ MAŞIN!~s~'
    else
        result = result .. '\nOğurluq: ~g~təmiz~s~'
    end

    cb(true, result)
end)

-- ==================== 83. YOL POLİSİ ====================

ESX.RegisterServerCallback('196rp_policeadv:checkDriver', function(source, cb, targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local target = ESX.GetPlayerFromId(tonumber(targetId) or 0)

    if not IsJob(xPlayer, Config.Jobs.police, 0) then
        return cb(false, 'Bu əmr yalnız polis üçündür!')
    end

    if not target then
        return cb(false, 'Şəxs tapılmadı!')
    end

    local lics = MySQL.query.await(
        'SELECT `type` FROM `user_licenses` WHERE `owner` = ?', { target.identifier }) or {}

    local have = {}
    for i = 1, #lics do
        have[lics[i].type] = true
    end

    local lines = {}
    for i = 1, #Config.RoadPolice.licenseTypes do
        local t = Config.RoadPolice.licenseTypes[i]
        lines[#lines + 1] = ('%s %s'):format(have[t] and '✅' or '❌', t)
    end

    cb(true, ('👮 ~y~%s~s~ (ID %s)\nİş: %s\n\nVƏSİQƏLƏR:\n%s'):format(
        target.getName(), target.source,
        target.job and target.job.label or '?',
        table.concat(lines, '\n')))
end)

-- ==================== 84. K9 ====================

ESX.RegisterServerCallback('196rp_policeadv:k9Search', function(source, cb, targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local target = ESX.GetPlayerFromId(tonumber(targetId) or 0)

    if not IsJob(xPlayer, Config.Jobs.police, Config.K9.minGrade) then
        return cb(false, 'K9 axtarışı üçün rütbəniz kifayət etmir!')
    end

    if not target then
        return cb(false, 'Şəxs tapılmadı!')
    end

    local found = {}

    for i = 1, #Config.K9.illegalItems do
        local item = Config.K9.illegalItems[i]
        local inv = target.getInventoryItem(item)
        if inv and inv.count > 0 then
            found[#found + 1] = ('%sx%s'):format(inv.count, item)
        end
    end

    if #found == 0 then
        return cb(true, ('🐕 İt ~y~%s~s~ adlı şəxsdə qadağan olunmuş əşya tapmadı.'):format(target.getName()))
    end

    cb(true, ('🐕🚨 İt aşkar etdi! ~y~%s~s~ üzərində: ~r~%s~s~'):format(
        target.getName(), table.concat(found, ', ')))
end)

-- ==================== 85. SWAT ====================

ESX.RegisterServerCallback('196rp_policeadv:swat', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not IsJob(xPlayer, Config.Jobs.police, Config.SWAT.minGrade) then
        return cb(false, 'SWAT üçün rütbəniz kifayət etmir!')
    end

    cb(true, '~g~SWAT təchizatı verildi.~s~')
end)

-- ==================== 87. TİB HELİKOPTERİ ====================

ESX.RegisterServerCallback('196rp_policeadv:spawnHelicopter', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not IsJob(xPlayer, Config.Jobs.ambulance, Config.AirAmbulance.minGrade) then
        return cb(false, 'Helikopter üçün rütbəniz kifayət etmir!')
    end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)

    if #(coords - Config.AirAmbulance.spawn) > 150.0 then
        return cb(false, 'Xəstəxana helikopter meydançasından uzaqdasınız!')
    end

    cb(true, '~g~TİB helikopteri hazırdır.~s~')
end)

-- ==================== 88. YANĞINSÖNDÜRƏN DƏRƏCƏLƏRİ ====================

ESX.RegisterServerCallback('196rp_policeadv:getRanks', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local lines = { '🚒 YANĞINSÖNDÜRƏN DƏRƏCƏLƏRİ:' }

    for i = 1, #Config.FireRanks do
        local r = Config.FireRanks[i]
        lines[#lines + 1] = ('%s %s — %s'):format(
            (xPlayer and xPlayer.job and xPlayer.job.name == Config.Jobs.firefighter
                and (xPlayer.job.grade or 0) == r.grade) and '➡️' or '•',
            r.label, table.concat(r.abilities, ', '))
    end

    cb(table.concat(lines, '\n'))
end)

-- ==================== 89. MÜLKİ MÜDAFİƏ ====================

ESX.RegisterServerCallback('196rp_policeadv:civilDefence', function(source, cb, message)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local job = JobName(xPlayer)
    local minGrade = Config.CivilDefence.minGrade[job]

    if not minGrade or (xPlayer.job.grade or 0) < minGrade then
        return cb(false, 'Fövqəladə elan üçün səlahiyyətiniz yoxdur!')
    end

    local now = os.time()
    if lastAlert[source] and now - lastAlert[source] < Config.CivilDefence.cooldown then
        return cb(false, ('Gözləyin: %s saniyə'):format(Config.CivilDefence.cooldown - (now - lastAlert[source])))
    end
    lastAlert[source] = now

    message = tostring(message or ''):sub(1, Config.CivilDefence.maxLength)

    TriggerClientEvent('196rp_policeadv:alert', -1, message, xPlayer.getName())

    cb(true, '~g~Mülki müdafiə xəbərdarlığı bütün şəhərə göndərildi.~s~')
end)

-- ==================== 86. MAAŞ ARTIMI ====================

local function TrackService(xPlayer)
    local job = JobName(xPlayer)
    if not job or job == 'unemployed' then
        return
    end

    local row = MySQL.single.await(
        'SELECT `job` FROM `196rp_service` WHERE `identifier` = ?', { xPlayer.identifier })

    if not row then
        MySQL.insert.await('INSERT INTO `196rp_service` (`identifier`, `job`, `started_at`) VALUES (?, ?, ?)',
            { xPlayer.identifier, job, os.time() })
    elseif row.job ~= job then
        MySQL.update.await('UPDATE `196rp_service` SET `job` = ?, `started_at` = ? WHERE `identifier` = ?',
            { job, os.time(), xPlayer.identifier })
    end
end

AddEventHandler('esx:playerLoaded', function(source, xPlayer)
    Wait(3000)
    TrackService(xPlayer)
end)

AddEventHandler('esx:setJob', function(source, job, lastJob)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        Wait(1000)
        TrackService(xPlayer)
    end
end)

CreateThread(function()
    Wait(20000)

    while true do
        Wait(Config.Salary.intervalMinutes * 60000)

        local rows = MySQL.query.await(
            'SELECT `identifier`, `job`, `started_at` FROM `196rp_service` WHERE `job` IS NOT NULL') or {}

        for i = 1, #rows do
            local xPlayer = ESX.GetPlayerFromIdentifier(rows[i].identifier)

            if xPlayer and JobName(xPlayer) == rows[i].job then
                local years = (os.time() - (rows[i].started_at or os.time())) / (365 * 24 * 3600)
                local mult = math.min(Config.Salary.maxBonusMult, years * Config.Salary.bonusPerYear)

                if mult > 0.005 then
                    local base = (xPlayer.job and xPlayer.job.grade_salary) or 0
                    local bonus = math.floor(base * mult)

                    if bonus > 0 then
                        xPlayer.addAccountMoney('bank', bonus)
                        Notify(xPlayer.source,
                            ('~g~Staj əlavəsi:~s~ +%s$ (%s il xidmət)'):format(bonus, math.floor(years)), 'success')
                    end
                end
            end
        end
    end
end)

-- ==================== ÇIXIŞ ====================

AddEventHandler('playerDropped', function()
    lastRadar[source] = nil
    lastAlert[source] = nil
end)

-- ==================== DİGƏR RESURSLAR ÜÇÜN ====================

exports('IsSwatOnDuty', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    return IsJob(xPlayer, Config.Jobs.police, Config.SWAT.minGrade)
end)
