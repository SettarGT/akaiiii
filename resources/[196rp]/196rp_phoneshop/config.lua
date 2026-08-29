-- 196 RP | Telefon mağazası — 20 model (10 Aifon + 10 Samsan)
--
-- VACİQ QEYD (müəllif hüquqları): real brend adları/loqoları istifadə olunmur.
-- "Aifon" və "Samsan" parodiya adlardır. Heç bir real loqo oyunda göstərilmir.

Config = {}

-- Mağazalar (Bakı rayonlarında yerləşir — bax: 196rp_bakumap)
Config.Shops = {
    {
        id = 'telefon_28may',
        name = '196 Mobil — 28 May',
        district = '28 May',
        coords = vector3(-265.0, -957.0, 31.0),
        ped = { model = 'a_m_m_business_01', scenario = 'WORLD_HUMAN_CLIPBOARD' },
    },
    {
        id = 'telefon_genclik',
        name = '196 Mobil — Gənclik',
        district = 'Gənclik',
        coords = vector3(-544.0, -204.0, 38.0),
        ped = { model = 'a_m_m_business_01', scenario = 'WORLD_HUMAN_CLIPBOARD' },
    },
    {
        id = 'telefon_neriman',
        name = '196 Mobil — Nəriman Nərimanov',
        district = 'Nəriman Nərimanov',
        coords = vector3(150.0, -180.0, 55.0),
        ped = { model = 'a_m_m_business_01', scenario = 'WORLD_HUMAN_CLIPBOARD' },
    },
}

-- Alınan telefon inventara bu əşya kimi düşür (items cədvəlində mövcuddur)
Config.PhoneItem = 'phone'

-- Satışda geri alma faizi
Config.SellRate = 0.50

-- Alqı-satqı arası gözləmə (ms)
Config.Cooldown = 3000

-- ==================== 20 TELEFON MODELİ ====================

Config.Phones = {
    -- ---------- AİFON (10 model) ----------
    { id = 'aifon11', brand = 'Aifon', name = 'Aifon 11', price = 900, storage = 64, colour = 'Qara' },
    { id = 'aifon12', brand = 'Aifon', name = 'Aifon 12', price = 1250, storage = 128, colour = 'Ağ' },
    { id = 'aifon13', brand = 'Aifon', name = 'Aifon 13', price = 1500, storage = 128, colour = 'Mavi' },
    { id = 'aifon14', brand = 'Aifon', name = 'Aifon 14', price = 1800, storage = 128, colour = 'Qara' },
    { id = 'aifon14pro', brand = 'Aifon', name = 'Aifon 14 Pro', price = 2400, storage = 256, colour = 'Bənövşəyi' },
    { id = 'aifon15', brand = 'Aifon', name = 'Aifon 15', price = 2100, storage = 128, colour = 'Yaşıl' },
    { id = 'aifon15pro', brand = 'Aifon', name = 'Aifon 15 Pro', price = 2900, storage = 256, colour = 'Titan' },
    { id = 'aifon15promax', brand = 'Aifon', name = 'Aifon 15 Pro Max', price = 3600, storage = 512, colour = 'Titan' },
    { id = 'aifon16', brand = 'Aifon', name = 'Aifon 16', price = 2600, storage = 128, colour = 'Mavi' },
    { id = 'aifon16pro', brand = 'Aifon', name = 'Aifon 16 Pro', price = 3900, storage = 512, colour = 'Qara Titan' },

    -- ---------- SAMSAN (10 model) ----------
    { id = 'samsan_s10', brand = 'Samsan', name = 'Samsan S10', price = 750, storage = 128, colour = 'Ağ' },
    { id = 'samsan_s20', brand = 'Samsan', name = 'Samsan S20', price = 1050, storage = 128, colour = 'Boz' },
    { id = 'samsan_s21', brand = 'Samsan', name = 'Samsan S21', price = 1300, storage = 128, colour = 'Bənövşəyi' },
    { id = 'samsan_s22', brand = 'Samsan', name = 'Samsan S22', price = 1600, storage = 256, colour = 'Qara' },
    { id = 'samsan_s23', brand = 'Samsan', name = 'Samsan S23', price = 1900, storage = 256, colour = 'Krem' },
    { id = 'samsan_s24', brand = 'Samsan', name = 'Samsan S24', price = 2300, storage = 256, colour = 'Sarı' },
    { id = 'samsan_s24ultra', brand = 'Samsan', name = 'Samsan S24 Ultra', price = 3500, storage = 512, colour = 'Titan Boz' },
    { id = 'samsan_note20', brand = 'Samsan', name = 'Samsan Note 20', price = 1750, storage = 256, colour = 'Mis' },
    { id = 'samsan_a54', brand = 'Samsan', name = 'Samsan A54', price = 600, storage = 128, colour = 'Mavi' },
    { id = 'samsan_flip5', brand = 'Samsan', name = 'Samsan Flip 5', price = 2000, storage = 256, colour = 'Nanə' },
}

-- Mağaza blipi
Config.Blip = { sprite = 502, colour = 3, scale = 0.85, label = '📱 196 Mobil (telefon mağazası)' }

-- Marker
Config.Marker = { drawDistance = 25.0, interactDistance = 1.8 }

-- Qeyd: bütün modellər Config.Phones daxilindədir — yeni model əlavə etmək üçün
-- yalnız bu cədvələ bir sətir əlavə etmək kifayətdir (server qiyməti özündən yoxlayır).
