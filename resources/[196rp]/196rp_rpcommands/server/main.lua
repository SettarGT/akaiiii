-- 196 RP | Rol-pley əmrləri — server tərəfi
-- /me /do /try /ooc /report /b

local ESX = exports['es_extended']:getSharedObject()

local function PlayerName(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        return ('ID %s'):format(src)
    end
    return ('%s %s'):format(xPlayer.get('firstName') or '?', xPlayer.get('lastName') or '?')
end

local function Nearby(src, radius)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then
        return { src }
    end

    local coords = GetEntityCoords(ped)
    local list = {}

    for _, pid in pairs(ESX.GetPlayers()) do
        local other = GetPlayerPed(pid)
        if other and other ~= 0 and #(GetEntityCoords(other) - coords) <= radius then
            list[#list + 1] = pid
        end
    end

    return list
end

-- ==================== /me — hərəkət ====================

RegisterCommand('me', function(source, args)
    if source == 0 or #args == 0 then
        return
    end

    local text = table.concat(args, ' ')
    for _, pid in pairs(Nearby(source, 20.0)) do
        TriggerClientEvent('chat:addMessage', pid, {
            color = { 200, 140, 255 },
            multiline = true,
            args = { ('%s (ID %s)'):format(PlayerName(source), source), text }
        })
    end
end, false)

-- ==================== /do — vəziyyət təsviri ====================

RegisterCommand('do', function(source, args)
    if source == 0 or #args == 0 then
        return
    end

    local text = table.concat(args, ' ')
    for _, pid in pairs(Nearby(source, 20.0)) do
        TriggerClientEvent('chat:addMessage', pid, {
            color = { 130, 180, 255 },
            multiline = true,
            args = { 'DO', ('%s ((%s))'):format(text, PlayerName(source)) }
        })
    end
end, false)

-- ==================== /try — şans əməli ====================

RegisterCommand('try', function(source, args)
    if source == 0 or #args == 0 then
        return
    end

    local text = table.concat(args, ' ')
    local success = math.random(1, 100) <= 50

    for _, pid in pairs(Nearby(source, 20.0)) do
        TriggerClientEvent('chat:addMessage', pid, {
            color = success and { 120, 220, 120 } or { 230, 120, 120 },
            multiline = true,
            args = { 'TRY', ('%s — %s ((%s))'):format(text, success and 'uğurlu' or 'uğursuz', PlayerName(source)) }
        })
    end
end, false)

-- ==================== /ooc — kənar söhbət ====================

RegisterCommand('ooc', function(source, args)
    if source == 0 or #args == 0 then
        return
    end

    local text = table.concat(args, ' ')
    for _, pid in pairs(Nearby(source, 25.0)) do
        TriggerClientEvent('chat:addMessage', pid, {
            color = { 160, 160, 160 },
            multiline = true,
            args = { ('OOC %s'):format(source), text }
        })
    end
end, false)

-- ==================== /b — yaxın kənar söhbət ====================

RegisterCommand('b', function(source, args)
    if source == 0 or #args == 0 then
        return
    end

    local text = table.concat(args, ' ')
    for _, pid in pairs(Nearby(source, 10.0)) do
        TriggerClientEvent('chat:addMessage', pid, {
            color = { 150, 150, 150 },
            multiline = true,
            args = { ('%s'):format(source), text }
        })
    end
end, false)

-- ==================== /report — adminə şikayət ====================

RegisterCommand('report', function(source, args)
    if source == 0 or #args == 0 then
        TriggerClientEvent('chat:addMessage', source, {
            color = { 230, 120, 120 },
            multiline = true,
            args = { 'Report', 'İstifadə: /report [ID] [səbəb]' }
        })
        return
    end

    local targetId = tonumber(args[1])
    table.remove(args, 1)
    local reason = table.concat(args, ' ')

    if not targetId or reason == '' then
        TriggerClientEvent('chat:addMessage', source, {
            color = { 230, 120, 120 },
            multiline = true,
            args = { 'Report', 'İstifadə: /report [ID] [səbəb]' }
        })
        return
    end

    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        TriggerClientEvent('chat:addMessage', source, {
            color = { 230, 120, 120 },
            multiline = true,
            args = { 'Report', 'Bu ID-li oyunçu onlayn deyil!' }
        })
        return
    end

    TriggerClientEvent('chat:addMessage', source, {
        color = { 120, 220, 120 },
        multiline = true,
        args = { 'Report', 'Şikayətiniz adminlərə göndərildi. Təşəkkürlər!' }
    })

    for _, pid in pairs(ESX.GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(pid)
        if xPlayer and xPlayer.getGroup() == 'admin' then
            TriggerClientEvent('chat:addMessage', pid, {
                color = { 255, 100, 150 },
                multiline = true,
                args = { 'REPORT', ('%s (ID %s) → %s (ID %s): %s'):format(
                    PlayerName(source), source, PlayerName(targetId), targetId, reason) }
            })
        end
    end
end, false)

-- ==================== /id — öz ID-ni göstər ====================

RegisterCommand('id', function(source)
    if source == 0 then
        return
    end
    TriggerClientEvent('chat:addMessage', source, {
        color = { 200, 200, 200 },
        multiline = true,
        args = { 'ID', ('Sizin server ID-niz: %s'):format(source) }
    })
end, false)
