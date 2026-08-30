Config = {}

-- İş yerləri: ad + tip + qiymət
Config.BusinessTypes = {
    shop     = { label = 'Kiçik mağaza',   price = 25000,  icon = 'fas fa-store' },
    restaurant = { label = 'Restoran',     price = 50000,  icon = 'fas fa-utensils' },
    service  = { label = 'Avtoservis',     price = 75000,  icon = 'fas fa-wrench' },
    club     = { label = 'Gecə klubu',     price = 100000, icon = 'fas fa-martini-glass' },
}

-- Satışa çıxarılan iş yerləri (məkanlar)
Config.Businesses = {
    { id = 'shop_1',  type = 'shop',      label = '24/7 Mağaza',     coords = vector3(25.18, -1346.35, 29.49), heading = 0.0 },
    { id = 'shop_2',  type = 'shop',      label = 'Robin Mağaza',    coords = vector3(-706.29, -906.92, 19.21), heading = 0.0 },
    { id = 'rest_1',  type = 'restaurant', label = 'Baharat Restoran', coords = vector3(-580.09, -529.7, 40.25), heading = 0.0 },
    { id = 'serv_1',  type = 'service',   label = '196 Təmir Mərkəzi', coords = vector3(-193.97, -1338.69, 31.17), heading = 0.0 },
    { id = 'club_1',  type = 'club',      label = 'Mirage Klub',     coords = vector3(929.02, 45.51, 81.09), heading = 0.0 },
}

-- Kassa limiti
Config.MaxBalance = 2000000
