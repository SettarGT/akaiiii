Config = {}

-- DarkWeb kiosk yeri (gizli)
Config.DarkWeb = {
    label = 'DarkWeb Terminalı',
    coords = vector3(877.29, -1335.28, 25.91),
    heading = 0.0,
}

-- Narkotik əvəzi qanunsuz gəlir: kiber cinayət
Config.Hack = {
    MinPayout = 8000,      -- min gəlir (₣)
    MaxPayout = 30000,     -- max gəlir (₣)
    Cooldown = 300,        -- 5 dəq soyutma
    BaseSuccess = 45,      -- alətsiz uğur şansı (%)
    KitBonus = 25,         -- cyber_kit ilə bonus (%)
    KitCost = 5000,        -- alət qiyməti (₣)
}

-- Stress (196rp_stress resursu işləyirsə)
Config.StressIncrease = 30

-- Polis xəbərdarlığı
Config.Alert = true

-- Kiber alət (DarkWeb-dən alınır)
Config.Items = {
    cyber_kit = 'Kiber dəst',
}
