-- 196 RP | Ev heyvanları
-- Mağazada müxtəlif it və pişik növləri satılır. Heyvanı gəzdirmək, yemləmək olar.

Config = {}

-- Mağaza
Config.Shop = {
    name = '196 Ev Heyvanları Mağazası',
    coords = vector3(-1060.0, -1200.0, 6.5),
    blip = { sprite = 442, color = 2 },
}

-- Bir oyunçunun saxlaya biləcəyi maksimum heyvan sayı
Config.MaxPets = 3

-- Aclıq/sevinc azalma sürəti (hər 5 dəqiqədə)
Config.DecayInterval = 300000
Config.HungerDecay = 8
Config.HappyDecay = 5

-- Aclıq bu dəyərdən aşağı düşsə heyvan kədərlənir
Config.HungerWarning = 25

-- Yem əşyaları
Config.FoodItems = {
    dog = { item = 'it_yemi', label = 'İt yemi', amount = 35 },
    cat = { item = 'pisik_yemi', label = 'Pişik yemi', amount = 35 },
}

-- =====================================================================
-- SATIŞDA OLAN HEYVANLAR
-- =====================================================================

Config.Animals = {
    -- İTLƏR
    { species = 'dog', model = 'a_c_husky',     label = 'Sibir Huski',        price = 2500 },
    { species = 'dog', model = 'a_c_shepherd',  label = 'Alman Ovçarkası',    price = 3200 },
    { species = 'dog', model = 'a_c_retriever', label = 'Qızıl Retriver',     price = 2800 },
    { species = 'dog', model = 'a_c_rottweiler',label = 'Rotveyler',          price = 3500 },
    { species = 'dog', model = 'a_c_poodle',    label = 'Pudel',              price = 1800 },
    { species = 'dog', model = 'a_c_pug',       label = 'Paq',                price = 1500 },
    { species = 'dog', model = 'a_c_westy',     label = 'Vest-Haylend Teriyer', price = 1600 },

    -- PİŞİKLƏR
    { species = 'cat', model = 'a_c_cat_01',    label = 'Ev Pişiyi',          price = 900 },
}

-- İtlərin edə biləcəyi əmrlər
Config.DogCommands = {
    { id = 'follow', label = 'Dalımca gəl (gəzdirmə)', anim = nil },
    { id = 'sit',    label = 'Otur',            dict = 'creatures@rottweiler@amb@sleep_in_kennel@', anim = 'sleep_in_kennel' },
    { id = 'heel',   label = 'Yanımda dur',     dict = 'creatures@rottweiler@amb@world_dog_sitting@base@', anim = 'base' },
}

Config.CatCommands = {
    { id = 'follow', label = 'Dalımca gəl', anim = nil },
    { id = 'sit',    label = 'Uzan', dict = 'creatures@cat@amb@sleep_in_kennel@', anim = 'sleep_in_kennel' },
}
