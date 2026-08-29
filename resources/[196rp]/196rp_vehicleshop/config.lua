-- 196 RP | Avtosalon
-- Bütün maşınlar "vehicles" cədvəlində qeyd olunub (bax: 196rp.sql)

Config = {}

Config.Shops = {
    {
        id = 'avtosalon',
        name = 'Premium Deluxe Avtosalon',
        coords = vector3(-42.5, -1100.6, 26.4),
        heading = 90.0,
        blip = { sprite = 225, color = 49 },
        categories = { 'sedan', 'coupe', 'sports', 'super', 'suv', 'offroad', 'muscle', 'compact', 'van', 'boat', 'aircraft' }
    },
    {
        id = 'motosalon',
        name = 'Motosiklet Salonu',
        coords = vector3(1050.0, -900.0, 30.0),
        heading = 180.0,
        blip = { sprite = 226, color = 49 },
        categories = { 'motorcycle' }
    }
}

Config.CategoryLabels = {
    sedan = 'Sedan',
    coupe = 'Kupe',
    sports = 'İdman',
    super = 'Superkar',
    suv = 'Yolsuzluq (SUV)',
    offroad = 'Offroad',
    muscle = 'Məskl',
    compact = 'Kompakt',
    van = 'Furqon',
    motorcycle = 'Motosiklet',
    boat = 'Qayıq',
    aircraft = 'Təyyarə'
}

-- Maşınlar (name = mağazada görünən ad, model = spawn adı)
Config.Vehicles = {
    -- Sedan
    { name = 'Asea', model = 'asea', price = 5500, category = 'sedan' },
    { name = 'Fugitive', model = 'fugitive', price = 18000, category = 'sedan' },
    { name = 'Ingot', model = 'ingot', price = 4500, category = 'sedan' },
    { name = 'Intruder', model = 'intruder', price = 12000, category = 'sedan' },
    { name = 'Premier', model = 'premier', price = 9000, category = 'sedan' },
    { name = 'Primo', model = 'primo', price = 7000, category = 'sedan' },
    { name = 'Stanier', model = 'stanier', price = 6500, category = 'sedan' },
    { name = 'Stratum', model = 'stratum', price = 8500, category = 'sedan' },
    { name = 'Tailgater', model = 'tailgater', price = 35000, category = 'sedan' },
    { name = 'Regina', model = 'regina', price = 5000, category = 'sedan' },
    -- Kupe
    { name = 'Cognoscenti', model = 'cognoscenti', price = 55000, category = 'coupe' },
    { name = 'F620', model = 'f620', price = 40000, category = 'coupe' },
    { name = 'Jackal', model = 'jackal', price = 38000, category = 'coupe' },
    { name = 'Oracle', model = 'oracle', price = 32000, category = 'coupe' },
    { name = 'Sentinel', model = 'sentinel', price = 30000, category = 'coupe' },
    { name = 'Zion', model = 'zion', price = 35000, category = 'coupe' },
    -- İdman
    { name = 'Banshee', model = 'banshee', price = 120000, category = 'sports' },
    { name = 'Bestia GTS', model = 'bestiagts', price = 75000, category = 'sports' },
    { name = 'Carbonizzare', model = 'carbonizzare', price = 135000, category = 'sports' },
    { name = 'Comet', model = 'comet2', price = 115000, category = 'sports' },
    { name = 'Coquette', model = 'coquette', price = 138000, category = 'sports' },
    { name = 'Elegy RH8', model = 'elegy2', price = 95000, category = 'sports' },
    { name = 'Feltzer', model = 'feltzer2', price = 110000, category = 'sports' },
    { name = 'Jester', model = 'jester', price = 130000, category = 'sports' },
    { name = 'Kuruma', model = 'kuruma', price = 145000, category = 'sports' },
    { name = 'Massacro', model = 'massacro', price = 140000, category = 'sports' },
    { name = 'Sultan', model = 'sultan', price = 68000, category = 'sports' },
    -- Superkar
    { name = 'Adder', model = 'adder', price = 900000, category = 'super' },
    { name = 'Cheetah', model = 'cheetah', price = 650000, category = 'super' },
    { name = 'Entity XF', model = 'entityxf', price = 795000, category = 'super' },
    { name = 'Infernus', model = 'infernus', price = 440000, category = 'super' },
    { name = 'Osiris', model = 'osiris', price = 850000, category = 'super' },
    { name = 'T20', model = 't20', price = 1100000, category = 'super' },
    { name = 'Turismo R', model = 'turismor', price = 700000, category = 'super' },
    { name = 'Zentorno', model = 'zentorno', price = 875000, category = 'super' },
    -- SUV
    { name = 'Baller', model = 'baller2', price = 70000, category = 'suv' },
    { name = 'Cavalcade', model = 'cavalcade2', price = 55000, category = 'suv' },
    { name = 'Dubsta', model = 'dubsta', price = 60000, category = 'suv' },
    { name = 'FQ2', model = 'fq2', price = 48000, category = 'suv' },
    { name = 'Granger', model = 'granger', price = 65000, category = 'suv' },
    { name = 'Huntley S', model = 'huntley', price = 78000, category = 'suv' },
    { name = 'Patriot', model = 'patriot', price = 88000, category = 'suv' },
    { name = 'Radius', model = 'radius', price = 42000, category = 'suv' },
    { name = 'Seminole', model = 'seminole', price = 39000, category = 'suv' },
    { name = 'XLS', model = 'xls', price = 74000, category = 'suv' },
    -- Offroad
    { name = 'Bison', model = 'bison', price = 35000, category = 'offroad' },
    { name = 'Bodhi', model = 'bodhi2', price = 18000, category = 'offroad' },
    { name = 'Dubsta 6x6', model = 'dubsta3', price = 220000, category = 'offroad' },
    { name = 'Kalahari', model = 'kalahari', price = 25000, category = 'offroad' },
    { name = 'Mesa', model = 'mesa', price = 32000, category = 'offroad' },
    { name = 'Rancher XL', model = 'rancherxl', price = 28000, category = 'offroad' },
    { name = 'Rebel', model = 'rebel2', price = 22000, category = 'offroad' },
    { name = 'Sadler', model = 'sadler', price = 26000, category = 'offroad' },
    { name = 'Sandking', model = 'sandking', price = 55000, category = 'offroad' },
    { name = 'Trophy Truck', model = 'trophytruck', price = 160000, category = 'offroad' },
    -- Məskl
    { name = 'Blade', model = 'blade', price = 25000, category = 'muscle' },
    { name = 'Buffalo', model = 'buffalo', price = 38000, category = 'muscle' },
    { name = 'Dominator', model = 'dominator', price = 42000, category = 'muscle' },
    { name = 'Dukes', model = 'dukes', price = 30000, category = 'muscle' },
    { name = 'Gauntlet', model = 'gauntlet', price = 36000, category = 'muscle' },
    { name = 'Hotknife', model = 'hotknife', price = 90000, category = 'muscle' },
    { name = 'Phoenix', model = 'phoenix', price = 34000, category = 'muscle' },
    { name = 'Ruiner', model = 'ruiner', price = 32000, category = 'muscle' },
    { name = 'Sabre Turbo', model = 'sabregt', price = 35000, category = 'muscle' },
    -- Kompakt
    { name = 'Blista', model = 'blista', price = 4500, category = 'compact' },
    { name = 'Panto', model = 'panto', price = 3000, category = 'compact' },
    { name = 'Prairie', model = 'prairie', price = 5000, category = 'compact' },
    { name = 'Rhapsody', model = 'rhapsody', price = 2500, category = 'compact' },
    -- Furqon
    { name = 'Burrito', model = 'burrito3', price = 22000, category = 'van' },
    { name = 'Camper', model = 'camper', price = 45000, category = 'van' },
    { name = 'Rumpo', model = 'rumpo', price = 18000, category = 'van' },
    { name = 'Surfer', model = 'surfer', price = 14000, category = 'van' },
    { name = 'Youga', model = 'youga', price = 20000, category = 'van' },
    -- Motosiklet
    { name = 'Akuma', model = 'akuma', price = 7500, category = 'motorcycle' },
    { name = 'Bati 801', model = 'bati', price = 12000, category = 'motorcycle' },
    { name = 'BF400', model = 'bf400', price = 9500, category = 'motorcycle' },
    { name = 'Carbon RS', model = 'carbonrs', price = 16000, category = 'motorcycle' },
    { name = 'Double T', model = 'double', price = 14500, category = 'motorcycle' },
    { name = 'Faggio', model = 'faggio2', price = 1500, category = 'motorcycle' },
    { name = 'Hexer', model = 'hexer', price = 11000, category = 'motorcycle' },
    { name = 'PCJ 600', model = 'pcj', price = 8500, category = 'motorcycle' },
    { name = 'Ruffian', model = 'ruffian', price = 10000, category = 'motorcycle' },
    { name = 'Sanchez', model = 'sanchez', price = 6500, category = 'motorcycle' },
    { name = 'Vader', model = 'vader', price = 9000, category = 'motorcycle' },
    -- Qayıq
    { name = 'Dinghy', model = 'dinghy', price = 25000, category = 'boat' },
    { name = 'Jetmax', model = 'jetmax', price = 68000, category = 'boat' },
    { name = 'Marquis', model = 'marquis', price = 120000, category = 'boat' },
    { name = 'Seashark', model = 'seashark', price = 15000, category = 'boat' },
    { name = 'Speeder', model = 'speeder', price = 95000, category = 'boat' },
    -- Təyyarə
    { name = 'Cub 800', model = 'cub800', price = 200000, category = 'aircraft' },
    { name = 'Duster', model = 'duster', price = 275000, category = 'aircraft' },
    { name = 'Mammatus', model = 'mammatus', price = 350000, category = 'aircraft' },
}

Config.GetVehicle = function(model)
    for i = 1, #Config.Vehicles do
        if Config.Vehicles[i].model == model then
            return Config.Vehicles[i]
        end
    end
    return nil
end
