-- 196 RP | Bakı xəritəsi qatı
-- 12 metro stansiyası, rayonlar, xətlər və bütün resursların rayon təyinatı.
--
-- VACİQ QEYD (müəllif hüquqları):
--   Real brend adları/loqoları istifadə olunmur. Mağaza və məhsul adları parodiyadır.
--   Metro stansiyası adları coğrafi adlardır (ticarət nişanı deyil).
--
-- VACİQ QEYD (xəritə modu):
--   Bu resurs hazırkı GTA V dünyasında Bakı adlandırma/rayon/metro qatını qurur.
--   Real Bakı 3D binaları (MLO/ymap modu) quraşdırılarsa, yalnız aşağıdakı
--   Config.CustomCoords cədvəlini doldurub Config.UseCustomMap = true etmək
--   kifayətdir — bütün resurslar eyni adlardan istifadə edir.

Config = {}

Config.UseCustomMap = false   -- real Bakı MLO quraşdırılanda true edin

-- Hər stansiya üçün real Bakı koordinatı (MLO ilə birlikdə doldurulur)
Config.CustomCoords = {
    -- ['28may'] = vector3(0.0, 0.0, 0.0),
}

-- ==================== METRO STANSİYALARI ====================
-- line: 1 = Qırmızı xətt, 2 = Yaşıl xətt, 3 = Bənövşəyi xətt
-- coords: hazırkı dünyadakı dayaq nöqtəsi (UseCustomMap=false olduqda işləyir)

Config.Stations = {
    {
        id = 'iceriseher', name = 'İçərişəhər', line = 1, order = 1, city = 'Bakı',
        coords = vector3(-1850.0, -1231.0, 9.0),
        desc = 'Tarixi mərkəz, sahil, turizm zonası',
    },
    {
        id = 'sahil', name = 'Sahil', line = 1, order = 2, city = 'Bakı',
        coords = vector3(-1240.0, -1490.0, 4.0),
        desc = 'Dənizkənarı bulvar, çimərlik və kafelər',
    },
    {
        id = '28may', name = '28 May', line = 1, order = 3, city = 'Bakı',
        coords = vector3(-265.0, -957.0, 31.0),
        desc = 'Əsas nəqliyyat qovşağı, şəhər mərkəzi',
    },
    {
        id = 'genclik', name = 'Gənclik', line = 1, order = 4, city = 'Bakı',
        coords = vector3(-544.0, -204.0, 38.0),
        desc = 'Ticarət mərkəzləri, mağazalar, restoranlar',
    },
    {
        id = 'neriman', name = 'Nəriman Nərimanov', line = 1, order = 5, city = 'Bakı',
        coords = vector3(150.0, -180.0, 55.0),
        desc = 'Yaşayış və iş məhəlləsi',
    },
    {
        id = 'koroglu', name = 'Koroğlu', line = 1, order = 6, city = 'Bakı',
        coords = vector3(1140.0, -980.0, 46.0),
        desc = 'Nəqliyyat qovşağı, sənaye zonası',
    },
    {
        id = 'qaraqarayev', name = 'Qara Qarayev', line = 1, order = 7, city = 'Bakı',
        coords = vector3(1900.0, 3720.0, 32.0),
        desc = 'Şərq yaşayış massivi',
    },
    {
        id = 'xetai', name = 'Xətai', line = 2, order = 1, city = 'Bakı',
        coords = vector3(240.0, -1720.0, 29.0),
        desc = 'Cənub yaşayış rayonu',
    },
    {
        id = 'agseher', name = 'Ağ şəhər', line = 2, order = 2, city = 'Bakı',
        coords = vector3(-450.0, -2960.0, 6.0),
        desc = 'Yeni işgüzar məhəllə, liman zonası',
    },
    {
        id = 'dernegul', name = 'Dərnəgül', line = 2, order = 3, city = 'Bakı',
        coords = vector3(1150.0, -700.0, 57.0),
        desc = 'Şimal yaşayış massivi',
    },
    {
        id = '20yanvar', name = '20 Yanvar', line = 3, order = 1, city = 'Bakı',
        coords = vector3(-880.0, -190.0, 40.0),
        desc = 'Qərb qovşağı, universitet şəhərciyi',
    },
    {
        id = 'elmler', name = 'Elmlər Akademiyası', line = 3, order = 2, city = 'Bakı',
        coords = vector3(-680.0, -880.0, 23.0),
        desc = 'Elm və təhsil mərkəzi',
    },

    -- ============ RESPUBLİKA ŞƏHƏR VƏ RAYONLARI (24) ============
    -- line = 0 → Bakı metrosuna aid deyil, regional mərkəzdir.
    -- Koordinatlar hazırkı dünyadakı real quru dayaq nöqtələridir
    -- (mövcud konfiqlərdən seçilib). Real Azərbaycan xəritə modu
    -- quraşdırılanda Config.CustomCoords ilə əvəz olunur.

    {
        id = 'lenkeran', name = 'Lənkəran', line = 0, order = 0, city = 'Lənkəran',
        coords = vector3(-1990.0, -3370.0, 5.0),
        desc = 'Cənub bölgəsi — çay plantasiyaları və sitrus bağları',
    },
    {
        id = 'astara', name = 'Astara', line = 0, order = 0, city = 'Astara',
        coords = vector3(1050.0, -3100.0, 5.9),
        desc = 'Dənizkənarı cənub şəhəri, balıqçılıq',
    },
    {
        id = 'salyan', name = 'Salyan', line = 0, order = 0, city = 'Salyan',
        coords = vector3(-1850.0, -2800.0, 14.0),
        desc = 'Çay sahili, kənd təsərrüfatı mərkəzi',
    },
    {
        id = 'sirvan', name = 'Şirvan', line = 0, order = 0, city = 'Şirvan',
        coords = vector3(1000.0, -2300.0, 30.0),
        desc = 'Sənaye şəhəri, energetika',
    },
    {
        id = 'sumqayit', name = 'Sumqayıt', line = 0, order = 0, city = 'Sumqayıt',
        coords = vector3(-2096.9, -320.4, 13.2),
        desc = 'İri sənaye şəhəri, kimya və metallurgiya',
    },
    {
        id = 'naxcivan', name = 'Naxçıvan', line = 0, order = 0, city = 'Naxçıvan',
        coords = vector3(2580.5, 362.1, 108.5),
        desc = 'Dağlıq bölgə mərkəzi, tarixi abidələr',
    },
    {
        id = 'imisli', name = 'İmişli', line = 0, order = 0, city = 'İmişli',
        coords = vector3(-2961.2, 482.6, 15.7),
        desc = 'Aqrar rayon, pambıq və taxıl',
    },
    {
        id = 'xirdalan', name = 'Xırdalan', line = 0, order = 0, city = 'Xırdalan',
        coords = vector3(-3241.9, 1001.2, 12.8),
        desc = 'Paytaxta bitişik yaşayış şəhəri',
    },
    {
        id = 'culfa', name = 'Culfa', line = 0, order = 0, city = 'Culfa',
        coords = vector3(1300.0, 1100.0, 100.0),
        desc = 'Dağ keçidi, dəmir yolu qovşağı',
    },
    {
        id = 'ordubad', name = 'Ordubad', line = 0, order = 0, city = 'Ordubad',
        coords = vector3(2700.0, 1500.0, 24.0),
        desc = 'Bağlar diyarı, karvan yolu məntəqəsi',
    },
    {
        id = 'gedebeq', name = 'Gədəbəy', line = 0, order = 0, city = 'Gədəbəy',
        coords = vector3(-590.0, 2090.0, 130.0),
        desc = 'Mədənlər diyarı, dağ iqlimi',
    },
    {
        id = 'tovuz', name = 'Tovuz', line = 0, order = 0, city = 'Tovuz',
        coords = vector3(-2555.3, 2334.4, 33.1),
        desc = 'Qərb qapısı, üzümçülük',
    },
    {
        id = 'qazax', name = 'Qazax', line = 0, order = 0, city = 'Qazax',
        coords = vector3(1845.0, 2585.0, 45.7),
        desc = 'Qərb şəhəri, aqrar rayon',
    },
    {
        id = 'gence', name = 'Gəncə', line = 0, order = 0, city = 'Gəncə',
        coords = vector3(549.2, 2669.2, 42.2),
        desc = 'İkinci böyük şəhər, elm və mədəniyyət',
    },
    {
        id = 'goygol', name = 'Göygöl', line = 0, order = 0, city = 'Göygöl',
        coords = vector3(1175.1, 2706.4, 38.1),
        desc = 'Göl və meşə zonası, turizm',
    },
    {
        id = 'naftalan', name = 'Naftalan', line = 0, order = 0, city = 'Naftalan',
        coords = vector3(-1096.5, 2708.8, 19.1),
        desc = 'Müalicəvi neft kurortu',
    },
    {
        id = 'berde', name = 'Bərdə', line = 0, order = 0, city = 'Bərdə',
        coords = vector3(-1870.0, 2945.0, 42.0),
        desc = 'Qədim şəhər, ticarət mərkəzi',
    },
    {
        id = 'mingecevir', name = 'Mingəçevir', line = 0, order = 0, city = 'Mingəçevir',
        coords = vector3(400.0, 3590.0, 35.0),
        desc = 'Su anbarı və energetika şəhəri',
    },
    {
        id = 'sahdag', name = 'Şahdağ', line = 0, order = 0, city = 'Şahdağ',
        coords = vector3(-450.0, 4500.0, 300.0),
        desc = 'Dağ-xizək kurortu, qış turizmi',
    },
    {
        id = 'agdas', name = 'Ağdaş', line = 0, order = 0, city = 'Ağdaş',
        coords = vector3(2450.0, 4970.0, 46.0),
        desc = 'Mərkəzi rayon, ipəkçilik',
    },
    {
        id = 'seki', name = 'Şəki', line = 0, order = 0, city = 'Şəki',
        coords = vector3(-530.0, 5380.0, 70.0),
        desc = 'Tarixi şəhər, karvansara və sənətkarlıq',
    },
    {
        id = 'qebele', name = 'Qəbələ', line = 0, order = 0, city = 'Qəbələ',
        coords = vector3(450.0, 5400.0, 150.0),
        desc = 'Turizm mərkəzi, dağ otelləri',
    },
    {
        id = 'zaqatala', name = 'Zaqatala', line = 0, order = 0, city = 'Zaqatala',
        coords = vector3(-447.0, 6014.0, 31.7),
        desc = 'Fındıq bağları, təbiət qoruğu',
    },
    {
        id = 'quba', name = 'Quba', line = 0, order = 0, city = 'Quba',
        coords = vector3(145.0, 6360.0, 31.3),
        desc = 'Şimal bölgəsi, alma bağları və xalçaçılıq',
    },}

-- ==================== ŞƏHƏRLƏR ====================
-- Xəritə UI-da qruplaşdırma üçün

Config.Cities = {
    { id = 'baki', name = 'Bakı', metro = true, desc = 'Paytaxt — 12 metro stansiyası, 3 xətt' },
    { id = 'sumqayit', name = 'Sumqayıt', metro = false, desc = 'İri sənaye şəhəri' },
    { id = 'gence', name = 'Gəncə', metro = false, desc = 'İkinci böyük şəhər' },
    { id = 'mingecevir', name = 'Mingəçevir', metro = false, desc = 'Energetika şəhəri' },
    { id = 'naxcivan', name = 'Naxçıvan', metro = false, desc = 'Dağlıq bölgə mərkəzi' },
    { id = 'seki', name = 'Şəki', metro = false, desc = 'Tarixi şəhər' },
    { id = 'lenkeran', name = 'Lənkəran', metro = false, desc = 'Cənub bölgəsi' },
}

-- Xətlərin adları və rəngləri
Config.Lines = {
    [1] = { name = 'Qırmızı xətt', colour = 1 },   -- İçərişəhər → Qara Qarayev
    [2] = { name = 'Yaşıl xətt', colour = 3 },     -- Xətai → Ağ şəhər → Dərnəgül
    [3] = { name = 'Bənövşəyi xətt', colour = 7 }, -- 20 Yanvar → Elmlər Akademiyası
}

-- ==================== RAYONLAR ====================
-- Hər stansiya ətrafındakı ərazi bu rayon sayılır (metr ilə radius)

Config.DistrictRadius = 700.0
Config.NotifyOnDistrictChange = true

-- ==================== BLİP / PERFORMANS ====================

Config.Blip = {
    sprite = 167,          -- metro simvolu
    scale = 0.85,
    shortRange = true,     -- YALNIZ yaxınlaşanda görünür (FPS üçün vacib)
}

Config.Perf = {
    markerDrawDistance = 40.0,   -- bu məsafədən uzaqda marker çəkilmir
    lineDrawDistance = 150.0,    -- metro xətləri yalnız bu məsafədə çəkilir
    idleWait = 1000,             -- uzaqda olarkən gözləmə (ms)
    nearWait = 0,                -- yaxında olarkən
    maxStations = 12,
}

-- ==================== KÖMƏKÇİ FUNKSİYALAR (shared) ====================

Baku = {}

--Stansiya obyektini ada görə qaytarır
function Baku.GetStation(idOrName)
    for i = 1, #Config.Stations do
        local s = Config.Stations[i]
        if s.id == idOrName or s.name == idOrName then
            return s
        end
    end
    return nil
end

-- Aktiv koordinat mənbəyi (hazırkı dünya və ya real Bakı MLO)
function Baku.Coords(stationId)
    if Config.UseCustomMap and Config.CustomCoords[stationId] then
        return Config.CustomCoords[stationId]
    end

    local s = Baku.GetStation(stationId)
    return s and s.coords or vector3(0.0, 0.0, 0.0)
end

-- Verilmiş koordinata ən yaxın stansiya
function Baku.Nearest(coords)
    local best, bestDist = nil, math.huge

    for i = 1, #Config.Stations do
        local s = Config.Stations[i]
        local d = #(coords - Baku.Coords(s.id))

        if d < bestDist then
            best, bestDist = s, d
        end
    end

    return best, bestDist
end

-- Verilmiş koordinatın rayonu (radius daxilində)
function Baku.District(coords)
    local station, dist = Baku.Nearest(coords)

    if not station then
        return nil
    end

    if dist <= Config.DistrictRadius then
        return station
    end

    -- Kənar ərazilər ən yaxın stansiyaya bağlanır, amma "kənar" kimi qeyd olunur
    return station
end

-- Xətt üzrə stansiyalar (sıralanmış)
function Baku.LineStations(lineId)
    local list = {}

    for i = 1, #Config.Stations do
        local s = Config.Stations[i]
        if s.line == lineId then
            list[#list + 1] = s
        end
    end

    table.sort(list, function(a, b) return a.order < b.order end)

    return list
end
