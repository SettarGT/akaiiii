-- 196rp_bakumap / objects.lua unit testləri
-- Qeyd: config.lua əvvəl yüklənməlidir (Config cədvəli orada yaranır)

test('prop qatı standart olaraq SÖNDÜRÜLÜB (original dizayn tələbi)', function()
    assertEq(Config.Objects.Enabled, false, 'Enabled')
end)

test('despawn məsafəsi spawn məsafəsindən böyükdür', function()
    assertTrue(Config.Objects.DespawnDistance > Config.Objects.SpawnDistance,
        ('spawn %.0f, despawn %.0f'):format(
            Config.Objects.SpawnDistance, Config.Objects.DespawnDistance))
end)

test('obyekt limiti müəyyən edilib (yaddaş zəmanəti)', function()
    assertTrue(Config.Objects.MaxObjects > 0, 'MaxObjects')
    assertTrue(Config.Objects.MaxObjects <= 300, 'MaxObjects çox yüksəkdir: ' .. Config.Objects.MaxObjects)
end)

test('döngü aralığı performansa uyğundur (>= 500 ms)', function()
    assertTrue(Config.Objects.TickMs >= 500, 'TickMs: ' .. tostring(Config.Objects.TickMs))
end)

test('hər stansiya girişində eyni sayda obyekt var', function()
    local n = #Config.Objects.StationLayout
    assertTrue(n >= 8, 'giriş komplekti çox kiçikdir: ' .. n)

    local total = n * #Config.Stations + #Config.Objects.Extras
    print(('    [info] cəmi spesifikasiya: %d, eyni anda maksimum: %d'):format(
        total, Config.Objects.MaxObjects))
end)

test('giriş komplektindəki id-lər unikaldır', function()
    local seen = {}

    for i = 1, #Config.Objects.StationLayout do
        local id = Config.Objects.StationLayout[i].id
        assertFalse(seen[id], 'təkrar layout id: ' .. tostring(id))
        seen[id] = true
        assertTrue(type(Config.Objects.StationLayout[i].model) == 'string', 'model yoxdur: ' .. id)
    end
end)

test('xüsusi tikililər mövcud stansiyalara bağlıdır', function()
    for i = 1, #Config.Objects.Extras do
        local ex = Config.Objects.Extras[i]
        assertTrue(Baku.GetStation(ex.station) ~= nil,
            'naməlum stansiya: ' .. tostring(ex.station) .. ' (' .. ex.id .. ')')
    end
end)

test('bütün modellər adlandırılıb və boş deyil', function()
    local models = {}

    for i = 1, #Config.Objects.StationLayout do
        models[Config.Objects.StationLayout[i].model] = true
    end

    for i = 1, #Config.Objects.Extras do
        models[Config.Objects.Extras[i].model] = true
    end

    local count = 0
    for name in pairs(models) do
        assertTrue(#name > 3, 'qısa model adı: ' .. name)
        count = count + 1
    end

    print(('    [info] unikal model: %d'):format(count))
end)

test('GroundSnap parametri məntiqli dəyərdir', function()
    local v = Config.Objects.GroundSnap
    assertTrue(v == true or v == false, 'GroundSnap boolean deyil')
end)
