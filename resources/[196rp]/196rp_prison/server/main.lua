local QBCore = exports['qb-core']:GetCoreObject()
local cooldowns = {}

-- ── Həbsxana işi ──
RegisterNetEvent('196rp_prison:server:work', function(zoneId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local jail = tonumber(Player.PlayerData.metadata.injail) or 0
    if jail <= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Siz məhbus deyilsiniz.', 'error')
        return
    end

    -- qb-prison həbsdə olan oyunçunu həbsxana ərazisinə teleport edir;
    -- server yalnız həbsxana ərazisində yoxlayır:
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    if #(coords - vector3(1693.33, 2569.51, 44.55)) > 180 then
        TriggerClientEvent('QBCore:Notify', src, 'Bu işlər yalnız həbsxanada işləyir.', 'error')
        return
    end

    if cooldowns[src] and cooldowns[src] > os.time() then
        TriggerClientEvent('QBCore:Notify', src, ('⏳ Gözləyin: %d san'):format(cooldowns[src] - os.time()), 'error')
        return
    end

    local reduce = Config.Reduce[zoneId]
    if not reduce then return end
    cooldowns[src] = os.time() + Config.Cooldown

    local newJail = math.max(0, jail - reduce)
    Player.Functions.SetMetaData('injail', newJail)

    local label = zoneId
    for _, z in ipairs(Config.WorkZones) do if z.id == zoneId then label = z.label end end

    TriggerClientEvent('QBCore:Notify', src, ('✅ %s işləndi: -%d san həbs · Qalan: %d dəq'):format(label, reduce, math.floor(newJail / 60)), 'success')

    if newJail <= 0 then
        TriggerClientEvent('QBCore:Notify', src, '🎉 Həbs müddəti bitdi — sərbəstsiniz!', 'success')
    end
end)
