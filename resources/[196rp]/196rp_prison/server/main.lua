local QBCore = exports['qb-core']:GetCoreObject()
local cooldowns = {}

RegisterNetEvent('196rp_prison:server:work', function(workId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local jail = tonumber(Player.PlayerData.metadata.injail) or 0
    if jail <= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Siz məhbus deyilsiniz.', 'error')
        return
    end

    -- Həbsxanada olmasını server yoxlayır
    local coords = GetEntityCoords(GetPlayerPed(src))
    local inPrison = #(coords - vector3(1756.0, 2595.0, 44.9)) < 120
    if not inPrison then
        TriggerClientEvent('QBCore:Notify', src, 'Bu işlər yalnız həbsxanada işləyir.', 'error')
        return
    end

    local cfg = Config.Effects[workId]
    if not cfg then return end

    if cooldowns[src] and cooldowns[src] > os.time() then
        TriggerClientEvent('QBCore:Notify', src, ('⏳ Cooldown: %d san'):format(cooldowns[src] - os.time()), 'error')
        return
    end

    cooldowns[src] = os.time() + Config.Cooldown

    -- Vaxt azaltma (metadata injail)
    local newJail = jail - cfg.seconds
    if newJail < 0 then newJail = 0 end
    Player.Functions.SetMetaData('injail', newJail)

    local label = workId
    for _, z in ipairs(Config.WorkZones) do
        if z.id == workId then label = z.label end
    end
    local remaining = math.floor(newJail / 60)
    TriggerClientEvent('QBCore:Notify', src, ('✅ %s işləndi: -%d san həbs · Qalan: %d dəq'):format(label, cfg.seconds, remaining), 'success')

    if newJail <= 0 then
        TriggerClientEvent('QBCore:Notify', src, '🎉 Həbs müddəti bitdi — azadsınız!', 'success')
    end
end)
