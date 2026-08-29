-- 196 RP | Ev daxili imkanlar konfiqurasiyası
-- Bəndlər: 71 (ev açarları), 73 (seyf), 74 (divar rəngi), 75 (icarəyə vermək),
-- 76 (ev telefonu), 78 (balkon/bağça), 79 (qonaqlar), 80 (yataq otağı effekti)

-- 196rp_housing konfiqi @import ilə əvvəl yüklənir, ona görə Config sıfırlanmır
Config = Config or {}

-- 196rp_housing ilə eyni interyer
Config.Interior = vector3(266.0, -1007.0, -38.0)

-- İnteryer daxilindəki nöqtələr
Config.Points = {
    bed     = vector3(265.4, -998.6, -38.0),
    safe    = vector3(260.2, -1002.5, -38.0),
    phone   = vector3(268.4, -1004.2, -38.0),
    wall    = vector3(266.0, -1000.0, -38.0),
    balcony = vector3(262.0, -1010.0, -38.0),
}

Config.MarkerDist = 1.6
Config.InteriorDist = 12.0

-- ==================== 74. DIVAR RƏNGİ ====================

Config.WallColors = {
    { label = 'Ağ',        rgb = { 255, 255, 255 } },
    { label = 'Krem',      rgb = { 245, 235, 210 } },
    { label = 'Bej',       rgb = { 222, 184, 135 } },
    { label = 'Açıq boz',  rgb = { 200, 200, 205 } },
    { label = 'Mavi',      rgb = { 120, 170, 220 } },
    { label = 'Yaşıl',     rgb = { 140, 200, 150 } },
    { label = 'Çəhrayı',   rgb = { 235, 170, 190 } },
    { label = 'Bənövşəyi', rgb = { 170, 140, 210 } },
    { label = 'Qırmızı',   rgb = { 210, 100, 100 } },
    { label = 'Sarı',      rgb = { 240, 210, 120 } },
}

Config.WallLight = {
    range = 14.0,
    intensity = 4.0,
}

-- ==================== 73. SEYF ====================

Config.Safe = {
    price = 5000,          -- seyf almaq üçün
    maxMoney = 250000,
    maxItems = 60,         -- ümumi əşya sayı limiti
}

-- ==================== 75. İCARƏ ====================

Config.Rent = {
    minPrice = 500,
    maxPrice = 25000,
    periodHours = 24,      -- icarə müddəti (real saat)
    depositMult = 2.0,     -- kirayəçi depozit ödəyir
}

-- ==================== 80. YATAQ ====================

Config.Bed = {
    sleepTime = 8000,
    healAmount = 60,
    stressRelief = 25,
}

-- ==================== 78. BALKON ====================

Config.Balcony = {
    label = 'Balkon / bağça zonası',
    relaxTime = 10000,
    stressRelief = 15,
}
