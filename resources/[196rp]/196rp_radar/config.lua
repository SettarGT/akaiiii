Config = {}

-- Radar parametrləri
Config.Radar = {
    Range = 35.0,        -- məsafə (m)
    FOV = 60.0,          -- baxış bucağı dərəcə
    MaxSpeed = 350,      -- km/s (limit tanıma üçün)
    UpdateRate = 150,    -- ms (NUI yeniləmə)
}

-- Sürət limitləri (km/s) — radarda göstərilir
Config.SpeedLimits = {
    { label = 'Mərkəz',  speed = 40 },
    { label = 'Şəhər',   speed = 60 },
    { label = 'Magistral', speed = 100 },
}

-- İşlər
Config.Jobs = { 'police', 'sheriff', 'ranger', 'trooper' }

-- Plate scanner məsafəsi
Config.PlateRange = 6.0
