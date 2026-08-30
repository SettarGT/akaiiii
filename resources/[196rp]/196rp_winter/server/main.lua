local QBCore = exports['qb-core']:GetCoreObject()

local winterOn = false
local tires = {}   -- plate -> true

local function LoadState()
    local row = MySQL.single('SELECT value FROM 196_settings WHERE name = ?', { 'winter' })
    if row then
        winterOn = row.value == '1'
    end
end
LoadState()

local function SaveState()
    MySQL.update('INSERT INTO 196_settings (name, value) VALUES (?, ?) ON DUPLICATE KEY UPDATE value = VALUES(value)', {
        'winter', winterOn and '1' or '0',
    })
end

local function Broadcast()
    TriggerClientEvent('196rp_winter:client:state', -1, { winter = winterOn })
end

-- ── Admin: /qis ──
RegisterCommand('qis', function(src)
    if not IsPlayerAceAllowed(src, 'command') and src ~= 0 then return end
    winterOn = not winterOn
    SaveState()
    Broadcast()
    local label = winterOn and '❄️ Qış mövsümü AÇIQ' or '☀️ Yay mövsümü AÇIQ'
    TriggerClientEvent('QBCore:Notify', -1, label, 'primary')
end, false)

-- ── Mövsüm sorğusu ──
RegisterNetEvent('196rp_winter:server:getState', function()
    TriggerClientEvent('196rp_winter:client:state', source, { winter = winterOn })
end)

-- ── Mexanik: qış təkəri ──
RegisterNetEvent('196rp_winter:server:setTires', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or Player.PlayerData.job.name ~= 'mechanic' then return end
    plate = tostring(plate or ''):upper()
    if plate == '' then return end
    if (Player.PlayerData.money.cash or 0) < Config.WinterTirePrice then
        TriggerClientEvent('QBCore:Notify', src, ('❄ Qış təkəri: ₣%d'):format(Config.WinterTirePrice), 'error')
        return
    end
    Player.Functions.RemoveMoney('cash', Config.WinterTirePrice, 'winter-tires')
    tires[plate] = true
    TriggerClientEvent('QBCore:Notify', src, ('❄ %s plitəsinə qış təkəri quraşdırıldı!'):format(plate), 'success')
end)

RegisterNetEvent('196rp_winter:server:hasTires', function(plate)
    TriggerClientEvent('196rp_winter:client:tires', source, { plate = plate, has = tires[tostring(plate or ''):upper()] == true })
end)
