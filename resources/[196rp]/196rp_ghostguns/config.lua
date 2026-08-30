Config = {}

-- Gizli emalatxana (Paleto)
Config.Workshop = {
    label = 'Gizli Emalatxana',
    coords = vector3(-1090.2, 4898.5, 97.9),
    radius = 2.5,
}

-- Hissələr (hər biri scrap_metal ilə)
Config.Parts = {
    { item = 'ghost_frame',  label = 'Ghost Çərçivə',  scrap = 8,  time = 10 },
    { item = 'ghost_slide',  label = 'Ghost Sürüşmə',  scrap = 6,  time = 8 },
    { item = 'ghost_trigger', label = 'Ghost Tetik',   scrap = 3,  time = 6 },
}

-- Yığma
Config.Assemble = {
    weapon = 'weapon_pistol',
    label = 'Ghost Silah (pistol)',
    time = 15,
    policeNotifyChance = 0.15,  -- %15: polis xəbərdarlığı (196rp_logs)
}

-- Stress artımı (196rp_stress varsa)
Config.Stress = 15
