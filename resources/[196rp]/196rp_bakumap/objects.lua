-- 196 RP | Bakı xəritəsi — 3D obyekt qatı (shared config)
--
-- Bütün model adları GTA V-nin RƏSMİ obyekt siyahısından götürülüb və yoxlanılıb
-- (DurtyFree/gta-v-data-dumps → ObjectList.ini, 21 631 ad).
-- Heç bir real brend loqosu istifadə olunmur.
--
-- PERFORMANS QAYDALARI (kasma olmaması üçün):
--   1. Yalnız SpawnDistance daxilindəki obyektlər mövcuddur (adətən 12-24 ədəd)
--   2. DespawnDistance-dən kənarda olanlar silinir → yaddaş artmır
--   3. Obyektlər LOKAL yaradılır (isNetwork = false) → şəbəkə trafiki 0
--   4. Hamısı statikdir (FreezeEntityPosition) → fizika hesablanması yoxdur
--   5. Model sorğuları keşlənir, hər model bir dəfə yüklənir

Config.Objects = {}

Config.Objects.Enabled = true
Config.Objects.GroundSnap = true          -- obyektləri yerə oturdur
Config.Objects.SpawnDistance = 120.0      -- bu məsafəyə qədər spawn olunur
Config.Objects.DespawnDistance = 180.0    -- bu məsafədən sonra silinir
Config.Objects.MaxObjects = 150           -- sərt limit (yaddaş zəmanəti)
Config.Objects.TickMs = 1500              -- yoxlama aralığı

-- ==================== HƏR STANSİYANIN GİRİŞ KOMPLEKTİ ====================
-- dx/dy = stansiya mərkəzindən dünya koordinatı ilə sürüşmə
-- z     = stansiya z-inə əlavə (mənfi = yerə basdırılır)

Config.Objects.StationLayout = {
    { id = 'kiosk',    model = 'prop_busstop_02',            dx =  0.0, dy =  0.0, z = -1.0, heading = 0.0 },
    { id = 'ekran',    model = 'v_serv_metro_infoscreen1',   dx =  0.0, dy =  2.4, z = -0.2, heading = 180.0 },
    { id = 'skamya1',  model = 'prop_bench_01a',             dx =  3.0, dy =  3.2, z = -0.9, heading = 90.0 },
    { id = 'skamya2',  model = 'prop_bench_01a',             dx = -3.0, dy =  3.2, z = -0.9, heading = 90.0 },
    { id = 'direk1',   model = 'prop_flagpole_2a',           dx =  5.5, dy = -1.5, z = -1.0, heading = 0.0 },
    { id = 'direk2',   model = 'prop_flagpole_2a',           dx = -5.5, dy = -1.5, z = -1.0, heading = 0.0 },
    { id = 'isıq1',    model = 'prop_streetlight_01',        dx =  8.0, dy =  1.5, z = -1.0, heading = 0.0 },
    { id = 'isıq2',    model = 'prop_streetlight_01',        dx = -8.0, dy =  1.5, z = -1.0, heading = 0.0 },
    { id = 'qutu1',    model = 'prop_bin_01a',               dx =  3.4, dy =  0.6, z = -0.9, heading = 0.0 },
    { id = 'qutu2',    model = 'prop_bin_01a',               dx = -3.4, dy =  0.6, z = -0.9, heading = 0.0 },
    { id = 'mane1',    model = 'prop_barrier_work01a',       dx =  6.0, dy =  4.5, z = -0.9, heading = 0.0 },
    { id = 'mane2',    model = 'prop_barrier_work01a',       dx = -6.0, dy =  4.5, z = -0.9, heading = 0.0 },
}

-- ==================== RAYONLARA GÖRƏ XÜSUSİ TİKİLİLƏR ====================
-- station = stansiya id-si (bax: config.lua → Config.Stations)

Config.Objects.Extras = {
    -- Ağ şəhər: yeni tikinti zonası (kranlar + konteynerlər)
    { id = 'ag_kran1',  station = 'agseher',     model = 'prop_towercrane_01a', dx =  25.0, dy = -18.0, z = 0.0, heading = 45.0 },
    { id = 'ag_kran2',  station = 'agseher',     model = 'prop_towercrane_01a', dx = -30.0, dy =  12.0, z = 0.0, heading = 200.0 },
    { id = 'ag_kont1',  station = 'agseher',     model = 'prop_container_01a',  dx =  12.0, dy =   8.0, z = -1.0, heading = 30.0 },
    { id = 'ag_kont2',  station = 'agseher',     model = 'prop_container_01a',  dx =  17.0, dy =   6.0, z = -1.0, heading = 30.0 },
    { id = 'ag_kont3',  station = 'agseher',     model = 'prop_container_01b',  dx =  14.5, dy =  12.0, z = -1.0, heading = 120.0 },

    -- Qara Qarayev: yaşayış massivi + su qülləsi
    { id = 'qq_su',     station = 'qaraqarayev', model = 'prop_watertower01',   dx = -20.0, dy = -14.0, z = 0.0, heading = 0.0 },
    { id = 'qq_kont1',  station = 'qaraqarayev', model = 'prop_container_01b',  dx =  15.0, dy =  10.0, z = -1.0, heading = 90.0 },
    { id = 'qq_kont2',  station = 'qaraqarayev', model = 'prop_container_01c',  dx =  20.0, dy =   8.0, z = -1.0, heading = 90.0 },

    -- 28 May: mərkəzi tağ
    { id = 'may_tag',   station = '28may',       model = 'sum_prop_archway_01', dx =   0.0, dy = -14.0, z = -1.0, heading = 0.0 },

    -- İçərişəhər: tarixi giriş qülləsi
    { id = 'ic_qulle',  station = 'iceriseher',  model = 'prop_guard_tower_glass', dx = 10.0, dy = -8.0, z = -1.0, heading = 0.0 },
}

-- Cəmi obyektlər: 12 stansiya × 12 = 144 + 11 xüsusi = 155
-- Eyni anda mövcud olan: yalnız 120 m daxilindəkilər (adətən 12-24)
