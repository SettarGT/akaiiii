local QBCore = exports['qb-core']:GetCoreObject()

-- Vergi dərəcəsi (it olsa müvəqqəti dəyişikliklər yadda qalmasın — sadəcə runtime)
local currentRate = Config.TaxRate

-- ── Export: digər resurslar istifadə edir ──
exports('GetRate', function()
    return currentRate
end)

exports('ApplyTax', function(amount)
    return math.floor(amount * (1 + currentRate / 100))
end)

-- ── Vergi yazılışı ──
local function LogTax(src, reason, amount)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    MySQL.insert('INSERT INTO 196_tax_logs (citizenid, reason, amount, created_at) VALUES (?, ?, ?, NOW())', {
        Player.PlayerData.citizenid, reason, amount,
    })
end

-- Export: vergini kəs və qeydə al
exports('ChargeTax', function(src, amount, reason)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return 0 end
    local tax = math.floor(amount * (currentRate / 100))
    if tax <= 0 then return 0 end
    -- Nağddan kəs, olmazsa bankdan
    if (Player.PlayerData.money.cash or 0) >= tax then
        Player.Functions.RemoveMoney('cash', tax, 'tax:' .. (reason or 'unknown'))
    else
        local rest = tax - (Player.PlayerData.money.cash or 0)
        if rest > 0 then
            Player.Functions.RemoveMoney('cash', (Player.PlayerData.money.cash or 0), 'tax:' .. (reason or 'unknown'))
            Player.Functions.RemoveMoney('bank', rest, 'tax:' .. (reason or 'unknown'))
        end
    end
    LogTax(src, reason or 'unknown', tax)
    return tax
end)

-- ── Vergi statistikası (panel) ──
RegisterNetEvent('196rp_tax:server:stats', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not IsPlayerAceAllowed(src, Config.AdminAce) then return end
    MySQL.query('SELECT COALESCE(SUM(amount), 0) AS total, COUNT(*) AS count FROM 196_tax_logs', {}, function(r)
        local totals = { total = r[1] and r[1].total or 0, count = r[1] and r[1].count or 0 }
        MySQL.query('SELECT COALESCE(SUM(amount), 0) AS today FROM 196_tax_logs WHERE created_at >= CURDATE()', {}, function(r2)
            totals.today = r2[1] and r2[1].today or 0
            TriggerClientEvent('196rp_tax:client:stats', src, { rate = currentRate, totals = totals })
        end)
    end)
end)

-- ── Vergi dərəcəsini dəyiş (admin) ──
RegisterCommand('vergi', function(source, args)
    local src = source
    if src > 0 and not (IsPlayerAceAllowed(src, Config.AdminAce)) then
        TriggerClientEvent('QBCore:Notify', src, 'Bu əmr adminlər üçündür!', 'error')
        return
    end
    if not args[1] then
        if src > 0 then
            TriggerClientEvent('QBCore:Notify', src, ('Hazırkı vergi: %s%%'):format(currentRate), 'primary')
        end
        TriggerServerEvent('196rp_tax:server:stats')
        return
    end
    local rate = tonumber(args[1])
    if not rate or rate < 0 or rate > 50 then
        if src > 0 then TriggerClientEvent('QBCore:Notify', src, 'Vergi 0% - 50% arası olmalıdır.', 'error') end
        return
    end
    currentRate = rate
    if src > 0 then
        TriggerClientEvent('QBCore:Notify', src, ('✅ Vergi dərəcəsi: %s%%'):format(rate), 'success')
    end
    print(('[196RP] Vergi dərəcəsi dəyişdirildi: %s%%'):format(rate))
end, false)
