-- 196 RP | Sosial sistemlər — server tərəfi
-- Hədiyyə, evlilik, dostluq, missiya sistemi

local ESX = exports['es_extended']:getSharedObject()

local proposals = {}    -- [targetSource] = { from = source, fromName = '...' }
local missions = {}     -- [source] = { index, startedAt }
local lastMission = {}  -- [source] = os.time()

-- ==================== KÖMƏKÇİLƏR ====================

local function Notify(src, msg, typ)
    TriggerClientEvent('esx:showNotification', src, msg, typ or 'info', 6000)
end

local function NameOf(xPlayer)
    if not xPlayer then
        return 'naməlum'
    end
    return xPlayer.getName()
end

local function Distance(src, otherSrc)
    local ped = GetPlayerPed(src)
    local other = GetPlayerPed(otherSrc)

    if not ped or ped == 0 or not other or other == 0 then
        return math.huge
    end

    return #(GetEntityCoords(ped) - GetEntityCoords(other))
end

local function GetUserName(identifier)
    local row = MySQL.single.await('SELECT `firstname`, `lastname` FROM `users` WHERE `identifier` = ?', { identifier })
    if not row then
        return identifier
    end
    return ('%s %s'):format(row.firstname or '?', row.lastname or '?')
end

-- ==================== 97. HƏDİYYƏ ====================

ESX.RegisterServerCallback('196rp_social:giveMoney', function(source, cb, targetId, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local target = ESX.GetPlayerFromId(tonumber(targetId) or 0)

    if not xPlayer or not target then
        return cb(false, 'Oyunçu tapılmadı!')
    end

    if target.source == source then
        return cb(false, 'Özünüzə hədiyyə verə bilməzsiniz!')
    end

    amount = math.floor(tonumber(amount) or 0)

    if amount < 1 or amount > Config.Gift.maxMoney then
        return cb(false, 'Yanlış məbləğ!')
    end

    if Distance(source, target.source) > Config.Gift.maxDistance then
        return cb(false, 'Oyunçu çox uzaqdadır!')
    end

    if xPlayer.getMoney() < amount then
        return cb(false, 'Üzərinizdə bu qədər nağd pul yoxdur!')
    end

    xPlayer.removeMoney(amount)
    target.addMoney(amount)

    Notify(target.source, ('~g~🎁 %s~s~ sizə ~y~%s$~s~ hədiyyə etdi!'):format(NameOf(xPlayer), amount), 'success')

    cb(true, ('~g~%s$ hədiyyə verildi.~s~'):format(amount))
end)

ESX.RegisterServerCallback('196rp_social:giveItem', function(source, cb, targetId, item, count)
    local xPlayer = ESX.GetPlayerFromId(source)
    local target = ESX.GetPlayerFromId(tonumber(targetId) or 0)

    if not xPlayer or not target then
        return cb(false, 'Oyunçu tapılmadı!')
    end

    if target.source == source then
        return cb(false, 'Özünüzə hədiyyə verə bilməzsiniz!')
    end

    item = tostring(item or ''):lower()
    count = math.floor(tonumber(count) or 0)

    if item == '' or count < 1 then
        return cb(false, 'Yanlış əşya və ya miqdar!')
    end

    if Distance(source, target.source) > Config.Gift.maxDistance then
        return cb(false, 'Oyunçu çox uzaqdadır!')
    end

    local inv = xPlayer.getInventoryItem(item)
    if not inv or inv.count < count then
        return cb(false, 'Sizdə bu qədər əşya yoxdur!')
    end

    if not target.canCarryItem(item, count) then
        return cb(false, 'Oyunçunun çantasında yer yoxdur!')
    end

    xPlayer.removeInventoryItem(item, count)
    target.addInventoryItem(item, count)

    Notify(target.source, ('~g~🎁 %s~s~ sizə ~y~%sx%s~s~ hədiyyə etdi!'):format(NameOf(xPlayer), count, item), 'success')

    cb(true, ('~g~%sx%s hədiyyə verildi.~s~'):format(count, item))
end)

-- ==================== 98. EVLİLİK ====================

ESX.RegisterServerCallback('196rp_social:propose', function(source, cb, targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local target = ESX.GetPlayerFromId(tonumber(targetId) or 0)

    if not xPlayer or not target then
        return cb(false, 'Oyunçu tapılmadı!')
    end

    if target.source == source then
        return cb(false, 'Özünüzə evlilik təklifi edə bilməzsiniz!')
    end

    local ring = xPlayer.getInventoryItem(Config.Marriage.ringItem)
    if not ring or ring.count < 1 then
        return cb(false, ('Evlilik təklifi üçün ~y~%s~s~ lazımdır!'):format(Config.Marriage.ringItem))
    end

    if Distance(source, target.source) > Config.Marriage.proposeDistance then
        return cb(false, 'Oyunçu çox uzaqdadır!')
    end

    local mine = MySQL.single.await('SELECT `status` FROM `196rp_marriages` WHERE `identifier` = ?', { xPlayer.identifier })
    if mine then
        return cb(false, mine.status == 'married' and 'Siz artıq evlisiniz!' or 'Artıq nişanlısınız!')
    end

    local theirs = MySQL.single.await('SELECT `status` FROM `196rp_marriages` WHERE `identifier` = ?', { target.identifier })
    if theirs then
        return cb(false, theirs.status == 'married' and 'Bu oyunçu artıq evlidir!' or 'Bu oyunçu artıq nişanlıdır!')
    end

    xPlayer.removeInventoryItem(Config.Marriage.ringItem, 1)

    proposals[target.source] = { from = source, fromName = NameOf(xPlayer) }

    TriggerClientEvent('196rp_social:proposal', target.source, source, NameOf(xPlayer))

    -- 60 saniyə ərzində cavab verilməsə təklif etibarsız olur
    SetTimeout(60000, function()
        if proposals[target.source] and proposals[target.source].from == source then
            proposals[target.source] = nil
            Notify(source, '~r~Təklifə cavab verilmədi.~s~ Üzük geri qaytarıldı.', 'error')
            xPlayer.addInventoryItem(Config.Marriage.ringItem, 1)
        end
    end)

    cb(true, ('~g~%s~s~ adlı oyunçuya evlilik təklifi göndərildi.'):format(NameOf(target)))
end)

ESX.RegisterServerCallback('196rp_social:proposalResponse', function(source, cb, accepted)
    local data = proposals[source]

    if not data then
        return cb()
    end

    proposals[source] = nil

    local proposer = ESX.GetPlayerFromId(data.from)
    local responder = ESX.GetPlayerFromId(source)

    if not proposer or not responder then
        return cb()
    end

    if not accepted then
        proposer.addInventoryItem(Config.Marriage.ringItem, 1)
        TriggerClientEvent('196rp_social:proposalResult', data.from,
            ('~r~%s~s~ təklifinizi rədd etdi.'):format(NameOf(responder)), false)
        return cb()
    end

    local now = os.time()

    MySQL.update.await([[
        INSERT INTO `196rp_marriages` (`identifier`, `partner`, `married_at`, `status`) VALUES (?, ?, ?, 'engaged')
        ON DUPLICATE KEY UPDATE `partner` = VALUES(`partner`), `married_at` = VALUES(`married_at`), `status` = 'engaged'
    ]], { proposer.identifier, responder.identifier, now })

    MySQL.update.await([[
        INSERT INTO `196rp_marriages` (`identifier`, `partner`, `married_at`, `status`) VALUES (?, ?, ?, 'engaged')
        ON DUPLICATE KEY UPDATE `partner` = VALUES(`partner`), `married_at` = VALUES(`married_at`), `status` = 'engaged'
    ]], { responder.identifier, proposer.identifier, now })

    TriggerClientEvent('196rp_social:proposalResult', data.from,
        ('~g~%s~s~ təklifinizi qəbul etdi! Toy üçün mərasim meydanına gedin (/toy).'):format(NameOf(responder)), true)
    Notify(source, '~g~Nişanlandınız!~s~ Toy üçün mərasim meydanına gedin.', 'success')

    cb()
end)

ESX.RegisterServerCallback('196rp_social:getMarriage', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(nil)
    end

    local row = MySQL.single.await(
        'SELECT `partner`, `married_at`, `status` FROM `196rp_marriages` WHERE `identifier` = ?',
        { xPlayer.identifier })

    if not row then
        return cb(nil)
    end

    cb({
        partner = row.partner,
        partnerName = GetUserName(row.partner),
        marriedAt = row.married_at and os.date('%d.%m.%Y', row.married_at) or nil,
        status = row.status,
    })
end)

ESX.RegisterServerCallback('196rp_social:ceremony', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local row = MySQL.single.await(
        'SELECT `partner`, `status` FROM `196rp_marriages` WHERE `identifier` = ?', { xPlayer.identifier })

    if not row then
        return cb(false, 'Siz nişanlı deyilsiniz! Əvvəlcə /evlilikteklifi verin.')
    end

    if row.status == 'married' then
        return cb(false, 'Siz artıq evlisiniz!')
    end

    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - Config.Marriage.venue) > Config.Marriage.venueDist then
        return cb(false, 'Toy mərasimi meydanından uzaqdasınız!')
    end

    local xPartner = ESX.GetPlayerFromIdentifier(row.partner)

    if not xPartner then
        return cb(false, 'Həyat yoldaşınız onlayn deyil!')
    end

    if Distance(source, xPartner.source) > Config.Marriage.venueDist then
        return cb(false, 'Həyat yoldaşınız mərasim meydanında deyil!')
    end

    local bank = xPlayer.getAccount('bank')
    if bank and bank.money >= Config.Marriage.ceremonyCost then
        xPlayer.removeAccountMoney('bank', Config.Marriage.ceremonyCost)
    elseif xPlayer.getMoney() >= Config.Marriage.ceremonyCost then
        xPlayer.removeMoney(Config.Marriage.ceremonyCost)
    else
        return cb(false, ('Toy mərasimi üçün ~y~%s$~s~ lazımdır!'):format(Config.Marriage.ceremonyCost))
    end

    local now = os.time()

    MySQL.update.await('UPDATE `196rp_marriages` SET `status` = ?, `married_at` = ? WHERE `identifier` IN (?, ?)',
        { 'married', now, xPlayer.identifier, row.partner })

    TriggerClientEvent('esx:showNotification', -1,
        ('💍 ~g~%s~s~ və ~g~%s~s~ evləndi! Təbrik edirik!'):format(NameOf(xPlayer), NameOf(xPartner)), 'success')

    cb(true, '~g~Təbriklər!~s~ Artıq rəsmən evlisiniz.')
end)

ESX.RegisterServerCallback('196rp_social:divorce', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local row = MySQL.single.await('SELECT `partner`, `status` FROM `196rp_marriages` WHERE `identifier` = ?',
        { xPlayer.identifier })

    if not row or row.status ~= 'married' then
        return cb(false, 'Siz evli deyilsiniz!')
    end

    MySQL.update.await('DELETE FROM `196rp_marriages` WHERE `identifier` IN (?, ?)',
        { xPlayer.identifier, row.partner })

    local xPartner = ESX.GetPlayerFromIdentifier(row.partner)
    if xPartner then
        Notify(xPartner.source, ('~r~%s~s~ sizdən boşandı.'):format(NameOf(xPlayer)), 'error')
    end

    cb(true, '~y~Boşanma rəsmiləşdi.~s~')
end)

-- ==================== 99. DOSTLUQ ====================

ESX.RegisterServerCallback('196rp_social:addFriend', function(source, cb, targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local target = ESX.GetPlayerFromId(tonumber(targetId) or 0)

    if not xPlayer or not target then
        return cb(false, 'Oyunçu tapılmadı!')
    end

    if target.source == source then
        return cb(false, 'Özünüzü dost siyahısına əlavə edə bilməzsiniz!')
    end

    if Distance(source, target.source) > Config.Friend.maxDistance then
        return cb(false, 'Oyunçu çox uzaqdadır!')
    end

    local count = MySQL.scalar.await('SELECT COUNT(*) FROM `196rp_friends` WHERE `identifier` = ?', { xPlayer.identifier })

    if (tonumber(count) or 0) >= Config.Friend.maxFriends then
        return cb(false, ('Dost siyahısı doludur! Limit: %s'):format(Config.Friend.maxFriends))
    end

    local exists = MySQL.scalar.await(
        'SELECT COUNT(*) FROM `196rp_friends` WHERE `identifier` = ? AND `friend` = ?',
        { xPlayer.identifier, target.identifier })

    if (tonumber(exists) or 0) > 0 then
        return cb(false, 'Bu oyunçu artıq dost siyahınızda var!')
    end

    MySQL.insert.await('INSERT INTO `196rp_friends` (`identifier`, `friend`) VALUES (?, ?)',
        { xPlayer.identifier, target.identifier })

    MySQL.insert.await('INSERT IGNORE INTO `196rp_friends` (`identifier`, `friend`) VALUES (?, ?)',
        { target.identifier, xPlayer.identifier })

    Notify(target.source, ('~g~👥 %s~s~ sizi dost siyahısına əlavə etdi.'):format(NameOf(xPlayer)), 'success')

    cb(true, ('~g~%s~s~ dost siyahınıza əlavə edildi.'):format(NameOf(target)))
end)

ESX.RegisterServerCallback('196rp_social:getFriends', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb({})
    end

    local rows = MySQL.query.await(
        'SELECT `friend` FROM `196rp_friends` WHERE `identifier` = ? ORDER BY `friend`',
        { xPlayer.identifier }) or {}

    local list = {}

    for i = 1, #rows do
        local friendId = rows[i].friend
        local xFriend = ESX.GetPlayerFromIdentifier(friendId)
        local marr = MySQL.scalar.await(
            "SELECT COUNT(*) FROM `196rp_marriages` WHERE `identifier` = ? AND `status` = 'married'", { friendId })

        list[#list + 1] = {
            identifier = friendId,
            name = GetUserName(friendId),
            online = xFriend ~= nil,
            married = (tonumber(marr) or 0) > 0,
        }
    end

    cb(list)
end)

ESX.RegisterServerCallback('196rp_social:removeFriend', function(source, cb, identifier)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    MySQL.update.await('DELETE FROM `196rp_friends` WHERE (`identifier` = ? AND `friend` = ?) OR (`identifier` = ? AND `friend` = ?)',
        { xPlayer.identifier, identifier, identifier, xPlayer.identifier })

    cb(true, '~g~Dostluq silindi.~s~')
end)

ESX.RegisterServerCallback('196rp_social:sendMoney', function(source, cb, identifier, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    amount = math.floor(tonumber(amount) or 0)
    if amount < 1 then
        return cb(false, 'Yanlış məbləğ!')
    end

    local isFriend = MySQL.scalar.await(
        'SELECT COUNT(*) FROM `196rp_friends` WHERE `identifier` = ? AND `friend` = ?',
        { xPlayer.identifier, identifier })

    if (tonumber(isFriend) or 0) == 0 then
        return cb(false, 'Yalnız dostunuza pul göndərə bilərsiniz!')
    end

    local bank = xPlayer.getAccount('bank')
    if not bank or bank.money < amount then
        return cb(false, 'Bankda kifayət qədər pul yoxdur!')
    end

    xPlayer.removeAccountMoney('bank', amount)

    local xTarget = ESX.GetPlayerFromIdentifier(identifier)

    if xTarget then
        xTarget.addAccountMoney('bank', amount)
    else
        MySQL.update.await(
            "UPDATE `users` SET `accounts` = JSON_SET(COALESCE(`accounts`, '{}'), '$.bank', CAST(JSON_UNQUOTE(JSON_EXTRACT(COALESCE(`accounts`, '{}'), '$.bank')) AS UNSIGNED) + ?) WHERE `identifier` = ?",
            { amount, identifier })
    end

    cb(true, ('~g~%s$ göndərildi.~s~'):format(amount))
end)

ESX.RegisterServerCallback('196rp_social:getFriendPosition', function(source, cb, identifier)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false)
    end

    local isFriend = MySQL.scalar.await(
        'SELECT COUNT(*) FROM `196rp_friends` WHERE `identifier` = ? AND `friend` = ?',
        { xPlayer.identifier, identifier })

    if (tonumber(isFriend) or 0) == 0 then
        return cb(false)
    end

    local xTarget = ESX.GetPlayerFromIdentifier(identifier)
    if not xTarget then
        return cb(false)
    end

    local coords = GetEntityCoords(GetPlayerPed(xTarget.source))

    cb(true, { x = coords.x, y = coords.y, z = coords.z }, NameOf(xTarget))
end)

-- ==================== 100. MİSSİYALAR ====================

ESX.RegisterServerCallback('196rp_social:startMission', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, nil, 'Xəta baş verdi!')
    end

    if missions[source] then
        return cb(false, nil, 'Artıq aktiv missiyanız var!')
    end

    local now = os.time()
    if lastMission[source] and now - lastMission[source] < Config.Mission.cooldown then
        return cb(false, nil, ('Gözləyin: %s saniyə'):format(Config.Mission.cooldown - (now - lastMission[source])))
    end

    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - Config.Mission.board) > 20.0 then
        return cb(false, nil, 'Missiya lövhəsindən uzaqdasınız!')
    end

    local index = math.random(1, #Config.Missions)
    local m = Config.Missions[index]

    missions[source] = { index = index, startedAt = now }
    lastMission[source] = now

    cb(true, {
        index = index,
        label = m.label,
        coords = { x = m.target.x, y = m.target.y, z = m.target.z },
        radius = m.radius,
    }, ('~g~Missiya:~s~ %s\n%s'):format(m.label, m.description))
end)

ESX.RegisterServerCallback('196rp_social:finishMission', function(source, cb, index)
    local xPlayer = ESX.GetPlayerFromId(source)
    local data = missions[source]

    if not xPlayer or not data then
        return cb(false, 'Aktiv missiya yoxdur!')
    end

    if tonumber(index) ~= data.index then
        return cb(false, 'Missiya uyğun gəlmir!')
    end

    local m = Config.Missions[data.index]
    if not m then
        missions[source] = nil
        return cb(false, 'Missiya konfiqurasiyası tapılmadı!')
    end

    if os.time() - data.startedAt > Config.Mission.timeLimit then
        missions[source] = nil
        return cb(false, '~r~Missiyanın vaxtı bitdi!~s~')
    end

    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - m.target) > (m.radius + 5.0) then
        return cb(false, 'Missiya yerindən uzaqdasınız!')
    end

    missions[source] = nil

    local bonus = 0
    if os.time() - data.startedAt < 120 then
        bonus = math.floor(m.reward * 0.25)
    end

    xPlayer.addAccountMoney('bank', m.reward + bonus)

    cb(true, ('~g~%s tamamlandı!~s~ Ödəniş: ~y~%s$~s~%s'):format(
        m.label, m.reward, bonus > 0 and (' + sürət bonusu ~y~%s$~s~'):format(bonus) or ''))
end)

ESX.RegisterServerCallback('196rp_social:cancelMission', function(source, cb)
    missions[source] = nil
    cb(true)
end)

-- ==================== ÇIXIŞ ====================

AddEventHandler('playerDropped', function()
    local src = source

    proposals[src] = nil
    missions[src] = nil
    lastMission[src] = nil

    for target, data in pairs(proposals) do
        if data.from == src then
            proposals[target] = nil
        end
    end
end)

-- ==================== DİGƏR RESURSLAR ÜÇÜN ====================

exports('GetSpouse', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return nil
    end

    local row = MySQL.single.await(
        "SELECT `partner` FROM `196rp_marriages` WHERE `identifier` = ? AND `status` = 'married'",
        { xPlayer.identifier })

    return row and row.partner or nil
end)
