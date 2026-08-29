-- 196 RP | Dövlət qüvvələri (əlavə) konfiqurasiyası
-- Bəndlər: 81 (polis qərargahı içi), 82 (polis radarı), 83 (yol polisi),
-- 84 (K9 iti), 85 (SWAT), 86 (maaş artımı), 87 (TİB helikopteri),
-- 88 (yanğınsöndürən dərəcələri), 89 (mülki müdafiə xəbərdarlığı)

Config = {}

Config.Jobs = {
    police = 'police',
    ambulance = 'ambulance',
    firefighter = 'firefighter',
}

-- ==================== 81. POLİS QƏRARGAHI ====================

Config.HQ = {
    entrance = vector3(441.0, -982.0, 30.7),      -- Mission Row girişi
    interior = vector3(443.5, -980.4, 30.68),
    exit = vector3(441.0, -982.0, 30.7),
    interiorDist = 12.0,
    points = {
        computer = { coords = vector3(442.0, -978.0, 30.68), label = 'Kompüter — axtarış sistemi' },
        armory = { coords = vector3(450.0, -980.0, 30.68), label = 'Cəbhəxana' },
        cells = { coords = vector3(462.0, -994.0, 30.68), label = 'Kamera bloku' },
    },
    armoryWeapons = {
        { weapon = 'WEAPON_COMBATPISTOL', ammo = 120 },
        { weapon = 'WEAPON_STUNGUN', ammo = 50 },
        { weapon = 'WEAPON_NIGHTSTICK', ammo = 0 },
        { weapon = 'WEAPON_FLASHLIGHT', ammo = 0 },
    },
    minGradeArmory = 1,
}

-- ==================== 82. POLİS RADARI ====================

Config.Radar = {
    maxDistance = 40.0,
    cooldown = 5,
}

-- ==================== 83. YOL POLİSİ ====================

Config.RoadPolice = {
    checkDistance = 15.0,
    speedWarn = 120.0,        -- km/saat — bu həddən yuxarı xəbərdarlıq
    licenseTypes = { 'dmv', 'drive', 'drive_bike', 'drive_truck', 'boat', 'pilot' },
}

-- ==================== 84. K9 İTİ ====================

Config.K9 = {
    model = 'a_c_shepherd',
    searchDistance = 4.0,
    searchTime = 6000,
    illegalItems = { 'marijuana', 'saxta_pul', 'saxta_vesiqe', 'qifil_acari', 'som' },
    minGrade = 1,
}

-- ==================== 85. SWAT ====================

Config.SWAT = {
    minGrade = 3,
    armour = 100,
    shieldProp = 'prop_ballistic_shield',
    shieldDict = 'anim@heists@money_grab@briefcase',
    weapons = {
        { weapon = 'WEAPON_CARBINERIFLE', ammo = 250 },
        { weapon = 'WEAPON_PUMPSHOTGUN', ammo = 100 },
    },
}

-- ==================== 86. MAAŞ ARTIMI ====================

Config.Salary = {
    intervalMinutes = 30,      -- yoxlama intervalı
    bonusPerYear = 0.10,       -- hər il üçün maaşın 10%-i əlavə
    maxBonusMult = 0.50,       -- ən çox 50% əlavə
}

-- ==================== 87. TİB HELİKOPTERİ ====================

Config.AirAmbulance = {
    model = 'maverick',
    spawn = vector3(340.0, -585.0, 74.0),
    heading = 240.0,
    minGrade = 2,
    plate = '196TIB01',
}

-- ==================== 88. YANĞINSÖNDÜRƏN DƏRƏCƏLƏRİ ====================

Config.FireRanks = {
    { grade = 0, label = 'Sınaq müddətli', abilities = { 'Yanğın söndürmə' } },
    { grade = 1, label = 'Yanğınsöndürən', abilities = { 'Yanğın söndürmə', 'Yanğın maşını çağırma' } },
    { grade = 2, label = 'Briqadir', abilities = { 'Yanğın söndürmə', 'Yanğın maşını çağırma', 'Əməliyyat rəhbərliyi' } },
    { grade = 3, label = 'Yanğın rəisi', abilities = { 'Yanğın söndürmə', 'Yanğın maşını çağırma', 'Əməliyyat rəhbərliyi', 'Fövqəladə elan' } },
    minVehicleGrade = 1,
    minAlertGrade = 3,
}

-- ==================== 89. MÜLKİ MÜDAFİƏ ====================

Config.CivilDefence = {
    minGrade = { police = 3, ambulance = 2, firefighter = 3 },
    durationSeconds = 60,
    cooldown = 300,
    maxLength = 120,
}
