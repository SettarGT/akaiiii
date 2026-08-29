-- 196 RP | Admin əmrləri — server tərəfi
-- /goto /bring /tp2 /kick /setjob /heal /revive

local ESX = exports['es_extended']:getSharedObject()

local function IsAdmin(source)
    if source == 0 then
        return true
    end
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer ~= nil and xPlayer.getGroup() == 'admin'
end

local function Deny(source)
    TriggerClientEvent('chat:addMessage', source, {
        color = { 230, 80, 80 },
        multiline = true,
        args = { 'Admin', 'Bu əmrdən yalnız adminlər istifadə edə bilər!' }
    })
end

-- ==================== /goto — oyunçunun yanına get ====================

local function DoGoto(source, targetId)
    if not IsAdmin(source) then
        return Deny(source)
    end

    local target = tonumber(targetId)
    if not target then
        return
    end

    local ped = GetPlayerPed(target)
    if not ped or ped == 0 then
        return
    end

    local coords = GetEntityCoords(ped)
    TriggerClientEvent('196rp_admin:teleport', source, { x = coords.x, y = coords.y, z = coords.z }, GetEntityHeading(ped))
end

RegisterCommand('goto', function(source, args)
    DoGoto(source, args and args[1])
end, false)

RegisterNetEvent('196rp_admin:goto', function(target)
    DoGoto(source, target)
end)

-- ==================== /bring — oyunçunu yanına gətir ====================

local function DoBring(source, targetId)
    if not IsAdmin(source) then
        return Deny(source)
    end

    local target = tonumber(targetId)
    if not target then
        return
    end

    local adminPed = GetPlayerPed(source)
    if not adminPed or adminPed == 0 then
        return
    end

    local coords = GetEntityCoords(adminPed)
    TriggerClientEvent('196rp_admin:teleport', target, { x = coords.x + 1.5, y = coords.y, z = coords.z }, GetEntityHeading(adminPed))

    TriggerClientEvent('esx:showNotification', target, '~y~Admin sizi yanına gətirdi.~s~', 'info')
end

RegisterCommand('bring', function(source, args)
    DoBring(source, args and args[1])
end, false)

RegisterNetEvent('196rp_admin:bring', function(target)
    DoBring(source, target)
end)

-- ==================== /tp2 — özünü başqa oyunçunun yanına ====================

local function DoTp2(source, targetId)
    if not IsAdmin(source) then
        return Deny(source)
    end

    local target = tonumber(targetId)
    if not target then
        return
    end

    local ped = GetPlayerPed(target)
    if not ped or ped == 0 then
        return
    end

    local coords = GetEntityCoords(ped)
    TriggerClientEvent('196rp_admin:teleport', source, { x = coords.x - 1.5, y = coords.y, z = coords.z }, GetEntityHeading(ped))
end

RegisterCommand('tp2', function(source, args)
    DoTp2(source, args and args[1])
end, false)

RegisterNetEvent('196rp_admin:tp2', function(target)
    DoTp2(source, target)
end)

-- ==================== /coords — mövqeyi göstər ====================

RegisterCommand('coords', function(source)
    if not IsAdmin(source) then
        return Deny(source)
    end

    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then
        return
    end

    local c = GetEntityCoords(ped)
    TriggerClientEvent('chat:addMessage', source, {
        color = { 120, 200, 255 },
        multiline = true,
        args = { 'Coords', ('vector3(%.1f, %.1f, %.1f) heading %.1f'):format(c.x, c.y, c.z, GetEntityHeading(ped)) }
    })
end, false)

-- ==================== /setjob ====================

RegisterCommand('setjob', function(source, args)
    if not IsAdmin(source) then
        return Deny(source)
    end

    local target = tonumber(args and args[1])
    local jobName = args and args[2]
    local grade = tonumber(args and args[3]) or 0

    if not target or not jobName then
        TriggerClientEvent('chat:addMessage', source, {
            color = { 230, 80, 80 }, multiline = true,
            args = { 'Admin', 'İstifadə: /setjob [id] [iş adı] [rütbə]' }
        })
        return
    end

    local xTarget = ESX.GetPlayerFromId(target)
    if not xTarget then
        return
    end

    local exists = MySQL.scalar.await('SELECT COUNT(*) FROM `job_grades` WHERE `job_name` = ? AND `grade` = ?',
        { jobName, grade })

    if not exists or exists == 0 then
        TriggerClientEvent('chat:addMessage', source, {
            color = { 230, 80, 80 }, multiline = true,
            args = { 'Admin', ('%s işində %s rütbəsi yoxdur!'):format(jobName, grade) }
        })
        return
    end

    xTarget.setJob(jobName, grade)
    TriggerClientEvent('esx:showNotification', source,
        ('~g~%s oyunçusuna %s işi verildi.~s~'):format(target, jobName), 'success')
end, false)

-- ==================== /heal və /revive ====================

RegisterCommand('heal', function(source, args)
    if not IsAdmin(source) then
        return Deny(source)
    end

    local target = tonumber(args and args[1]) or source
    TriggerClientEvent('196rp_ems:healed', target)
end, false)

RegisterCommand('revive', function(source, args)
    if not IsAdmin(source) then
        return Deny(source)
    end

    local target = tonumber(args and args[1]) or source
    TriggerClientEvent('196rp_ems:revived', target)
end, false)

-- ==================== /kick ====================

RegisterCommand('kick', function(source, args)
    if not IsAdmin(source) then
        return Deny(source)
    end

    local target = tonumber(args and args[1])
    if not target then
        return
    end

    table.remove(args, 1)
    local reason = table.concat(args, ' ')
    if reason == '' then
        reason = 'Admin tərəfindən çıxarıldı'
    end

    DropPlayer(target, ('[196 RP] %s'):format(reason))
end, false)

-- ==================== /giveitem ====================

RegisterCommand('giveitem', function(source, args)
    if not IsAdmin(source) then
        return Deny(source)
    end

    local target = tonumber(args and args[1])
    local item = args and args[2]
    local count = tonumber(args and args[3]) or 1

    if not target or not item then
        return
    end

    local xTarget = ESX.GetPlayerFromId(target)
    if not xTarget then
        return
    end

    xTarget.addInventoryItem(item, count)
    TriggerClientEvent('esx:showNotification', source,
        ('~g~%s oyunçusuna %s x%s verildi.~s~'):format(target, item, count), 'success')
end, false)
