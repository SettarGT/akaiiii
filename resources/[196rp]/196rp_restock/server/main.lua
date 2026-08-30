local QBCore = exports['qb-core']:GetCoreObject()
local cooldowns = {}

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

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

-- ═══════════════════════════════════════════════════════════════
-- Kuryer zənciri (sifariş → anbar → çatdırılma)
-- ═══════════════════════════════════════════════════════════════

local orders = {}   -- id -> { kioskId, kioskLabel, requester, supplier, created, expires }

local function GetKiosk(id)
    for _, k in ipairs(Config.Kiosks) do
        if k.id == id then return k end
    end
end

local function CountOrders()
    local n = 0
    for _ in pairs(orders) do n = n + 1 end
    return n
end

-- Sifariş ver (hər kəsin kioskdan)
RegisterNetEvent('196rp_restock:server:order', function(kioskId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local kiosk = GetKiosk(kioskId)
    if not kiosk then return end
    if CountOrders() >= Config.Courier.MaxOrders then
        Notify(src, 'Logistika: aktiv sifarişlər doludur — bir az sonra.', 'error')
        return
    end
    if (Player.PlayerData.money.cash or 0) < Config.Courier.OrderFee then
        Notify(src, ('Sifariş haqqı: ₣%d'):format(Config.Courier.OrderFee), 'error')
        return
    end
    Player.Functions.RemoveMoney('cash', Config.Courier.OrderFee, 'restock-order')
    local id = #orders + 1
    orders[id] = {
        kioskId = kioskId, kioskLabel = kiosk.label,
        requester = src, supplier = nil,
        created = os.time(), expires = os.time() + Config.Courier.Expire,
    }
    Notify(src, ('📦 Sifariş yaradıldı: %s. Kuryer anbardan götürüb gətirəcək.'):format(kiosk.label), 'success')
end)

-- Anbardan götür (kuryer)
RegisterNetEvent('196rp_restock:server:pickup', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local jobOk = false
    for _, j in ipairs(Config.Courier.Jobs) do
        if Player.PlayerData.job.name == j then jobOk = true end
    end
    if not jobOk then
        Notify(src, 'Kuryer işi tələb olunur (trucker).', 'error')
        return
    end

    local orderId
    for id, o in pairs(orders) do
        if not o.supplier and o.expires > os.time() then orderId = id end
    end
    if not orderId then
        Notify(src, 'Gözləyən sifariş yoxdur.', 'primary')
        return
    end
    orders[orderId].supplier = src
    Player.Functions.AddItem('restock_crate', 1)
    Notify(src, ('📦 Sifariş götürüldü (%s) — mağazaya çatdırın!'):format(orders[orderId].kioskLabel), 'success')
end)

-- Çatdır (kioskda)
RegisterNetEvent('196rp_restock:server:deliver', function(kioskId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local crateCount = 0
    for _, it in ipairs(Player.PlayerData.items) do
        if it and it.name == 'restock_crate' then crateCount = crateCount + (it.amount or 0) end
    end
    if crateCount <= 0 then
        Notify(src, 'Əlinizdə restock qutusu yoxdur — anbardan götürün.', 'error')
        return
    end

    for id, o in pairs(orders) do
        if o.supplier == src and o.kioskId == kioskId and o.expires > os.time() then
            Player.Functions.RemoveItem('restock_crate', 1)
            TriggerEvent('qb-shops:server:RestockShopItems', kioskId)
            Player.Functions.AddMoney('cash', Config.Courier.PayOut, 'restock-delivery')
            orders[id] = nil
            Notify(src, ('✅ Çatdırıldı: %s (+₣%d)'):format(o.kioskLabel, Config.Courier.PayOut), 'success')
            local Req = QBCore.Functions.GetPlayer(o.requester)
            if Req then
                Notify(o.requester, ('📦 Sifarişiniz çatdırıldı!'):format(), 'success')
            end
            return
        end
    end
    Notify(src, 'Bu kiosk üçün aktiv sifarişiniz yoxdur.', 'error')
end)

-- Bitmiş sifarişləri təmizlə
CreateThread(function()
    while true do
        Wait(30000)
        for id, o in pairs(orders) do
            if o.expires <= os.time() then
                orders[id] = nil
            end
        end
    end
end)
