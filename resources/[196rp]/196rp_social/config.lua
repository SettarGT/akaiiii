-- 196 RP | Sosial sistemlər konfiqurasiyası
-- Bəndlər: 97 (hədiyyə), 98 (evlilik), 99 (dostluq), 100 (missiya sistemi)

Config = {}

-- ==================== 97. HƏDİYYƏ ====================

Config.Gift = {
    maxDistance = 5.0,
    maxMoney = 50000,
    wrapTime = 4000,
    item = 'hediyye',
}

-- ==================== 98. EVLİLİK ====================

Config.Marriage = {
    ringItem = 'uzuk',
    proposeDistance = 4.0,
    venue = vector3(-1660.0, -300.0, 51.5),      -- toy mərasimi yeri
    venueDist = 30.0,
    ceremonyTime = 15000,
    ceremonyCost = 2500,
    sharedAccountMult = 0.0,                     -- 0 = ortaq hesab bağlıdır
}

-- ==================== 99. DOSTLUQ ====================

Config.Friend = {
    maxDistance = 10.0,
    maxFriends = 50,
    blipSprite = 1,
    blipColour = 2,
}

-- ==================== 100. MİSSİYA SİSTEMİ ====================

Config.Mission = {
    cooldown = 120,          -- missiyalar arası saniyə
    timeLimit = 900,         -- missiyanı bitirmək üçün saniyə
    board = vector3(-268.0, -957.0, 31.2),      -- İş Mərkəzi lövhəsi
    boardDist = 2.5,
    blipSprite = 408,
    blipColour = 5,
}

Config.Missions = {
    {
        label = 'İtmiş yükü tap',
        description = 'Anbar yaxınlığında itmiş yükü tapın.',
        target = vector3(-430.0, -2770.0, 5.0),
        radius = 15.0,
        reward = 300,
        time = 8000,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
    },
    {
        label = 'Yaralı şəxsə kömək et',
        description = 'Küçədə kömək gözləyən şəxsə çatın.',
        target = vector3(-1150.0, -890.0, 13.0),
        radius = 15.0,
        reward = 250,
        time = 9000,
        scenario = 'CODE_HUMAN_MEDIC_KNEEL',
    },
    {
        label = 'Fotoşəkil çək',
        description = 'Şəhərin mənzərəli nöqtəsində reportaj hazırlayın.',
        target = vector3(-1200.0, -1450.0, 4.5),
        radius = 20.0,
        reward = 200,
        time = 7000,
        scenario = 'WORLD_HUMAN_PAPARAZZI',
    },
    {
        label = 'Xarab maşını təmir et',
        description = 'Yol kənarında qalmış sürücüyə kömək edin.',
        target = vector3(1140.0, -980.0, 46.0),
        radius = 15.0,
        reward = 350,
        time = 12000,
        scenario = 'WORLD_HUMAN_WELDING',
    },
    {
        label = 'Bağçanı sulamaq',
        description = 'Şəhər parkında bitkilərə qulluq edin.',
        target = vector3(-1250.0, -1000.0, 7.0),
        radius = 15.0,
        reward = 180,
        time = 9000,
        scenario = 'WORLD_HUMAN_GARDENER_PLANT',
    },
    {
        label = 'Sənədləri çatdır',
        description = 'Bələdiyyə sənədlərini ünvana aparın.',
        target = vector3(246.0, -687.0, 30.5),
        radius = 15.0,
        reward = 220,
        time = 6000,
        scenario = 'WORLD_HUMAN_CLIPBOARD',
    },
    {
        label = 'Gecə növbəsi',
        description = 'Anbarda gecə növbəsini saxlayın.',
        target = vector3(145.0, 6360.0, 31.3),
        radius = 20.0,
        reward = 400,
        time = 12000,
        scenario = 'WORLD_HUMAN_GUARD_STAND',
    },
}
