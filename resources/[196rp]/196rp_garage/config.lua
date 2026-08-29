-- 196 RP | Qaraj sistemi

Config = {}

-- Qarajlar
Config.Garages = {
    { id = 'garage_center', name = 'Mərkəzi Qaraj', type = 'car', coords = vector3(227.0, -792.0, 30.4) },
    { id = 'garage_davis', name = 'Davis Qarajı', type = 'car', coords = vector3(365.0, -1570.0, 29.3) },
    { id = 'garage_vinewood', name = 'Vinewood Qarajı', type = 'car', coords = vector3(630.0, 270.0, 103.1) },
    { id = 'garage_sandy', name = 'Sandy Shores Qarajı', type = 'car', coords = vector3(549.2, 2669.2, 42.2) },
    { id = 'garage_paleto', name = 'Paleto Bay Qarajı', type = 'car', coords = vector3(-300.0, 6250.0, 31.5) },
    { id = 'garage_delperro', name = 'Del Perro Qarajı', type = 'car', coords = vector3(-1180.0, -900.0, 14.0) },
    { id = 'garage_marina', name = 'Vespucci Marina (Qayıqlar)', type = 'boat', coords = vector3(-1010.0, -640.0, 12.0) },
    { id = 'garage_airport', name = 'Hava Limanı Anqarı (Təyyarələr)', type = 'aircraft', coords = vector3(-1030.0, -2750.0, 20.0) },
}

-- Mühafizə (impound) meydançası — buradan cərimə ödəyib maşını geri alırsınız
Config.Impound = {
    name = 'Mühafizə Meydançası',
    coords = vector3(400.0, -1620.0, 29.0),
    retrievePrice = 300
}

-- Mexanik servis məntəqələri (təmir + yuma)
Config.Services = {
    { id = 'service_1', name = 'Mexanik Servis — La Mesa', coords = vector3(488.4, -1318.7, 29.2) },
    { id = 'service_2', name = 'Mexanik Servis — La Puerta', coords = vector3(723.1, -1088.9, 22.2) },
    { id = 'service_3', name = 'Mexanik Servis — Strawberry', coords = vector3(-211.5, -1324.9, 30.9) },
    { id = 'service_4', name = 'Mexanik Servis — Elysian', coords = vector3(-1154.9, -2006.1, 13.2) },
    { id = 'wash_1', name = 'Avtoyuma — Legion', coords = vector3(20.5, -1393.7, 29.3) },
    { id = 'wash_2', name = 'Avtoyuma — Vespucci', coords = vector3(-698.6, -933.3, 19.0) },
}

Config.RepairPrice = 250   -- tam təmir
Config.WashPrice = 50      -- yuma
