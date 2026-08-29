-- 196 RP | Daşınmaz əmlak — server tərəfi
-- Ev alışı / satışı / qıfıl

local ESX = exports['es_extended']:getSharedObject()

-- ==================== EVLƏRİN VƏZİYYƏTİ ====================

ESX.RegisterServerCallback('196rp_housing:getHouses', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb({})
    end

    local rows = MySQL.query.await(
        'SELECT `house_id`, `owner`, `locked` FROM `196rp_houses` WHERE `owner` IS NOT NULL'
    ) or {}

    local result = {}
    for i = 1, #rows do
        result[rows[i].house_id] = {
            owned = rows[i].owner == xPlayer.identifier,
            locked = (rows[i].locked or 0) == 1
        }
    end

    cb(result)
end)

ESX.RegisterServerCallback('196rp_housing:getOwnedHouses', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb({})
    end

    local rows = MySQL.query.await(
        'SELECT `house_id` FROM `196rp_houses` WHERE `owner` = ?',
        { xPlayer.identifier }
    ) or {}

    local list = {}
    for i = 1, #rows do
        local house = Config.GetHouse(rows[i].house_id)
        list[#list + 1] = {
            house_id = rows[i].house_id,
            name = house and house.name or rows[i].house_id
        }
    end

    cb(list)
end)

-- ==================== ALIŞ ====================

ESX.RegisterServerCallback('196rp_housing:buyHouse', function(source, cb, houseId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local house = Config.GetHouse(houseId)
    if not house then
        return cb(false, 'Belə bir ev yoxdur!')
    end

    local existing = MySQL.single.await('SELECT `owner` FROM `196rp_houses` WHERE `house_id` = ?', { houseId })
    if existing and existing.owner then
        return cb(false, 'Bu ev artıq satılıb!')
    end

    local price = house.price
    local bank = xPlayer.getAccount('bank')
    local bankMoney = bank and bank.money or 0

    if bankMoney >= price then
        xPlayer.removeAccountMoney('bank', price)
    elseif xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
    else
        return cb(false, ('Pulunuz kifayət etmir! Qiymət: ~y~%s$~s~'):format(price))
    end

    MySQL.prepare.await(
        'INSERT INTO `196rp_houses` (`house_id`, `owner`, `price`, `locked`) VALUES (?, ?, ?, 0) ON DUPLICATE KEY UPDATE `owner` = VALUES(`owner`), `price` = VALUES(`price`)',
        { houseId, xPlayer.identifier, price }
    )

    cb(true, ('~g~Təbriklər!~s~ %s artıq sizindir.\nÖdəniş: ~y~%s$~s~'):format(house.name, price))
end)

-- ==================== SATIŞ ====================

ESX.RegisterServerCallback('196rp_housing:sellHouse', function(source, cb, houseId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local house = Config.GetHouse(houseId)
    if not house then
        return cb(false, 'Belə bir ev yoxdur!')
    end

    local row = MySQL.single.await('SELECT `owner` FROM `196rp_houses` WHERE `house_id` = ?', { houseId })
    if not row or row.owner ~= xPlayer.identifier then
        return cb(false, 'Bu ev sizə məxsus deyil!')
    end

    local refund = math.floor(house.price * 0.75)
    xPlayer.addAccountMoney('bank', refund)

    MySQL.update.await('UPDATE `196rp_houses` SET `owner` = NULL, `locked` = 0 WHERE `house_id` = ?', { houseId })

    cb(true, ('~g~%s satıldı!~s~ Bankınıza ~y~%s$~s~ köçürüldü.'):format(house.name, refund))
end)

-- ==================== QIFIL ====================

ESX.RegisterServerCallback('196rp_housing:toggleLock', function(source, cb, houseId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false)
    end

    local row = MySQL.single.await('SELECT `owner`, `locked` FROM `196rp_houses` WHERE `house_id` = ?', { houseId })
    if not row or row.owner ~= xPlayer.identifier then
        TriggerClientEvent('esx:showNotification', source, 'Bu ev sizə məxsus deyil!', 'error')
        return cb(false)
    end

    local newLocked = (row.locked or 0) == 1 and 0 or 1
    MySQL.update.await('UPDATE `196rp_houses` SET `locked` = ? WHERE `house_id` = ?', { newLocked, houseId })

    cb(newLocked == 1)
end)
