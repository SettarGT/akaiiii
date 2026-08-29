Config = {}

-- Yanğın stansiyası (növbə + maşın)
Config.Station = {
    coords = vector3(-470.0, -710.0, 30.0),
    label = 'Yanğınsöndürən Stansiyası',
    blip = { sprite = 436, color = 1 },
}

-- Yanğın maşını
Config.FireTruck = 'firetruk'
Config.FireTruckPlatePrefix = 'YAN'

-- Yanğın baş vermə ehtimalı olan yerlər (şəhər + kənd)
Config.FireSpawns = {
    vector3(-880.0, -130.0, 38.0),   -- şəhər mərkəzi
    vector3(-300.0, -300.0, 20.0),   -- davis
    vector3(320.0, -700.0, 30.0),    -- mission row
    vector3(1200.0, -1100.0, 30.0),  -- liman
    vector3(-1100.0, -1600.0, 5.0),  -- del perro
    vector3(1700.0, 3700.0, 34.0),   -- sandy shores
    vector3(2500.0, 4900.0, 46.0),   -- grapeseed
    vector3(-250.0, 6300.0, 31.0),   -- paleto
    vector3(950.0, 40.0, 81.0),      -- kazino yaxınlığı
    vector3(480.0, -980.0, 30.0),    -- polis yaxınlığı
}

-- Yanğın parametrləri
Config.FireInterval = { min = 480000, max = 900000 }   -- yeni yanğın (8-15 dəq)
Config.FireLifetime = 300000                            -- yanğın müddəti (5 dəq)
Config.PayPerFire = 250                                 -- hər söndürülmüş yanğına ödəniş
Config.ExtinguishTime = 6000                             -- söndürmə müddəti (ms)

-- Yanğın zamanı TİB-ə xəbərdarlıq
Config.NotifyEMS = true
