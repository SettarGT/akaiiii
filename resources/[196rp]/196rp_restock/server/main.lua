local QBCore = exports['qb-core']:GetCoreObject()
local cooldowns = {}

-- qb-shops event ilə anbarın doldurulması
RegisterNetEvent('196rp_restock:server:do', function(kioskId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local kiosk
    for _, k in ipairs(Config.Kiosks) do
        if k.id == kioskId then kiosk = k end
    end
    if not kiosk then return end

    -- 1. Cooldown
    if cooldowns[src] and cooldowns[src] > os.time() then
        TriggerClientEvent('QBCore:Notify', src, ('⏳ Gözləyin: %d san'):format(cooldowns[src] - os.time()), 'error')
        return
    end

    -- 2. Pul
    if (Player.PlayerData.money.cash or 0) < Config.Fee then
        TriggerClientEvent('QBCore:Notify', src, ('❌ Restock qiyməti: ₣%d'):format(Config.Fee), 'error')
        return
    end

    -- 3. qb-shops-un daxili restock eventi (server-side TriggerEvent — təhlükəsiz:
    --    deliveryPay içində GetPlayer(nil) -> nil, yalnız restock hissəsi işləyir)
    TriggerEvent('qb-shops:server:RestockShopItems', kiosk.id)

    Player.Functions.RemoveMoney('cash', Config.Fee, 'restock')
    cooldowns[src] = os.time() + Config.Cooldown

    TriggerClientEvent('QBCore:Notify', src, ('✅ %s anbarı dolduruldu (-₣%d)'):format(kiosk.label, Config.Fee), 'success')
end)
