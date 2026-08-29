-- 196 RP | Nəqliyyat konfiqurasiyası
-- Bəndlər: 45 (maşın açarları), 46 (dönmə işıqları), 47 (avtomobil icarəsi),
-- 48 (velosiped icarəsi), 49 (elektrik skuterlər), 50 (motodeliver), 52 (qayıq icarəsi)

Config = {}

-- ==================== 45. MAŞIN AÇARLARI ====================

Config.Keys = {
    listCommand = 'acarlar',        -- /acarlar → açar siyahısı
    lockCommand = 'kilidle',        -- /kilidle → ən yaxın maşını kilidlə/aç
    giveCommand = 'acarver',        -- /acarver [server ID]
    maxDistance = 6.0,              -- kilidləmək üçün maşına məsafə
    engineRequireKey = true,        -- açarsız mühərrik işə düşmür
    alarmSound = true,              -- kilidli maşına minəndə həyəcan siqnalı
    platePrefix = '196',            -- açar verilə bilən nömrə ön eki
}

-- ==================== 46. DÖNMƏ İŞIQLARI ====================

Config.TurnSignals = {
    leftControl = 234,   -- ← sol ox düyməsi (INPUT_VEH_PREV_RADIO_TRACK)
    rightControl = 235,  -- → sağ ox düyməsi (INPUT_VEH_NEXT_RADIO_TRACK)
    hazardControl = 85,  -- X düyməsi (INPUT_VEH_DUCK) → havari
    sound = true,        -- klik səsi
    tickInterval = 500,  -- səs təkrar intervalı (ms)
}

-- ==================== 47/48/49/52. İCARƏ NÖQTƏLƏRİ ====================

-- kind: 'car' | 'bike' | 'scooter' | 'boat'
Config.Rentals = {
    {
        kind = 'car',
        label = '196 Avtomobil İcarəsi',
        icon = 'fas fa-car',
        coords = vector3(-950.0, -2970.0, 13.9),      -- hava limanı icarə məntəqəsi
        spawn = vector3(-945.0, -2965.0, 13.9),
        heading = 145.0,
        returnCoords = vector3(-950.0, -2970.0, 13.9),
        returnRadius = 25.0,
        pricePerDay = 250,     -- 1 "gün" = Config.RentalDayMinutes real dəqiqə
        vehicles = {
            { model = 'panto',    label = 'Panto (kompakt)' },
            { model = 'blista',   label = 'Blista (kompakt)' },
            { model = 'asea',     label = 'Asea (sedan)' },
            { model = 'premier',  label = 'Premier (sedan)' },
            { model = 'emperor',  label = 'Emperor (sedan)' },
            { model = 'sultan',   label = 'Sultan (idman)' },
        },
    },
    {
        kind = 'bike',
        label = '196 Velosiped Stansiyası',
        icon = 'fas fa-bicycle',
        coords = vector3(-1230.0, -1450.0, 4.3),      -- Vespucci çimərliyi
        spawn = vector3(-1228.0, -1448.0, 4.3),
        heading = 220.0,
        returnCoords = vector3(-1230.0, -1450.0, 4.3),
        returnRadius = 20.0,
        pricePerDay = 60,
        vehicles = {
            { model = 'bmx',     label = 'BMX' },
            { model = 'cruiser', label = 'Cruiser' },
            { model = 'fixter',  label = 'Fixter' },
            { model = 'scorcher', label = 'Scorcher (dağ)' },
        },
    },
    {
        kind = 'bike',
        label = '196 Velosiped Stansiyası (Mərkəz)',
        icon = 'fas fa-bicycle',
        coords = vector3(-148.0, -1610.0, 30.7),      -- Legion Meydanı
        spawn = vector3(-146.0, -1608.0, 30.7),
        heading = 20.0,
        returnCoords = vector3(-148.0, -1610.0, 30.7),
        returnRadius = 20.0,
        pricePerDay = 60,
        vehicles = {
            { model = 'bmx',      label = 'BMX' },
            { model = 'cruiser',  label = 'Cruiser' },
            { model = 'fixter',   label = 'Fixter' },
        },
    },
    {
        kind = 'scooter',
        label = '196 Elektrik Skuter Stansiyası',
        icon = 'fas fa-motorcycle',
        coords = vector3(274.0, -900.0, 29.2),
        spawn = vector3(276.0, -898.0, 29.2),
        heading = 90.0,
        returnCoords = vector3(274.0, -900.0, 29.2),
        returnRadius = 20.0,
        pricePerDay = 100,
        vehicles = {
            { model = 'faggio', label = 'Elektrik skuter' },
        },
    },
    {
        kind = 'boat',
        label = '196 Qayıq İcarəsi',
        icon = 'fas fa-ship',
        coords = vector3(-800.0, -1510.0, 1.6),
        spawn = vector3(-795.0, -1505.0, 0.5),
        heading = 190.0,
        returnCoords = vector3(-800.0, -1510.0, 1.6),
        returnRadius = 40.0,
        pricePerDay = 400,
        vehicles = {
            { model = 'seashark', label = 'Su motosikleti' },
            { model = 'tropic',   label = 'Tropic (sürət qayığı)' },
            { model = 'suntrap',  label = 'Suntrap (gəzinti)' },
        },
    },
}

Config.RentalDayMinutes = 30       -- 1 icarə günü = 30 real dəqiqə
Config.RentalDepositMult = 2.0     -- depozit = 1 günlük qiymət × 2
Config.MaxActiveRentals = 1        -- eyni vaxtda ən çox 1 icarə

-- ==================== 50. MOTODELİVER ====================

Config.Delivery = {
    job = 'motodeliver',
    jobLabel = 'Motodeliver',
    depot = vector3(-1200.0, -890.0, 12.0),        -- sifariş mərkəzi
    spawn = vector3(-1198.0, -888.0, 12.0),
    heading = 30.0,
    bike = 'faggio',
    maxDistance = 6000.0,                          -- ən uzaq çatdırılma məsafəsi
    payPerKm = 40,                               -- hər km üçün ödəniş ($)
    basePay = 40,                                  -- əsas ödəniş
    tipChance = 35,                                -- məsləhət (tip) şansı %
    tipAmount = 25,
    orderTimeout = 300,                            -- saniyə
    cooldown = 15,                                 -- yeni sifariş arası saniyə
    destinations = {
        { label = 'Vespucci Çimərliyi',    coords = vector3(-1240.0, -1490.0, 4.4) },
        { label = 'Vinewood Bulvarı',      coords = vector3(150.0, -180.0, 55.0) },
        { label = 'Del Perro Pier',        coords = vector3(-1850.0, -1230.0, 8.6) },
        { label = 'Legion Meydanı',        coords = vector3(-150.0, -1620.0, 30.7) },
        { label = 'Rockford Plaza',        coords = vector3(-880.0, -190.0, 40.0) },
        { label = 'La Mesa',               coords = vector3(1140.0, -980.0, 46.0) },
        { label = 'Strawberry',            coords = vector3(240.0, -1720.0, 29.0) },
        { label = 'Little Seoul',          coords = vector3(-680.0, -880.0, 23.0) },
        { label = 'Mirror Park',           coords = vector3(1150.0, -700.0, 57.0) },
        { label = 'Sandy Shores',          coords = vector3(1900.0, 3720.0, 32.0) },
        { label = 'Paleto Bay',            coords = vector3(-280.0, 6220.0, 31.0) },
        { label = 'Chumash',               coords = vector3(-3150.0, 1050.0, 20.0) },
    },
}

-- ==================== ÜMUMİ ====================

Config.Blips = {
    rental = { sprite = 227, colour = 3, scale = 0.8 },
    delivery = { sprite = 478, colour = 2, scale = 0.8 },
}
