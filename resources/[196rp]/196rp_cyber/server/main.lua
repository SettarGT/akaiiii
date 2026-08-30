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
