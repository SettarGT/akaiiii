Config = {}

-- Tibbi bölgələr (6 zona)
Config.Zones = {
    { id = 'head',   label = 'Baş',        icon = 'fas fa-head-side-virus' },
    { id = 'thorax', label = 'Sinə',       icon = 'fas fa-lungs' },
    { id = 'larm',   label = 'Sol qol',    icon = 'fas fa-hand' },
    { id = 'rarm',   label = 'Sağ qol',    icon = 'fas fa-hand' },
    { id = 'lleg',   label = 'Sol ayaq',   icon = 'fas fa-shoe-prints' },
    { id = 'rleg',   label = 'Sağ ayaq',   icon = 'fas fa-shoe-prints' },
}

-- Kritik hədd (bu dəyərdən yuxarı cərrahiyyə tələb olunur)
Config.Critical = 55

-- Müalicə parametrləri
Config.BandageReduce = 25     -- /sarqi
Config.SplintReduce  = 35     -- /gips (ayaq/qol)
Config.SurgeryHeal   = 100    -- /cerrahiye uğurla bitəndə bərpa
Config.ReviveMaxSum  = 20     -- ümumi zədə bu həddən aşağı olarsa diriltmək olar

-- Xərək məsafəsi
Config.CarryRange = 3.0

-- İşlər
Config.Jobs = { 'ambulance', 'doctor' }

-- Simvollar (cərrahiyyə minigame)
Config.SurgerySymbols = { '🩺', '💉', '🧬', '🩹', '⚕️' }
Config.SurgerySteps = 5
Config.SurgeryTime = 2.5  -- hər addım üçün saniyə
