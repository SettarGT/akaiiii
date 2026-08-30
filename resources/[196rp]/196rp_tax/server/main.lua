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
-- Gəlir vergisi: net məbləği qaytarır (səbəb vergiyə daxildirsə)
function ApplyIncome(src, amount, reason)
    amount = tonumber(amount) or 0
    if amount <= 0 or not Config.IncomeTax or Config.IncomeTax <= 0 then return amount end
    if not reason or reason == 'unknown' then return amount end
    local taxable = false
    for _, r in ipairs(Config.IncomeReasons) do
        if reason:lower() == r:lower() then taxable = true break end
    end
    if not taxable then return amount end
    local tax = math.floor(amount * Config.IncomeTax / 100 + 0.5)
    if tax <= 0 then return amount end
    TriggerClientEvent('QBCore:Notify', src, ('🏛 Gəlir vergisi: -₣%d (%d%%)'):format(tax, Config.IncomeTax), 'primary')
    return amount - tax
end

exports('ApplyIncome', ApplyIncome)

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


-- ═══════════════════════════════════════════════════════════════
-- Həftəlik vergilər (avtomobil ₣250, ev ₣500)
-- ═══════════════════════════════════════════════════════════════

local function ChargeWeekly(cid, name, vehicles, houses)
    if vehicles <= 0 and houses <= 0 then return end
    local amount = vehicles * Config.Weekly.VehicleTax + houses * Config.Weekly.HouseTax
    local Player = QBCore.Functions.GetPlayerByCitizenId(cid)
    if not Player then return end
    local src = Player.PlayerData.source

    local balance = (Player.PlayerData.money.bank or 0) + (Player.PlayerData.money.cash or 0)
    if amount <= 0 or balance <= 0 then
        TriggerClientEvent('QBCore:Notify', src, ('⚠️ Həftəlik vergi ödənilmədi (₣%d) — hesabınızda pul yoxdur.'):format(amount), 'error')
        return
    end
    local fromBank = math.min(amount, (Player.PlayerData.money.bank or 0))
    if fromBank > 0 then
        Player.Functions.RemoveMoney('bank', fromBank, 'weekly-tax')
    end
    local rest = amount - fromBank
    if rest > 0 then
        Player.Functions.RemoveMoney('cash', rest, 'weekly-tax')
    end
    LogTax(src, 'weekly:vehicle+' .. vehicles .. ':house+' .. houses, amount)
    TriggerClientEvent('QBCore:Notify', src, ('🏛 Həftəlik vergi: -₣%d (maşın %d × ₣250, ev %d × ₣500)'):format(amount, vehicles, houses), 'primary')
end

CreateThread(function()
    while true do
        Wait(Config.Weekly.CheckInterval * 1000)
        if not Config.Weekly.Enabled then return end
        local now = os.time()

        -- avtomobillər
        MySQL.query('SELECT citizenid, COUNT(*) AS c FROM player_vehicles GROUP BY citizenid', {}, function(vehRows)
            for _, v in ipairs(vehRows or {}) do
                MySQL.single('SELECT veh_last FROM 196_tax_bills WHERE citizenid = ?', { v.citizenid }, function(row)
                    local last = row and row.veh_last or now - Config.Weekly.WeekSeconds
                    if now - last >= Config.Weekly.WeekSeconds then
                        MySQL.insert('INSERT INTO 196_tax_bills (citizenid, veh_last, house_last) VALUES (?, ?, 0) ON DUPLICATE KEY UPDATE veh_last = ?', {
                            v.citizenid, now, now,
                        })
                        ChargeWeekly(v.citizenid, 'vehicle', v.c, 0)
                    end
                end)
            end
        end)

        -- evlər
        MySQL.query('SELECT citizenid, COUNT(*) AS c FROM player_houses GROUP BY citizenid', {}, function(houseRows)
            for _, h in ipairs(houseRows or {}) do
                MySQL.single('SELECT house_last FROM 196_tax_bills WHERE citizenid = ?', { h.citizenid }, function(row)
                    local last = row and row.house_last or now - Config.Weekly.WeekSeconds
                    if now - last >= Config.Weekly.WeekSeconds then
                        MySQL.insert('INSERT INTO 196_tax_bills (citizenid, veh_last, house_last) VALUES (?, 0, ?) ON DUPLICATE KEY UPDATE house_last = ?', {
                            h.citizenid, now, now,
                        })
                        ChargeWeekly(h.citizenid, 'house', 0, h.c)
                    end
                end)
            end
        end)
    end
end)

-- /vergibax — növbəti ödəniş məlumatı
RegisterCommand('vergibax', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local cid = Player.PlayerData.citizenid
    MySQL.single('SELECT veh_last, house_last FROM 196_tax_bills WHERE citizenid = ?', { cid }, function(row)
        local nextV = (row and row.veh_last or 0) + Config.Weekly.WeekSeconds
        local nextH = (row and row.house_last or 0) + Config.Weekly.WeekSeconds
        TriggerClientEvent('QBCore:Notify', source,
            ('🏛 Növbəti vergi: avtomobil %s, ev %s'):format(nextV > os.time() and os.date('%d.%m', nextV) or 'bu gün', nextH > os.time() and os.date('%d.%m', nextH) or 'bu gün'), 'primary')
    end)
end, false)
