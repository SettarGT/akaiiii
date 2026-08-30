Config = {}

-- Balıqçılıq nöqtələri (qayıqda/təyyarə yox — 0 NPC)
Config.Spots = {
    {
        id = 'pier_a',
        label = '🏝 Liman Dayanacağı A',
        coords = vector3(-1049.0, -1376.0, 0.6),
        radius = 3.0,
        catches = { { item = 'carp',     chance = 65 }, { item = 'swordfish', chance = 35 } },
    },
    {
        id = 'pier_b',
        label = '🏝 Liman Dayanacağı B',
        coords = vector3(-1155.0, -1318.0, 0.6),
        radius = 3.0,
        catches = { { item = 'carp', chance = 50 }, { item = 'swordfish', chance = 50 } },
    },
    {
        id = 'deep',
        label = '🌊 Dərin Su Sahəsi',
        coords = vector3(1287.0, -1719.0, 0.2),
        radius = 3.5,
        catches = { { item = 'swordfish', chance = 55 }, { item = 'shark', chance = 45 } },
    },
}

-- Qayıq modeli (pulsuz iş qayığı)
Config.Boat = {
    model = 'dinghy',
    spawnCoords = vector4(-1032.16, -1367.07, 0.2, 180.0),
}

-- Qarmaq mini-game
Config.Minigame = {
    Difficulty = 'medium',
    Keys = '1234',
    EmptyChance = 15, -- % boş gəlmə şansı
}

-- İş tələbi
Config.Job = 'fisher'
