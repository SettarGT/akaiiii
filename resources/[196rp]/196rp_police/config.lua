-- 196 RP | Polis sistemi

Config = {}

Config.Stations = {
    { name = 'Polis İdarəsi — Mission Row', coords = vector3(425.1, -979.5, 30.7), vehicleSpawn = vector3(430.0, -990.0, 30.7), vehicleHeading = 90.0 },
    { name = 'Polis Bölməsi — Sandy Shores', coords = vector3(1853.0, 3686.0, 34.3), vehicleSpawn = vector3(1860.0, 3690.0, 34.3), vehicleHeading = 180.0 },
    { name = 'Polis Bölməsi — Paleto Bay', coords = vector3(-447.0, 6014.0, 31.7), vehicleSpawn = vector3(-440.0, 6020.0, 31.7), vehicleHeading = 180.0 },
    { name = 'Polis Bölməsi — Davis', coords = vector3(360.0, -1580.0, 29.3), vehicleSpawn = vector3(365.0, -1585.0, 29.3), vehicleHeading = 90.0 },
}

-- Həbsxana kamerası
Config.Jail = {
    coords = vector3(1697.0, 2561.0, 45.6),
    heading = 270.0
}

-- Həbsdən çıxandan sonra şəhərə qayıdış nöqtəsi
Config.ReleaseSpawn = vector3(215.0, -810.0, 30.7)

-- Polis maşınları
Config.PoliceVehicles = {
    'police2', -- şəhər patrul
    'policeb', -- motosiklet
    'police3', -- offroad
}
