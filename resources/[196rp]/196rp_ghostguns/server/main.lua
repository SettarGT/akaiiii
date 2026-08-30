local QBCore = exports['qb-core']:GetCoreObject()

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

local function LogChannel(channel, title, desc)
    if GetResourceState('196rp_logs') == 'started' then
        exports['196rp_logs']:Send(channel, title, desc, 16711680)
    end
end

local function HasItem(Player, item, amount)
    local inv = Player.PlayerData.items or {}
    for _, it in ipairs(inv) do
        if it and it.name == item and (it.amount or 0) >= amount then return true end
    end
    return false
end

-- ── Hissə istehsalı ──
RegisterNetEvent('196rp_ghostguns:server:craft', function(partIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local part = Config.Parts[tonumber(partIndex)]
    if not part then return end

    if not HasItem(Player, 'scrap_metal', part.scrap) then
        Notify(src, ('Kifayət qədər metal yoxdur — %d ədəd lazımdır.'):format(part.scrap), 'error')
        return
    end
    if HasItem(Player, part.item, 1) then
        Notify(src, 'Bu hissə artıq çantanızdadır.', 'error')
        return
    end

    for i = 1, part.scrap do
        Player.Functions.RemoveItem('scrap_metal', 1)
    end
    Player.Functions.AddItem(part.item, 1)
    Notify(src, ('🔧 %s hazırdır!'):format(part.label), 'success')

    if GetResourceState('196rp_stress') == 'started' then
        exports['196rp_stress']:AddStress(src, Config.Stress, true)
    end
end)

-- ── Yığma ──
RegisterNetEvent('196rp_ghostguns:server:assemble', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    for _, p in ipairs(Config.Parts) do
        if not HasItem(Player, p.item, 1) then
            Notify(src, 'Bütün hissələr lazımdır (çərçivə, sürüşmə, tetik).', 'error')
            return
        end
    end

    for _, p in ipairs(Config.Parts) do
        Player.Functions.RemoveItem(p.item, 1)
    end
    Player.Functions.AddItem(Config.Assemble.weapon, 1, false, false, {
        serial = nil,
        ghost = true,
    })
    Notify(src, ('🔫 %s yığıldı — seriya nömrəsi YOXDUR (izsiz)!'):format(Config.Assemble.label), 'success')
    LogChannel('anticheat', 'Ghost Gun', ('%s (%s) lisenziyasız silah yığdı!'):format(
        Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        Player.PlayerData.citizenid), 0xFF0000)

    if GetResourceState('196rp_stress') == 'started' then
        exports['196rp_stress']:AddStress(src, Config.Stress + 10, true)
    end

    if math.random() < Config.Assemble.policeNotifyChance then
        LogChannel('anticheat', '🔔 Polis siqnalı', 'Gizli emalatxanada şübhəli fəaliyyət aşkar edildi.', 0xFFFF00)
        if GetResourceState('196rp_dispatch') == 'started' then
            TriggerClientEvent('196rp_ghostguns:client:911', src, 'Gizli emalatxanada şübhəli səs-küy (Paleto)')
        end
    end
end)
