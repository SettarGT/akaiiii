Config = {}

-- Restock kiosk yerləri (qb-shops Config.Locations key-ləri ilə uyğun)
Config.Kiosks = {
    { id = '247supermarket',  label = '24/7 Supermarket (Santos)', coords = vector3(25.19, -1341.79, 29.5) },
    { id = '247supermarket2', label = '24/7 Supermarket (Paleto)', coords = vector3(-3034.51, 585.28, 7.9) },
    { id = 'ltdgasoline',     label = 'LTD Yanacaq (Grove)',       coords = vector3(-47.2, -1753.6, 29.42) },
    { id = 'ltdgasoline2',    label = 'LTD Yanacaq (Airport)',     coords = vector3(-706.55, -909.15, 19.22) },
}

-- Restock qiyməti
Config.Fee = 500  -- ₣
Config.Cooldown = 300 -- saniyə
Config.PerItemAdd = 10 -- hər məhsula əlavə ediləcək minimum (qb-shops 10-50 verir)
