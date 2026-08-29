Config = {}

-- Tuninq emalatxanaları (xəritədə açar simvolu ilə işarələnir)
Config.Shops = {
    { name = 'Mərkəz Tuninq', coords = vector3(-356.0, -133.0, 39.0) },
    { name = 'Liman Tuninq',  coords = vector3(-211.6, -1320.8, 31.0) },
}

Config.BlipSprite = 446
Config.BlipColor = 5
Config.InteractDist = 3.5

-- Qiymətlər ($)
Config.Categories = {
    {
        label = 'Mühərrik', slot = 11, maxLevel = 3,
        prices = { 500, 1200, 2500 },
        levels = { 'Səviyyə 1', 'Səviyyə 2', 'Səviyyə 3 (max)' },
    },
    {
        label = 'Əyləclər', slot = 12, maxLevel = 3,
        prices = { 400, 900, 1800 },
        levels = { 'İdman əyləcləri', 'Yarış əyləcləri', 'Karbon əyləclər' },
    },
    {
        label = 'Ötürücü qutusu', slot = 13, maxLevel = 2,
        prices = { 600, 1400 },
        levels = { 'İdman ötürücü', 'Yarış ötürücüsü' },
    },
    {
        label = 'Asqı', slot = 15, maxLevel = 3,
        prices = { 500, 1000, 2000 },
        levels = { 'Aşağı asqı', 'İdman asqısı', 'Yarış asqısı' },
    },
    {
        label = 'Zireh', slot = 16, maxLevel = 4,
        prices = { 700, 1400, 2200, 3500 },
        levels = { 'Zireh 20%', 'Zireh 40%', 'Zireh 60%', 'Tam zireh' },
    },
}

Config.TurboPrice = 3000
Config.XenonPrice = 800

Config.Colors = {
    { label = 'Qara',   c1 = 0,   c2 = 0 },
    { label = 'Ağ',     c1 = 111, c2 = 111 },
    { label = 'Qırmızı', c1 = 27, c2 = 27 },
    { label = 'Mavi',   c1 = 64, c2 = 64 },
    { label = 'Yaşıl',  c1 = 53, c2 = 53 },
    { label = 'Sarı',   c1 = 89, c2 = 89 },
    { label = 'Narıncı', c1 = 38, c2 = 38 },
    { label = 'Boz metal', c1 = 4, c2 = 4 },
}
