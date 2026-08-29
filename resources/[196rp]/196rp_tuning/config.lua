Config = {}

-- Emalatxanalar (GPS blipi də yaradılır)
Config.Shops = {
    { name = 'Mərkəz Tuninq', coords = vector3(-356.0, -133.0, 39.0), heading = 90.0 },
    { name = 'Liman Tuninq', coords = vector3(1174.9, -1804.6, 26.0), heading = 0.0 },
}

-- Kategoriyalar (slot, səviyyələr, qiymətlər)
Config.Categories = {
    { label = 'Mühərrik', slot = 11, levels = {
        { price = 500 }, { price = 1200 }, { price = 2500 },
    } },
    { label = 'Əyləclər', slot = 12, levels = {
        { price = 400 }, { price = 900 }, { price = 1800 },
    } },
    { label = 'Ötürücü', slot = 13, levels = {
        { price = 600 }, { price = 1400 },
    } },
    { label = 'Asqı', slot = 15, levels = {
        { price = 500 }, { price = 1000 }, { price = 2000 },
    } },
    { label = 'Zireh', slot = 16, levels = {
        { price = 800 }, { price = 1600 }, { price = 3000 }, { price = 4500 },
    } },
}

Config.TurboPrice = 3000
Config.XenonPrice = 800

Config.Colors = {
    { label = 'Qara', color1 = 0, color2 = 0 },
    { label = 'Ağ', color1 = 112, color2 = 112 },
    { label = 'Qırmızı', color1 = 27, color2 = 27 },
    { label = 'Mavi', color1 = 64, color2 = 64 },
    { label = 'Yaşıl', color1 = 51, color2 = 51 },
    { label = 'Sarı', color1 = 88, color2 = 88 },
    { label = 'Narıncı', color1 = 36, color2 = 36 },
    { label = 'Çəhrayı', color1 = 135, color2 = 135 },
    { label = 'Qızılı', color1 = 143, color2 = 143 },
    { label = 'Gümüşü', color1 = 110, color2 = 110 },
}

Config.Text = {
    header = '196 Tuninq',
    close = '⬅ Geri',
    stock = 'Fabrik vəziyyəti (pulsuz)',
    stock_done = 'Avtomobil fabrik vəziyyətinə qaytarıldı',
    turbo = 'Turbo',
    xenon = 'Ksenon faralar',
    color_menu = 'Rəng',
    not_enough = 'Kifayət qədər pulunuz yoxdur!',
    paid = 'Ödəniş edildi: $%{price}',
    need_driver = 'Tuninq üçün sürücü oturacağında olmalısınız',
}
