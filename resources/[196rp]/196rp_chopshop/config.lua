Config = {}

-- Söküm sexi
Config.Location = {
    label = '196 Söküm Sexi',
    coords = vector3(474.91, -1605.97, 19.76),
    heading = 0.0,
}

-- Hissə satış nöqtəsi
Config.SellPoint = {
    label = 'Qara Bazar Satışı',
    coords = vector3(473.15, -1599.14, 19.91),
}

-- Qiymətlər
Config.Prices = {
    ScrapPrice = 120,   -- bir metal parçası (₣)
}

-- Stress (196rp_stress resursu işləyirsə)
Config.StressIncrease = 40

-- Söküm parametrləri
Config.Chop = {
    Time = 45,          -- söküm vaxtı (saniyə)
    MinParts = 4,       -- min hissə
    MaxParts = 8,       -- max hissə
    Cooldown = 600,     -- 10 dəq soyutma
    MaxDistance = 8.0,  -- maşın məsafəsi
}
