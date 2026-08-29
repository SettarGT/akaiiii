-- 196 RP | Şəhər işləri konfiqurasiyası
-- Bəndlər: 16 (pizza çatdırma), 17 (kuryer), 20 (yanacaqçı), 22 (jurnalist),
-- 23 (rəqqasə), 24 (yük logistikası), 25 (bağban), 26 (arıçılıq), 27 (heyvandarlıq),
-- 29 (elektrikçi), 30 (santexnik), 31 (əczaçı), 32 (həkim qəbulu), 33 (stomatoloq),
-- 34 (veterinar), 35 (gözəllik salonu), 36 (masaj), 37 (detallinq), 38 (əmlak agenti),
-- 39 (bilet satıcısı)

Config = {}

Config.MarkerRadius = 2.5
Config.Blip = { sprite = 478, colour = 2, scale = 0.8 }
Config.RouteBlip = { sprite = 408, colour = 5, scale = 0.9 }

-- ====================================================================
-- A) MARŞRUT İŞLƏRİ — sifariş götür, ünvana çatdır, ödəniş al
-- ====================================================================

Config.RouteJobs = {
    {
        job = 'pizzaboy',
        label = 'Pizza çatdırma',
        icon = '🍕',
        depot = vector3(-1195.0, -897.0, 13.9),
        spawn = vector3(-1193.0, -895.0, 13.9),
        heading = 120.0,
        vehicle = 'faggio',
        platePrefix = 'PZ',
        item = 'pizza',
        basePay = 50,
        payPerKm = 45,
        tipChance = 40,
        tipAmount = 20,
        timeout = 360,
        cooldown = 10,
        destinations = {
            { label = 'Vespucci Çimərliyi',  coords = vector3(-1240.0, -1490.0, 4.4) },
            { label = 'Del Perro Pier',      coords = vector3(-1850.0, -1230.0, 8.6) },
            { label = 'Rockford Plaza',      coords = vector3(-880.0, -190.0, 40.0) },
            { label = 'Mirror Park',         coords = vector3(1150.0, -700.0, 57.0) },
            { label = 'Little Seoul',        coords = vector3(-680.0, -880.0, 23.0) },
            { label = 'Vinewood Bulvarı',    coords = vector3(150.0, -180.0, 55.0) },
        },
    },
    {
        job = 'courier',
        label = 'Kuryer',
        icon = '📦',
        depot = vector3(-430.0, -2770.0, 5.0),
        spawn = vector3(-428.0, -2768.0, 5.0),
        heading = 200.0,
        vehicle = 'bison',
        platePrefix = 'KR',
        item = 'paket',
        basePay = 60,
        payPerKm = 55,
        tipChance = 25,
        tipAmount = 30,
        timeout = 600,
        cooldown = 12,
        destinations = {
            { label = 'Legion Meydanı',   coords = vector3(-150.0, -1620.0, 30.7) },
            { label = 'La Mesa',          coords = vector3(1140.0, -980.0, 46.0) },
            { label = 'Strawberry',       coords = vector3(240.0, -1720.0, 29.0) },
            { label = 'Davis',            coords = vector3(100.0, -1500.0, 29.0) },
            { label = 'Chumash',          coords = vector3(-3150.0, 1050.0, 20.0) },
            { label = 'Sandy Shores',     coords = vector3(1900.0, 3720.0, 32.0) },
            { label = 'Paleto Bay',       coords = vector3(-280.0, 6220.0, 31.0) },
        },
    },
    {
        job = 'trucker',
        label = 'Yük daşıma (logistika)',
        icon = '🚚',
        depot = vector3(145.0, 6360.0, 31.3),
        spawn = vector3(147.0, 6362.0, 31.3),
        heading = 90.0,
        vehicle = 'mule',
        platePrefix = 'YK',
        item = 'yuk',
        basePay = 150,
        payPerKm = 90,
        tipChance = 15,
        tipAmount = 50,
        timeout = 1200,
        cooldown = 30,
        destinations = {
            { label = 'Los Santos Limanı',   coords = vector3(-450.0, -2960.0, 6.0) },
            { label = 'Davis Anbarı',        coords = vector3(350.0, -1620.0, 29.0) },
            { label = 'Rockford Anbarı',     coords = vector3(-760.0, -230.0, 37.0) },
            { label = 'Sandy Anbarı',        coords = vector3(1740.0, 3760.0, 34.0) },
            { label = 'Chumash Anbarı',      coords = vector3(-3050.0, 900.0, 15.0) },
            { label = 'Hava Limanı Anbarı',  coords = vector3(-1050.0, -2900.0, 13.9) },
        },
    },
}

-- ====================================================================
-- B) SAHƏ İŞLƏRİ — təsadüfi yerə get, işi gör, ödəniş al
-- ====================================================================

Config.FieldJobs = {
    {
        job = 'reporter',
        label = 'Jurnalist',
        icon = '📰',
        depot = vector3(-1080.0, -250.0, 37.7),
        task = 'Hadisə yerində reportaj hazırlayın',
        scenario = 'WORLD_HUMAN_PAPARAZZI',
        time = 10000,
        pay = 120,
        giveItem = 'qezete',
        giveCount = 1,
        cooldown = 25,
        locations = {
            { label = 'Bank soyğunu xəbəri',   coords = vector3(150.0, -1040.0, 29.3) },
            { label = 'Yol qəzası',            coords = vector3(-850.0, -1200.0, 6.5) },
            { label = 'Yanğın hadisəsi',        coords = vector3(-470.0, -710.0, 30.0) },
            { label = 'Şəhər məclisi',         coords = vector3(-544.0, -204.0, 38.2) },
            { label = 'Çimərlik tədbiri',      coords = vector3(-1300.0, -1400.0, 4.5) },
            { label = 'Bazar xəbərləri',       coords = vector3(-90.0, -1600.0, 30.6) },
        },
    },
    {
        job = 'electrician',
        label = 'Elektrikçi',
        icon = '🔌',
        depot = vector3(700.0, -960.0, 24.0),
        task = 'Elektrik xəttini təmir edin',
        scenario = 'WORLD_HUMAN_WELDING',
        time = 12000,
        pay = 150,
        cooldown = 30,
        locations = {
            { label = 'Küçə işıqları (Mərkəz)',   coords = vector3(-200.0, -900.0, 29.3) },
            { label = 'Transformator qutusu',     coords = vector3(800.0, -1000.0, 26.0) },
            { label = 'Yarımstansiya',            coords = vector3(2700.0, 1500.0, 24.0) },
            { label = 'Kabel xətti',              coords = vector3(-1100.0, -150.0, 40.0) },
            { label = 'Ev şəbəkəsi',              coords = vector3(1300.0, -600.0, 68.0) },
            { label = 'Sandy elektrik xətti',     coords = vector3(1800.0, 3700.0, 34.0) },
        },
    },
    {
        job = 'plumber',
        label = 'Santexnik',
        icon = '🔧',
        depot = vector3(-580.0, -900.0, 23.0),
        task = 'Su borusunu təmir edin',
        scenario = 'WORLD_HUMAN_WELDING',
        time = 11000,
        pay = 130,
        cooldown = 28,
        locations = {
            { label = 'Mənzil blokundakı sızma',  coords = vector3(-700.0, -800.0, 23.0) },
            { label = 'Kanalizasiya qapağı',      coords = vector3(-300.0, -1300.0, 29.0) },
            { label = 'Restoran mətbəxi',         coords = vector3(-1100.0, -1450.0, 5.0) },
            { label = 'Su nasosu stansiyası',     coords = vector3(-1400.0, -1700.0, 5.0) },
            { label = 'Otel su xətti',            coords = vector3(-1100.0, 200.0, 60.0) },
            { label = 'Paleto su xətti',          coords = vector3(-300.0, 6300.0, 31.0) },
        },
    },
    {
        job = 'gardener',
        label = 'Bağban',
        icon = '🌱',
        depot = vector3(-1300.0, -1150.0, 6.0),
        task = 'Bitkiləri əkin və suvarın',
        scenario = 'WORLD_HUMAN_GARDENER_PLANT',
        time = 9000,
        pay = 80,
        giveItem = 'gul',
        giveCount = 2,
        cooldown = 20,
        locations = {
            { label = 'Şəhər parkı',         coords = vector3(-1250.0, -1000.0, 7.0) },
            { label = 'Legion bağı',         coords = vector3(-160.0, -1650.0, 30.7) },
            { label = 'Vinewood bağı',       coords = vector3(200.0, -300.0, 48.0) },
            { label = 'Mirror Park bağı',    coords = vector3(1200.0, -600.0, 60.0) },
            { label = 'Sahil xiyabanı',      coords = vector3(-1500.0, -1300.0, 6.0) },
        },
    },
}

-- ====================================================================
-- C) SABİT NÖQTƏ İŞLƏRİ — nöqtədə dayan, xidmət göstər, ödəniş al
-- ====================================================================

Config.StationJobs = {
    {
        job = 'fueler', label = 'Yanacaqçı', icon = '⛽',
        coords = vector3(1700.0, 3770.0, 34.5),
        task = 'Müştərinin maşınını doldurun',
        scenario = 'WORLD_HUMAN_WELDING',
        time = 8000, pay = 70, cooldown = 10,
    },
    {
        job = 'dancer', label = 'Rəqqasə / Rəqqas', icon = '💃',
        coords = vector3(-1390.0, -590.0, 30.3),
        task = 'Səhnədə rəqs edin',
        scenario = 'WORLD_HUMAN_PARTYING',
        time = 15000, pay = 90, cooldown = 15, tipChance = 50, tipAmount = 40,
    },
    {
        job = 'beekeeper', label = 'Arıçı', icon = '🐝',
        coords = vector3(2350.0, 4870.0, 41.9),
        task = 'Pətəkdən bal toplayın',
        scenario = 'WORLD_HUMAN_GARDENER_PLANT',
        time = 10000, pay = 40, cooldown = 18, giveItem = 'bal', giveCount = 3,
    },
    {
        job = 'farmer', label = 'Heyvandar', icon = '🐄',
        coords = vector3(2400.0, 4950.0, 47.6),
        task = 'Heyvanlara qulluq edin',
        scenario = 'WORLD_HUMAN_GARDENER_PLANT',
        time = 10000, pay = 45, cooldown = 18, giveItem = 'sud', giveCount = 2, giveItem2 = 'yumurta', giveCount2 = 2,
    },
    {
        job = 'pharmacist', label = 'Əczaçı', icon = '💊',
        coords = vector3(-1830.0, -1140.0, 13.0),
        task = 'Müştəri üçün dərman hazırlayın',
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        time = 9000, pay = 80, cooldown = 12, giveItem = 'derman', giveCount = 1,
    },
    {
        job = 'doctor', label = 'Növbətçi həkim', icon = '🩺',
        coords = vector3(307.0, -595.0, 43.3),
        task = 'Xəstə qəbulu keçirin',
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        time = 12000, pay = 140, cooldown = 25,
    },
    {
        job = 'dentist', label = 'Stomatoloq', icon = '🦷',
        coords = vector3(-880.0, -30.0, 39.0),
        task = 'Xəstənin dişlərini müalicə edin',
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        time = 12000, pay = 160, cooldown = 25,
    },
    {
        job = 'vet', label = 'Veterinar', icon = '🐾',
        coords = vector3(-1490.0, -380.0, 40.0),
        task = 'Heyvanı müayinə edin',
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        time = 11000, pay = 120, cooldown = 22,
    },
    {
        job = 'beautician', label = 'Gözəllik salonu', icon = '💅',
        coords = vector3(-1140.0, -1540.0, 5.0),
        task = 'Müştəriyə manikür / makiyaj edin',
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        time = 10000, pay = 100, cooldown = 18,
    },
    {
        job = 'masseur', label = 'Masaj ustası', icon = '💆',
        coords = vector3(-1120.0, -1520.0, 5.0),
        task = 'Müştəriyə masaj edin',
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        time = 14000, pay = 130, cooldown = 20,
    },
    {
        job = 'detailer', label = 'Maşın detallinqi', icon = '✨',
        coords = vector3(-220.0, -1330.0, 30.0),
        task = 'Maşını cilalayın və parladın',
        scenario = 'WORLD_HUMAN_WELDING',
        time = 13000, pay = 110, cooldown = 18,
    },
    {
        job = 'realestate', label = 'Əmlak agenti', icon = '🏠',
        coords = vector3(-1350.0, -700.0, 25.0),
        task = 'Ev nümayişi keçirin',
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        time = 16000, pay = 220, cooldown = 40,
    },
    {
        job = 'ticketeer', label = 'Bilet satıcısı', icon = '🎟️',
        coords = vector3(-1420.0, -260.0, 46.0),
        task = 'Bilet satın',
        scenario = 'WORLD_HUMAN_STAND_IMPATIENT',
        time = 6000, pay = 45, cooldown = 8,
    },
}
