Config = {}

-- Discord webhook URL-ləri (öz serverinizin kanalları)
Config.Webhooks = {
    conn      = '',   -- giriş/çıxış
    money     = '',   -- pul əməliyyatları
    kills     = '',   -- ölümlər
    admin     = '',   -- admin əmrləri
    veh       = '',   -- avtomobil hadisələri
    items     = '',   -- əşya əlavə/silinmə
    reports   = '',   -- oyunçu reportları
    wl        = '',   -- whitelist müraciətləri
    anticheat = '',   -- cheat şübhələri
}

-- Anticheat parametrləri
Config.Anticheat = {
    CheckInterval = 5000,      -- yoxlama (ms)
    MaxSpeedRunning = 70,      -- piyada: 5 saniyədə max məsafə (m)
    MaxSpeedVehicle = 350,     -- maşın: km/saat həddi
    FlagsToKick = 3,           -- bu qədər flag → kick
    ExcludeAdmins = true,
}

-- Webhook davranışı
Config.LogEverything = false   -- true: hər şeyi (#money daxil)
