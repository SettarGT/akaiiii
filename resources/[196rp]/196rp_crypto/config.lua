Config = {}

-- Kripto kiosk yeri
Config.Location = {
    label = '196 Kripto Bazarı',
    coords = vector3(-616.85, -709.51, 31.31),
    heading = 0.0,
}

-- Başlanğıc qiymət (₣)
Config.StartPrice = 1200

-- Bazar simulyasiyası
Config.Sim = {
    Interval = 60,       -- hər 60 saniyə yenilənir
    Volatility = 0.06,   -- hərəkət amplitudası (%)
    HistorySize = 48,    -- qrafikdə nöqtə sayı
}

-- Əməliyyat limitləri
Config.Limits = {
    MinTrade = 100,       -- min əməliyyat (₣)
    MaxTrade = 1000000,   -- max əməliyyat (₣)
    Fee = 1.0,            -- komissiya (%)
}
