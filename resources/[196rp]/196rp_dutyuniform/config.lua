-- 196 RP | Dövlət formaları
--
-- ⚠️ VACİB QAYDA: "196" loqosu / adı YALNIZ dövlət orqanlarının formalarında istifadə olunur.
-- Mülki (vətəndaş) geyimlərində heç bir 196 işarəsi yoxdur — onlar adi geyim mağazalarındadır.
--
-- Dövlət işləri: Polis, TİB (Təcili Yardım), Yanğınsöndürən.

Config = {}

-- 196 brend adı (formalarda görünür)
Config.Brand = '196'
Config.BrandFull = '196 Dövlət Xidməti'

-- Formaların saxlandığı şkaf nöqtələri (hər dövlət orqanının öz binasında)
Config.Wardrobes = {
    -- POLİS
    { job = 'police', label = '196 Polis — Geyim Otağı (Mission Row)', coords = vector3(452.6, -987.5, 30.7) },
    { job = 'police', label = '196 Polis — Geyim Otağı (Davis)',      coords = vector3(365.0, -1580.0, 29.3) },
    { job = 'police', label = '196 Polis — Geyim Otağı (Sandy)',      coords = vector3(1853.0, 3686.0, 34.3) },
    { job = 'police', label = '196 Polis — Geyim Otağı (Paleto)',     coords = vector3(-447.0, 6014.0, 31.7) },

    -- TİB (Təcili Yardım)
    { job = 'ambulance', label = '196 TİB — Geyim Otağı (Pillbox)',   coords = vector3(307.0, -595.0, 43.3) },
    { job = 'ambulance', label = '196 TİB — Geyim Otağı (Sandy)',     coords = vector3(1839.0, 3672.0, 34.3) },
    { job = 'ambulance', label = '196 TİB — Geyim Otağı (Paleto)',    coords = vector3(-247.0, 6330.0, 32.4) },

    -- YANĞINSÖNDÜRƏN
    { job = 'firefighter', label = '196 Yanğınsöndürən — Geyim Otağı', coords = vector3(-470.0, -710.0, 30.0) },
}

-- =====================================================================
-- FORMALAR
-- Hər forma: component = { [kompID] = { d = drawable, t = texture } }
-- prop = { [propID] = { d = drawable, t = texture } }
--
-- GTA V komponent ID-ləri:
--   1 = maska, 3 = qol, 4 = şalvar, 5 = çanta, 6 = ayaqqabı,
--   7 = aksessuar, 8 = köynək, 9 = jilet, 10 = nişan/çap, 11 = gödəkçə
-- Prop ID-ləri: 0 = papaq/kaska, 1 = eynək, 2 = qulaq, 6 = saat
--
-- Qeyd: index dəyərlərini öz serverinizdə sınayıb dəyişə bilərsiniz —
-- hamısı burada cəmlənib ki, kod dəyişmədən düzəliş etmək asan olsun.
-- =====================================================================

Config.Uniforms = {
    ------------------------------------------------------------------
    -- 196 POLİS
    ------------------------------------------------------------------
    police = {
        {
            label = '196 Polis — Patrul Forması',
            grade = 0,
            component = {
                [3]  = { d = 30, t = 0 },   -- qol
                [4]  = { d = 35, t = 0 },   -- şalvar
                [6]  = { d = 25, t = 0 },   -- ayaqqabı
                [8]  = { d = 58, t = 0 },   -- köynək
                [10] = { d = 8,  t = 0 },   -- "196" sinə nişanı (polis emblemi)
                [11] = { d = 55, t = 0 },   -- gödəkçə
            },
            prop = {
                [0] = { d = 17, t = 0 },    -- polis papağı
            },
            armor = 50,
        },
        {
            label = '196 Polis — Serjant Forması',
            grade = 2,
            component = {
                [3]  = { d = 30, t = 0 },
                [4]  = { d = 35, t = 1 },
                [6]  = { d = 25, t = 0 },
                [8]  = { d = 58, t = 1 },
                [9]  = { d = 17, t = 0 },   -- jilet
                [10] = { d = 8,  t = 1 },   -- rütbə nişanı
                [11] = { d = 55, t = 1 },
            },
            prop = {
                [0] = { d = 17, t = 0 },
            },
            armor = 75,
        },
        {
            label = '196 Polis — SWAT / Xüsusi Əməliyyat',
            grade = 3,
            component = {
                [1]  = { d = 35, t = 0 },   -- maska
                [3]  = { d = 32, t = 0 },
                [4]  = { d = 36, t = 0 },
                [6]  = { d = 26, t = 0 },
                [8]  = { d = 60, t = 0 },
                [9]  = { d = 18, t = 0 },   -- ağır jilet
                [10] = { d = 9,  t = 0 },
                [11] = { d = 57, t = 0 },
            },
            prop = {
                [0] = { d = 41, t = 0 },    -- kaska
            },
            armor = 100,
        },
        {
            label = '196 Polis — Rəis Forması (parad)',
            grade = 4,
            component = {
                [3]  = { d = 30, t = 0 },
                [4]  = { d = 35, t = 2 },
                [6]  = { d = 25, t = 1 },
                [8]  = { d = 58, t = 2 },
                [10] = { d = 8,  t = 2 },   -- rəis nişanı
                [11] = { d = 55, t = 2 },
            },
            prop = {
                [0] = { d = 17, t = 1 },
            },
            armor = 0,
        },
    },

    ------------------------------------------------------------------
    -- 196 TİB (TƏCİLİ YARDIM)
    ------------------------------------------------------------------
    ambulance = {
        {
            label = '196 TİB — Feldşer Forması',
            grade = 0,
            component = {
                [3]  = { d = 32, t = 0 },
                [4]  = { d = 36, t = 1 },
                [6]  = { d = 27, t = 0 },
                [8]  = { d = 15, t = 0 },   -- tibbi köynək
                [10] = { d = 11, t = 0 },   -- "196 TİB" emblemi
                [11] = { d = 57, t = 1 },
            },
            prop = {},
            armor = 0,
        },
        {
            label = '196 TİB — Həkim Forması (xalat)',
            grade = 2,
            component = {
                [3]  = { d = 33, t = 0 },
                [4]  = { d = 36, t = 2 },
                [6]  = { d = 27, t = 1 },
                [8]  = { d = 15, t = 1 },
                [10] = { d = 11, t = 1 },
                [11] = { d = 58, t = 0 },   -- ağ xalat
            },
            prop = {},
            armor = 0,
        },
        {
            label = '196 TİB — Reanimasiya Briqadası',
            grade = 3,
            component = {
                [3]  = { d = 32, t = 0 },
                [4]  = { d = 36, t = 1 },
                [6]  = { d = 26, t = 0 },
                [8]  = { d = 15, t = 2 },
                [9]  = { d = 20, t = 0 },   -- işıqqaytarıcı jilet
                [10] = { d = 11, t = 2 },
                [11] = { d = 57, t = 2 },
            },
            prop = {
                [0] = { d = 40, t = 0 },
            },
            armor = 25,
        },
    },

    ------------------------------------------------------------------
    -- 196 YANĞINSÖNDÜRƏN
    ------------------------------------------------------------------
    firefighter = {
        {
            label = '196 Yanğınsöndürən — Döyüş Forması',
            grade = 0,
            component = {
                [3]  = { d = 34, t = 0 },
                [4]  = { d = 37, t = 0 },
                [6]  = { d = 28, t = 0 },
                [8]  = { d = 16, t = 0 },
                [9]  = { d = 21, t = 0 },   -- istiliyədavamlı jilet
                [10] = { d = 12, t = 0 },   -- "196 YS" emblemi
                [11] = { d = 59, t = 0 },
            },
            prop = {
                [0] = { d = 42, t = 0 },    -- yanğın kaskası
            },
            armor = 50,
        },
        {
            label = '196 Yanğınsöndürən — Briqadir',
            grade = 2,
            component = {
                [3]  = { d = 34, t = 0 },
                [4]  = { d = 37, t = 1 },
                [6]  = { d = 28, t = 1 },
                [8]  = { d = 16, t = 1 },
                [9]  = { d = 21, t = 1 },
                [10] = { d = 12, t = 1 },
                [11] = { d = 59, t = 1 },
            },
            prop = {
                [0] = { d = 42, t = 1 },
            },
            armor = 75,
        },
    },
}

-- Növbədən çıxanda bərpa olunacaq mülki geyim üçün xəbərdarlıq
Config.Messages = {
    noJob = 'Bu geyim otağı yalnız %s əməkdaşları üçündür!',
    noGrade = 'Bu forma üçün rütbəniz kifayət etmir!',
    dressed = '196 forması geyinildi: %s',
    civilian = 'Mülki geyimə keçdiniz.',
}
