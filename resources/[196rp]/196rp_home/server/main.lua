-- 196 RP | Ev daxili imkanlar — server tərəfi
-- Açarlar, seyf, divar rəngi, icarə, qonaqlar, yataq (spawn), balkon

local ESX = exports['es_extended']:getSharedObject()

-- ==================== KÖMƏKÇİLƏR ====================

local function Notify(src, msg, typ)
    TriggerClientEvent('esx:showNotification', src, msg, typ or 'info', 6000)
end

local function HouseExists(houseId)
    return Config.GetHouse(houseId) ~= nil
end

local function GetOwnerIdentifier(houseId)
    local row = MySQL.single.await('SELECT `owner` FROM `196rp_houses` WHERE `house_id` = ?', { houseId })
    return row and row.owner or nil
end

local function IsOwner(xPlayer, houseId)
    local owner = GetOwnerIdentifier(houseId)
    return owner ~= nil and owner == xPlayer.identifier
end

local function HasAccess(xPlayer, houseId)
    if IsOwner(xPlayer, houseId) then
        return true
    end

    local n = MySQL.scalar.await([[
        SELECT COUNT(*) FROM (
            SELECT `house_id` FROM `196rp_house_keys` WHERE `identifier` = ? AND `house_id` = ?
            UNION ALL
            SELECT `house_id` FROM `196rp_house_guests` WHERE `identifier` = ? AND `house_id` = ?
            UNION ALL
            SELECT `house_id` FROM `196rp_house_rentals` WHERE `renter` = ? AND `house_id` = ? AND `active` = 1
        ) AS t
    ]], { xPlayer.identifier, houseId, xPlayer.identifier, houseId, xPlayer.identifier, houseId })

    return (tonumber(n) or 0) > 0
end

local function InsideHouse(src)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then
        return false
    end
    return #(GetEntityCoords(ped) - Config.Interior) < Config.InteriorDist
end

local function GetSettings(houseId)
    local row = MySQL.single.await(
        'SELECT * FROM `196rp_house_settings` WHERE `house_id` = ?', { houseId })

    if not row then
        MySQL.insert.await('INSERT INTO `196rp_house_settings` (`house_id`) VALUES (?)', { houseId })
        row = MySQL.single.await('SELECT * FROM `196rp_house_settings` WHERE `house_id` = ?', { houseId })
    end

    return row
end

local function NameOf(xPlayer)
    if not xPlayer then
        return 'naməlum'
    end
    return xPlayer.getName()
end

-- ==================== İCARƏ MÜDDƏTİ / GƏLİR ====================

CreateThread(function()
    while true do
        Wait(60000)

        -- Müddəti bitmiş icarələri bağla
        local rows = MySQL.query.await(
            'SELECT `id`, `started_at` FROM `196rp_house_rentals` WHERE `active` = 1 AND `renter` IS NOT NULL') or {}

        for i = 1, #rows do
            local elapsedHours = (os.time() - (rows[i].started_at or 0)) / 3600
            if elapsedHours >= Config.Rent.periodHours then
                MySQL.update.await('UPDATE `196rp_house_rentals` SET `renter` = NULL, `started_at` = 0 WHERE `id` = ?',
                    { rows[i].id })
            end
        end

        -- Offlayn sahiblərə icarə gəliri
        local pending = MySQL.query.await(
            'SELECT `id`, `owner`, `price` FROM `196rp_house_rentals` WHERE `paid_out` = 0 AND `renter` IS NOT NULL') or {}

        for i = 1, #pending do
            local xOwner = ESX.GetPlayerFromIdentifier(pending[i].owner)
            if xOwner then
                xOwner.addAccountMoney('bank', pending[i].price)
                Notify(xOwner.source,
                    ('~g~Ev icarəsi gəliri:~s~ +%s$'):format(pending[i].price), 'success')
                MySQL.update.await('UPDATE `196rp_house_rentals` SET `paid_out` = 1 WHERE `id` = ?', { pending[i].id })
            end
        end
    end
end)

-- ==================== EV MƏLUMATI ====================

ESX.RegisterServerCallback('196rp_home:getAccessHouse', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(nil, nil)
    end

    -- Sahib olduğu, açarı olan, qonağı olduğu və ya kirayələdiyi ilk ev
    local rows = MySQL.query.await([[
        SELECT h.`house_id` FROM `196rp_houses` h
        WHERE h.`owner` = ?
        UNION
        SELECT k.`house_id` FROM `196rp_house_keys` k
        JOIN `196rp_houses` h2 ON h2.`house_id` = k.`house_id`
        WHERE k.`identifier` = ?
        UNION
        SELECT g.`house_id` FROM `196rp_house_guests` g
        JOIN `196rp_houses` h3 ON h3.`house_id` = g.`house_id`
        WHERE g.`identifier` = ?
        UNION
        SELECT r.`house_id` FROM `196rp_house_rentals` r
        WHERE r.`renter` = ? AND r.`active` = 1
    ]], { xPlayer.identifier, xPlayer.identifier, xPlayer.identifier, xPlayer.identifier }) or {}

    if #rows == 0 then
        return cb(nil, nil)
    end

    local houseId = rows[1].house_id
    local house = Config.GetHouse(houseId)
    local settings = GetSettings(houseId)

    cb({
        house_id = houseId,
        name = house and house.name or houseId,
    }, settings and settings.wall_color or nil)
end)

-- ==================== 74. DİVAR RƏNGİ ====================

ESX.RegisterServerCallback('196rp_home:setWallColor', function(source, cb, houseId, colorIndex)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not HouseExists(houseId) then
        return cb(false, 'Xəta baş verdi!')
    end

    if not IsOwner(xPlayer, houseId) then
        return cb(false, 'Yalnız ev sahibi divar rəngini dəyişə bilər!')
    end

    colorIndex = tonumber(colorIndex) or 1
    if not Config.WallColors[colorIndex] then
        return cb(false, 'Belə bir rəng yoxdur!')
    end

    GetSettings(houseId)
    MySQL.update.await('UPDATE `196rp_house_settings` SET `wall_color` = ? WHERE `house_id` = ?',
        { colorIndex, houseId })

    cb(true, ('~g~Divar rəngi: %s~s~'):format(Config.WallColors[colorIndex].label))
end)

-- ==================== 73. SEYF ====================

ESX.RegisterServerCallback('196rp_home:getSafe', function(source, cb, houseId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not HouseExists(houseId) then
        return cb(false, 0, {})
    end

    if not HasAccess(xPlayer, houseId) then
        return cb(false, 0, {})
    end

    local row = MySQL.single.await('SELECT `money`, `items` FROM `196rp_house_safes` WHERE `house_id` = ?', { houseId })

    if not row then
        return cb(false, 0, {})   -- seyf alınmayıb
    end

    local items = {}
    if row.items and row.items ~= '' then
        local decoded = json.decode(row.items)
        if type(decoded) == 'table' then
            for item, count in pairs(decoded) do
                local meta = MySQL.single.await('SELECT `label` FROM `items` WHERE `name` = ?', { item })
                items[#items + 1] = { item = item, count = count, label = meta and meta.label or item }
            end
        end
    end

    cb(true, row.money or 0, items)
end)

ESX.RegisterServerCallback('196rp_home:buySafe', function(source, cb, houseId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not HouseExists(houseId) then
        return cb(false, 'Xəta baş verdi!')
    end

    if not IsOwner(xPlayer, houseId) then
        return cb(false, 'Seyfi yalnız ev sahibi ala bilər!')
    end

    local exists = MySQL.scalar.await('SELECT COUNT(*) FROM `196rp_house_safes` WHERE `house_id` = ?', { houseId })
    if (tonumber(exists) or 0) > 0 then
        return cb(false, 'Bu evdə artıq seyf var!')
    end

    if xPlayer.getMoney() >= Config.Safe.price then
        xPlayer.removeMoney(Config.Safe.price)
    else
        local bank = xPlayer.getAccount('bank')
        if bank and bank.money >= Config.Safe.price then
            xPlayer.removeAccountMoney('bank', Config.Safe.price)
        else
            return cb(false, ('Pulunuz kifayət etmir! Lazımdır: ~y~%s$~s~'):format(Config.Safe.price))
        end
    end

    MySQL.insert.await('INSERT INTO `196rp_house_safes` (`house_id`, `money`, `items`) VALUES (?, 0, ?)',
        { houseId, json.encode({}) })

    cb(true, ('~g~Seyf quraşdırıldı!~s~ Ödəniş: %s$'):format(Config.Safe.price))
end)

ESX.RegisterServerCallback('196rp_home:depositMoney', function(source, cb, houseId, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not HouseExists(houseId) then
        return cb(false, 'Xəta baş verdi!')
    end

    amount = math.floor(tonumber(amount) or 0)
    if amount < 1 then
        return cb(false, 'Yanlış məbləğ!')
    end

    if not HasAccess(xPlayer, houseId) or not InsideHouse(source) then
        return cb(false, 'Seyfin yanında deyilsiniz!')
    end

    if xPlayer.getMoney() < amount then
        return cb(false, 'Üzərinizdə bu qədər nağd pul yoxdur!')
    end

    local row = MySQL.single.await('SELECT `money` FROM `196rp_house_safes` WHERE `house_id` = ?', { houseId })
    if not row then
        return cb(false, 'Bu evdə seyf yoxdur!')
    end

    if (row.money or 0) + amount > Config.Safe.maxMoney then
        return cb(false, ('Seyf doludur! Limit: ~y~%s$~s~'):format(Config.Safe.maxMoney))
    end

    xPlayer.removeMoney(amount)
    MySQL.update.await('UPDATE `196rp_house_safes` SET `money` = `money` + ? WHERE `house_id` = ?',
        { amount, houseId })

    cb(true, ('~g~%s$ seyfə qoyuldu.~s~'):format(amount))
end)

ESX.RegisterServerCallback('196rp_home:withdrawMoney', function(source, cb, houseId, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not HouseExists(houseId) then
        return cb(false, 'Xəta baş verdi!')
    end

    amount = math.floor(tonumber(amount) or 0)
    if amount < 1 then
        return cb(false, 'Yanlış məbləğ!')
    end

    if not HasAccess(xPlayer, houseId) or not InsideHouse(source) then
        return cb(false, 'Seyfin yanında deyilsiniz!')
    end

    local row = MySQL.single.await('SELECT `money` FROM `196rp_house_safes` WHERE `house_id` = ?', { houseId })
    if not row or (row.money or 0) < amount then
        return cb(false, 'Seyfdə bu qədər pul yoxdur!')
    end

    MySQL.update.await('UPDATE `196rp_house_safes` SET `money` = `money` - ? WHERE `house_id` = ?',
        { amount, houseId })
    xPlayer.addMoney(amount)

    cb(true, ('~g~%s$ seyfdən götürüldü.~s~'):format(amount))
end)

ESX.RegisterServerCallback('196rp_home:depositItem', function(source, cb, houseId, item, count)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not HouseExists(houseId) then
        return cb(false, 'Xəta baş verdi!')
    end

    item = tostring(item or ''):lower()
    count = math.floor(tonumber(count) or 0)

    if item == '' or count < 1 then
        return cb(false, 'Yanlış əşya və ya miqdar!')
    end

    if not HasAccess(xPlayer, houseId) or not InsideHouse(source) then
        return cb(false, 'Seyfin yanında deyilsiniz!')
    end

    local inv = xPlayer.getInventoryItem(item)
    if not inv or inv.count < count then
        return cb(false, 'Sizdə bu qədər əşya yoxdur!')
    end

    local row = MySQL.single.await('SELECT `items` FROM `196rp_house_safes` WHERE `house_id` = ?', { houseId })
    if not row then
        return cb(false, 'Bu evdə seyf yoxdur!')
    end

    local items = {}
    if row.items and row.items ~= '' then
        local decoded = json.decode(row.items)
        if type(decoded) == 'table' then
            items = decoded
        end
    end

    local total = 0
    for _, c in pairs(items) do
        total = total + (tonumber(c) or 0)
    end

    if total + count > Config.Safe.maxItems then
        return cb(false, ('Seyf doludur! Limit: %s əşya'):format(Config.Safe.maxItems))
    end

    xPlayer.removeInventoryItem(item, count)
    items[item] = (items[item] or 0) + count

    MySQL.update.await('UPDATE `196rp_house_safes` SET `items` = ? WHERE `house_id` = ?',
        { json.encode(items), houseId })

    cb(true, ('~g~%s ədəd %s seyfə qoyuldu.~s~'):format(count, item))
end)

ESX.RegisterServerCallback('196rp_home:withdrawItem', function(source, cb, houseId, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not HouseExists(houseId) then
        return cb(false, 'Xəta baş verdi!')
    end

    item = tostring(item or ''):lower()

    if not HasAccess(xPlayer, houseId) or not InsideHouse(source) then
        return cb(false, 'Seyfin yanında deyilsiniz!')
    end

    local row = MySQL.single.await('SELECT `items` FROM `196rp_house_safes` WHERE `house_id` = ?', { houseId })
    if not row or not row.items or row.items == '' then
        return cb(false, 'Seyfdə əşya yoxdur!')
    end

    local items = json.decode(row.items) or {}
    local count = tonumber(items[item]) or 0

    if count < 1 then
        return cb(false, 'Seyfdə bu əşya yoxdur!')
    end

    if not xPlayer.canCarryItem(item, count) then
        return cb(false, 'Çantanızda yer yoxdur!')
    end

    items[item] = nil
    xPlayer.addInventoryItem(item, count)

    MySQL.update.await('UPDATE `196rp_house_safes` SET `items` = ? WHERE `house_id` = ?',
        { json.encode(items), houseId })

    cb(true, ('~g~%s ədəd %s götürüldü.~s~'):format(count, item))
end)

-- ==================== 71. AÇARLAR / 79. QONAQLAR ====================

local function ListPeople(tbl, houseId)
    local rows = MySQL.query.await(
        ('SELECT `identifier` FROM `%s` WHERE `house_id` = ?'):format(tbl), { houseId }) or {}

    local list = {}
    for i = 1, #rows do
        local user = MySQL.single.await(
            'SELECT `firstname`, `lastname` FROM `users` WHERE `identifier` = ?', { rows[i].identifier })
        local xTarget = ESX.GetPlayerFromIdentifier(rows[i].identifier)

        list[#list + 1] = {
            identifier = rows[i].identifier,
            name = user and (('%s %s'):format(user.firstname or '?', user.lastname or '?')) or rows[i].identifier,
            source = xTarget and xTarget.source or nil,
        }
    end

    return list
end

ESX.RegisterServerCallback('196rp_home:getKeys', function(source, cb, houseId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not HouseExists(houseId) or not IsOwner(xPlayer, houseId) then
        return cb({})
    end
    cb(ListPeople('196rp_house_keys', houseId))
end)

ESX.RegisterServerCallback('196rp_home:getGuests', function(source, cb, houseId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not HouseExists(houseId) or not IsOwner(xPlayer, houseId) then
        return cb({})
    end
    cb(ListPeople('196rp_house_guests', houseId))
end)

local function AddPerson(source, tbl, houseId, targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local target = ESX.GetPlayerFromId(tonumber(targetId) or 0)

    if not xPlayer or not target then
        return false, 'Oyunçu tapılmadı!'
    end

    if not HouseExists(houseId) then
        return false, 'Belə bir ev yoxdur!'
    end

    if not IsOwner(xPlayer, houseId) then
        return false, 'Yalnız ev sahibi icazə verə bilər!'
    end

    if target.identifier == xPlayer.identifier then
        return false, 'Özünüzə icazə verə bilməzsiniz!'
    end

    local exists = MySQL.scalar.await(
        ('SELECT COUNT(*) FROM `%s` WHERE `house_id` = ? AND `identifier` = ?'):format(tbl),
        { houseId, target.identifier })

    if (tonumber(exists) or 0) > 0 then
        return false, 'Bu oyunçuda artıq icazə var!'
    end

    MySQL.insert.await(('INSERT INTO `%s` (`house_id`, `identifier`) VALUES (?, ?)'):format(tbl),
        { houseId, target.identifier })

    TriggerClientEvent('196rp_home:refresh', target.source)

    return true, ('~g~%s~s~ üçün giriş icazəsi verildi.'):format(NameOf(target))
end

local function RemovePerson(source, tbl, houseId, identifier)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or not HouseExists(houseId) then
        return false, 'Xəta baş verdi!'
    end

    if not IsOwner(xPlayer, houseId) then
        return false, 'Yalnız ev sahibi icazəni ləğv edə bilər!'
    end

    MySQL.update.await(('DELETE FROM `%s` WHERE `house_id` = ? AND `identifier` = ?'):format(tbl),
        { houseId, identifier })

    local xTarget = ESX.GetPlayerFromIdentifier(identifier)
    if xTarget then
        TriggerClientEvent('196rp_home:refresh', xTarget.source)
    end

    return true, '~g~Giriş icazəsi ləğv edildi.~s~'
end

ESX.RegisterServerCallback('196rp_home:giveKey', function(source, cb, houseId, targetId)
    local ok, msg = AddPerson(source, '196rp_house_keys', houseId, targetId)
    cb(ok, msg)
end)

ESX.RegisterServerCallback('196rp_home:revokeKey', function(source, cb, houseId, identifier)
    local ok, msg = RemovePerson(source, '196rp_house_keys', houseId, identifier)
    cb(ok, msg)
end)

ESX.RegisterServerCallback('196rp_home:addGuest', function(source, cb, houseId, targetId)
    local ok, msg = AddPerson(source, '196rp_house_guests', houseId, targetId)
    cb(ok, msg)
end)

ESX.RegisterServerCallback('196rp_home:removeGuest', function(source, cb, houseId, identifier)
    local ok, msg = RemovePerson(source, '196rp_house_guests', houseId, identifier)
    cb(ok, msg)
end)

-- ==================== 75. İCARƏ ====================

ESX.RegisterServerCallback('196rp_home:listRent', function(source, cb, houseId, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not HouseExists(houseId) then
        return cb(false, 'Xəta baş verdi!')
    end

    if not IsOwner(xPlayer, houseId) then
        return cb(false, 'Yalnız ev sahibi icarəyə verə bilər!')
    end

    price = math.floor(tonumber(price) or 0)
    if price < Config.Rent.minPrice or price > Config.Rent.maxPrice then
        return cb(false, ('Qiymət %s - %s aralığında olmalıdır!'):format(Config.Rent.minPrice, Config.Rent.maxPrice))
    end

    local exists = MySQL.scalar.await(
        'SELECT COUNT(*) FROM `196rp_house_rentals` WHERE `house_id` = ? AND `renter` IS NOT NULL', { houseId })
    if (tonumber(exists) or 0) > 0 then
        return cb(false, 'Bu ev artıq kirayədədir!')
    end

    MySQL.update.await([[
        INSERT INTO `196rp_house_rentals` (`house_id`, `owner`, `price`, `active`, `paid_out`)
        VALUES (?, ?, ?, 1, 0)
        ON DUPLICATE KEY UPDATE `owner` = VALUES(`owner`), `price` = VALUES(`price`),
                                `active` = 1, `renter` = NULL, `paid_out` = 0, `started_at` = 0
    ]], { houseId, xPlayer.identifier, price })

    cb(true, ('~g~Ev %s$ qiymətinə icarəyə çıxarıldı.~s~ /ev menyusundan baxıla bilər.'):format(price))
end)

ESX.RegisterServerCallback('196rp_home:stopRent', function(source, cb, houseId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not HouseExists(houseId) then
        return cb(false, 'Xəta baş verdi!')
    end

    if not IsOwner(xPlayer, houseId) then
        return cb(false, 'Yalnız ev sahibi icarəni dayandıra bilər!')
    end

    MySQL.update.await('UPDATE `196rp_house_rentals` SET `active` = 0, `renter` = NULL WHERE `house_id` = ?', { houseId })

    cb(true, '~g~İcarə dayandırıldı.~s~')
end)

ESX.RegisterServerCallback('196rp_home:getRentals', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb({})
    end

    local rows = MySQL.query.await(
        'SELECT `house_id`, `price` FROM `196rp_house_rentals` WHERE `active` = 1 AND `renter` IS NULL') or {}

    local list = {}
    for i = 1, #rows do
        local house = Config.GetHouse(rows[i].house_id)
        list[#list + 1] = {
            house_id = rows[i].house_id,
            name = house and house.name or rows[i].house_id,
            price = rows[i].price,
        }
    end

    cb(list)
end)

ESX.RegisterServerCallback('196rp_home:rentHouse', function(source, cb, houseId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not HouseExists(houseId) then
        return cb(false, 'Xəta baş verdi!')
    end

    local row = MySQL.single.await(
        'SELECT `id`, `owner`, `price` FROM `196rp_house_rentals` WHERE `house_id` = ? AND `active` = 1 AND `renter` IS NULL',
        { houseId })

    if not row then
        return cb(false, 'Bu ev icarədə deyil!')
    end

    if row.owner == xPlayer.identifier then
        return cb(false, 'Öz evinizi kirayəyə götürə bilməzsiniz!')
    end

    local total = row.price + math.floor(row.price * Config.Rent.depositMult)

    local bank = xPlayer.getAccount('bank')
    if bank and bank.money >= total then
        xPlayer.removeAccountMoney('bank', total)
    elseif xPlayer.getMoney() >= total then
        xPlayer.removeMoney(total)
    else
        return cb(false, ('Pulunuz kifayət etmir! Lazımdır: ~y~%s$~s~ (icərisində depozit var)'):format(total))
    end

    MySQL.update.await(
        'UPDATE `196rp_house_rentals` SET `renter` = ?, `started_at` = ?, `paid_out` = 0 WHERE `id` = ?',
        { xPlayer.identifier, os.time(), row.id })

    -- Depozit geri qaytarılır, kirayə haqqı sahibə gedir
    xPlayer.addAccountMoney('bank', math.floor(row.price * Config.Rent.depositMult))

    local house = Config.GetHouse(houseId)

    cb(true, ('~g~%s~s~ evini %s saatlıq kirayəyə götürdünüz! Ödəniş: ~y~%s$~s~'):format(
        house and house.name or houseId, Config.Rent.periodHours, row.price))
end)

-- ==================== 80. YATAQ / 78. BALKON ====================

ESX.RegisterServerCallback('196rp_home:sleep', function(source, cb, houseId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not HouseExists(houseId) then
        return cb(false, 'Xəta baş verdi!')
    end

    if not HasAccess(xPlayer, houseId) then
        return cb(false, 'Bu evə giriş icazəniz yoxdur!')
    end

    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - Config.Points.bed) > 5.0 then
        return cb(false, 'Yatağın yanında deyilsiniz!')
    end

    GetSettings(houseId)
    MySQL.update.await([[
        UPDATE `196rp_house_settings`
        SET `spawn_x` = ?, `spawn_y` = ?, `spawn_z` = ?, `spawn_h` = ?, `spawn_house` = ?
        WHERE `house_id` = ?
    ]], { Config.Points.bed.x, Config.Points.bed.y, Config.Points.bed.z, 0.0, houseId, houseId })

    -- Stress azaldılması (196rp_lifestyle varsa)
    if GetResourceState('196rp_lifestyle') == 'started' then
        exports['196rp_lifestyle']:AddStress(source, -Config.Bed.stressRelief)
    end

    cb(true, '~g~Yatdınız və doğulma nöqtəsi olaraq eviniz seçildi.~s~')
end)

ESX.RegisterServerCallback('196rp_home:relax', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    if not InsideHouse(source) then
        return cb(false, 'Ev daxilində deyilsiniz!')
    end

    if GetResourceState('196rp_lifestyle') == 'started' then
        exports['196rp_lifestyle']:AddStress(source, -Config.Balcony.stressRelief)
    end

    cb(true, ('~g~Dincəldiniz.~s~ Stress -%s'):format(Config.Balcony.stressRelief))
end)

-- ==================== GİRİŞDƏ SPAWN ====================

AddEventHandler('esx:playerLoaded', function(source, xPlayer)
    Wait(4000)

    local row = MySQL.single.await([[
        SELECT s.`spawn_x`, s.`spawn_y`, s.`spawn_z`, s.`spawn_h`
        FROM `196rp_house_settings` s
        JOIN `196rp_houses` h ON h.`house_id` = s.`spawn_house`
        WHERE s.`spawn_house` IS NOT NULL AND h.`owner` = ?
        LIMIT 1
    ]], { xPlayer.identifier })

    if row and row.spawn_x and row.spawn_y then
        TriggerClientEvent('196rp_home:goSpawn', source,
            { x = row.spawn_x, y = row.spawn_y, z = row.spawn_z }, row.spawn_h or 0.0)
    end

    TriggerClientEvent('196rp_home:refresh', source)
end)

-- Ev satılanda təmizlik
AddEventHandler('196rp_housing:sold', function(houseId)
    MySQL.update.await('DELETE FROM `196rp_house_keys` WHERE `house_id` = ?', { houseId })
    MySQL.update.await('DELETE FROM `196rp_house_guests` WHERE `house_id` = ?', { houseId })
    MySQL.update.await('DELETE FROM `196rp_house_rentals` WHERE `house_id` = ?', { houseId })
end)

-- ==================== DİGƏR RESURSLAR ÜÇÜN ====================

exports('CanEnterHouse', function(source, houseId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or not HouseExists(houseId) then
        return false
    end
    return HasAccess(xPlayer, houseId)
end)
