Config = {}

-- ═══════════════════════════════════════════════════════════════
-- 196 RP | Onboarding (Yeni oyunçu təcrübəsi)
-- ═══════════════════════════════════════════════════════════════

-- Aeroport (LSIA) — yeni oyunçular burada spawn olur
Config.AirportSpawn = {
    coords = vector4(-1032.0, -2731.0, 13.9, 180.0), -- LSIA terminal çıxışı
}

-- Bələdiyyə (pasport / FİN / sürücülük) — GPS ulduzu
Config.CityHallWaypoint = {
    coords = vector3(-550.8, -191.5, 38.2), -- City Hall
}

-- Rentcar kiosk (aeroportdan çıxışda)
Config.Kiosk = {
    coords = vector3(-1025.0, -2726.0, 13.9),
    heading = 180.0,
    prop = 'prop_atm_02',            -- kiosk obyekti
    label = 'Rent-A-Car | Kiosk',
}

-- Rentcar maşını (yeni oyunçular üçün)
Config.RentCar = {
    model = 'blista',                -- ən ucuz start maşını
    pricePerHour = 250,              -- ₣/saat
    firstRentalFree = true,          -- ilk icarə pulsuz (onboarding)
    freeRentalSeconds = 1800,        -- 30 dəqiqə pulsuz
    maxRentalMinutes = 120,          -- maksimum icarə müddəti
    deposit = 500,                   -- zəmanət (qaytaranda geri)
    returnCoords = vector3(-1028.0, -2722.0, 13.9), -- qaytarma nöqtəsi (aeroport)
    returnRadius = 8.0,
}

-- Onboarding menyusu (ilk giriş üçün)
Config.Onboarding = {
    enabled = true,
    cinematicTime = 8000,            -- kinematik kamera müddəti (ms)
    waypointToCityHall = true,       -- Bələdiyyəyə GPS ulduzu
    teleportToAirport = true,        -- spawn aerporta köçürülür
}

-- İpucu pəncərələri (tooltips)
Config.Tips = {
    { icon = '💬', title = 'Danışıq',   text = 'Yaxındakılarla danışmaq üçün [N] düyməsini saxla. Səs səviyyəsi üçün [F7].', showAfter = 2000,  duration = 6000 },
    { icon = '🎒', title = 'İnventar',  text = 'Çantanı açmaq və əşyalara baxmaq üçün [I] və ya [TAB] bas.', showAfter = 9000,  duration = 6000 },
    { icon = '📱', title = 'Telefon',   text = 'Əlaqə qurmaq üçün [F1] (radial) və ya [M] (telefon) düyməsini istifadə et.', showAfter = 16000, duration = 6000 },
    { icon = '🚗', title = 'Rentcar',   text = 'Kioskdakı maşını icarəyə götür, [G] mühərrik, [L] kilid, [B] kəmər.', showAfter = 23000, duration = 6000 },
    { icon = '🗺️', title = 'Bələdiyyə', text = 'Pasport və FİN üçün xəritədəki qızılı ulduza (Bələdiyyə) get.', showAfter = 30000, duration = 8000 },
}

-- Cinematik ekran mətni
Config.Welcome = {
    title = '196 RP',
    subtitle = 'Yeni Era',
    title2 = '196 RP-yə Xoş Gəlmisiniz',
}

-- Qaytarma əmri
Config.ReturnCommand = 'rentqaytar'
