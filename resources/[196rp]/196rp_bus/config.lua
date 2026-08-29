-- 196 RP | Avtobus sistemi konfiqurasiyası
-- Hər nömrə ayrı marşrutla gedir. Tətbiq (/avtobus) hansı nömrənin hara getdiyini göstərir.

Config = {}

-- Sərnişin gediş haqqı (şəhərdaxili)
Config.CityFare = 10

-- Şəhərlərarası gediş haqqı (avtovağzal)
Config.IntercityFare = 120

-- Avtobus modeli və rəngi
Config.BusModel = 'bus'
Config.BusSpeed = 13.0   -- m/s

-- =====================================================================
-- MARŞRUTLAR (hər nömrə ayrı yerə gedir)
-- =====================================================================

Config.Routes = {
    {
        number = 1,
        name = 'Mərkəz Xətti',
        color = { r = 40, g = 130, b = 230 },
        blipColor = 3,
        stops = {
            { label = 'Avtovağzal',              coords = vector3(452.0, -625.0, 28.0) },
            { label = 'Legion Meydanı',          coords = vector3(215.0, -810.0, 30.7) },
            { label = 'Binco Geyim',             coords = vector3(72.3, -1399.1, 29.4) },
            { label = '24/7 Market',             coords = vector3(25.7, -1345.5, 29.5) },
            { label = 'Maze Bank',               coords = vector3(-75.0, -822.0, 30.0) },
            { label = 'Pillbox Xəstəxanası',     coords = vector3(307.0, -595.0, 43.3) },
        }
    },
    {
        number = 2,
        name = 'Sahil Xətti',
        color = { r = 40, g = 200, b = 120 },
        blipColor = 2,
        stops = {
            { label = 'Del Perro Çimərliyi',     coords = vector3(-1580.0, -1050.0, 13.0) },
            { label = 'Vespucci Kanalı',         coords = vector3(-1100.0, -1520.0, 4.5) },
            { label = 'Pier Restoranı',          coords = vector3(-1631.0, -1010.0, 6.0) },
            { label = 'Vespucci Marina',         coords = vector3(-1010.0, -640.0, 12.0) },
            { label = 'Legion Meydanı',          coords = vector3(215.0, -810.0, 30.7) },
        }
    },
    {
        number = 3,
        name = 'Şimal Xətti',
        color = { r = 230, g = 150, b = 30 },
        blipColor = 5,
        stops = {
            { label = 'Paleto Bay',              coords = vector3(-250.0, 6300.0, 32.0) },
            { label = 'Grapeseed',               coords = vector3(2450.0, 4960.0, 46.0) },
            { label = 'Sandy Shores',            coords = vector3(1600.0, 3700.0, 34.0) },
            { label = 'Harmony',                 coords = vector3(400.0, 3590.0, 35.0) },
            { label = 'Alamo Gölü',              coords = vector3(1320.0, 4250.0, 33.0) },
        }
    },
    {
        number = 4,
        name = 'Hava Limanı Xətti',
        color = { r = 200, g = 60, b = 200 },
        blipColor = 27,
        stops = {
            { label = 'Hava Limanı Terminalı',   coords = vector3(-1030.0, -2750.0, 20.0) },
            { label = 'Elysian Limanı',          coords = vector3(1050.0, -3100.0, 5.9) },
            { label = 'Maze Bank',               coords = vector3(-75.0, -822.0, 30.0) },
            { label = 'Vinewood Bulvarı',        coords = vector3(310.0, 190.0, 104.0) },
            { label = 'Avtovağzal',              coords = vector3(452.0, -625.0, 28.0) },
        }
    },
}

-- =====================================================================
-- AVTOVAĞZAL (şəhərlərarası xətlər)
-- =====================================================================

Config.Terminal = {
    coords = vector3(452.0, -625.0, 28.0),
    label = '196 Avtovağzal — Şəhərlərarası Xətlər',
    destinations = {
        { label = 'Sandy Shores',   coords = vector3(1600.0, 3700.0, 34.0), price = 120 },
        { label = 'Paleto Bay',     coords = vector3(-250.0, 6300.0, 32.0), price = 180 },
        { label = 'Grapeseed',      coords = vector3(2450.0, 4960.0, 46.0), price = 150 },
        { label = 'Hava Limanı',    coords = vector3(-1030.0, -2750.0, 20.0), price = 100 },
        { label = 'Del Perro',      coords = vector3(-1580.0, -1050.0, 13.0), price = 90 },
        { label = 'Chumash',        coords = vector3(-3150.0, 1050.0, 20.0), price = 200 },
    }
}

-- =====================================================================
-- TAKSİ ÇAĞIRIŞI
-- =====================================================================

Config.Taxi = {
    fare = 60,            -- sərnişinin ödədiyi məbləğ
    driverShare = 50,     -- sürücünün qazancı
    callDuration = 90,    -- çağırış xəritədə neçə saniyə görünür
}
