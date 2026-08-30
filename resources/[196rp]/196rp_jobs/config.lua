Config = {}

-- ═══════════ İş Mərkəzləri (start) ═══════════
Config.JobCenters = {
    { label = 'Mərkəz İş Mərkəzi', coords = vector3(-266.63, -965.76, 31.22), icon = 'fas fa-briefcase' },
    { label = 'Sahil İş Mərkəzi', coords = vector3(995.31, -1184.85, 27.09), icon = 'fas fa-briefcase' },
    { label = 'Aeroport İş Mərkəzi', coords = vector3(-1049.12, -2747.23, 42.01), icon = 'fas fa-briefcase' },
}

-- ═══════════ İşlər ═══════════
Config.Jobs = {
    { job = 'fisher',      label = '🐟 Balıqçı',    min = 120, max = 200,  tool = 'fishing_rod', anim = { dict = 'amb@world_human_stand_fishing@idle_a', name = 'idle_a', flags = 49 }, time = 25000 },
    { job = 'miner',       label = '⛏ Mədənçi',    min = 140, max = 220,  tool = 'pickaxe',      anim = { dict = 'amb@world_human_const_drill@male@drill@base', name = 'base', flags = 49 }, time = 30000 },
    { job = 'lumberjack',  label = '🪓 Meşəçi',     min = 130, max = 210,  tool = 'axe',          anim = { dict = 'amb@world_human_const_bush_trim@male@trim@base', name = 'base', flags = 49 }, time = 25000 },
    { job = 'construction',label = '🏗 İnşaatçı',   min = 150, max = 240,  tool = 'hammer',       anim = { dict = 'amb@world_human_const_drill@male@drill@base', name = 'base', flags = 49 }, time = 30000 },
    { job = 'mechanic',    label = '🔧 Mexanik',    duty = true },
    { job = 'cardealer',   label = '🚗 Avtosalon',  duty = true },
}

-- ═══════════ İş zonaları ═══════════
Config.Zones = {
    -- Balıqçılıq (liman/sahil)
    { id = 'fish_a', job = 'fisher', item = 'fish',       coords = vector3(-1047.38, -1375.02, 4.01), radius = 3.0, marker = 'Balıqçılıq A' },
    { id = 'fish_b', job = 'fisher', item = 'fish',       coords = vector3(-1153.11, -1316.89, 5.12), radius = 3.0, marker = 'Balıqçılıq B' },
    { id = 'fish_c', job = 'fisher', item = 'fish',       coords = vector3(1287.32, -1717.66, 14.84), radius = 3.0, marker = 'Balıqçılıq C' },
    -- Mədən (karxana)
    { id = 'mine_a', job = 'miner',  item = 'stone',      coords = vector3(2953.17, 2791.78, 39.85), radius = 3.0, marker = 'Karxana A' },
    { id = 'mine_b', job = 'miner',  item = 'stone',      coords = vector3(2958.35, 2775.75, 39.11), radius = 3.0, marker = 'Karxana B' },
    { id = 'mine_c', job = 'miner',  item = 'stone',      coords = vector3(2943.18, 2773.63, 39.67), radius = 3.0, marker = 'Karxana C' },
    -- Meşə
    { id = 'wood_a', job = 'lumberjack', item = 'wood',   coords = vector3(-536.27, 5575.52, 72.68), radius = 3.0, marker = 'Meşə A' },
    { id = 'wood_b', job = 'lumberjack', item = 'wood',   coords = vector3(-564.21, 5518.95, 79.50), radius = 3.0, marker = 'Meşə B' },
    { id = 'wood_c', job = 'lumberjack', item = 'wood',   coords = vector3(-504.18, 5548.30, 76.63), radius = 3.0, marker = 'Meşə C' },
    -- İnşaat
    { id = 'con_a', job = 'construction', item = 'cement', coords = vector3(970.29, -1188.84, 26.70), radius = 3.5, marker = 'Tikinti A' },
    { id = 'con_b', job = 'construction', item = 'brick',  coords = vector3(1019.16, -1352.98, 26.53), radius = 3.5, marker = 'Tikinti B' },
    { id = 'con_c', job = 'construction', item = 'brick',  coords = vector3(1045.40, -1414.34, 25.94), radius = 3.5, marker = 'Tikinti C' },
}

-- ═══════════ Satış məntəqələri ═══════════
Config.SellPoints = {
    { id = 'sell_fish',   label = '🐟 Balıq Bazarı',     coords = vector3(-1036.88, -1383.29, 4.01),  job = 'fisher',       buys = { fish = 90 } },
    { id = 'sell_stone',  label = '⛏ Daş Emalı',         coords = vector3(1096.69, -1907.91, 30.70), job = 'miner',        buys = { stone = 110, coal = 200 } },
    { id = 'sell_wood',   label = '🪵 Mişar Dəyirmanı',   coords = vector3(-1090.03, 3160.10, 36.27), job = 'lumberjack',   buys = { wood = 100, plank = 180 } },
    { id = 'sell_con',    label = '🏗 Tikinti Anbarı',    coords = vector3(967.70, -1189.40, 27.20),  job = 'construction', buys = { cement = 100, brick = 120 } },
}

-- ═══════════ Mexanik ═══════════
Config.Mechanic = {
    RepairPrice = 400,          -- ₣ (duty varsa 1x)
    BoostPrice = 300,           -- ₣ (təkər + yanacaq)
    MaxDistance = 6.0,
    SelfRepairMultiplier = 2.5, -- duty yoxdursa (self-repair stansiyası)
    Station = {
        label = 'Self-Repair Stansiyası (2.5x)',
        coords = vector3(-48.27, -1105.42, 26.42), -- Avtosalon yanı
        radius = 4.0,
    },
}

-- ═══════════ İş geyimləri (uniforma) ═══════════
-- slot: 3=torso, 4=ayaq, 6=ayaqqabı, 11=üst
Config.Uniforms = {
    miner =       { { slot = 3, draw = 34, tex = 0 }, { slot = 4, draw = 24, tex = 0 }, { slot = 11, draw = 219, tex = 0 } },
    lumberjack =  { { slot = 3, draw = 34, tex = 0 }, { slot = 4, draw = 23, tex = 0 }, { slot = 11, draw = 220, tex = 0 } },
    construction ={ { slot = 3, draw = 34, tex = 0 }, { slot = 4, draw = 22, tex = 0 }, { slot = 11, draw = 218, tex = 0 } },
    fisher =      { { slot = 3, draw = 34, tex = 0 }, { slot = 4, draw = 21, tex = 0 } },
    mechanic =    { { slot = 3, draw = 1, tex = 0 },  { slot = 4, draw = 23, tex = 0 } },
    cardealer =   { { slot = 3, draw = 1, tex = 0 },  { slot = 4, draw = 25, tex = 0 } },
}

-- ═══════════ Avtosalon ═══════════
Config.CarDealer = {
    SaleCenter = { label = '196 Avtosalon', coords = vector3(-50.27, -1101.42, 26.42), radius = 8.0 },
    Vehicles = {
        { model = 'panto',     label = 'Panto',        price = 4000 },
        { model = 'kanjo',     label = 'Kanjo',        price = 8000 },
        { model = 'blista',    label = 'Blista',       price = 10000 },
        { model = 'asbo',      label = 'ASBO',         price = 12000 },
        { model = 'sultan',    label = 'Sultan',       price = 25000 },
        { model = 'sentinel',  label = 'Sentinel',     price = 35000 },
    },
}
