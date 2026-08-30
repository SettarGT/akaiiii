local QBCore = exports['qb-core']:GetCoreObject()

local function IsAllowed(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end
    return Config.AccessJobs[Player.PlayerData.job.name] == true
end

-- ── MDT aç ──
RegisterNetEvent('196rp_mdt:server:open', function()
    local src = source
    if not IsAllowed(src) then
        TriggerClientEvent('QBCore:Notify', src, 'MDT yalnız polis üçündür!', 'error')
        return
    end
    TriggerClientEvent('196rp_mdt:client:open', src)
end)

-- ── RPC sorğusu ──
RegisterNetEvent('196rp_mdt:server:request', function(id, action, payload)
    local src = source
    if not IsAllowed(src) then
        TriggerClientEvent('196rp_mdt:client:response', src, id, {})
        return
    end
    payload = payload or {}

    if action == 'searchPlayer' then
        local results = {}
        for _, p in ipairs(QBCore.Functions.GetPlayers()) do
            local Player = QBCore.Functions.GetPlayer(p)
            if Player then
                local name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
                local citizenid = Player.PlayerData.citizenid
                local q = tostring(payload.query or ''):lower()
                if q == '' or name:lower():find(q, 1, true) or citizenid:lower():find(q, 1, true) or tostring(p) == q then
                    results[#results + 1] = {
                        source = p,
                        name = name,
                        citizenid = citizenid,
                        phone = Player.PlayerData.charinfo.phone or '-',
                        job = Player.PlayerData.job.label or '-',
                        cash = Player.PlayerData.money.cash or 0,
                        bank = Player.PlayerData.money.bank or 0,
                    }
                end
            end
        end
        TriggerClientEvent('196rp_mdt:client:response', src, id, results)
        return
    end

    if action == 'getRecords' then
        MySQL.query('SELECT * FROM 196_police_records WHERE citizenid = ? ORDER BY created_at DESC', { payload.citizenid or '' }, function(result)
            TriggerClientEvent('196rp_mdt:client:response', src, id, result or {})
        end)
        return
    end

    if action == 'searchVehicle' then
        MySQL.query([[
            SELECT pv.plate, pv.vehicle, pv.garage, pv.state, pv.owner, p.charinfo
            FROM player_vehicles pv
            LEFT JOIN players p ON p.citizenid = pv.owner
            WHERE pv.plate = ?
        ]], { tostring(payload.query or ''):upper() }, function(result)
            if result and #result > 0 then
                local r = result[1]
                local ok, info = pcall(json.decode, r.charinfo or '{}')
                r.owner_name = ok and ((info.firstname or '') .. ' ' .. (info.lastname or '')) or 'Naməlum'
            end
            TriggerClientEvent('196rp_mdt:client:response', src, id, result or {})
        end)
        return
    end

    TriggerClientEvent('196rp_mdt:client:response', src, id, {})
end)

-- ── Cərimə yaz (pul + qeyd) ──
RegisterNetEvent('196rp_mdt:server:addFine', function(targetSrc, amount, reason)
    local src = source
    if not IsAllowed(src) then return end

    local Officer = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(tonumber(targetSrc))
    if not Target then
        TriggerClientEvent('QBCore:Notify', src, 'Hədəf oyunçu onlayn deyil!', 'error')
        return
    end
    amount = tonumber(amount) or 0
    if amount <= 0 or amount > 100000 then
        TriggerClientEvent('QBCore:Notify', src, 'Cərimə məbləği 1 ₣ - 100 000 ₣ arası olmalıdır.', 'error')
        return
    end
    if Target.PlayerData.citizenid == Officer.PlayerData.citizenid then
        return
    end

    -- Ödəniş: əvvəl nağd, sonra bank
    local paid = 0
    local cash = Target.PlayerData.money.cash or 0
    if cash > 0 then
        local take = math.min(cash, amount)
        Target.Functions.RemoveMoney('cash', take, 'mdt-fine')
        paid = take
    end
    if paid < amount then
        local bank = Target.PlayerData.money.bank or 0
        local take = math.min(bank, amount - paid)
        Target.Functions.RemoveMoney('bank', take, 'mdt-fine')
        paid = paid + take
    end

    local officerName = Officer.PlayerData.charinfo.firstname .. ' ' .. Officer.PlayerData.charinfo.lastname

    MySQL.insert('INSERT INTO 196_police_records (citizenid, type, title, details, officer_name, fine_amount, created_at) VALUES (?, ?, ?, ?, ?, ?, NOW())', {
        Target.PlayerData.citizenid, 'fine', reason or 'Cərimə', ('Cərimə tətbiq olundu. Ödənildi: ₣%d'):format(paid), officerName, amount,
    })

    TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, ('📋 Sizə %s tərəfindən cərimə yazıldı: %s (-₣%d)'):format(officerName, reason or 'Cərimə', paid), 'error')
    TriggerClientEvent('QBCore:Notify', src, ('✅ Cərimə yazıldı: %s → -₣%d'):format(Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname, paid), 'success')
end)

-- ── Xəbərdarlıq / qeyd ──
RegisterNetEvent('196rp_mdt:server:addRecord', function(targetSrc, recordType, title, details)
    local src = source
    if not IsAllowed(src) then return end
    local Officer = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(tonumber(targetSrc))
    if not Target or not Target.PlayerData then
        return
    end
    local officerName = Officer.PlayerData.charinfo.firstname .. ' ' .. Officer.PlayerData.charinfo.lastname
    MySQL.insert('INSERT INTO 196_police_records (citizenid, type, title, details, officer_name, fine_amount, created_at) VALUES (?, ?, ?, ?, ?, 0, NOW())', {
        Target.PlayerData.citizenid, recordType, title or 'Qeyd', details or '', officerName,
    })
    TriggerClientEvent('QBCore:Notify', src, '✅ Qeyd əlavə olundu.', 'success')
end)
