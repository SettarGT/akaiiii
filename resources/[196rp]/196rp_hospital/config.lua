Config = {}

-- Xəstəxana girişləri (qəbul masası)
Config.Locations = {
    { label = 'Pillbox Xəstəxanası', coords = vector3(307.69, -594.16, 43.18), heading = 20.0 },
    { label = 'Mount Zonah Xəstəxanası', coords = vector3(-447.42, -317.47, 34.61), heading = 0.0 },
}

-- Qiymətlər (₣ Fanteyn)
Config.Prices = {
    Insurance   = 2500,  -- 30 günlük sığorta (müalicə pulsuz)
    Heal        = 800,   -- müalicə (sığortasız)
    Revive      = 2000,  -- AED (EMS yoxdursa, canlandırma)
}

Config.InsuranceDays = 30      -- sığorta müddəti
Config.ReviveCooldown = 180    -- canlandırma arası (saniyə)
