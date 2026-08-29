-- 196 RP | Bələdiyyə işləri
-- Günün müxtəlif vaxtlarında şəhərin müxtəlif yerlərində təmir/təmizlik işləri açılır.

Config = {}

-- Yeni iş hadisəsi neçə dəqiqədən bir açılır
Config.EventInterval = 900000   -- 15 dəqiqə

-- Hadisə neçə dəqiqə aktiv qalır
Config.EventLifetime = 600000   -- 10 dəqiqə

-- İş yalnız bu işdə olanlara açıqdır (nil = hamı üçün açıqdır)
Config.RequireJob = nil

-- =====================================================================
-- İŞ NÖVLƏRİ — günün hansı vaxtında hansı iş görülür
-- hour = oyun saatı aralığı
-- =====================================================================

Config.WorkTypes = {
    {
        id = 'road',
        label = 'Yol Təmiri',
        icon = '🚧',
        hours = { 6, 11 },          -- səhər saatları
        time = 8000,
        pay = 220,
        anim = { dict = 'amb@world_human_hammering@male@base', lib = 'base' },
        prop = { model = 'prop_tool_hammer', bone = 57005 },
        messages = { 'Yoldakı çuxur bağlandı!', 'Asfalt bərpa olundu!' }
    },
    {
        id = 'clean',
        label = 'Küçə Təmizliyi',
        icon = '🧹',
        hours = { 12, 16 },         -- gündüz
        time = 6000,
        pay = 140,
        anim = { dict = 'amb@world_human_bum_bin@base', lib = 'base' },
        prop = { model = 'prop_tool_broom', bone = 28422 },
        messages = { 'Küçə təmizləndi!', 'Zibil yığıldı!' }
    },
    {
        id = 'light',
        label = 'İşıq Dirəyinin Dəyişdirilməsi',
        icon = '💡',
        hours = { 17, 23 },         -- axşam/gecə
        time = 10000,
        pay = 300,
        anim = { dict = 'amb@world_human_welding@base', lib = 'base' },
        prop = { model = 'prop_tool_wrench', bone = 28422 },
        messages = { 'İşıq dirəyi bərpa olundu!', 'Lampa dəyişdirildi!' }
    },
    {
        id = 'graffiti',
        label = 'Divar Təmizliyi',
        icon = '🎨',
        hours = { 0, 5 },           -- gecə
        time = 7000,
        pay = 180,
        anim = { dict = 'amb@world_human_bum_wash@base', lib = 'base' },
        prop = nil,
        messages = { 'Divar təmizləndi!' }
    },
}

-- =====================================================================
-- İŞ YERLƏRİ (təsadüfi seçilir)
-- =====================================================================

Config.Locations = {
    { label = 'Legion Meydanı',        coords = vector3(215.0, -810.0, 30.5) },
    { label = 'Maze Bank küçəsi',      coords = vector3(-75.0, -822.0, 30.0) },
    { label = 'Del Perro bulvarı',     coords = vector3(-1180.0, -900.0, 13.0) },
    { label = 'Vinewood bulvarı',      coords = vector3(310.0, 190.0, 104.0) },
    { label = 'Davis küçələri',        coords = vector3(365.0, -1580.0, 29.3) },
    { label = 'La Mesa sənaye',        coords = vector3(1000.0, -2300.0, 30.0) },
    { label = 'Elysian limanı',        coords = vector3(1050.0, -3100.0, 5.9) },
    { label = 'Sandy Shores mərkəzi',  coords = vector3(1600.0, 3700.0, 34.0) },
    { label = 'Paleto Bay küçəsi',     coords = vector3(-250.0, 6300.0, 32.0) },
    { label = 'Grapeseed yolu',        coords = vector3(2450.0, 4960.0, 46.0) },
    { label = 'Strawberry küçəsi',     coords = vector3(-1150.0, -1520.0, 4.5) },
    { label = 'Harmony',               coords = vector3(400.0, 3590.0, 35.0) },
}
