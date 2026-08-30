local QBCore = exports['qb-core']:GetCoreObject()

local vipCache = {}   -- citizenid -> expires
local lastPlate = {}

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

local function IsVip(citizenid)
    local exp = vipCache[citizenid]
    return exp and exp > os.time()
end

local function SetVip(cid, expires)
    vipCache[cid] = expires
    MySQL.update('INSERT INTO 196_vip (citizenid, expires, active, updated_at) VALUES (?, ?, ?, NOW()) ON DUPLICATE KEY UPDATE expires = VALUES(expires), active = VALUES(active), updated_at = NOW()', {
        cid, expires, expires > os.time() and 1 or 0,
    })
end

local function SyncPlayer(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    -- Queue prioriteti: aktiv VIP-ə daimi prioritet
    if GetResourceState('connectqueue') == 'started' then
        if IsVip(Player.PlayerData.citizenid) then
            Queue.AddPriority(Player.PlayerData.license, Config.VIP.QueuePower, false)
        else
            Queue.RemovePriority(Player.PlayerData.license)
        end
    end
    TriggerClientEvent('196rp_vip:client:sync', src, { vip = IsVip(Player.PlayerData.citizenid), expires = vipCache[Player.PlayerData.citizenid] or 0 })
end

-- ── Oyunçu girəndə ──
RegisterNetEvent('QBCore:Server:PlayerLoaded', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local cid = Player.PlayerData.citizenid
    MySQL.query('SELECT expires, active FROM 196_vip WHERE citizenid = ?', { cid }, function(r)
        if r and #r > 0 then
            vipCache[cid] = tonumber(r[1].expires) or 0
            if vipCache[cid] <= os.time() and tonumber(r[1].active) == 1 then
                MySQL.update('UPDATE 196_vip SET active = 0 WHERE citizenid = ?', { cid })
            end
        end
        SyncPlayer(src)
    end)
end)

-- ── Bitmə yoxlaması ──
CreateThread(function()
    while true do
        Wait(Config.VIP.CheckInterval * 1000)
        for _, src in ipairs(QBCore.Functions.GetPlayers()) do
            local Player = QBCore.Functions.GetPlayer(src)
            if Player and Player.PlayerData.citizenid and not IsVip(Player.PlayerData.citizenid) then
                SyncPlayer(src)
            end
        end
    end
end)

-- ── Admin: VIP ver / al ──
RegisterCommand('viptver', function(source, args)
    local src = source
    if src > 0 and not IsPlayerAceAllowed(src, 'command') then
        Notify(src, 'Admin deyilsiniz!', 'error')
        return
    end
    local Target = QBCore.Functions.GetPlayer(tonumber(args[1]))
    local days = tonumber(args[2]) or 30
    if not Target or days < 1 then return end
    local cid = Target.PlayerData.citizenid
    local cur = vipCache[cid] or os.time()
    local expires = math.max(cur, os.time()) + days * 86400
    SetVip(cid, expires)
    SyncPlayer(Target.PlayerData.source)
    if src > 0 then Notify(src, ('✅ VIP verildi: %s — %d gün'):format(Target.PlayerData.charinfo.firstname, days), 'success') end
    print(('[196RP] VIP verildi: %s (%d gün)'):format(cid, days))
end, false)

RegisterCommand('viptelə', function(source, args)
    local src = source
    if src > 0 and not IsPlayerAceAllowed(src, 'command') then
        Notify(src, 'Admin deyilsiniz!', 'error')
        return
    end
    local Target = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if not Target then return end
    SetVip(Target.PlayerData.citizenid, 0)
    SyncPlayer(Target.PlayerData.source)
    if src > 0 then Notify(src, '🗑 VIP silindi.', 'success') end
end, false)

-- ── VIP plitə ──
RegisterNetEvent('196rp_vip:server:plate', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if not IsVip(Player.PlayerData.citizenid) then
        Notify(src, 'Bu xüsusiyyət VIP üçündür! (/vip)', 'error')
        return
    end
    plate = tostring(plate or ''):upper():gsub('%s+', '')
    if #plate < 3 or #plate > 8 or not plate:match('^[A-Z0-9]+$') then
        Notify(src, 'Plitə 3-8 simvol (hərf/rəqəm) olmalıdır.', 'error')
        return
    end
    local now = os.time()
    if lastPlate[src] and (now - lastPlate[src]) < Config.VIP.PlateCooldown then
        Notify(src, ('Plitə dəyişikliyi soyutma: %d saniyə.'):format(Config.VIP.PlateCooldown - (now - lastPlate[src])), 'error')
        return
    end
    lastPlate[src] = now
    TriggerClientEvent('196rp_vip:client:changePlate', src, plate)
end)
