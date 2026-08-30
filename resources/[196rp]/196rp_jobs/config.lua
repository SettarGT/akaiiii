Config = {}

-- ══════════════════════════════════════════════════════
--  196 RP | İş Mərkəzi + İş Oyunu (balıqçılıq, mədən,
--  meşə, inşaat) — 0 NPC, hibrid self-service
-- ══════════════════════════════════════════════════════

-- İş Mərkəzi məkanları
Config.Locations = {
    { label = 'Mərkəz İş Mərkəzi', coords = vector3(-266.63, -965.76, 31.22), heading = 180.0 },
    { label = 'Sahil İş Mərkəzi', coords = vector3(995.31, -1184.85, 27.09), heading = 180.0 },
}

-- Açıq işlər (iş mərkəzindən düzəlmək olar)
Config.Jobs = {
    fisher        = 'Balıqçılıq — sahildə balıq tut, bazara sat',
    miner         = 'Mədənçilik — qayadan daş, kömür çıxar',
    lumberjack    = 'Meşə — ağac kəs, odun sat',
    construction  = 'İnşaat — material yığ, obyektlər qur',
    vineyard      = 'Üzümçülük — üzüm yığ və emal et',
    mechanic      = 'Mexanik — avtomobilləri təmir et',
    cardealer     = 'Avtosalon — avtomobil sat',
    trucker       = 'Yük daşıma — anbarlara yük çatdır',
    taxi          = 'Taksi — sərnişin daşı',
    bus           = 'Avtobus — marşrut sür',
    garbage       = 'Zibilçilik — şəhəri təmizlə',
    tow           = 'Yedək — avtomobil daşı',
}

-- Hər işin aləti (işə düzələndə verilir, çıxanda alınır)
Config.Tools = {
    fisher       = 'fishing_rod',
    miner        = 'pickaxe',
    lumberjack   = 'axe',
}

-- İş sahələri: hər iş üçün 3 zona
Config.Zones = {
    fishing = {
        { label = 'Sahil A', coords = vector3(-1047.38, -1375.02, 4.01), radius = 3.0 },
        { label = 'Sahil B', coords = vector3(-1153.11, -1316.89, 5.12), radius = 3.0 },
        { label = 'Sahil C', coords = vector3(1287.32, -1717.66, 14.84), radius = 3.0 },
    },
    mining = {
        { label = 'Karyer A', coords = vector3(2953.17, 2791.78, 39.85), radius = 3.0 },
        { label = 'Karyer B', coords = vector3(2958.35, 2775.75, 39.11), radius = 3.0 },
        { label = 'Karyer C', coords = vector3(2943.18, 2773.63, 39.67), radius = 3.0 },
    },
    lumberjack = {
        { label = 'Meşə A', coords = vector3(-536.27, 5575.52, 72.68), radius = 3.0 },
        { label = 'Meşə B', coords = vector3(-564.21, 5518.95, 79.50), radius = 3.0 },
        { label = 'Meşə C', coords = vector3(-504.18, 5548.30, 76.63), radius = 3.0 },
    },
    construction = {
        { label = 'Tikinti A', coords = vector3(970.29, -1188.84, 26.70), radius = 3.5 },
        { label = 'Tikinti B', coords = vector3(1019.16, -1352.98, 26.53), radius = 3.5 },
        { label = 'Tikinti C', coords = vector3(1045.40, -1414.34, 25.94), radius = 3.5 },
    },
}

-- Satış nöqtələri (materialdan pul)
Config.SellPoints = {
    { label = 'Balıq bazarı',            coords = vector3(-1036.88, -1383.29, 4.01),  jobs = { fisher } },
    { label = 'Daş emal mərkəzi',        coords = vector3(1096.69, -1907.91, 30.70), jobs = { miner } },
    { label = 'Mişar dəyirmanı',         coords = vector3(-1090.03, 3160.10, 36.27), jobs = { lumberjack } },
    { label = 'Tikinti anbarı',          coords = vector3(967.70, -1189.40, 27.20), jobs = { construction } },
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
    fishing      = 6,
    mining       = 5,
    lumberjack   = 5,
    build        = 4,
}

-- İnşaat: obyekt başına addım sayı və bonus
Config.Construction = {
    StepsPerSite = 6,      -- 6 material töküləndə obyekt hazır
    Bonus        = 900,    -- hazır obyekt bonusu (₣)
    Materials    = { 'brick', 'cement' },
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
