Config = {}

-- HUD və status parametrləri
Config.SaveInterval = 60000        -- verilənlər bazasına yazma tezliyi (ms)
Config.SyncInterval = 10000        -- serverə sinxronizasiya tezliyi (ms)

Config.Status = {
    foodDecay = 0.8,               -- hər 10 saniyədə toxluq itkisi
    waterDecay = 1.4,              -- hər 10 saniyədə su itkisi
    sprintEnergy = 0.4,            -- qaçış zamanı hər saniyə enerji itkisi
    restEnergy = 0.15,             -- istirahət zamanı hər 5 saniyədə enerji artımı
    lowWater = 25,                 -- bu dəyərdən aşağıda sağlamlıq azalır
    lowFood = 25,                  -- bu dəyərdən aşağıda sağlamlıq azalır
    lowEnergy = 20,                -- bu dəyərdən aşağıda yorğunluq xəbərdarlığı
}

-- Yeməklər (əşya adı → toxluq dəyəri)
Config.Food = {
    ['corek'] = 20,
    ['sendvic'] = 25,
    ['burger'] = 30,
    ['hotdog'] = 25,
    ['pizza'] = 35,
    ['dondurma'] = 10,
    ['meyve'] = 15,
    ['baliq'] = 25,
    ['mal_eti'] = 20,
    ['bugda'] = 5,
}

-- İçkilər (əşya adı → su dəyəri)
Config.Drinks = {
    ['su'] = 35,
    ['kola'] = 25,
    ['qehve'] = 20,
    ['pive'] = 15,
    ['serab'] = 10,
    ['araq'] = 10,
}
