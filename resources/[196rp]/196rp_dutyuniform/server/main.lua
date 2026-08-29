-- 196 RP | Dövlət formaları — server tərəfi
-- Yalnız dövlət işlərinin əməkdaşları forma geyinə bilər (metadata-də saxlanılır)

local ESX = exports['es_extended']:getSharedObject()

-- [source] = uniformIndex
local worn = {}

local function IsValidJob(jobName)
    return Config.Uniforms[jobName] ~= nil
end

-- ==================== FORMA GEYİN / ÇIXAR ====================

ESX.RegisterServerCallback('196rp_dutyuniform:setWorn', function(source, cb, uniformIndex)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false)
    end

    local jobName = xPlayer.job.name

    if not IsValidJob(jobName) then
        return cb(false)
    end

    -- Mülki geyimə keçid
    if uniformIndex == nil then
        worn[source] = nil
        xPlayer.setMeta('dutyUniform', nil)
        return cb(true)
    end

    uniformIndex = tonumber(uniformIndex)
    local uniforms = Config.Uniforms[jobName]
    local uniform = uniforms and uniforms[uniformIndex]

    if not uniform then
        return cb(false)
    end

    -- Rütbə yoxlaması
    if (uniform.grade or 0) > xPlayer.job.grade then
        TriggerClientEvent('esx:showNotification', source, Config.Messages.noGrade, 'error')
        return cb(false)
    end

    worn[source] = uniformIndex
    xPlayer.setMeta('dutyUniform', uniformIndex)

    cb(true)
end)

-- ==================== GİRİŞ ZAMANI BƏRPA ====================

AddEventHandler('esx:playerLoaded', function(source, xPlayer)
    Wait(3000)

    local uniformIndex = xPlayer.getMeta('dutyUniform')
    if not uniformIndex then
        return
    end

    -- İş dəyişibsə formanı sil
    if not IsValidJob(xPlayer.job.name) then
        xPlayer.setMeta('dutyUniform', nil)
        return
    end

    local uniforms = Config.Uniforms[xPlayer.job.name]
    if not uniforms or not uniforms[tonumber(uniformIndex)] then
        xPlayer.setMeta('dutyUniform', nil)
        return
    end

    worn[source] = tonumber(uniformIndex)
    TriggerClientEvent('196rp_dutyuniform:restore', source, tonumber(uniformIndex))
end)

-- ==================== İŞ DƏYİŞƏNDƏ FORMA ÇIXIR ====================

AddEventHandler('esx:setJob', function(source, job)
    if not worn[source] then
        return
    end

    if not IsValidJob(job and job.name or '') then
        worn[source] = nil
        TriggerClientEvent('196rp_dutyuniform:forceUndress', source)

        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.setMeta('dutyUniform', nil)
        end
    end
end)

-- ==================== DİGƏR RESURSLAR ÜÇÜN ====================

exports('IsWearingUniform', function(source)
    return worn[source] ~= nil
end)

exports('UndressPlayer', function(source)
    if worn[source] then
        worn[source] = nil
        TriggerClientEvent('196rp_dutyuniform:forceUndress', source)

        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.setMeta('dutyUniform', nil)
        end
    end
end)

AddEventHandler('playerDropped', function()
    worn[source] = nil
end)
