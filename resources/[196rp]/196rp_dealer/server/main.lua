local QBCore = exports['qb-core']:GetCoreObject()

local testDrives = {}

-- Plitə generasiyası
local function GenPlate()
    local chars = 'ABCDEFGHJKLMNPRSTUVYZ0123456789'
    local plate = Config.PlatePrefix
    for _ = 1, 6 do
        plate = plate .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return plate
end

-- ── Satış ──
RegisterNetEvent('196rp_dealer:server:buy', function(model)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local vehConfig
    for _, v in ipairs(Config.Vehicles) do
        if v.model == model then vehConfig = v end
    end
    if not vehConfig then return end
    if not QBCore.Shared.Vehicles[model] then
        TriggerClientEvent('QBCore:Notify', src, 'Bu model serverdə tapılmadı!', 'error')
        return
    end

    local price = vehConfig.price
    local taxed = price
    local taxRate = 0
    if GetResourceState('196rp_tax') == 'started' then
        taxed = exports['196rp_tax']:ApplyTax(price)
        taxRate = exports['196rp_tax']:GetRate()
    end
    local bank = Player.PlayerData.money.bank or 0
    local cash = Player.PlayerData.money.cash or 0

    if bank < taxed and cash < taxed then
        TriggerClientEvent('QBCore:Notify', src, ('Kifayət qədər pul yoxdur — qiymət (vergi ilə) ₣%d'):format(taxed), 'error')
        return
    end

    -- Əvvəl bankdan, qalığı nağddan
    if bank >= taxed then
        Player.Functions.RemoveMoney('bank', taxed, 'avtosalon-alis')
    else
        Player.Functions.RemoveMoney('bank', bank, 'avtosalon-alis')
        Player.Functions.RemoveMoney('cash', taxed - bank, 'avtosalon-alis')
    end

    local plate = GenPlate()
    MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state, garage, fuel, engine, body) VALUES (?, ?, ?, ?, ?, ?, 1, ?, 100, 1000.0, 1000.0)', {
        Player.PlayerData.license, Player.PlayerData.citizenid, model, '', '{}', plate, 'pillboxgarage',
    }, function()
        TriggerClientEvent('QBCore:Notify', src, ('🎉 Təbriklər! %s alındı (-₣%d) + vergi %s%%. Plitə: %s — qarajdan götürün.'):format(vehConfig.label, taxed, taxRate, plate), 'success')
    end)
end)

-- ── Sınaq sürüşü ──
RegisterNetEvent('196rp_dealer:server:testdrive', function(model)
    local src = source
    local vehConfig
    for _, v in ipairs(Config.Vehicles) do
        if v.model == model then vehConfig = v end
    end
    if not vehConfig then return end
    if testDrives[src] and testDrives[src] > os.time() then
        TriggerClientEvent('QBCore:Notify', src, 'Sınaq sürüşü artıq aktivdir!', 'error')
        return
    end
    testDrives[src] = os.time() + Config.TestDriveTime
    local plate = 'TEST' .. math.random(1000, 9999)
    TriggerClientEvent('196rp_dealer:client:testdrive', src, model, plate, Config.TestDriveTime)
end)


