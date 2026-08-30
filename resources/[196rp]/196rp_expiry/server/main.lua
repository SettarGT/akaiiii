local QBCore = exports['qb-core']:GetCoreObject()

local function GetDuration(item)
    for _, v in ipairs(Config.FoodItems) do
        if v == item then return Config.FoodTime end
    end
    for _, v in ipairs(Config.MedsItems) do
        if v == item then return Config.MedsTime end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════
-- Yeni əlavə edilən əşyalara istifadə müddəti yaz (qb-inventory hook)
-- ═══════════════════════════════════════════════════════════════
if GetResourceState('qb-inventory') == 'started' then
    exports['qb-inventory']:AddHook('ItemAdded', function(itemType, hookData)
        if not hookData or not hookData.item then return end
        local dur = GetDuration(hookData.item.name)
        if not dur then return end
        local info = hookData.item.info or {}
        info.expire = os.time() + dur
        hookData.item.info = info
        return info
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- Bitmiş müddətli əşyaları sil
-- ═══════════════════════════════════════════════════════════════
CreateThread(function()
    while true do
        Wait(Config.CheckInterval * 1000)
        for _, src in ipairs(QBCore.Functions.GetPlayers()) do
            local Player = QBCore.Functions.GetPlayer(src)
            if Player and Player.PlayerData.items then
                local removed = {}
                for i, it in ipairs(Player.PlayerData.items) do
                    if it and it.info and it.info.expire and it.info.expire < os.time() then
                        Player.Functions.RemoveItem(it.name, it.amount or 1, false, false, 'expired')
                        removed[#removed + 1] = it.label or it.name
                    end
                end
                if #removed > 0 then
                    TriggerClientEvent('QBCore:Notify', src, '⚰️ İstifadə müddəti bitdi: ' .. table.concat(removed, ', '), 'error')
                end
            end
        end
    end
end)
