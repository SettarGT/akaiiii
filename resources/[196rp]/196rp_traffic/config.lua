-- 196 RP | Şəhər canlılığı konfiqurasiyası
-- Şəhər heç vaxt boş qalmır: piyadalar və maşınlar həmişə hərəkətdədir.
-- Xüsusi/adlı NPC-lər yoxdur — yalnız adi şəhər əhalisi.

Config = {}

-- Trafik sıxlığı (0.0 - 1.0)
Config.VehicleDensity = 0.9        -- hərəkətdə olan maşınlar
Config.ParkedDensity = 0.7         -- park olunmuş maşınlar
Config.RandomVehicleDensity = 0.9  -- təsadüfi maşınlar
Config.PedDensity = 0.85           -- piyadalar
Config.ScenarioPedDensity = 0.8    -- stansiya/məşğul piyadalar

-- Büdcə (3 = maksimum keyfiyyət)
Config.PedBudget = 3
Config.VehicleBudget = 3

-- Şəhərdən çox uzaqda (kənd) trafiki azalt
Config.RemoteMultiplier = 0.5
Config.RemoteDistance = 2500.0     -- mərkəzdən bu qədər uzaqda
