-- 196 RP | Yanacaq sistemi — server tərəfi
-- Yanacaq səviyyəsinin saxlanması + ödənişli doldurma
-- 42-ci bənd: gün ərzində benzin qiyməti dəyişir

local ESX = exports['es_extended']:getSharedObject()

-- [plate] = fuel (0-100)
local fuelLevels = {}

-- ==================== QİYMƏT DƏYİŞKƏNLİYİ (42) ====================
-- Saat 6:00-da yeni günün qiyməti təyin olunur: ±30% dalğalanma

local currentPrice = Config.FuelPrice
local priceDay = nil

local function RollPrice()
    local hour = tonumber(os.date('%H')) or 12
    local dayKey = os.date('%Y-%m-%d')

    if priceDay == dayKey and hour < 6 then
        return
    end

    priceDay = dayKey
    math.randomseed(os.time())
    local factor = (math.random(70, 130) / 100)
    currentPrice = math.floor(Config.FuelPrice * factor * 100) / 100

    print(('[196rp_fuel] Bugünkü yanacaq qiyməti: $%s / litr'):format(currentPrice))
end

RollPrice()

CreateThread(function()
    while true do
        Wait(600000) -- 10 dəqiqə
        RollPrice()
    end
end)

exports('GetFuelPrice', function()
    return currentPrice
end)

-- ==================== SİNXRONİZASİYA ====================

RegisterNetEvent('196rp_fuel:sync', function(plate, fuel)
    if type(plate) ~= 'string' or type(fuel) ~= 'number' then
        return
    end

    fuel = math.max(0.0, math.min(100.0, fuel))
    fuelLevels[plate:upper()] = math.floor(fuel * 10) / 10
end)

exports('GetVehicleFuel', function(plate)
    if type(plate) ~= 'string' then
        return 100.0
    end
    return fuelLevels[plate:upper()] or 100.0
end)

exports('SetVehicleFuel', function(plate, fuel)
    if type(plate) ~= 'string' then
        return
    end
    fuelLevels[plate:upper()] = math.max(0.0, math.min(100.0, tonumber(fuel) or 0.0))
end)

-- ==================== DOLDURMA ====================

ESX.RegisterServerCallback('196rp_fuel:refuel', function(source, cb, plate, liters)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!', 0)
    end

    if type(plate) ~= 'string' then
        return cb(false, 'Maşın tapılmadı!', 0)
    end

    liters = math.floor(tonumber(liters) or 0)
    if liters < 1 or liters > 100 then
        return cb(false, '1-100 litr arası seçin!', 0)
    end

    -- Məntəqəyə yaxınlıq yoxlaması
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local nearStation = false

    for i = 1, #Config.Stations do
        if #(coords - Config.Stations[i].coords) < 15.0 then
            nearStation = true
            break
        end
    end

    if not nearStation then
        return cb(false, 'Yanacaq məntəqəsinə yaxın deyilsiniz!', 0)
    end

    local current = fuelLevels[plate:upper()] or 50.0
    local maxAdd = 100.0 - current
    if maxAdd < 1.0 then
        return cb(false, 'Bak artıq doludur!', current)
    end

    if liters > maxAdd then
        liters = math.floor(maxAdd)
    end

    local cost = math.ceil(liters * currentPrice)

    if xPlayer.getMoney() < cost then
        return cb(false, ('Pulunuz kifayət etmir! Lazımdır: ~y~%s$~s~'):format(cost), current)
    end

    xPlayer.removeMoney(cost)

    local newFuel = math.floor((current + liters) * 10) / 10
    fuelLevels[plate:upper()] = newFuel

    cb(true, ('~g~%s litr~s~ yanacaq dolduruldu — ~y~%s$~s~ (1L = %s$)')
        :format(liters, cost, currentPrice), newFuel)
end)
