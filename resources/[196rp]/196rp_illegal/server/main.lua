-- 196 RP | Qanunsuz fəaliyyətlər — server tərəfi
-- Qıfıl açarı, şom, rehin alma, dələduzluq, müsadirə basqını, gizli anbar, zibil ərazisi

local ESX = exports['es_extended']:getSharedObject()

local hostages = {}     -- [takerId] = { target, startedAt, timer }
local cooldowns = {}    -- [source] = { [key] = os.time() }

-- ==================== KÖMƏKÇİLƏR ====================

local function Notify(src, msg, typ)
    TriggerClientEvent('esx:showNotification', src, msg, typ or 'info', 6000)
end

local function SetCooldown(src, key, seconds)
    if not cooldowns[src] then
        cooldowns[src] = {}
    end
    cooldowns[src][key] = os.time() + (seconds or 0)
end

local function OnCooldown(src, key)
    local t = cooldowns[src]
    if not t or not t[key] then
        return false
    end

    local left = t[key] - os.time()
    if left > 0 then
        Notify(src, ('~r~Gözləyin:~s~ %s saniyə'):format(left), 'error')
        return true
    end

    return false
end

-- Bu radiusdakı polislərə xəbər verir
local function AlertPolice(coords, radius, label)
    local xPlayers = ESX.GetPlayers()

    for i = 1, #xPlayers do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

        if xPlayer and xPlayer.job and xPlayer.job.name == 'police' then
            local ped = GetPlayerPed(xPlayers[i])

            if ped and ped ~= 0 then
                local d = #(GetEntityCoords(ped) - coords)

                if d <= radius then
                    Notify(xPlayers[i], ('~o~🚨 HƏYƏCAN:~s~ %s'):format(label), 'error')
                    TriggerClientEvent('196rp_illegal:policeAlert', xPlayers[i],
                        { x = coords.x, y = coords.y, z = coords.z }, label)
                end
            end
        end
    end
end

local function HasItem(xPlayer, item)
    local inv = xPlayer.getInventoryItem(item)
    return inv and inv.count > 0
end

local function ToolRoll(xPlayer, tool, key)
    if not HasItem(xPlayer, tool.item) then
        return false, ('~r~%s~s~ aləti sizdə yoxdur!'):format(tool.label)
    end

    if OnCooldown(xPlayer.source, key) then
        return false, 'Bir az gözləyin.'
    end

    SetCooldown(xPlayer.source, key, tool.cooldown)

    if math.random(1, 100) <= (tool.breakChance or 0) then
        xPlayer.removeInventoryItem(tool.item, 1)
        return false, ('~r~%s sınadı!~s~'):format(tool.label)
    end

    if math.random(1, 100) > (tool.successChance or 50) then
        return false, '~r~Alınmadı!~s~ Yenidən cəhd edin.'
    end

    return true, '~g~Uğurlu!~s~'
end

-- ==================== ÇIXIŞ ====================

AddEventHandler('playerDropped', function()
    local src = source
    cooldowns[src] = nil

    if hostages[src] then
        local target = hostages[src].target
        TriggerClientEvent('196rp_illegal:hostageEnd', target, '~g~Sizi buraxdılar.~s~')
        hostages[src] = nil
    end

    for takerId, data in pairs(hostages) do
        if data.target == src then
            TriggerClientEvent('196rp_illegal:hostageEnd', src, 'Rehinəlik bitdi.')
            hostages[takerId] = nil
        end
    end
end)

-- ==================== 66. QIFIL AÇARI / ŞOM ====================

ESX.RegisterServerCallback('196rp_illegal:breakIn', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    plate = (tostring(plate or ''):gsub('%s+', '')):upper()

    local tool = HasItem(xPlayer, Config.Tools.lockpick.item) and Config.Tools.lockpick or Config.Tools.crowbar
    local ok, msg = ToolRoll(xPlayer, tool, 'breakin')

    if not ok then
        -- Uğursuz cəhd polisə xəbər verə bilər
        local ped = GetPlayerPed(source)
        if ped and ped ~= 0 then
            AlertPolice(GetEntityCoords(ped), tool.alertRadius or 40.0, 'Şübhəli şəxs maşın açmağa çalışır')
        end
        return cb(false, msg)
    end

    if plate ~= '' then
        if GetResourceState('196rp_vehicle') == 'started' then
            exports['196rp_vehicle']:ForceUnlock(plate)
        else
            TriggerClientEvent('196rp_vehicle:lockState', -1, plate, false)
        end
    end

    cb(true, ('~g~%s işlədi!~s~ Maşın açıldı.'):format(tool.label))
end)

-- ==================== 68. MÜSADİRƏ ANBARI BASQINI ====================

ESX.RegisterServerCallback('196rp_illegal:raidImpound', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, nil, 'Xəta baş verdi!')
    end

    if not HasItem(xPlayer, Config.ImpoundRaid.toolItem) then
        return cb(false, nil, ('~r~%s~s~ lazımdır!'):format(Config.Tools.crowbar.label))
    end

    if OnCooldown(source, 'raid') then
        return cb(false, nil, 'Bir az gözləyin.')
    end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)

    if #(coords - Config.ImpoundRaid.gate) > 12.0 then
        return cb(false, nil, 'Anbar qapısından uzaqdasınız!')
    end

    SetCooldown(source, 'raid', Config.ImpoundRaid.cooldown)

    local model = Config.ImpoundRaid.models[math.random(1, #Config.ImpoundRaid.models)]
    local plate = ('%s%03d'):format(Config.ImpoundRaid.platePrefix, math.random(1, 999))

    -- Maşını oğurlanmış kimi qeyd et (polis radarı üçün)
    MySQL.insert.await([[
        INSERT INTO `196rp_stolen_vehicles` (`plate`, `model`, `stolen_at`)
        VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE `model` = VALUES(`model`), `stolen_at` = VALUES(`stolen_at`), `recovered` = 0
    ]], { plate, model, os.time() })

    SetPlayerWantedLevel(source, Config.ImpoundRaid.wantedLevel, false)
    SetPlayerWantedLevelNow(source, false)

    AlertPolice(coords, Config.ImpoundRaid.policeAlertRadius, 'Müsadirə anbarına basqın!')

    cb(true, { model = model, plate = plate }, '~g~Anbar açıldı!~s~ Polis xəbərdar edildi.')
end)

-- ==================== 65. REHİN ALMA ====================

ESX.RegisterServerCallback('196rp_illegal:takeHostage', function(source, cb, targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local target = ESX.GetPlayerFromId(tonumber(targetId) or 0)

    if not xPlayer or not target then
        return cb(false, 'Oyunçu tapılmadı!')
    end

    if not HasItem(xPlayer, Config.Hostage.item) then
        return cb(false, ('Rehin almaq üçün ~y~%s~s~ lazımdır!'):format(Config.Tools.crowbar.label))
    end

    if hostages[source] then
        return cb(false, 'Sizdə artıq rehinə var!')
    end

    for takerId, data in pairs(hostages) do
        if data.target == target.source then
            return cb(false, 'Bu oyunçu artıq rehindir!')
        end
    end

    if OnCooldown(source, 'hostage') then
        return cb(false, 'Bir az gözləyin.')
    end

    local ped = GetPlayerPed(source)
    local targetPed = GetPlayerPed(target.source)

    if not ped or ped == 0 or not targetPed or targetPed == 0 then
        return cb(false, 'Oyunçu tapılmadı!')
    end

    if #(GetEntityCoords(ped) - GetEntityCoords(targetPed)) > Config.Hostage.maxDistance + 1.0 then
        return cb(false, 'Oyunçu çox uzaqdadır!')
    end

    if target.job and target.job.name == 'police' then
        return cb(false, 'Polisi rehin ala bilməzsiniz!')
    end

    SetCooldown(source, 'hostage', Config.Hostage.cooldown)

    hostages[source] = { target = target.source, startedAt = os.time() }

    TriggerClientEvent('196rp_illegal:hostageStart', target.source)
    TriggerClientEvent('196rp_illegal:hostageFollow', target.source, source)

    AlertPolice(GetEntityCoords(ped), Config.Hostage.policeAlertRadius, 'Rehin alma hadisəsi!')

    -- Vaxt bitəndə mükafat
    SetTimeout(Config.Hostage.duration * 1000, function()
        if not hostages[source] then
            return
        end

        local taker = ESX.GetPlayerFromId(source)
        local victim = ESX.GetPlayerFromId(hostages[source].target)

        hostages[source] = nil

        if victim then
            TriggerClientEvent('196rp_illegal:hostageEnd', victim.source, '~g~Sizi buraxdılar.~s~')
        end

        if taker then
            taker.addAccountMoney('bank', Config.Hostage.reward)
            Notify(source, ('~g~Rehinə əməliyyatı uğurla bitdi!~s~ +%s$'):format(Config.Hostage.reward), 'success')
        end
    end)

    cb(true, ('~r~%s~s~ adlı oyunçunu rehin aldınız! Polis xəbərdar edildi.'):format(target.getName()))
end)

RegisterNetEvent('196rp_illegal:hostageLost', function(targetId)
    local src = source
    local data = hostages[src]

    if not data or data.target ~= tonumber(targetId) then
        return
    end

    hostages[src] = nil
    Notify(src, '~r~Rehinə qaçdı!~s~', 'error')
    AlertPolice(GetEntityCoords(GetPlayerPed(src)), 200.0, 'Rehin qaçdı — şübhəli axtarılır')
end)

-- Rehinəni buraxmaq
RegisterCommand('rehiniburax', function(source)
    local data = hostages[source]

    if not data then
        return Notify(source, 'Sizdə rehinə yoxdur.', 'error')
    end

    hostages[source] = nil
    TriggerClientEvent('196rp_illegal:hostageEnd', data.target, '~g~Sizi buraxdılar.~s~')
    Notify(source, 'Rehinəni buraxdınız.', 'info')
end, true)

-- ==================== 67. DƏLƏDUZLUQ ====================

ESX.RegisterServerCallback('196rp_illegal:fraud', function(source, cb, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    amount = math.floor(tonumber(amount) or 0)

    if amount < 100 or amount > Config.Fraud.maxPerOperation then
        return cb(false, 'Yanlış miqdar!')
    end

    if OnCooldown(source, 'fraud') then
        return cb(false, 'Bir az gözləyin.')
    end

    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - Config.Fraud.table) > 5.0 then
        return cb(false, 'Çap masasından uzaqdasınız!')
    end

    local bank = xPlayer.getAccount('bank')
    if not bank or bank.money < amount then
        return cb(false, ('Bankda ~y~%s$~s~ yoxdur!'):format(amount))
    end

    SetCooldown(source, 'fraud', Config.Fraud.cooldown)
    xPlayer.removeAccountMoney('bank', amount)

    -- Saxta vəsiqə riski azaldır
    local caughtChance = Config.Fraud.caughtChance
    if HasItem(xPlayer, Config.Fraud.fakeIdItem) then
        caughtChance = math.floor(caughtChance / 2)
    end

    if math.random(1, 100) <= caughtChance then
        AlertPolice(GetEntityCoords(ped), 250.0, 'Saxta pul çapı aşkarlandı!')
        return cb(false, ('~r~Əməliyyat ifşa olundu!~s~ %s$ itirdiniz və polis xəbərdar edildi.'):format(amount))
    end

    local fake = math.floor(amount * Config.Fraud.exchangeRate)
    xPlayer.addInventoryItem(Config.Fraud.moneyItem, fake)

    cb(true, ('~g~%s$ təmiz pul → ~y~%s$~s~ saxta pula çevrildi (əşya olaraq).'):format(amount, fake))
end)

-- Saxta pulu nağdlaşdırmaq (risk var)
ESX.RegisterUsableItem(Config.Fraud.moneyItem, function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return
    end

    local inv = xPlayer.getInventoryItem(Config.Fraud.moneyItem)
    if not inv or inv.count < 100 then
        return Notify(source, 'Ən azı 100 ədəd saxta pul lazımdır.', 'error')
    end

    local amount = inv.count
    xPlayer.removeInventoryItem(Config.Fraud.moneyItem, amount)

    if math.random(1, 100) <= Config.Fraud.depositPenalty then
        local fine = math.floor(amount * 0.3)
        local rest = amount - fine
        xPlayer.addAccountMoney('bank', rest)
        AlertPolice(GetEntityCoords(GetPlayerPed(source)), 200.0, 'Saxta pul dövriyyəsi aşkarlandı!')
        return Notify(source, ('~r~Bank saxta pulu aşkarladı!~s~ %s$ cərimə, %s$ hesabınıza keçdi.'):format(fine, rest), 'error')
    end

    xPlayer.addAccountMoney('bank', amount)
    Notify(source, ('~g~%s$ nağdlaşdırıldı.~s~'):format(amount), 'success')
end)

-- ==================== 69. GİZLİ ANBAR ====================

ESX.RegisterServerCallback('196rp_illegal:getStash', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb({})
    end

    local rows = MySQL.query.await(
        'SELECT `item`, `count` FROM `196rp_hideout_stash` WHERE `identifier` = ? AND `count` > 0',
        { xPlayer.identifier }) or {}

    for i = 1, #rows do
        local item = MySQL.single.await('SELECT `label` FROM `items` WHERE `name` = ?', { rows[i].item })
        rows[i].label = item and item.label or rows[i].item
    end

    cb(rows)
end)

ESX.RegisterServerCallback('196rp_illegal:depositItem', function(source, cb, item, count)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    item = tostring(item or ''):lower()
    count = math.floor(tonumber(count) or 0)

    if item == '' or count < 1 then
        return cb(false, 'Yanlış əşya və ya miqdar!')
    end

    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - Config.Hideout.stash) > 5.0 then
        return cb(false, 'Anbardan uzaqdasınız!')
    end

    local inv = xPlayer.getInventoryItem(item)
    if not inv or inv.count < count then
        return cb(false, 'Sizdə bu qədər əşya yoxdur!')
    end

    -- Anbar limiti
    local total = MySQL.scalar.await(
        'SELECT IFNULL(SUM(`count`), 0) FROM `196rp_hideout_stash` WHERE `identifier` = ?', { xPlayer.identifier })

    if (tonumber(total) or 0) + count > Config.Hideout.stashSlots then
        return cb(false, ('Anbar doludur! Limit: %s'):format(Config.Hideout.stashSlots))
    end

    xPlayer.removeInventoryItem(item, count)

    MySQL.update.await([[
        INSERT INTO `196rp_hideout_stash` (`identifier`, `item`, `count`) VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE `count` = `count` + VALUES(`count`)
    ]], { xPlayer.identifier, item, count })

    cb(true, ('~g~%s ədəd %s anbara qoyuldu.~s~'):format(count, item))
end)

ESX.RegisterServerCallback('196rp_illegal:withdrawItem', function(source, cb, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    item = tostring(item or ''):lower()

    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - Config.Hideout.stash) > 5.0 then
        return cb(false, 'Anbardan uzaqdasınız!')
    end

    local row = MySQL.single.await(
        'SELECT `count` FROM `196rp_hideout_stash` WHERE `identifier` = ? AND `item` = ?',
        { xPlayer.identifier, item })

    if not row or (row.count or 0) < 1 then
        return cb(false, 'Anbarda bu əşya yoxdur!')
    end

    if not xPlayer.canCarryItem(item, row.count) then
        return cb(false, 'Çantanızda yer yoxdur!')
    end

    xPlayer.addInventoryItem(item, row.count)

    MySQL.update.await(
        'UPDATE `196rp_hideout_stash` SET `count` = 0 WHERE `identifier` = ? AND `item` = ?',
        { xPlayer.identifier, item })

    cb(true, ('~g~%s ədəd %s götürüldü.~s~'):format(row.count, item))
end)

-- ==================== 70. ZİBİL ƏRAZİSİ ====================

ESX.RegisterServerCallback('196rp_illegal:scrapVehicle', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    if OnCooldown(source, 'scrap') then
        return cb(false, 'Bir az gözləyin.')
    end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)

    if #(coords - Config.Junkyard.coords) > 12.0 then
        return cb(false, 'Doğrama məntəqəsindən uzaqdasınız!')
    end

    SetCooldown(source, 'scrap', Config.Junkyard.cooldown)

    local scrapCount = math.random(3, 8)
    local pay = scrapCount * Config.Junkyard.payPerScrap
    local bonus = 0

    plate = (tostring(plate or ''):gsub('%s+', '')):upper()

    if plate ~= '' and plate:sub(1, #Config.Junkyard.platePrefix) == Config.Junkyard.platePrefix then
        bonus = Config.Junkyard.stolenVehicleBonus
        MySQL.update.await('UPDATE `196rp_stolen_vehicles` SET `recovered` = 1 WHERE `plate` = ?', { plate })
    end

    xPlayer.addAccountMoney('bank', pay + bonus)
    xPlayer.addInventoryItem(Config.Junkyard.scrapItem, scrapCount)

    -- Bəzən basqın olur
    if math.random(1, 100) <= Config.Junkyard.ambushChance then
        AlertPolice(coords, 200.0, 'Zibil ərazisində şübhəli fəaliyyət!')
    end

    cb(true, ('~g~%s ədəd qırıntı~s~ (+%s$)%s'):format(
        scrapCount, pay, bonus > 0 and (' + oğurlanmış maşın bonusu ~y~%s$~s~'):format(bonus) or ''))
end)

-- ==================== DİGƏR RESURSLAR ÜÇÜN ====================

exports('IsVehicleStolen', function(plate)
    plate = (tostring(plate or ''):gsub('%s+', '')):upper()
    local n = MySQL.scalar.await(
        'SELECT COUNT(*) FROM `196rp_stolen_vehicles` WHERE `plate` = ? AND `recovered` = 0', { plate })
    return (tonumber(n) or 0) > 0
end)
