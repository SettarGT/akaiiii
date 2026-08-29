-- 196rp_bakumap / config.lua unit testləri

test('36 şəhər/rayon mövcuddur', function()
    assertEq(#Config.Stations, 36, 'stansiya sayı')
end)

test('12 Bakı + 24 region', function()
    local baku, region = 0, 0

    for i = 1, #Config.Stations do
        if Config.Stations[i].city == 'Bakı' then
            baku = baku + 1
        else
            region = region + 1
        end
    end

    assertEq(baku, 12, 'Bakı stansiyası')
    assertEq(region, 24, 'region sayı')
end)

test('bütün id-lər unikaldır', function()
    local seen = {}

    for i = 1, #Config.Stations do
        local id = Config.Stations[i].id
        assertFalse(seen[id], 'təkrarlanan id: ' .. tostring(id))
        seen[id] = true
    end
end)

test('hər stansiyanın adı, şəhəri və koordinatı var', function()
    for i = 1, #Config.Stations do
        local s = Config.Stations[i]
        assertTrue(type(s.name) == 'string' and #s.name > 0, 'ad yoxdur: ' .. s.id)
        assertTrue(type(s.city) == 'string' and #s.city > 0, 'city yoxdur: ' .. s.id)
        assertTrue(type(s.coords) == 'table' and s.coords.x ~= nil, 'coords yoxdur: ' .. s.id)
    end
end)

test('GetStation id və ad ilə işləyir', function()
    assertEq(Baku.GetStation('28may').name, '28 May', 'id ilə axtarış')
    assertEq(Baku.GetStation('Gəncə').id, 'gence', 'ad ilə axtarış')
    assertEq(Baku.GetStation('yoxdur_bele'), nil, 'mövcud olmayan')
end)

test('Nearest dəqiq mərkəzi tapır', function()
    local s = Baku.Nearest(vector3(-265.0, -957.0, 31.0))
    assertEq(s.id, '28may', '28 May mərkəzi')

    local g = Baku.Nearest(vector3(549.2, 2669.2, 42.2))
    assertEq(g.id, 'gence', 'Gəncə mərkəzi')
end)

test('District radius daxilində doğru rayonu verir', function()
    -- 28 May-dan 300 m şərqdə (radius 700 m)
    local s = Baku.District(vector3(-265.0 + 300.0, -957.0, 31.0))
    assertEq(s.id, '28may', 'radius daxilində')
end)

test('LineStations sıralanmış qaytarır', function()
    local line1 = Baku.LineStations(1)
    assertEq(#line1, 7, 'Qırmızı xətt stansiyası')
    assertEq(line1[1].id, 'iceriseher', 'birinci')
    assertEq(line1[7].id, 'qaraqarayev', 'sonuncu')

    for i = 2, #line1 do
        assertTrue(line1[i].order > line1[i - 1].order, 'order ardıcıllığı pozulub')
    end
end)

test('3 xətt mövcuddur', function()
    assertEq(#Config.Lines[1].name > 0, true, 'Qırmızı xətt')
    assertEq(#Baku.LineStations(2), 3, 'Yaşıl xətt')
    assertEq(#Baku.LineStations(3), 2, 'Bənövşəyi xətt')
end)

test('Region stansiyaları line = 0 (metroya aid deyil)', function()
    for i = 1, #Config.Stations do
        local s = Config.Stations[i]

        if s.city ~= 'Bakı' then
            assertEq(s.line, 0, 'region line: ' .. s.id)
        end
    end
end)

test('CustomCoords real xəritə moduna keçidi təmin edir', function()
    Config.UseCustomMap = true
    Config.CustomCoords['28may'] = vector3(111.0, 222.0, 33.0)

    local c = Baku.Coords('28may')
    assertNear(c.x, 111.0, 0.001, 'custom x')
    assertNear(c.y, 222.0, 0.001, 'custom y')

    -- digər stansiyalar köhnə koordinatda qalır
    local other = Baku.Coords('gence')
    assertNear(other.x, 549.2, 0.001, 'gence dəyişməməlidir')

    Config.UseCustomMap = false
    Config.CustomCoords['28may'] = nil

    assertNear(Baku.Coords('28may').x, -265.0, 0.001, 'geri qayıdış')
end)

test('Config.Cities qruplaşdırma cədvəli doludur', function()
    assertTrue(#Config.Cities >= 7, 'şəhər siyahısı')

    local found = false
    for i = 1, #Config.Cities do
        if Config.Cities[i].id == 'baki' then
            found = true
            assertEq(Config.Cities[i].metro, true, 'Bakı metro olmalıdır')
        end
    end

    assertTrue(found, 'Bakı şəhəri siyahıda yoxdur')
end)

test('Stansiyalar bir-birindən ən azı 400 m aralıdır', function()
    for i = 1, #Config.Stations do
        for j = i + 1, #Config.Stations do
            local a = Config.Stations[i].coords
            local b = Config.Stations[j].coords
            local d = math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2)

            assertTrue(d > 400, ('%s ilə %s çox yaxındır (%.0f m)'):format(
                Config.Stations[i].id, Config.Stations[j].id, d))
        end
    end
end)
