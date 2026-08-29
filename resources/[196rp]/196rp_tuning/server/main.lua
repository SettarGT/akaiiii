local QBCore = exports['qb-core']:GetCoreObject()

-- Ödəniş callback: nağd pul kifayət deyilsə bankdan çıxar
QBCore.Functions.CreateCallback('196rp_tuning:pay', function(source, cb, price, label)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        cb(false)
        return
    end
    price = tonumber(price)
    if not price or price <= 0 then
        cb(false)
        return
    end
    local cash = Player.Functions.GetMoney('cash')
    if cash >= price then
        Player.Functions.RemoveMoney('cash', price, '196rp_tuning: ' .. tostring(label))
        cb(true)
        return
    end
    local bank = Player.Functions.GetMoney('bank')
    if bank >= price then
        Player.Functions.RemoveMoney('bank', price, '196rp_tuning: ' .. tostring(label))
        cb(true)
        return
    end
    cb(false)
end)
