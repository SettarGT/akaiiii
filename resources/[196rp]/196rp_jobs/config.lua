Config = {}

-- ══════════════════════════════════════════════════════
--  196 RP | İş Mərkəzi (0 NPC, hibrid self-service)
-- ══════════════════════════════════════════════════════

-- İş Mərkəzi məkanları (NUI panel 196rp_hybrid ilə eyni yerlər)
Config.Locations = {
    { label = 'Mərkəz İş Mərkəzi', coords = vector3(-266.63, -965.76, 31.22), heading = 180.0 },
    { label = 'Sahil İş Mərkəzi', coords = vector3(995.31, -1184.85, 27.09), heading = 180.0 },
    { label = 'Aeroport İş Mərkəzi', coords = vector3(-1049.12, -2747.23, 42.01), heading = 180.0 },
}

-- Açıq işlər (iş mərkəzindən düzəlmək olar)
Config.Jobs = {
    pilot        = { label = 'Aviasiya',        icon = 'fas fa-plane',        desc = 'Hava taksisi / icarə uçuşları' },
    fisher       = { label = 'Balıqçılıq',      icon = 'fas fa-fish',         desc = 'Sahildə balıq tut, bazara sat' },
    miner        = { label = 'Mədənçilik',      icon = 'fas fa-mountain',     desc = 'Qayadan daş, kömür çıxar' },
    lumberjack   = { label = 'Meşəçi',          icon = 'fas fa-tree',         desc = 'Ağac kəs, odun sat' },
    construction = { label = 'İnşaat',           icon = 'fas fa-helmet-safety', desc = 'Material yığ, obyektlər qur' },
    vineyard     = { label = 'Üzümçülük',       icon = 'fas fa-wine-bottle',  desc = 'Üzüm yığ və emal et' },
    mechanic     = { label = 'Mexanik',         icon = 'fas fa-wrench',       desc = 'Avtomobilləri təmir et (/temir)' },
    cardealer    = { label = 'Avtosalon',       icon = 'fas fa-car-side',     desc = 'Avtomobil sat (/avtomobil, /sat)' },
    trucker      = { label = 'Yük daşıma',      icon = 'fas fa-truck',        desc = 'Anbarlara yük çatdır' },
    taxi         = { label = 'Taksi',           icon = 'fas fa-taxi',         desc = 'Sərnişin daşı' },
    bus          = { label = 'Avtobus',         icon = 'fas fa-bus',          desc = 'Marşrut sür' },
    garbage      = { label = 'Zibilçilik',      icon = 'fas fa-trash',        desc = 'Şəhəri təmizlə' },
    fire         = { label = 'Yanğınsöndürmə', icon = 'fas fa-fire-extinguisher', desc = 'Yanğınları söndür (/sondur, /yangin)' },
    tow          = { label = 'Yedək',           icon = 'fas fa-truck-pickup', desc = 'Avtomobil daşı' },
}

-- Hər işin aləti (işə düzələndə verilir, çıxanda alınır)
Config.Tools = {
    fisher       = 'fishing_rod',
    miner        = 'pickaxe',
    lumberjack   = 'axe',
}

-- İş sahələri: hər iş üçün zonalar (item = yığılan məhsul)
Config.Zones = {
    fisher = {
        { label = 'Sahil A', coords = vector3(-1047.38, -1375.02, 4.01), radius = 3.0, item = 'fish' },
        { label = 'Sahil B', coords = vector3(-1153.11, -1316.89, 5.12), radius = 3.0, item = 'fish' },
        { label = 'Sahil C', coords = vector3(1287.32, -1717.66, 14.84), radius = 3.0, item = 'fish' },
    },
    miner = {
        { label = 'Karyer A', coords = vector3(2953.17, 2791.78, 39.85), radius = 3.0, item = 'stone' },
        { label = 'Karyer B', coords = vector3(2958.35, 2775.75, 39.11), radius = 3.0, item = 'stone' },
        { label = 'Karyer C', coords = vector3(2943.18, 2773.63, 39.67), radius = 3.0, item = 'stone' },
    },
    lumberjack = {
        { label = 'Meşə A', coords = vector3(-536.27, 5575.52, 72.68), radius = 3.0, item = 'wood' },
        { label = 'Meşə B', coords = vector3(-564.21, 5518.95, 79.50), radius = 3.0, item = 'wood' },
        { label = 'Meşə C', coords = vector3(-504.18, 5548.30, 76.63), radius = 3.0, item = 'wood' },
    },
    construction = {
        { label = 'Tikinti A', coords = vector3(970.29, -1188.84, 26.70), radius = 3.5, item = 'brick' },
        { label = 'Tikinti B', coords = vector3(1019.16, -1352.98, 26.53), radius = 3.5, item = 'cement' },
        { label = 'Tikinti C', coords = vector3(1045.40, -1414.34, 25.94), radius = 3.5, item = 'brick' },
    },
}

-- Satış nöqtələri (materialdan pul) — iş başına
Config.SellPoints = {
    fisher =       { label = 'Balıq bazarı',      coords = vector3(-1036.88, -1383.29, 4.01) },
    miner =        { label = 'Daş emal mərkəzi',  coords = vector3(1096.69, -1907.91, 30.70) },
    lumberjack =   { label = 'Mişar dəyirmanı',   coords = vector3(-1090.03, 3160.10, 36.27) },
    construction = { label = 'Tikinti anbarı',    coords = vector3(967.70, -1189.40, 27.20) },
}

-- Qiymətlər (₣ Fanteyn)
Config.Prices = {
    fish     = 65,
    stone    = 30,
    coal     = 45,
    wood     = 40,
    brick    = 35,
    cement   = 40,
}

-- İşləmə vaxtı (saniyə)
Config.WorkTime = {
    fisher      = 6,
    miner       = 5,
    lumberjack  = 5,
    construction = 4,
}

-- İnşaat: obyekt başına addım sayı və bonus
Config.Construction = {
    StepsPerSite = 6,
    Bonus        = 900,
    Materials    = { 'brick', 'cement' },
}

-- Mexanik təmiri
Config.Repair = {
    BasePrice = 100,
    PricePerDamage = 16,
    MaxPrice = 5000,
}

-- Avtosalon (cardealer)
Config.Dealer = {
    SpawnAt = vector3(-50.27, -1101.42, 26.42), -- Avtosalon yanı
    SpawnHeading = 24.0,
    Radius = 4.0,
    Models = { 'sultan', 'elegy2', 'blista' },
    PriceMultiplier = 1.4,   -- QBCore price * 1.4 (satış törəməsi)
}

-- Animasiyalar
Config.Animations = {
    fisher       = { dict = 'amb@world_human_stand_fishing@idle_a', name = 'idle_a' },
    miner        = { dict = 'amb@world_human_const_drill@male@drill@base', name = 'base' },
    lumberjack   = { dict = 'amb@world_human_const_bush_trim@male@trim@base', name = 'base' },
    construction = { dict = 'amb@world_human_const_drill@male@drill@base', name = 'base' },
    default      = { dict = 'amb@world_human_const_drill@male@drill@base', name = 'base' },
}

Config.Text = {
    header          = 'İş Mərkəzi',
    current_job     = 'Hazırkı iş: %{job}',
    job_info        = '%{label}',
    quit_job        = 'İşdən çıx',
    quit_desc       = 'Mülki vətəndaş ol',
    applied         = '%{job} işinə düzəldiniz!',
    quit_msg        = 'İşdən çıxdınız. Artıq mülki vətəndaşsınız.',
    already         = 'Artıq bu işdəsiniz.',
    wrong_syntax    = 'Düzgün istifadə: /is <iş adı>',
    not_open        = 'Bu iş hazırda qəbul etmir.',
    need_tool       = 'Əvvəlcə işə düzəlin — alət avtomatik verilir!',
    working         = 'İşlənir...',
    got_item        = '%{item} əldə etdiniz!',
    sold            = 'Satıldı: %{item} x%{count} → +₣%{money}',
    no_items        = 'Satmaq üçün məhsulunuz yoxdur.',
    site_progress   = 'Obyekt: %{step}/%{total}',
    site_done       = '🎉 Obyekt tamamlandı! Bonus: +₣%{bonus}',
    cooldown        = 'Bir az gözləyin...',
    wrong_job       = 'Bu zona sizin işiniz üçün deyil.',
    collect_label   = 'İşlə',
    sell_label      = 'Məhsulları sat',
}
