-- 196 RP | Sürət kameraları və yol nişanları
--
-- Kameralar YALNIZ aşağıdakı nöqtələrdədir — şəhərin qalan hissəsində rahat sürmək olar.
-- Kameraya 100 metr qalmış xəritədə işarə + bildiriş gəlir.

Config = {}

-- Xəbərdarlıq məsafəsi (metr)
Config.WarnDistance = 100

-- Cərimə: hər km/s artıq üçün
Config.FinePerKmh = 8
Config.MinFine = 100
Config.MaxFine = 5000

-- =====================================================================
-- SÜRƏT KAMERALARI (hər birinin öz sürət həddi var)
-- =====================================================================

Config.Cameras = {
    -- Şəhər mərkəzi (limit 50)
    { coords = vector3(215.0, -810.0, 30.5),  limit = 50, name = 'Legion Meydanı' },
    { coords = vector3(-75.0, -822.0, 30.5),  limit = 50, name = 'Maze Bank qarşısı' },
    { coords = vector3(25.7, -1345.5, 29.3),  limit = 50, name = '24/7 Market küçəsi' },
    { coords = vector3(425.0, -979.0, 30.5),  limit = 50, name = 'Polis İdarəsi yolu' },

    -- Sahil yolu (limit 60)
    { coords = vector3(-1180.0, -900.0, 13.5), limit = 60, name = 'Del Perro bulvarı' },
    { coords = vector3(-1631.0, -1010.0, 6.5), limit = 60, name = 'Pier yolu' },

    -- Magistral yollar (limit 90)
    { coords = vector3(-750.0, -2200.0, 20.5), limit = 90, name = 'Elysian magistralı' },
    { coords = vector3(1000.0, -2300.0, 30.5), limit = 90, name = 'La Mesa magistralı' },
    { coords = vector3(2050.0, 2830.0, 45.5),  limit = 90, name = 'Şərq magistralı' },
    { coords = vector3(-2555.0, 2334.0, 33.5), limit = 90, name = 'Route 68' },

    -- Kənd yolları (limit 70)
    { coords = vector3(1600.0, 3700.0, 34.5),  limit = 70, name = 'Sandy Shores girişi' },
    { coords = vector3(2450.0, 4960.0, 46.5),  limit = 70, name = 'Grapeseed yolu' },
    { coords = vector3(-250.0, 6300.0, 32.5),  limit = 70, name = 'Paleto Bay girişi' },
}

-- =====================================================================
-- SÜRƏT HƏDDİ ZONALARI (yol nişanları — 44-cü bənd)
-- =====================================================================

Config.SpeedZones = {
    { coords = vector3(0.0, -900.0, 30.0),     radius = 700.0, limit = 50, label = 'Şəhər mərkəzi' },
    { coords = vector3(-1400.0, -1000.0, 10.0), radius = 500.0, limit = 60, label = 'Sahil zonası' },
    { coords = vector3(300.0, 200.0, 105.0),   radius = 500.0, limit = 50, label = 'Vinewood' },
    { coords = vector3(1600.0, 3700.0, 34.0),  radius = 600.0, limit = 70, label = 'Sandy Shores' },
    { coords = vector3(-250.0, 6300.0, 32.0),  radius = 600.0, limit = 70, label = 'Paleto Bay' },
    { coords = vector3(2450.0, 4960.0, 46.0),  radius = 600.0, limit = 70, label = 'Grapeseed' },
    { coords = vector3(1000.0, -2500.0, 30.0), radius = 900.0, limit = 90, label = 'Cənub magistralı' },
    { coords = vector3(-2400.0, 2400.0, 33.0), radius = 900.0, limit = 90, label = 'Qərb magistralı' },
}
