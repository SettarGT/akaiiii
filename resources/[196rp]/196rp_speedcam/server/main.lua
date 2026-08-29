-- 196 RP | Sürət kameraları — server tərəfi
-- Sürəti aşan oyunçuya cərimə

local ESX = exports['es_extended']:getSharedObject()

-- [source] = son cərimə vaxtı (spam qorunması)
local lastFine = {}

ESX.RegisterServerCallback('196rp_speedcam:fine', function(source, cb, camName, limit, speed)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, nil)
    end

    camName = tostring(camName or '?')
    limit = tonumber(limit) or 50
    speed = tonumber(speed) or 0

    if speed <= limit then
        return cb(false, nil)
    end

    -- 30 saniyədə bir dəfədən çox cərimə yazılmır
    local now = os.time()
    if lastFine[source] and now - lastFine[source] < 30 then
        return cb(false, nil)
    end
    lastFine[source] = now

    local over = speed - limit
    local fine = math.min(Config.MaxFine, math.max(Config.MinFine, over * Config.FinePerKmh))

    -- Əvvəl nağd, sonra bank
    local paid = 0
    local fromCash = math.min(xPlayer.getMoney(), fine)
    if fromCash > 0 then
        xPlayer.removeMoney(fromCash)
        paid = fromCash
    end

    local remaining = fine - paid
    if remaining > 0 then
        local bank = xPlayer.getAccount('bank')
        local fromBank = math.min(bank and bank.money or 0, remaining)
        if fromBank > 0 then
            xPlayer.removeAccountMoney('bank', fromBank)
            paid = paid + fromBank
        end
    end

    if paid > 0 then
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_police', function(account)
            if account then
                account.addMoney(paid)
            end
        end)
    end

    cb(true, ('~r~📸 SÜRƏT KAMERASI (%s)~s~\nLimit: ~y~%s km/s~s~ | Sizin sürət: ~r~%s km/s~s~\nCərimə: ~r~%s$~s~')
        :format(camName, limit, speed, paid))
end)

AddEventHandler('playerDropped', function()
    lastFine[source] = nil
end)
