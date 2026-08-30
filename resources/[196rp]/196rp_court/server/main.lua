local QBCore = exports['qb-core']:GetCoreObject()

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

-- ── RPC: qeydləri gətir ──
RegisterNetEvent('196rp_court:server:request', function(id, action, payload)
    local src = source
    if action == 'records' then
        MySQL.query('SELECT * FROM 196_police_records WHERE citizenid = ? ORDER BY created_at DESC LIMIT 20', { payload.citizenid or '' }, function(r)
            TriggerClientEvent('196rp_court:client:response', src, id, r or {})
        end)
        return
    end
    TriggerClientEvent('196rp_court:client:response', src, id, {})
end)

-- ── Öz qeydlərim ──
RegisterNetEvent('196rp_court:server:myRecords', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    MySQL.query('SELECT * FROM 196_police_records WHERE citizenid = ? ORDER BY created_at DESC LIMIT 20', { Player.PlayerData.citizenid }, function(r)
        TriggerClientEvent('196rp_court:client:showRecords', src, r or {}, 'Sizin qeydiyyat tarixçəniz')
    end)
end)

-- ── Hüquqşünas: müvekkil qeydləri ──
RegisterCommand('vekil', function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or Player.PlayerData.job.name ~= 'lawyer' then
        Notify(src, 'Bu əmr hüquqşünaslar üçündür!', 'error')
        return
    end
    local target = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if not target then
        Notify(src, 'Oyunçu tapılmadı!', 'error')
        return
    end
    MySQL.query('SELECT * FROM 196_police_records WHERE citizenid = ? ORDER BY created_at DESC LIMIT 20', { target.PlayerData.citizenid }, function(r)
        local name = target.PlayerData.charinfo.firstname .. ' ' .. target.PlayerData.charinfo.lastname
        TriggerClientEvent('196rp_court:client:showRecords', src, r or {}, ('Müvekkil: %s'):format(name))
    end)
end, false)

-- ── Hakim qərarı (cərimə + həbs) ──
RegisterCommand('qerar', function(source, args)
    local src = source
    local Judge = QBCore.Functions.GetPlayer(src)
    if not Judge or Judge.PlayerData.job.name ~= 'judge' then
        Notify(src, 'Bu əmr hakimlər üçündür!', 'error')
        return
    end
    local target = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if not target then
        Notify(src, 'Oyunçu tapılmadı!', 'error')
        return
    end
    local fine = tonumber(args[2]) or 0
    local jail = tonumber(args[3]) or 0
    if fine < 0 or fine > Config.Limits.MaxFine or jail < 0 or jail > Config.Limits.MaxJail then
        Notify(src, ('Qərar limitləri: cərimə ₣0 - ₣%d, həbs 0 - %d dəq.'):format(Config.Limits.MaxFine, Config.Limits.MaxJail), 'error')
        return
    end
    if target.PlayerData.citizenid == Judge.PlayerData.citizenid then return end

    local paid = 0
    if fine > 0 then
        local cash = target.PlayerData.money.cash or 0
        local take = math.min(cash, fine)
        if take > 0 then target.Functions.RemoveMoney('cash', take, 'court-fine') end
        paid = take
        if paid < fine then
            local bank = target.PlayerData.money.bank or 0
            local take2 = math.min(bank, fine - paid)
            if take2 > 0 then target.Functions.RemoveMoney('bank', take2, 'court-fine') end
            paid = paid + take2
        end
    end
    if jail > 0 then
        target.Functions.SetMetaData('injail', jail)
    end

    local judgeName = Judge.PlayerData.charinfo.firstname .. ' ' .. Judge.PlayerData.charinfo.lastname
    local reason = args[4] and table.concat({ args[4], args[5], args[6], args[7], args[8], args[9], args[10] }, ' ') or 'Məhkəmə qərarı'

    MySQL.insert('INSERT INTO 196_police_records (citizenid, type, title, details, officer_name, fine_amount, created_at) VALUES (?, ?, ?, ?, ?, ?, NOW())', {
        target.PlayerData.citizenid, 'court', 'Məhkəmə qərarı', ('Cərimə ₣%d · Həbs %d dəq · %s'):format(paid, jail, reason), judgeName, fine,
    })

    TriggerClientEvent('QBCore:Notify', target.PlayerData.source, ('⚖️ Məhkəmə qərarı: cərimə -₣%d, həbs %d dəq. Səbəb: %s'):format(paid, jail, reason), 'error')
    Notify(src, ('✅ Qərar verildi: %s → -₣%d, %d dəq həbs'):format(target.PlayerData.charinfo.firstname .. ' ' .. target.PlayerData.charinfo.lastname, paid, jail), 'success')
end, false)

RegisterCommand('qerar2', function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or Player.PlayerData.job.name ~= 'judge' then
        Notify(src, 'Bu əmr hakimlər üçündür!', 'error')
        return
    end
    local target = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if not target then
        Notify(src, 'Oyunçu tapılmadı!', 'error')
        return
    end
    MySQL.query('SELECT * FROM 196_police_records WHERE citizenid = ? ORDER BY created_at DESC LIMIT 20', { target.PlayerData.citizenid }, function(r)
        local name = target.PlayerData.charinfo.firstname .. ' ' .. target.PlayerData.charinfo.lastname
        TriggerClientEvent('196rp_court:client:showRecords', src, r or {}, ('Təqsirləndirilən: %s'):format(name))
    end)
end, false)
