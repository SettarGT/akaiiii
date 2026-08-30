Config = {}

-- Stress parametrləri
Config.Stress = {
    IncreaseHack = 30,       -- kiber hücum
    IncreaseChop = 40,       -- maşın sökümü
    RelaxAmount = 20,        -- /nəfəs ilə azalma
    RelaxTime = 4,           -- nəfəs məşqi (saniyə)
    RelaxCooldown = 60,      -- nəfəs arası (saniyə)
    WarnThreshold = 70,      -- xəbərdarlıq həddi
    CheckInterval = 90,      -- yoxlama intervalı (saniyə)
}

-- Yemək/iqlim ilə azalma (istifadə olunan itemlər)
Config.RelaxFoods = {
    sandwich = 15, water_bottle = 10,
}
