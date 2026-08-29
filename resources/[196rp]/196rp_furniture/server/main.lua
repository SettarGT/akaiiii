-- 196 RP | Mebel sistemi — server tərəfi
-- Mebel alışı, yerləşdirmə, anbara yığma, satış

local ESX = exports['es_extended']:getSharedObject()

local function FindFurniture(model)
    for i = 1, #Config.Furniture do
        if Config.Furniture[i].model == model then
            return Config.Furniture[i]
        end
    end
    return nil
end

local function OwnsHouse(identifier, houseId)
    local row = MySQL.single.await(
        'SELECT `owner` FROM `196rp_houses` WHERE `house_id` = ?',
        { houseId }
    )
    return row and row.owner == identifier
end

-- ==================== ALIŞ ====================

ESX.RegisterServerCallback('196rp_furniture:buy', function(source, cb, model, houseId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local item = FindFurniture(model)
    if not item then
        return cb(false, 'Belə bir mebel yoxdur!')
    end

    if not OwnsHouse(xPlayer.identifier, houseId) then
        return cb(false, 'Bu ev sizə məxsus deyil!')
    end

    -- Mağazaya yaxınlıq
    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - Config.Store.coords) > 30.0 then
        return cb(false, 'Mebel mağazasına yaxın deyilsiniz!')
    end

    if xPlayer.getMoney() < item.price then
        local bank = xPlayer.getAccount('bank')
        if not bank or bank.money < item.price then
            return cb(false, ('Pulunuz kifayət etmir! Qiymət: ~y~%s$~s~'):format(item.price))
        end
        xPlayer.removeAccountMoney('bank', item.price)
    else
        xPlayer.removeMoney(item.price)
    end

    MySQL.insert.await(
        'INSERT INTO `196rp_furniture` (`house_id`, `owner`, `model`, `label`, `placed`, `coords`, `rotation`) VALUES (?, ?, ?, ?, 0, NULL, 0)',
        { houseId, xPlayer.identifier, model, item.label }
    )

    cb(true, ('~g~%s alındı!~s~ Ödəniş: ~y~%s$~s~\nMebel anbarınızdadır — evdə yerləşdirin.'):format(item.label, item.price))
end)

-- ==================== SİYAHI ====================

ESX.RegisterServerCallback('196rp_furniture:getHouseFurniture', function(source, cb, houseId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb({})
    end

    if not OwnsHouse(xPlayer.identifier, houseId) then
        return cb({})
    end

    local rows = MySQL.query.await(
        'SELECT `id`, `model`, `label`, `placed`, `coords`, `rotation` FROM `196rp_furniture` WHERE `house_id` = ? ORDER BY `id` ASC',
        { houseId }
    ) or {}

    cb(rows)
end)

-- ==================== YERLƏŞDİRMƏ ====================

ESX.RegisterServerCallback('196rp_furniture:place', function(source, cb, furnitureId, coords, rotation)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false)
    end

    local row = MySQL.single.await(
        'SELECT `id`, `owner`, `house_id` FROM `196rp_furniture` WHERE `id` = ?',
        { tonumber(furnitureId) }
    )

    if not row or row.owner ~= xPlayer.identifier then
        return cb(false)
    end

    if type(coords) ~= 'table' then
        return cb(false)
    end

    local coordsJson = json.encode({
        x = tonumber(coords.x) or 0.0,
        y = tonumber(coords.y) or 0.0,
        z = tonumber(coords.z) or 0.0
    })

    MySQL.update.await(
        'UPDATE `196rp_furniture` SET `placed` = 1, `coords` = ?, `rotation` = ? WHERE `id` = ?',
        { coordsJson, tonumber(rotation) or 0.0, row.id }
    )

    cb(true)
end)

-- ==================== ANBARA YIĞMA ====================

ESX.RegisterServerCallback('196rp_furniture:unplace', function(source, cb, furnitureId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false)
    end

    local row = MySQL.single.await(
        'SELECT `id`, `owner` FROM `196rp_furniture` WHERE `id` = ?',
        { tonumber(furnitureId) }
    )

    if not row or row.owner ~= xPlayer.identifier then
        return cb(false)
    end

    MySQL.update.await('UPDATE `196rp_furniture` SET `placed` = 0, `coords` = NULL WHERE `id` = ?', { row.id })
    cb(true)
end)

-- ==================== SATIŞ ====================

ESX.RegisterServerCallback('196rp_furniture:sell', function(source, cb, furnitureId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local row = MySQL.single.await(
        'SELECT `id`, `owner`, `model` FROM `196rp_furniture` WHERE `id` = ?',
        { tonumber(furnitureId) }
    )

    if not row or row.owner ~= xPlayer.identifier then
        return cb(false, 'Bu mebel sizə məxsus deyil!')
    end

    local item = FindFurniture(row.model)
    local refund = math.floor((item and item.price or 1000) * 0.5)

    MySQL.update.await('DELETE FROM `196rp_furniture` WHERE `id` = ?', { row.id })
    xPlayer.addMoney(refund)

    cb(true, ('~g~Mebel satıldı!~s~ +~y~%s$~s~'):format(refund))
end)
