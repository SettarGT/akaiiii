Config = {}

-- Bərbər salonları
Config.Barbers = {
    { id = 'barber_1', name = 'Bərbər salonu — Mərkəz', coords = vector3(-814.3, -183.8, 37.6) },
    { id = 'barber_2', name = 'Bərbər salonu — Vinewood', coords = vector3(135.5, -1708.3, 29.3) },
    { id = 'barber_3', name = 'Bərbər salonu — Sandy Shores', coords = vector3(1932.9, 3729.6, 32.8) },
}

-- Döymə salonları
Config.Tattoos = {
    { id = 'tattoo_1', name = 'Döymə salonu — Mərkəz', coords = vector3(-1153.0, -1425.0, 4.9) },
    { id = 'tattoo_2', name = 'Döymə salonu — Del Perro', coords = vector3(-1550.0, -950.0, 9.0) },
}

-- Bərbər menyusunda icazəli hissələr (saç, saqqal, makiyaj və s.)
Config.BarberRestrict = {
    'hair_1', 'hair_2', 'hair_color_1', 'hair_color_2',
    'beard_type', 'beard_size', 'beard_color_1', 'beard_color_2',
    'eyebrow_type', 'eyebrow_size', 'eyebrow_color_1', 'eyebrow_color_2',
    'makeup_type', 'makeup_thickness', 'makeup_color_1', 'makeup_color_2',
    'lipstick_type', 'lipstick_thickness', 'lipstick_color_1', 'lipstick_color_2',
    'eye_color', 'cheeks_1', 'cheeks_2',
}

-- Döymə kolleksiyaları (GTA V standart döymələri)
Config.TattooCategories = {
    {
        name = 'qol',
        label = '💪 Qol döymələri',
        items = {
            { label = 'Qol — 1', collection = 'mp_tattoos', overlay = 'FM_Tat_Arm_1_1' },
            { label = 'Qol — 2', collection = 'mp_tattoos', overlay = 'FM_Tat_Arm_2_1' },
            { label = 'Qol — 3', collection = 'mp_tattoos', overlay = 'FM_Tat_Arm_3_1' },
            { label = 'Qol — 4', collection = 'mp_tattoos', overlay = 'FM_Tat_Arm_4_1' },
            { label = 'Qol — 5', collection = 'mp_tattoos', overlay = 'FM_Tat_Arm_5_1' },
            { label = 'Qol — 6', collection = 'mp_tattoos', overlay = 'FM_Tat_Arm_6_1' },
            { label = 'Çiyin — 1', collection = 'mp_tattoos', overlay = 'FM_Tat_Shoulder_1_1' },
            { label = 'Çiyin — 2', collection = 'mp_tattoos', overlay = 'FM_Tat_Shoulder_2_1' },
        }
    },
    {
        name = 'kurek',
        label = '🖐 Kürək döymələri',
        items = {
            { label = 'Kürək — 1', collection = 'mp_tattoos', overlay = 'FM_Tat_Back_1_1' },
            { label = 'Kürək — 2', collection = 'mp_tattoos', overlay = 'FM_Tat_Back_2_1' },
            { label = 'Kürək — 3', collection = 'mp_tattoos', overlay = 'FM_Tat_Back_3_1' },
        }
    },
    {
        name = 'sine',
        label = '❤️ Sinə və qarın',
        items = {
            { label = 'Sinə — 1', collection = 'mp_tattoos', overlay = 'FM_Tat_Chest_1_1' },
            { label = 'Sinə — 2', collection = 'mp_tattoos', overlay = 'FM_Tat_Chest_2_1' },
            { label = 'Qarın — 1', collection = 'mp_tattoos', overlay = 'FM_Tat_Stomach_1_1' },
            { label = 'Qarın — 2', collection = 'mp_tattoos', overlay = 'FM_Tat_Stomach_2_1' },
        }
    },
    {
        name = 'ayaq',
        label = '🦵 Ayaq döymələri',
        items = {
            { label = 'Ayaq — 1', collection = 'mp_tattoos', overlay = 'FM_Tat_Legs_1_1' },
            { label = 'Ayaq — 2', collection = 'mp_tattoos', overlay = 'FM_Tat_Legs_2_1' },
        }
    },
}

-- Döymə qiyməti
Config.TattooPrice = 300
