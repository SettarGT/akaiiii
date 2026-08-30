local QBCore = exports['qb-core']:GetCoreObject()

local colors = {
    conn = 3066993, money = 15844367, kills = 15158332,
    admin = 15105570, veh = 3447003, items = 10181046,
    reports = 15548997, wl = 5793266, anticheat = 15548997,
}

-- ── Webhook göndər ──
function SendWebhook(channel, title, description, color)
    local url = Config.Webhooks[channel]
    if not url or url == '' then return end
    PerformHttpRequest(url, function() end, 'POST', json.encode({
        username = '196 RP Logs',
        embeds = { {
            title = title,
            description = description,
            color = color or colors[channel] or 16763904,
            footer = { text = '196 RP | ' .. os.date('%d.%m.%Y %H:%M') },
            timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        } },
    }), { ['Content-Type'] = 'application/json' })
end

exports('Send', function(channel, title, description, color)
    SendWebhook(channel, title, description, color)
end)

exports('SendWithFields', function(channel, title, fields, color)
    local url = Config.Webhooks[channel]
    if not url or url == '' then return end
    PerformHttpRequest(url, function() end, 'POST', json.encode({
        username = '196 RP Logs',
        embeds = { {
            title = title,
            fields = fields,
            color = color or colors[channel] or 16763904,
            timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        } },
    }), { ['Content-Type'] = 'application/json' })
end)

local function nameOf(player)
    if not player then return '?' end
    local c = player.PlayerData.charinfo
    return (c.firstname or '?') .. ' ' .. (c.lastname or '?')
end

-- ── Hook: Əşya (#items) — qb-inventory listener ──
if GetResourceState('qb-inventory') == 'started' then
    exports['qb-inventory']:AddListener('ItemAdded', function(_, data)
        if not data or not data.item then return end
        local who = data.source or '?'
        SendWithFields('items', '📦 Əşya əlavə edildi', {
            { name = 'Oyunçu', value = '`' .. tostring(who) .. '`', inline = true },
            { name = 'Əşya', value = data.item.label or data.item.name, inline = true },
            { name = 'Say', value = tostring(data.amount or 1), inline = true },
            { name = 'Səbəb', value = data.reason or '?', inline = true },
        })
    end)
    exports['qb-inventory']:AddListener('ItemRemoved', function(_, data)
        if not data or not data.item then return end
        local who = data.source or '?'
        SendWithFields('items', '🗑 Əşya silindi', {
            { name = 'Oyunçu', value = '`' .. tostring(who) .. '`', inline = true },
            { name = 'Əşya', value = data.item.label or data.item.name, inline = true },
            { name = 'Say', value = tostring(data.amount or 1), inline = true },
            { name = 'Səbəb', value = data.reason or '?', inline = true },
        })
    end)
end

-- ── Hook: giriş/çıxış ──
RegisterNetEvent('QBCore:Server:PlayerLoaded', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        SendWebhook('conn', '🟢 Oyunçu qoşuldu', ('**%s** (%d) · FİN %s'):format(nameOf(Player), src, Player.PlayerData.citizenid or '?'))
    end
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        SendWebhook('conn', '🔴 Oyunçu çıxdı', ('**%s** (%d)'):format(nameOf(Player), src))
    end
end)

-- ── Hook: ölüm (#kills) ──
RegisterNetEvent('hospital:server:SetDeathStatus', function(isDead)
    if not isDead then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        SendWebhook('kills', '💀 Ölüm', ('**%s** (%d) · FİN %s'):format(nameOf(Player), src, Player.PlayerData.citizenid or '?'))
    end
end)

-- ── Hook: qeyri-qanuni zədə ölümü (hava limanı hadisəsi üçün) ──
RegisterNetEvent('196rp_logs:server:logKill', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and data then
        SendWebhook('kills', '🔫 Ölüm hadisəsi', ('**%s** (%d)\n%ss'):format(nameOf(Player), src, data.reason or ''))
    end
end)

-- ── Hook: admin əmrləri ──
RegisterNetEvent('196rp_logs:server:adminCmd', function(cmd, details)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        SendWebhook('admin', '🛠 Admin əmri', ('**%s** (%d) istifadə etdi: `%s` %s'):format(nameOf(Player), src, tostring(cmd), tostring(details or '')))
    end
end)

-- ── Hook: pul əməliyyatları (#money qb-core daxili logundan) ──
RegisterNetEvent('qb-log:server:CreateLog', function(category, title, _, message, _)
    if category == 'playermoney' then
        SendWebhook('money', '💵 ' .. tostring(title), tostring(message or ''), colors.money)
    end
end)

-- ── Hook: avtomobil hadisələri ──
RegisterNetEvent('196rp_logs:server:vehEvent', function(veh, event, extra)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        SendWebhook('veh', '🚗 ' .. tostring(event), ('**%s** (%d) · %s %s'):format(nameOf(Player), src, tostring(veh or '?'), tostring(extra or '')))
    end
end)

-- ══════════════════════════════════════════
--  ANTICHEAT (yüngül: teleport/sürət yoxlaması)
-- ══════════════════════════════════════════
local tracked = {}
local flags = {}

local function IsAdmin(src)
    return Config.Anticheat.ExcludeAdmins and QBCore.Functions.HasPermission(src, 'admin')
end

local function Flag(src, kind, detail)
    local Player = QBCore.Functions.GetPlayer(src)
    flags[src] = (flags[src] or 0) + 1

    local name = Player and nameOf(Player) or tostring(src)
    SendWebhook('anticheat', ('⚠️ Anticheat: %s'):format(kind), ('**%s** (%d) · %s · Flag: **%d/%d**'):format(name, src, tostring(detail), flags[src], Config.Anticheat.FlagsToKick))

    for _, adminSrc in ipairs(QBCore.Functions.GetPlayers()) do
        if adminSrc ~= src and QBCore.Functions.HasPermission(adminSrc, 'admin') then
            TriggerClientEvent('QBCore:Notify', adminSrc, ('⚠️ ANTICHEAT: %s (%d) — %s'):format(name, src, kind), 'error')
        end
    end

    if flags[src] >= Config.Anticheat.FlagsToKick then
        SendWebhook('anticheat', '🚨 Kick edildi', ('**%s** (%d) — %d flag'):format(name, src, flags[src]))
        DropPlayer(src, '196 RP | Anticheat: qayda pozuntusu (' .. Config.Anticheat.FlagsToKick .. ' flag)')
        flags[src] = nil
        tracked[src] = nil
    end
end

CreateThread(function()
    while true do
        Wait(Config.Anticheat.CheckInterval)
        local interval = Config.Anticheat.CheckInterval / 1000
        for _, src in ipairs(QBCore.Functions.GetPlayers()) do
            local Player = QBCore.Functions.GetPlayer(src)
            if Player and not IsAdmin(src) then
                local ped = GetPlayerPed(src)
                local coords = GetEntityCoords(ped)
                local prev = tracked[src]
                local veh = GetVehiclePedIsIn(ped, false)

                if prev then
                    local dist = #(coords - prev.pos)
                    local speed = dist / interval
                    if veh ~= 0 then
                        local kmh = (dist / interval) * 3.6
                        if kmh > Config.Anticheat.MaxSpeedVehicle then
                            Flag(src, 'Həddindən artıq sürət', ('%d km/s'):format(math.floor(kmh)))
                        end
                    elseif speed > Config.Anticheat.MaxSpeedRunning then
                        Flag(src, 'Piyada sürət həkəti (teleport)', ('%d m / %ds'):format(math.floor(dist), math.floor(interval)))
                    end
                end
                tracked[src] = { pos = coords }
            end
        end
    end
end)

-- Oyunçu çıxanda təmizlə
RegisterNetEvent('QBCore:Server:OnPlayerUnload', function()
    local src = source
    tracked[src] = nil
    flags[src] = nil
end)
