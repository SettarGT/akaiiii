-- 196 RP | Tuninq — server tərəfi
-- Ödəniş yoxlaması: pul kifayət edirsə silir, əks halda rədd edir.

local ESX = exports['es_extended']:getSharedObject()

ESX.RegisterServerCallback('196rp_tuning:pay', function(source, cb, price, label)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false)
    end

    price = tonumber(price) or 0
    if price <= 0 then
        return cb(false)
    end

    if xPlayer.getMoney() < price then
        TriggerClientEvent('esx:showNotification', source,
            ('Pulunuz kifayət etmir! %s üçün ~y~%s$~s~ lazımdır.'):format(label or 'Hissə', price), 'error')
        return cb(false)
    end

    xPlayer.removeMoney(price)
    TriggerClientEvent('esx:showNotification', source,
        ('~g~%s quraşdırıldı!~s~ Ödəniş: ~y~%s$~s~'):format(label or 'Hissə', price), 'success')
    cb(true)
end)
