-- 196 RP | Həyat statusu — server tərəfi
-- Statusun saxlanması / yüklənməsi + yemək-içki istifadəsi

local ESX = exports['es_extended']:getSharedObject()

-- [identifier] = { food = 100, water = 100, energy = 100 }
local statuses = {}
local dirty = {}

local function Clamp(n)
    n = tonumber(n) or 0
    if n < 0 then n = 0 end
    if n > 100 then n = 100 end
    return math.floor(n * 10) / 10
end

-- ==================== YÜKLƏMƏ ====================

RegisterNetEvent('196rp_status:requestLoad', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        return
    end

    local identifier = xPlayer.identifier

    if not statuses[identifier] then
        local row = MySQL.single.await('SELECT `status` FROM `users` WHERE `identifier` = ?', { identifier })
        local saved = row and row.status or nil

        if saved then
            local ok, decoded = pcall(json.decode, saved)
            if ok and type(decoded) == 'table' then
                statuses[identifier] = {
                    food = Clamp(decoded.food or 100),
                    water = Clamp(decoded.water or 100),
                    energy = Clamp(decoded.energy or 100)
                }
            end
        end

        if not statuses[identifier] then
            statuses[identifier] = { food = 100, water = 100, energy = 100 }
        end
    end

    TriggerClientEvent('196rp_status:setStatus', src, statuses[identifier])
end)

-- ==================== SİNXRONİZASİYA ====================

RegisterNetEvent('196rp_status:sync', function(newStatus)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or type(newStatus) ~= 'table' then
        return
    end

    local identifier = xPlayer.identifier
    local current = statuses[identifier] or { food = 100, water = 100, energy = 100 }

    current.food = Clamp(newStatus.food or current.food)
    current.water = Clamp(newStatus.water or current.water)
    current.energy = Clamp(newStatus.energy or current.energy)

    statuses[identifier] = current
    dirty[identifier] = true
end)

-- ==================== VERİLƏNLƏR BAZASINA YAZMA ====================

CreateThread(function()
    while true do
        Wait(Config.SaveInterval or 60000)

        for identifier in pairs(dirty) do
            local s = statuses[identifier]
            if s then
                MySQL.update('UPDATE `users` SET `status` = ? WHERE `identifier` = ?',
                    { json.encode(s), identifier })
            end
            dirty[identifier] = nil
        end
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        local identifier = xPlayer.identifier
        local s = statuses[identifier]
        if s then
            MySQL.update('UPDATE `users` SET `status` = ? WHERE `identifier` = ?',
                { json.encode(s), identifier })
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then
        return
    end
    for identifier, s in pairs(statuses) do
        MySQL.update.await('UPDATE `users` SET `status` = ? WHERE `identifier` = ?',
            { json.encode(s), identifier })
    end
end)

-- ==================== YEMƏK / İÇKİ ====================

local function RegisterConsumable(itemName, kind)
    ESX.RegisterUsableItem(itemName, function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then
            return
        end

        local add = kind == 'food' and Config.Food[itemName] or Config.Drinks[itemName]
        if not add then
            return
        end

        local invItem = xPlayer.getInventoryItem(itemName)
        if not invItem or invItem.count < 1 then
            return
        end

        xPlayer.removeInventoryItem(itemName, 1)
        TriggerClientEvent('196rp_status:consume', source, itemName, add, kind)
    end)
end

for name in pairs(Config.Food) do
    RegisterConsumable(name, 'food')
end

for name in pairs(Config.Drinks) do
    RegisterConsumable(name, 'drink')
end

-- ==================== DİGƏR RESURSLAR ÜÇÜN ====================

exports('GetPlayerStatus', function(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then
        return nil
    end
    return statuses[xPlayer.identifier]
end)

exports('ChangeStatus', function(playerId, kind, amount)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then
        return false
    end

    local identifier = xPlayer.identifier
    local s = statuses[identifier] or { food = 100, water = 100, energy = 100 }

    if kind == 'food' or kind == 'water' or kind == 'energy' then
        s[kind] = Clamp(s[kind] + (tonumber(amount) or 0))
        statuses[identifier] = s
        dirty[identifier] = true
        TriggerClientEvent('196rp_status:setStatus', playerId, s)
        return true
    end

    return false
end)
