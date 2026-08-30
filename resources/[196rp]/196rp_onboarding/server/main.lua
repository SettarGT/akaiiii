local QBCore = exports['qb-core']:GetCoreObject()

-- ═══════════════════════════════════════════════════════════════
-- Yeni oyunçu yoxlanışı (ilk giriş → onboarding başlat)
-- ═══════════════════════════════════════════════════════════════

local function IsOnboardingDone(citizenid)
    local row = MySQL.single.await('SELECT done FROM `196_tutorial` WHERE citizenid = ? LIMIT 1', { citizenid })
    return row ~= nil and row.done == 1
end

local function MarkOnboardingDone(citizenid)
    MySQL.insert('INSERT INTO `196_tutorial` (citizenid, done, done_at) VALUES (?, 1, NOW()) ON DUPLICATE KEY UPDATE done = 1, done_at = NOW()', { citizenid })
end

AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    if not Config.Onboarding.enabled then return end
    local citizenid = Player.PlayerData.citizenid
    if IsOnboardingDone(citizenid) then return end

    -- Kimliyi ilə onboarding başlat
    TriggerClientEvent('196rp_onboarding:client:start', Player.PlayerData.source, Config.AirportSpawn.coords, Config.CityHallWaypoint.coords)
end)

-- ═══════════════════════════════════════════════════════════════
-- Sim kart: yeni 196-XXX nömrəsi
-- ═══════════════════════════════════════════════════════════════

RegisterNetEvent('196rp_onboarding:server:buysim', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if (Player.PlayerData.money.cash or 0) < Config.SimKiosk.price then
        TriggerClientEvent('QBCore:Notify', src, ('Sim kart qiyməti: ₣%d'):format(Config.SimKiosk.price), 'error')
        return
    end

    local newNumber = QBCore.Functions.CreatePhoneNumber()
    Player.Functions.RemoveMoney('cash', Config.SimKiosk.price, 'sim-card')
    Player.PlayerData.charinfo.phone = newNumber
    MySQL.update('UPDATE players SET charinfo = JSON_SET(charinfo, \'$.phone\', ?) WHERE citizenid = ?', { newNumber, Player.PlayerData.citizenid })

    TriggerClientEvent('QBCore:Notify', src, ('📱 Yeni nömrəniz: %s (-₣%d)'):format(newNumber, Config.SimKiosk.price), 'success')
end)

-- ═══════════════════════════════════════════════════════════════
-- Rentcar: kirayə / qaytarma / doldurma
-- ═══════════════════════════════════════════════════════════════

local rentals = {} -- plate → { citizenid, expires, free }

RegisterNetEvent('196rp_onboarding:server:rentcar', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Artıq aktiv icarəsi varsa
    for plate, r in pairs(rentals) do
        if r.citizenid == Player.PlayerData.citizenid then
            TriggerClientEvent('QBCore:Notify', src, 'Artıq aktiv icarəniz var. Qaytarmaq üçün /' .. Config.ReturnCommand, 'error')
            return
        end
    end

    -- İlk icarə pulsuzdur (onboarding bitməyənlər üçün)
    local free = not IsOnboardingDone(Player.PlayerData.citizenid)
    local price = Config.RentCar.pricePerHour
    if not free then
        if Player.PlayerData.money.cash < price then
            TriggerClientEvent('QBCore:Notify', src, 'Kifayət qədər pulunuz yoxdur! (Tələb: ₣' .. price .. ')', 'error')
            return
        end
        Player.Functions.RemoveMoney('cash', price, 'rentcar-kiraye')
    end

    -- Maşını dünyaya çıxar (klient icarə edir)
    TriggerClientEvent('196rp_onboarding:client:spawnRent', src, Config.RentCar.model, Config.RentCar.returnCoords)
end)

-- Klientdən qeydiyyat (maşın spawn edildikdə)
RegisterNetEvent('196rp_onboarding:server:registerRent', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not plate then return end
    rentals[plate] = {
        citizenid = Player.PlayerData.citizenid,
        expires = os.time() + Config.RentCar.maxRentalMinutes * 60,
        free = false,
    }
    MySQL.insert('INSERT INTO `196_rentals` (citizenid, plate, started_at, expires_at, status) VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL ? MINUTE), ?)',
        { Player.PlayerData.citizenid, plate, Config.RentCar.maxRentalMinutes, 'active' })
end)

-- Qaytarma
RegisterNetEvent('196rp_onboarding:server:returnRent', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local found = false
    for plate, r in pairs(rentals) do
        if r.citizenid == Player.PlayerData.citizenid then
            -- Maşını sil (klient)
            TriggerClientEvent('196rp_onboarding:client:despawnRent', src, plate)
            MySQL.update('UPDATE `196_rentals` SET status = ?, returned_at = NOW() WHERE plate = ? AND status = ?', { 'returned', plate, 'active' })
            rentals[plate] = nil
            found = true
            break
        end
    end
    if found then
        TriggerClientEvent('QBCore:Notify', src, 'Rentcar uğurla qaytarıldı. Xoş gəlmisiniz!', 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'Aktiv icarə tapılmadı.', 'error')
    end
end)

-- Onboarding bitdi → qeyd et
RegisterNetEvent('196rp_onboarding:server:done', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    MarkOnboardingDone(Player.PlayerData.citizenid)
end)

QBCore.Commands.Add(Config.ReturnCommand, 'Rentcarı qaytarmaq (Onboarding)', {}, false, function(source)
    TriggerEvent('196rp_onboarding:server:returnRent', source)
end, false)
