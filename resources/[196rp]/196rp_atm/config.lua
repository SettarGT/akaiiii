Config = {}

-- 196 Bank ATM-ləri
Config.Locations = {
    { label = '196 Bank | Legion', coords = vector3(111.14, -776.42, 31.66), heading = 180.0 },
    { label = '196 Bank | Del Perro', coords = vector3(15.02, -1119.58, 29.80), heading = 180.0 },
    { label = '196 Bank | Fleeca', coords = vector3(-34.71, -648.85, 32.73), heading = 180.0 },
    { label = '196 Bank | Portola', coords = vector3(145.88, -1041.14, 29.90), heading = 180.0 },
    { label = '196 Bank | Sandy', coords = vector3(1112.25, 263.68, 69.21), heading = 180.0 },
    { label = '196 Bank | Paleto', coords = vector3(-217.09, 6418.82, 31.88), heading = 180.0 },
}

-- Əməliyyat limitləri
Config.Limits = {
    MaxTransaction = 250000,   -- bir əməliyyat maksimumu
    QuickAmounts = { 100, 500, 1000, 5000, 10000 },  -- sürətli məbləğlər
}
