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

local rentals = {} -- plate → { citizenid, expires, free, startedAt, rate, firstPaid, depositPaid }

local function NightFactor()
    local hour = tonumber(os.date('%H')) or 0
    if hour >= Config.RentCar.nightStart and hour < Config.RentCar.nightEnd then
        return Config.RentCar.nightFactor or 0.5
    end
    return 1.0
end

local function FindModel(model)
    for _, m in ipairs(Config.RentCar.models) do
        if m.model == model then return m end
    end
    return Config.RentCar.models[1]
end

RegisterNetEvent('196rp_onboarding:server:rentcar', function(model)
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
    local modelDef = FindModel(model)
    local rate = math.floor(Config.RentCar.pricePerHour * NightFactor() + 0.5)
    local depositPaid = false
    local firstPaid = 0

    if not free then
        local need = rate + Config.RentCar.deposit
        if Player.PlayerData.money.cash < need then
            TriggerClientEvent('QBCore:Notify', src, ('Kifayət qədər pulunuz yoxdur! (Tələb: ₣%d — icarə + zəmanət)'):format(need), 'error')
            return
        end
        Player.Functions.RemoveMoney('cash', rate, 'rentcar-kiraye')
        Player.Functions.RemoveMoney('cash', Config.RentCar.deposit, 'rentcar-deposit')
        depositPaid = true
        firstPaid = rate
    end

    -- Maşını dünyaya çıxar (klient icarə edir)
    local pd = { citizenid = Player.PlayerData.citizenid, rate = rate, free = free, depositPaid = depositPaid, firstPaid = firstPaid }
    TriggerClientEvent('196rp_onboarding:client:spawnRent', src, modelDef.model, Config.RentCar.returnCoords, pd)
end)

-- Klientdən qeydiyyat (maşın spawn edildikdə)
RegisterNetEvent('196rp_onboarding:server:registerRent', function(plate, pd)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not plate then return end
    local extra = (type(pd) == 'table' and pd.citizenid == Player.PlayerData.citizenid) and pd or nil
    rentals[plate] = {
        citizenid = Player.PlayerData.citizenid,
        expires = os.time() + Config.RentCar.maxRentalMinutes * 60,
        free = extra and extra.free or false,
        startedAt = os.time(),
        rate = extra and extra.rate or math.floor(Config.RentCar.pricePerHour + 0.5),
        firstPaid = extra and extra.firstPaid or 0,
        depositPaid = extra and extra.depositPaid or false,
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

            -- Hesabat: istifadə olunan saatlar × gecə dərəcəsi, zəmanət qaytarılır
            local hours = math.max(1, math.ceil((os.time() - (r.startedAt or os.time())) / 3600))
            local total = hours * (r.rate or Config.RentCar.pricePerHour)
            local extraCost = math.max(0, total - (r.firstPaid or 0))
            if not r.free and extraCost > 0 and Player.PlayerData.money.cash >= extraCost then
                Player.Functions.RemoveMoney('cash', extraCost, 'rentcar-hesabat')
            end
            local refund = r.depositPaid and Config.RentCar.deposit or 0
            if refund > 0 then
                Player.Functions.AddMoney('cash', refund, 'rentcar-deposit-qaytar')
            end
            local nf = r.rate / Config.RentCar.pricePerHour
            TriggerClientEvent('QBCore:Notify', src,
                ('🎫 Rentcar: %d saat × ₣%d (gecə %d%%) = ₣%d | Zəmanət: +₣%d'):format(hours, r.rate or 250, math.floor(nf * 100), total, refund),
                'success')

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
