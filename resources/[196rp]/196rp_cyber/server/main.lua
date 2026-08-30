local QBCore = exports['qb-core']:GetCoreObject()

local lastHack = {}

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

-- ── Hack başlat ──
RegisterNetEvent('196rp_cyber:server:startHack', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local now = os.time()
    if lastHack[src] and (now - lastHack[src]) < Config.Hack.Cooldown then
        Notify(src, ('Gizli serverlər soyuyur — %d saniyə gözləyin.'):format(Config.Hack.Cooldown - (now - lastHack[src])), 'error')
        return
    end
    lastHack[src] = now
    TriggerClientEvent('196rp_cyber:client:startHack', src)
end)

-- ── Hack nəticəsi ──
RegisterNetEvent('196rp_cyber:server:hackResult', function(success)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if success then
        local payout = math.random(Config.Hack.MinPayout, Config.Hack.MaxPayout)
        if GetResourceState('196rp_stress') == 'started' then
            exports['196rp_stress']:AddStress(src, Config.StressIncrease)
        end
        Player.Functions.AddMoney('cash', payout, 'cyber-hack')
        TriggerClientEvent('QBCore:Notify', src, ('💻 Hack uğurlu! +₣%d (təmiz pul — sistemə giriş əldə etdiniz)'):format(payout), 'success')

        -- Polis xəbərdarlığı (növbətçi LEO)
        if Config.Alert then
            for _, p in ipairs(QBCore.Functions.GetPlayers()) do
                local P = QBCore.Functions.GetPlayer(p)
                if P and P.PlayerData.job.type == 'leo' and P.PlayerData.job.onduty then
                    TriggerClientEvent('QBCore:Notify', p, ('🚨 KİBER HÜCUM! Naməlum şəxs 196 serverlərinə giriş etdi. Yaxınlıqdakı kompüterləri yoxlayın!'), 'error')
                end
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Hack uğursuz — server izləri sildi. Amma sizi tapmadı...', 'error')
    end
end)

-- ── Alət al ──
RegisterNetEvent('196rp_cyber:server:buyKit', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if (Player.PlayerData.money.cash or 0) < Config.Hack.KitCost then
        Notify(src, ('Kifayət qədər pul yoxdur — kit ₣%d'):format(Config.Hack.KitCost), 'error')
        return
    end
    Player.Functions.RemoveMoney('cash', Config.Hack.KitCost, 'cyber-kit')
    Player.Functions.AddItem('cyber_kit', 1, false, false, 'cyber-kit')
    Notify(src, ('✅ Kiber dəst alındı (-₣%d). Hack şansı +%d%%.'):format(Config.Hack.KitCost, Config.Hack.KitBonus), 'success')
end)

-- ── Hack şansı (server hesablayır) ──
RegisterNetEvent('196rp_cyber:server:getChance', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        TriggerClientEvent('196rp_cyber:client:chance', src, Config.Hack.BaseSuccess)
        return
    end
    local chance = Config.Hack.BaseSuccess
    if Player.Functions.GetItemByName('cyber_kit') and Player.Functions.GetItemByName('cyber_kit').amount > 0 then
        chance = chance + Config.Hack.KitBonus
    end
    TriggerClientEvent('196rp_cyber:client:chance', src, chance)
end)

-- ═══════════════════════════════════════════════════════════════
-- DarkWeb anonim elanlar bordu
-- ═══════════════════════════════════════════════════════════════

local dwBoard = {}   -- { { alias, text, ts } }
local dwCooldown = {}

local ALIASES = { 'Shadow_', 'Ghost_', 'Neon_', 'Xan_', 'Rus_', 'Void_', 'Cypher_', 'Null_' }

local function RandAlias()
    return ALIASES[math.random(#ALIASES)] .. math.random(1000, 9999)
end

-- /dw <mətn> — anonim elan
QBCore.Commands.Add('dw', 'DarkWeb-də anonim elan yerləşdir (₣250)', { { name = 'mətn', help = 'Elan mətni' } }, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local text = table.concat(args, ' ')
    if #text < 3 or #text > 500 then
        TriggerClientEvent('QBCore:Notify', source, 'Elan 3–500 simvol olmalıdır.', 'error')
        return
    end
    if dwCooldown[source] and dwCooldown[source] > os.time() then
        TriggerClientEvent('QBCore:Notify', source, ('⏳ Soyutma: %d san'):format(dwCooldown[source] - os.time()), 'error')
        return
    end
    if (Player.PlayerData.money.cash or 0) < 250 then
        TriggerClientEvent('QBCore:Notify', source, 'Elan haqqı: ₣250', 'error')
        return
    end
    Player.Functions.RemoveMoney('cash', 250, 'darkweb-ad')
    dwBoard[#dwBoard + 1] = { alias = RandAlias(), text = text, ts = os.time() }
    if #dwBoard > 50 then table.remove(dwBoard, 1) end
    dwCooldown[source] = os.time() + 30
    TriggerClientEvent('QBCore:Notify', source, '🕶 Elan DarkWeb-ə yerləşdirildi (anonim).', 'success')

    -- polis qeydi
    if GetResourceState('196rp_logs') == 'started' then
        exports['196rp_logs']:Send('anticheat', '🌐 DarkWeb', 'Anonim elan yerləşdirildi (İz: əlçatmaz).', 0x8A2BE2)
    end
end)

-- /dwbax — son 10 elan (çatda)
QBCore.Commands.Add('dwbax', 'DarkWeb elanlarına bax (son 10)', {}, false, function(source)
    if #dwBoard == 0 then
        TriggerClientEvent('QBCore:Notify', source, 'DarkWeb boşdur.', 'primary')
        return
    end
    local lines = { '🌐 DARKWEB — ANONİM ELANLAR' }
    for i = math.max(1, #dwBoard - 9), #dwBoard do
        local e = dwBoard[i]
        lines[#lines + 1] = ('%s: %s'):format(e.alias, e.text)
    end
    TriggerClientEvent('chat:addMessage', source, {
        color = { 138, 43, 226 },
        multiline = true,
        args = { table.concat(lines, '\n') },
    })
end)
