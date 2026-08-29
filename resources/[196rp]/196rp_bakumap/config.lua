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
        id = 'iceriseher', name = 'İçərişəhər', line = 1, order = 1,
        coords = vector3(-1850.0, -1231.0, 9.0),
        desc = 'Tarixi mərkəz, sahil, turizm zonası',
    },
    {
        id = 'sahil', name = 'Sahil', line = 1, order = 2,
        coords = vector3(-1240.0, -1490.0, 4.0),
        desc = 'Dənizkənarı bulvar, çimərlik və kafelər',
    },
    {
        id = '28may', name = '28 May', line = 1, order = 3,
        coords = vector3(-265.0, -957.0, 31.0),
        desc = 'Əsas nəqliyyat qovşağı, şəhər mərkəzi',
    },
    {
        id = 'genclik', name = 'Gənclik', line = 1, order = 4,
        coords = vector3(-544.0, -204.0, 38.0),
        desc = 'Ticarət mərkəzləri, mağazalar, restoranlar',
    },
    {
        id = 'neriman', name = 'Nəriman Nərimanov', line = 1, order = 5,
        coords = vector3(150.0, -180.0, 55.0),
        desc = 'Yaşayış və iş məhəlləsi',
    },
    {
        id = 'koroglu', name = 'Koroğlu', line = 1, order = 6,
        coords = vector3(1140.0, -980.0, 46.0),
        desc = 'Nəqliyyat qovşağı, sənaye zonası',
    },
    {
        id = 'qaraqarayev', name = 'Qara Qarayev', line = 1, order = 7,
        coords = vector3(1900.0, 3720.0, 32.0),
        desc = 'Şərq yaşayış massivi',
    },
    {
        id = 'xetai', name = 'Xətai', line = 2, order = 1,
        coords = vector3(240.0, -1720.0, 29.0),
        desc = 'Cənub yaşayış rayonu',
    },
    {
        id = 'agseher', name = 'Ağ şəhər', line = 2, order = 2,
        coords = vector3(-450.0, -2960.0, 6.0),
        desc = 'Yeni işgüzar məhəllə, liman zonası',
    },
    {
        id = 'dernegul', name = 'Dərnəgül', line = 2, order = 3,
        coords = vector3(1150.0, -700.0, 57.0),
        desc = 'Şimal yaşayış massivi',
    },
    {
        id = '20yanvar', name = '20 Yanvar', line = 3, order = 1,
        coords = vector3(-880.0, -190.0, 40.0),
        desc = 'Qərb qovşağı, universitet şəhərciyi',
    },
    {
        id = 'elmler', name = 'Elmlər Akademiyası', line = 3, order = 2,
        coords = vector3(-680.0, -880.0, 23.0),
        desc = 'Elm və təhsil mərkəzi',
    },
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
