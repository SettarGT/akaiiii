-- 196 RP | Həyat tərzi konfiqurasiyası
-- Bəndlər: 2 (xəstəxana), 4 (gigiyena), 5 (siqaret), 6 (alkoqol), 7 (stress),
-- 8 (üzgüçülük), 9 (hava), 10 (geyim istiliyi), 11 (bişirmə), 12 (qeydlər),
-- 14 (yaş/ad günü), 15 (mövsümlər)

Config = {}

-- ==================== 4. GİGİYENA ====================

Config.Hygiene = {
    start = 100,
    decayPerMinute = 1.6,     -- hər dəqiqədə azalma
    lowThreshold = 25,        -- bu dəyərdən aşağı xəbərdarlıq
    healthDrain = 1,          -- aşağı gigiyenada hər 30 saniyədə can itkisi
    showerRestore = 100,
    showerTime = 6000,
}

-- Duş qəbul etmək mümkün olan yerlər
Config.Showers = {
    { label = 'Del Perro Çimərliyi — Duş',     coords = vector3(-1580.0, -1050.0, 13.0) },
    { label = 'Vespucci Çimərliyi — Duş',      coords = vector3(-1240.0, -1490.0, 4.4) },
    { label = 'Şəhər Hovuzu — Duş',            coords = vector3(-180.0, -1560.0, 30.7) },
    { label = 'İdman Zalı — Duş',              coords = vector3(-80.0, -1470.0, 30.0) },
    { label = 'Ev İnteryeri — Hamam',          coords = vector3(266.0, -1007.0, -38.0) },
}

-- ==================== 5. SİQARET ====================

Config.Smoking = {
    item = 'siqaret',
    stressRelief = 8,          -- siqaret stressi azaldır
    healthCost = 2,            -- amma canı bir az aparır
    duration = 8000,
    cooldown = 20000,
}

-- ==================== 6. ALKOQOL ====================

Config.Alcohol = {
    drinks = {
        ['pive']  = { level = 20, label = 'Pivə' },
        ['serab'] = { level = 45, label = 'Şərab' },
        ['araq']  = { level = 80, label = 'Araq' },
    },
    decayPerMinute = 4,        -- sərxoşluq azalma sürəti
    dizzyLevel = 30,           -- bu səviyyədə ekran bulanır
    staggerLevel = 60,         -- bu səviyyədə yerimə pozulur
    blackoutLevel = 95,        -- bu səviyyədə huşunu itirir
}

-- ==================== 7. STRESS ====================

Config.Stress = {
    start = 0,
    max = 100,
    increaseOnDamage = 6,      -- zərbə alanda
    increaseOnFight = 10,      -- dava zamanı
    decreasePerMinute = 1.2,   -- sakit olanda azalır
    restMultiplier = 3.0,      -- oturanda/uzananda 3 qat tez azalır
    warnThreshold = 60,
    panicThreshold = 85,       -- ekran titrəməsi
}

-- ==================== 8. ÜZGÜÇÜLÜK ====================

Config.Swimming = {
    staminaDrain = 1.2,        -- hər saniyədə üzümlülük itkisi
    dangerThreshold = 20,
    healthDrain = 2,           -- üzümlülük bitəndə can itkisi
    sickAfterDrown = true,     -- boğulandan sonra xəstələnir
}

-- ==================== 2. XƏSTƏXANA ====================

Config.Hospital = {
    healPrice = 500,           -- tam müalicə
    cureSickPrice = 300,       -- xəstəlikdən müalicə
    healTime = 8000,
    locations = {
        { label = 'Pillbox Xəstəxanası — Qəbul', coords = vector3(307.0, -595.0, 43.3) },
        { label = 'Sandy Shores Klinikası — Qəbul', coords = vector3(1839.0, 3672.0, 34.3) },
        { label = 'Paleto Bay Klinikası — Qəbul', coords = vector3(-247.0, 6330.0, 32.4) },
    },
}

-- ==================== 11. YEMƏK BİŞİRMƏ ====================

Config.Cooking = {
    -- Ev interyerindəki mətbəx nöqtəsi
    kitchen = vector3(265.0, -1000.0, -38.0),
    cookTime = 7000,
    recipes = {
        { label = 'Bişmiş ət',     ingredients = { { item = 'mal_eti', count = 1 } }, output = 'bismis_et', count = 1 },
        { label = 'Bişmiş balıq',  ingredients = { { item = 'baliq',   count = 2 } }, output = 'bismis_baliq', count = 1 },
        { label = 'Çörək',         ingredients = { { item = 'bugda',   count = 2 } }, output = 'corek',        count = 2 },
        { label = 'Meyvə salatı',  ingredients = { { item = 'meyve',   count = 2 } }, output = 'salat',        count = 1 },
    },
}

-- ==================== 12. QEYDLƏR ====================

Config.Notes = {
    max = 25,
    maxLength = 200,
}

-- ==================== 14. AD GÜNÜ ====================

Config.Birthday = {
    gift = 1000,
    message = '🎉 Bu gün ad gününüzdür! 196 RP komandası sizi təbrik edir.',
}

-- ==================== 15. MÖVSÜMLƏR ====================

Config.Seasons = {
    -- ay → mövsüm
    months = {
        [12] = 'winter', [1] = 'winter', [2] = 'winter',
        [3] = 'spring',  [4] = 'spring', [5] = 'spring',
        [6] = 'summer',  [7] = 'summer', [8] = 'summer',
        [9] = 'autumn',  [10] = 'autumn', [11] = 'autumn',
    },
    labels = {
        winter = '❄️ Qış',
        spring = '🌸 Yaz',
        summer = '☀️ Yay',
        autumn = '🍂 Payız',
    },
    effects = {
        winter = { energyDrainMult = 1.30, waterMult = 0.90 },  -- soyuqda enerji tez gedir
        spring = { energyDrainMult = 1.00, waterMult = 1.00 },
        summer = { energyDrainMult = 1.00, waterMult = 1.30 },  -- istidə su tez gedir
        autumn = { energyDrainMult = 1.10, waterMult = 1.00 },
    },
}

-- ==================== 9/10. HAVA VƏ GEYİM ====================

Config.Weather = {
    rain = { 'RAIN', 'THUNDER', 'CLEARING' },
    snow = { 'SNOW', 'SNOWLIGHT', 'XMAS', 'BLIZZARD' },
    rainStress = 0.4,          -- yağışda dəqiqədə stress artımı
    coldDamage = 1,            -- qışda soyuq geyimdə hər 30 saniyədə can itkisi
    jacketComponents = { 11, 3 }, -- gödəkçə / qol komponentləri
}

-- ==================== 1. VƏSİQƏ NÖVLƏRİ ====================

Config.Licenses = {
    { type = 'dmv',         label = 'Avtomobil vəsiqəsi',  price = 700,  vehicleClass = nil },
    { type = 'drive_bike',  label = 'Motosiklet vəsiqəsi', price = 500,  vehicleClass = 8 },
    { type = 'drive_truck', label = 'Yük maşını vəsiqəsi', price = 1200, vehicleClass = 20 },
    { type = 'boat',        label = 'Qayıq vəsiqəsi',      price = 900,  vehicleClass = 14 },
}
