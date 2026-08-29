-- 196 RP | Bərbər və döymə salonu — server tərəfi
-- Döymələrin saxlanması və satın alınması

local ESX = exports['es_extended']:getSharedObject()

ESX.RegisterServerCallback('196rp_barber:getTattoos', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb({})
    end

    local row = MySQL.single.await('SELECT `tattoos` FROM `196rp_tattoos` WHERE `identifier` = ?',
        { xPlayer.identifier })

    if not row or not row.tattoos then
        return cb({})
    end

    local ok, decoded = pcall(json.decode, row.tattoos)
    if ok and type(decoded) == 'table' then
        return cb(decoded)
    end

    cb({})
end)

ESX.RegisterServerCallback('196rp_barber:buyTattoo', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false)
    end

    local price = Config.TattooPrice or 250

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
    else
        local bank = xPlayer.getAccount('bank')
        if bank and bank.money >= price then
            xPlayer.removeAccountMoney('bank', price)
        else
            return cb(false)
        end
    end

    cb(true)
end)

RegisterNetEvent('196rp_barber:saveTattoos', function(overlays)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or type(overlays) ~= 'table' then
        return
    end

    -- Yalnız icazə verilən kolleksiya/overlay formatı
    local clean = {}
    for i = 1, math.min(#overlays, 40) do
        local o = overlays[i]
        if type(o) == 'table' and type(o.collection) == 'string' and type(o.overlay) == 'string' then
            clean[#clean + 1] = { collection = o.collection, overlay = o.overlay }
        end
    end

    MySQL.prepare.await(
        'INSERT INTO `196rp_tattoos` (`identifier`, `tattoos`) VALUES (?, ?) ON DUPLICATE KEY UPDATE `tattoos` = VALUES(`tattoos`)',
        { xPlayer.identifier, json.encode(clean) }
    )
end)
