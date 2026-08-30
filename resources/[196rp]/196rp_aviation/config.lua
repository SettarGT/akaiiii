Config = {}

-- Hava limanı hangar
Config.Hangar = {
    label = '196 Hava Limanı — Hangar',
    coords = vector3(-1586.7, -2926.28, 14.13),
    heading = 0.0,
    runway = vector3(-1622.28, -3101.86, 13.94),  -- uçuş zolağı start
    runwayHeading = 43.0,
}

-- İcarə təyyarələri
Config.Planes = {
    { model = 'mammatus', label = 'Mammatus',    price = 500,  time = 900 },  -- 15 dəq
    { model = 'duster',   label = 'Duster',      price = 750,  time = 900 },
    { model = 'velum',    label = 'Velum',       price = 1200, time = 900 },
}

-- Tələb: sürücülük lisenziyası (metadata)
Config.RequireLicense = true
