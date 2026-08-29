local QBCore = exports['qb-core']:GetCoreObject()
local cache = {}
local cacheTime = {}

-- ═══════════════════════════════════════════════════════════════
-- Yardımçı funksiyalar
-- ═══════════════════════════════════════════════════════════════

local function GetIdentifier(src, idtype)
    for _, id in pairs(GetPlayerIdentifiers(src)) do
        if string.find(id, idtype .. ':') then
            return string.sub(id, string.len(idtype) + 2)
        end
    end
    return nil
end

local function IsAdmin(src)
    for _, perm in pairs(Config.AdminPermissions) do
        if IsPlayerAceAllowed(src, perm) then
            return true
        end
    end
    return false
end

local function IsWhitelisted(license, steam)
    local key = 'lic:' .. tostring(license) .. '|steam:' .. tostring(steam)
    if cache[key] ~= nil and (os.time() - (cacheTime[key] or 0)) < Config.CacheTime then
        return cache[key]
    end
    local result = MySQL.single.await('SELECT status FROM `196_whitelist` WHERE license = ? OR steam = ? LIMIT 1',
        { license, steam })
    local allowed = result ~= nil and result.status == 'accepted' and true or false
    cache[key] = allowed
    cacheTime[key] = os.time()
    return allowed
end

local function SendWebhook(content, title, color, fields)
    if Config.Webhook == nil or Config.Webhook == '' or Config.Webhook:find('BURAYA') then
        return
    end
    local payload = {
        embeds = { {
            title = title or '196 RP | Whitelist',
            description = content,
            color = color or 3447003,
            fields = fields or {},
            footer = { text = 'Azerbaijan Role Play' },
            timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        } }
    }
    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST',
        json.encode(payload), { ['Content-Type'] = 'application/json' })
end

-- ═══════════════════════════════════════════════════════════════
-- Qoşulma qapısı — əsl whitelist!
-- qb-core/server/events.lua bu export-ı çağırır (orada yalnız bir
-- deferrals.done() işləyir, beləliklə iki resource qapını idarə etmir)
-- ═══════════════════════════════════════════════════════════════

--- Oyunçunun serverə daxil olmasına icazə verilirmi?
--- @return boolean allowed, string|nil reason
exports('CanJoin', function(src)
    if IsAdmin(src) then
        return true
    end
    if not Config.WhitelistEnabled or Config.OpenRegistration then
        return true
    end
    local license = GetIdentifier(src, 'license')
    local steam = GetIdentifier(src, 'steam')
    if not license and not steam then
        return false, '196 RP | Etibarlı identifikator tapılmadı. Steam-ı açıq saxlayın.'
    end
    if IsWhitelisted(license, steam) then
        return true
    end
    return false, Config.Text.gate_denied:gsub('%%{discord}', Config.DiscordInvite)
end)

-- ═══════════════════════════════════════════════════════════════
-- Müraciət
-- ═══════════════════════════════════════════════════════════════

RegisterNetEvent('196rp_whitelist:apply', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local license = GetIdentifier(src, 'license')
    local steam = GetIdentifier(src, 'steam')

    local existing = MySQL.single.await('SELECT status FROM `196_whitelist` WHERE license = ? OR steam = ? LIMIT 1',
        { license, steam })
    if existing then
        if existing.status == 'accepted' then
            TriggerClientEvent('QBCore:Notify', src, Config.Text.accepted, 'success')
        elseif existing.status == 'pending' then
            TriggerClientEvent('QBCore:Notify', src, Config.Text.already_applied, 'error')
        else
            -- təkrar müraciət etmək olar
            MySQL.update('UPDATE `196_whitelist` SET status = ?, applied_at = NOW() WHERE license = ? OR steam = ?',
                { 'pending', license, steam })
            TriggerClientEvent('QBCore:Notify', src, Config.Text.applied, 'success')
        end
        return
    end

    MySQL.insert('INSERT INTO `196_whitelist` (license, steam, firstname, lastname, age, discord, rp_exp, reason, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        {
            license, steam, data.firstname, data.lastname, data.age, data.discord, data.rpexp, data.reason, 'pending'
        })

    TriggerClientEvent('QBCore:Notify', src, Config.Text.applied, 'success')

    SendWebhook(nil, '📩 Yeni Whitelist Müraciəti', 5793266, {
        { name = 'Ad Soyad', value = data.firstname .. ' ' .. data.lastname, inline = true },
        { name = 'Yaş', value = tostring(data.age), inline = true },
        { name = 'Discord', value = data.discord, inline = true },
        { name = 'RP təcrübəsi', value = data.rpexp, inline = false },
        { name = 'Səbəb', value = data.reason, inline = false },
        { name = 'Steam', value = tostring(steam or 'Yoxdur'), inline = true },
        { name = 'License', value = tostring(license or 'Yoxdur'), inline = true },
    })
    print(('^2[196RP WHITELIST]^7 Yeni müraciət: %s %s (Steam: %s)'):format(data.firstname, data.lastname, tostring(steam)))
end)

-- ═══════════════════════════════════════════════════════════════
-- Admin əmrləri
-- ═══════════════════════════════════════════════════════════════

QBCore.Commands.Add('wluygula', 'Whitelist müraciətlərini göstər (Admin)', {}, false, function(source)
    if not IsAdmin(source) then return end
    local rows = MySQL.query.await('SELECT id, firstname, lastname, age, discord, rp_exp, license, steam FROM `196_whitelist` WHERE status = ? ORDER BY id DESC LIMIT 10', { 'pending' })
    if #rows == 0 then
        TriggerClientEvent('QBCore:Notify', source, 'Gözlənilən müraciət yoxdur.', 'success')
        return
    end
    for _, r in ipairs(rows) do
        TriggerClientEvent('QBCore:Notify', source,
            ('[#%s] %s %s | Yaş: %s | Discord: %s | Steam: %s'):format(r.id, r.firstname, r.lastname, r.age, r.discord or '-', r.steam or '-'), 'primary')
    end
end, false)

QBCore.Commands.Add('wlqebul', 'Whitelist müraciətini qəbul et (Admin)', { { name = 'id', help = 'Müraciət ID-si (/wluygula)' } }, false, function(source, args)
    if not IsAdmin(source) then return end
    local id = tonumber(args[1])
    if not id then return end
    local row = MySQL.single.await('SELECT * FROM `196_whitelist` WHERE id = ? LIMIT 1', { id })
    if not row then
        TriggerClientEvent('QBCore:Notify', source, 'Müraciət tapılmadı.', 'error')
        return
    end
    MySQL.update('UPDATE `196_whitelist` SET status = ?, reviewed_at = NOW(), reviewed_by = ? WHERE id = ?',
        { 'accepted', GetPlayerName(source), id })
    cache = {}
    cacheTime = {}
    SendWebhook(nil, '✅ Müraciət qəbul edildi', 3066993, {
        { name = 'Oyunçu', value = row.firstname .. ' ' .. row.lastname, inline = true },
        { name = 'Discord', value = row.discord or '-', inline = true },
        { name = 'Qəbul edən', value = GetPlayerName(source), inline = true },
    })
    TriggerClientEvent('QBCore:Notify', source, ('%s %s qəbul edildi!'):format(row.firstname, row.lastname), 'success')
end, false)

QBCore.Commands.Add('wlred', 'Whitelist müraciətini rədd et (Admin)', {
    { name = 'id', help = 'Müraciət ID-si (/wluygula)' },
    { name = 'reason', help = 'Rədd səbəbi' },
}, false, function(source, args)
    if not IsAdmin(source) then return end
    local id = tonumber(args[1])
    if not id then return end
    local reason = table.concat(args, ' ', 2)
    if reason == '' then reason = 'Səbəb göstərilməyib' end
    local row = MySQL.single.await('SELECT * FROM `196_whitelist` WHERE id = ? LIMIT 1', { id })
    if not row then
        TriggerClientEvent('QBCore:Notify', source, 'Müraciət tapılmadı.', 'error')
        return
    end
    MySQL.update('UPDATE `196_whitelist` SET status = ?, reason = ?, reviewed_at = NOW(), reviewed_by = ? WHERE id = ?',
        { 'denied', reason, GetPlayerName(source), id })
    cache = {}
    cacheTime = {}
    SendWebhook(nil, '❌ Müraciət rədd edildi', 15158332, {
        { name = 'Oyunçu', value = row.firstname .. ' ' .. row.lastname, inline = true },
        { name = 'Səbəb', value = reason, inline = false },
    })
    TriggerClientEvent('QBCore:Notify', source, 'Müraciət rədd edildi.', 'error')
end, false)

QBCore.Commands.Add('wlrem', 'Oyunçunu whitelist-dən çıxar (Admin)', {
    { name = 'id', help = 'Müraciət ID-si' },
}, false, function(source, args)
    if not IsAdmin(source) then return end
    local id = tonumber(args[1])
    if not id then return end
    MySQL.update('UPDATE `196_whitelist` SET status = ? WHERE id = ?', { 'removed', id })
    cache = {}
    cacheTime = {}
    TriggerClientEvent('QBCore:Notify', source, 'Oyunçu whitelist-dən çıxarıldı.', 'success')
end, false)

QBCore.Commands.Add('wlkesifle', 'Whitelist keşini sıfırla (Admin)', {}, false, function(source)
    if not IsAdmin(source) then return end
    cache = {}
    cacheTime = {}
    TriggerClientEvent('QBCore:Notify', source, 'Whitelist keşi sıfırlandı.', 'success')
end, false)
