Config = {}

-- Avtosalon yeri (məkan + qaraj təhvil nöqtəsi)
Config.Location = { label = '196 Avtosalon', coords = vector3(-57.16, -1086.2, 26.42), heading = 0.0 }
Config.Delivery = {
    { label = 'Təhvil nöqtəsi', coords = vector3(-54.71, -1096.0, 26.42) },
}

-- Satılan avtomobillər (model QBCore.Shared.Vehicles-də olmalıdır)
Config.Vehicles = {
    { model = 'weevil',   label = 'Weevil',   class = 'Kompakt', price = 9000 },
    { model = 'blista',   label = 'Blista',   class = 'Kompakt', price = 13000 },
    { model = 'sultan',   label = 'Sultan',   class = 'İdman',   price = 50000 },
    { model = 'sultan2',  label = 'Sultan Custom', class = 'İdman', price = 55000 },
    { model = 'elegy2',   label = 'Elegy RH8', class = 'İdman',  price = 150000 },
    { model = 'comet6',   label = 'Comet 6',  class = 'Liüks',   price = 180000 },
}

-- Sınaq sürüşü müddəti (saniyə)
Config.TestDriveTime = 60

-- Plitə prefiksi
Config.PlatePrefix = '196'
