Config = {}

-- Marina kiosk (Del Perro / sahil)
Config.Kiosk = {
    label = '196 Marina | Kiosk',
    coords = vector3(-1030.5, -1400.5, 5.0),
    heading = 270.0,
    prop = 'prop_atm_02',
}

-- Yaxta modelləri
Config.Yachts = {
    { model = 'suntrap',    label = 'Suntrap',    rentPrice = 800,   rentTime = 1800,  buyPrice = 120000 },
    { model = 'dinghy',     label = 'Dinghy',     rentPrice = 1200,  rentTime = 1800,  buyPrice = 160000 },
    { model = 'seashark',   label = 'Sea Shark',  rentPrice = 1500,  rentTime = 1800,  buyPrice = 190000 },
    { model = 'marquis',    label = 'Marquis',    rentPrice = 2500,  rentTime = 3600,  buyPrice = 350000 },
}

-- Suya çıxış nöqtələri
Config.SpawnPoints = {
    vector3(-985.0, -1520.0, 0.5),
    vector3(-1150.0, -1620.0, 0.5),
}

Config.SpawnHeading = 270.0

-- Kiosk fiziki radius
Config.Radius = 5.0
