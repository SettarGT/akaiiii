-- 196 RP | Discord loqları — server tərəfi
-- Qoşulma/çıxma, report, admin əməlləri webhook-a göndərilir

local ESX = exports['es_extended']:getSharedObject()

local function IsConfigured(kind)
    local url = Config.Webhooks and Config.Webhooks[kind]
    return url and url ~= '' and not url:find('BURAYA')
end

local function Send(kind, title, description, color)
    if not IsConfigured(kind) then
        return
    end

    local payload = json.encode({
        username = Config.ServerName or '196 RP',
        embeds = {
            {
                title = title,
                description = description,
                color = tonumber(color or Config.Colors.generic, 16) or 2196211,
                timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
            }
        }
    })

    PerformHttpRequest(Config.Webhooks[kind], function() end, 'POST', payload, {
        ['Content-Type'] = 'application/json'
    })
end

exports('SendDiscordLog', function(kind, title, description)
    Send(kind, title, description, Config.Colors and Config.Colors.generic)
end)

-- ==================== QOŞULMA / ÇIXMA ====================

AddEventHandler('playerJoining', function()
    local src = source
    local name = GetPlayerName(src) or ('ID %s'):format(src)
    Send('server', '🟢 Oyunçu qoşuldu', ('**%s** (ID %s) serverə daxil oldu.\nOnlayn: %s'):format(
        name, src, #GetPlayers()), Config.Colors and Config.Colors.join)
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    local name = GetPlayerName(src) or ('ID %s'):format(src)
    Send('server', '🔴 Oyunçu çıxdı', ('**%s** (ID %s) serverdən ayrıldı.\nSəbəb: %s\nOnlayn: %s'):format(
        name, src, tostring(reason or '?'), #GetPlayers()), Config.Colors and Config.Colors.leave)
end)

-- ==================== REPORT ====================

AddEventHandler('196rp:report', function(src, targetId, reason)
    local xPlayer = ESX.GetPlayerFromId(src)
    local name = xPlayer and ('%s %s'):format(xPlayer.get('firstName') or '?', xPlayer.get('lastName') or '?')
        or ('ID %s'):format(src)

    Send('report', '🚨 Yeni report', ('**%s** (ID %s) → **ID %s**\nSəbəb: %s'):format(
        name, src, targetId, reason), Config.Colors and Config.Colors.report)
end)

-- ==================== ADMIN ƏMƏLLƏRİ ====================

AddEventHandler('196rp:adminAction', function(src, action, detail)
    local xPlayer = ESX.GetPlayerFromId(src)
    local name = xPlayer and ('%s %s'):format(xPlayer.get('firstName') or '?', xPlayer.get('lastName') or '?')
        or 'Konsol'

    Send('admin', '🛠 Admin əməli', ('**%s** (ID %s): %s\n%s'):format(
        name, src, tostring(action), tostring(detail or '')), Config.Colors and Config.Colors.admin)
end)
