-- 196 RP | Qanunsuz fəaliyyətlər konfiqurasiyası
-- Bəndlər: 65 (rehin alma), 66 (şom və qıfıl açarı), 67 (dələduzluq),
-- 68 (müsadirə anbarından oğurluq), 69 (gizli yeraltı yer), 70 (zibil ərazisi)

Config = {}

-- ==================== 66. ŞOM VƏ QIFIL AÇARI ====================

Config.Tools = {
    lockpick = {
        item = 'qifil_acari',
        label = 'Qıfıl açarı',
        maxDistance = 3.0,
        time = 9000,          -- açma vaxtı
        successChance = 55,   -- uğur şansı %
        breakChance = 30,     -- alətin sınma şansı %
        cooldown = 20,
        alertRadius = 60.0,   -- bu məsafədəki polislər xəbər tutur
    },
    crowbar = {
        item = 'som',
        label = 'Şom',
        maxDistance = 3.5,
        time = 12000,
        successChance = 80,
        breakChance = 15,
        cooldown = 30,
    },
}

-- ==================== 65. REHİN ALMA ====================

Config.Hostage = {
    maxDistance = 3.0,
    followDistance = 1.8,
    duration = 180,             -- saniyə — rehin saxlama vaxtı
    policeAlertRadius = 300.0,  -- bu məsafədəki polislər xəbər tutur
    reward = 800,               -- rehinəni sağ-salamat saxlayıb qaçsan
    cooldown = 120,
    item = 'som',               -- rehin almaq üçün alət lazımdır
}

-- ==================== 67. DƏLƏDUZLUQ ====================

Config.Fraud = {
    table = vector3(985.0, -105.0, 74.0),      -- saxta pul masası (gizli otaqda)
    moneyItem = 'saxta_pul',
    fakeIdItem = 'saxta_vesiqe',
    exchangeRate = 1.35,        -- 1000$ təmiz pul → 1350$ saxta pul (banka qoyanda risk var)
    maxPerOperation = 20000,
    time = 15000,
    caughtChance = 12,          -- əməliyyat zamanı yaxalanma şansı %
    cooldown = 120,
    depositPenalty = 25,        -- saxta pulu banka qoyanda % cərimə riski
}

-- ==================== 68. MÜSADİRƏ ANBARI ====================

Config.ImpoundRaid = {
    gate = vector3(400.0, -1620.0, 29.0),       -- müsadirə meydançası (196rp_garage ilə eyni)
    spawn = vector3(410.0, -1615.0, 29.0),
    heading = 100.0,
    toolItem = 'som',
    time = 14000,
    cooldown = 600,
    policeAlertRadius = 120.0,
    wantedLevel = 3,
    models = { 'panto', 'blista', 'asea', 'emperor', 'premier', 'sultan', 'bison', 'faggio' },
    platePrefix = 'OGU',         -- oğurlanmış nömrə ön eki
}

-- ==================== 69. GİZLİ YER ====================

Config.Hideout = {
    entrance = vector3(700.0, -960.0, 24.0),    -- giriş (qapaq)
    interior = vector3(985.0, -100.0, 74.0),    -- yeraltı otaq
    interiorExit = vector3(982.0, -101.0, 74.0),
    exitTo = vector3(702.0, -960.0, 24.0),
    stash = vector3(990.0, -103.0, 74.0),
    blip = { sprite = 154, colour = 1, scale = 0.7 },
    showBlip = false,           -- xəritədə görünmür (gizli yer)
    stashSlots = 60,
}

-- ==================== 70. ZİBİL ƏRAZİSİ ====================

Config.Junkyard = {
    coords = vector3(2340.0, 3130.0, 48.0),
    radius = 25.0,
    scrapItem = 'qirinti',
    payPerScrap = 12,
    time = 10000,
    cooldown = 15,
    ambushChance = 12,          -- hücum şansı %
    stolenVehicleBonus = 200,   -- oğurlanmış maşını təhvil versən
    platePrefix = 'OGU',
}
