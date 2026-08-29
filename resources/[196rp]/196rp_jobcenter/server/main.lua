-- 196 RP | İş Mərkəzi — server tərəfi
-- İşə götürmə / işdən çıxma

local ESX = exports['es_extended']:getSharedObject()

local function FindPublic(name)
    for i = 1, #Config.PublicJobs do
        if Config.PublicJobs[i].name == name then
            return Config.PublicJobs[i]
        end
    end
    return nil
end

local function FindMunicipal(name)
    for i = 1, #Config.MunicipalJobs do
        if Config.MunicipalJobs[i].name == name then
            return Config.MunicipalJobs[i]
        end
    end
    return nil
end

-- Verilənlər bazasında iş və rütbə varmı?
local function JobExists(jobName)
    local count = MySQL.scalar.await('SELECT COUNT(*) FROM `jobs` WHERE `name` = ?', { jobName })
    if not count or count == 0 then
        return false
    end
    local grades = MySQL.scalar.await('SELECT COUNT(*) FROM `job_grades` WHERE `job_name` = ?', { jobName })
    return (grades or 0) > 0
end

-- ==================== İŞ SİYAHSI ====================

ESX.RegisterServerCallback('196rp_jobcenter:getJobs', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb({})
    end

    local list = {}

    for i = 1, #Config.PublicJobs do
        local j = Config.PublicJobs[i]
        if JobExists(j.name) then
            list[#list + 1] = {
                name = 'svc_' .. j.name,
                label = j.label,
                icon = j.icon,
                desc = j.desc,
                kind = 'service'
            }
        end
    end

    for i = 1, #Config.MunicipalJobs do
        local j = Config.MunicipalJobs[i]
        if JobExists(j.name) then
            list[#list + 1] = {
                name = 'mun_' .. j.name,
                label = j.label,
                icon = j.icon,
                desc = j.desc,
                kind = 'municipal'
            }
        end
    end

    cb(list)
end)

-- ==================== BƏLƏDDİYYƏ İŞİ ====================

ESX.RegisterServerCallback('196rp_jobcenter:hireMunicipal', function(source, cb, jobName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local j = FindMunicipal(jobName)
    if not j then
        return cb(false, 'Belə bir bələdiyyə işi yoxdur!')
    end

    if not JobExists(jobName) then
        return cb(false, 'Bu iş verilənlər bazasında qeydə alınmayıb (196rp.sql-i idxal edin).')
    end

    if xPlayer.job.name == jobName then
        return cb(false, 'Siz artıq bu işdə çalışırsınız!')
    end

    xPlayer.setJob(jobName, 0)
    cb(true, ('~g~Təbriklər!~s~ Siz artıq ~y~%s~s~ işindəsiniz.'):format(j.label))
end)

-- ==================== XİDMƏT İŞİ ====================

ESX.RegisterServerCallback('196rp_jobcenter:hireService', function(source, cb, jobName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local j = FindPublic(jobName)
    if not j then
        return cb(false, 'Belə bir xidmət işi yoxdur!')
    end

    if not JobExists(jobName) then
        return cb(false, 'Bu iş verilənlər bazasında qeydə alınmayıb (196rp.sql-i idxal edin).')
    end

    if xPlayer.job.name == jobName then
        return cb(false, 'Siz artıq bu işdə çalışırsınız!')
    end

    -- Polis/TİB üçün minimum rütbə yoxlaması
    if j.minGrade and xPlayer.job.grade < j.minGrade then
        return cb(false, 'Bu iş üçün rütbəniz kifayət etmir!')
    end

    xPlayer.setJob(jobName, 0)
    cb(true, ('~g~Təbriklər!~s~ Siz artıq ~y~%s~s~ işindəsiniz.'):format(j.label))
end)

-- ==================== İŞDƏN ÇIXMA ====================

ESX.RegisterServerCallback('196rp_jobcenter:quitJob', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    if xPlayer.job.name == 'unemployed' then
        return cb(false, 'Siz onsuz da işsizsiniz!')
    end

    xPlayer.setJob('unemployed', 0)
    cb(true, 'İşdən çıxdınız. İndi işsiz statusundasınız.')
end)
