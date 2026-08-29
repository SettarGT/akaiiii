-- 196 RP | Şəhər canlılığı konfiqurasiyası
--
-- ⚠️ QAYDA: NPC nəqliyyatı YALNIZ xidmət və iş maşınlarıdır —
-- taksi, avtobus, tikinti maşınları və bənzəri (zibil, evakuator, yük).
-- Adi mülki avtomobillər trafikte YOXDUR. Piyadalar isə qalır (şəhər boş görünmür).

Config = {}

-- Piyadalar (şəhər boş qalmasın deyə aktiv qalır)
Config.PedDensity = 0.85
Config.ScenarioPedDensity = 0.8
Config.PedBudget = 3

-- Mülki (adi) avtomobil trafiki — SÖNDÜRÜLÜB
Config.AmbientVehicles = false

-- NPC xidmət maşınları
Config.ServiceVehicles = {
    enabled = true,
    maxVehicles = 14,        -- eyni anda neçə NPC maşını olsun
    spawnRadius = 220.0,     -- oyunçudan bu qədər uzaqda yaranır
    despawnRadius = 420.0,   -- bu qədər uzaqlaşsa silinir
    spawnInterval = 4000,    -- yeni maşın yoxlama tezliyi (ms)
    minSpeed = 8.0,          -- m/s
    maxSpeed = 16.0,
}

-- =====================================================================
-- İCAZƏ VERİLƏN NPC NƏQLİYYATI
-- =====================================================================

Config.VehiclePools = {
    {
        id = 'taxi',
        label = 'Taksi',
        weight = 35,                       -- nə qədər tez-tez yaransın
        models = { 'taxi' },
        ped = 'a_m_m_business_01',
        speed = 14.0,
        color = { 252, 212, 40 },
    },
    {
        id = 'bus',
        label = 'Avtobus',
        weight = 20,
        models = { 'bus', 'coach' },
        ped = 's_m_m_lathandy_01',
        speed = 10.0,
        color = { 60, 90, 160 },
    },
    {
        id = 'construction',
        label = 'Tikinti',
        weight = 25,
        models = { 'dump', 'mixer2', 'flatbed', 'bulldozer', 'handler' },
        ped = 's_m_m_construction_01',
        speed = 8.0,
        color = { 220, 160, 30 },
    },
    {
        id = 'utility',
        label = 'Kommunal',
        weight = 12,
        models = { 'trash', 'towtruck', 'mule', 'benson' },
        ped = 's_m_m_garbage',
        speed = 9.0,
        color = { 120, 130, 120 },
    },
    {
        id = 'delivery',
        label = 'Çatdırılma',
        weight = 8,
        models = { 'boxville2', 'pony2' },
        ped = 'a_m_m_delivery_01',
        speed = 12.0,
        color = { 200, 200, 200 },
    },
}

-- Şəhərdən çox uzaqda (kənd) daha az maşın
Config.RemoteMultiplier = 0.5
Config.RemoteDistance = 2500.0
