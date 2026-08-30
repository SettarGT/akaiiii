local QBCore = exports['qb-core']:GetCoreObject()

local proposals = {}  -- target -> { from = src, type = 'marry'|'ck' }
local divorced = {}   -- src -> timestamp

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

local function LogAdmin(title, desc)
    if GetResourceState('196rp_logs') == 'started' then
        exports['196rp_logs']:Send('admin', title, desc, 16755456)
    end
end

local function IsMarried(cid, cb)
    MySQL.scalar('SELECT spouse_citizenid FROM 196_marriage WHERE citizenid = ? LIMIT 1', { cid }, cb)
end

-- ── Evlilik təklifi ──
RegisterCommand('evlen', function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local targetId = tonumber(args[1])
    if not targetId or targetId == source then
        Notify(source, 'İstifadə: /evlen <oyunçu ID>', 'error')
        return
    end
    local Target = QBCore.Functions.GetPlayer(targetId)
    if not Target then
        Notify(source, 'Oyunçu tapılmadı.', 'error')
        return
    end
    if proposals[targetId] then
        Notify(source, 'Bu oyunçuya artıq təklif göndərilib.', 'error')
        return
    end
    if (Player.PlayerData.money.cash or 0) < Config.Marriage.Price then
        Notify(source, ('Evlilik haqqı: ₣%d'):format(Config.Marriage.Price), 'error')
        return
    end

    IsMarried(Player.PlayerData.citizenid, function(other)
        if other then
            Notify(source, 'Artıq evlisiniz (/bosan).', 'error')
            return
        end
        IsMarried(Target.PlayerData.citizenid, function(other2)
            if other2 then
                Notify(source, 'Seçdiyiniz şəxs artıq evlidir.', 'error')
                return
            end
            proposals[targetId] = { from = source, type = 'marry' }
            TriggerClientEvent('196rp_family:client:proposal', targetId, {
                from = source,
                name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                kind = 'marry',
                price = Config.Marriage.Price,
            })
            Notify(source, '💍 Təklif göndərildi — təsdiq gözlənilir.', 'primary')
        end)
    end)
end, false)

-- ── Boşanma ──
RegisterCommand('bosan', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    IsMarried(Player.PlayerData.citizenid, function(other)
        if not other then
            Notify(source, 'Evli deyilsiniz.', 'primary')
            return
        end
        MySQL.update('DELETE FROM 196_marriage WHERE citizenid IN (?, ?)', { Player.PlayerData.citizenid, other })
        divorced[source] = os.time() + Config.Marriage.Cooldown
        Notify(source, '💔 Boşandınız.', 'primary')
    end)
end, false)

-- ── /evli ──
RegisterCommand('evli', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    MySQL.query('SELECT * FROM 196_marriage WHERE citizenid = ?', { Player.PlayerData.citizenid }, function(rows)
        local r = rows and rows[1]
        if r then
            Notify(source, ('💞 Evlisiniz: %s (tarix: %s)'):format(r.spouse_name, tostring(r.married_at)), 'success')
        else
            Notify(source, 'Subaysınız.', 'primary')
        end
    end)
end, false)

-- ── Təsdiq ──
RegisterNetEvent('196rp_family:server:confirm', function(accept)
    local src = source
    local p = proposals[src]
    if not p then return end
    proposals[src] = nil

    if not accept then
        Notify(p.from, 'Təklif rədd edildi.', 'error')
        return
    end

    if p.type == 'marry' then
        local Player = QBCore.Functions.GetPlayer(p.from)
        local Target = QBCore.Functions.GetPlayer(src)
        if not Player or not Target then return end
        if (Player.PlayerData.money.cash or 0) < Config.Marriage.Price then
            Notify(p.from, 'Kifayət qədər pul yoxdur.', 'error')
            return
        end
        local pname = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
        local tname = Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname
        Player.Functions.RemoveMoney('cash', Config.Marriage.Price, 'marriage')
        MySQL.insert('INSERT INTO 196_marriage (citizenid, spouse_citizenid, spouse_name, married_at) VALUES (?, ?, ?, NOW()), (?, ?, ?, NOW())', {
            Player.PlayerData.citizenid, Target.PlayerData.citizenid, tname,
            Target.PlayerData.citizenid, Player.PlayerData.citizenid, pname,
        })
        Notify(p.from, ('💞 Evləndiniz: %s!'):format(tname), 'success')
        Notify(src, ('💞 Evləndiniz: %s!'):format(pname), 'success')
    elseif p.type == 'ck' then
        local Target = QBCore.Functions.GetPlayer(src)
        if not Target then return end
        local name = Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname
        MySQL.update('DELETE FROM players WHERE citizenid = ?', { Target.PlayerData.citizenid })
        LogAdmin('CK təsdiqləndi', ('%s (%s) — karakter silindi (razılıqla).'):format(name, Target.PlayerData.citizenid))
        Notify(src, '☠️ CK təsdiqləndi — karakteriniz silindi. Yeni personaj yaradın.', 'error')
    end
end)

-- ── CK təklifi (admin) ──
RegisterCommand('ck', function(source, args)
    if source == 0 then return end
    if not IsPlayerAceAllowed(source, Config.CK.RequireAce) then
        Notify(source, 'Bu əmr admin üçündür.', 'error')
        return
    end
    local targetId = tonumber(args[1])
    local Target = targetId and QBCore.Functions.GetPlayer(targetId)
    if not Target then
        Notify(source, 'Oyunçu tapılmadı.', 'error')
        return
    end
    proposals[targetId] = { from = source, type = 'ck' }
    TriggerClientEvent('196rp_family:client:proposal', targetId, {
        from = source,
        name = '🔴 CK təklifi',
        kind = 'ck',
        price = 0,
    })
    Notify(source, 'CK təklifi göndərildi — oyunçu /ekran ilə təsdiqləməlidir.', 'primary')
end, false)
