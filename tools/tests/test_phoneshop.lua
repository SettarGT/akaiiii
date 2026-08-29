-- 196rp_phoneshop / config.lua unit testləri

test('20 telefon modeli var', function()
    assertEq(#Config.Phones, 20, 'model sayı')
end)

test('10 Aifon + 10 Samsan (parodiya adlar)', function()
    local aifon, samsan = 0, 0

    for i = 1, #Config.Phones do
        if Config.Phones[i].brand == 'Aifon' then
            aifon = aifon + 1
        elseif Config.Phones[i].brand == 'Samsan' then
            samsan = samsan + 1
        end
    end

    assertEq(aifon, 10, 'Aifon sayı')
    assertEq(samsan, 10, 'Samsan sayı')
end)

test('heç bir real brend adı istifadə olunmur', function()
    local banned = { 'iphone', 'samsung', 'apple', 'galaxy' }

    for i = 1, #Config.Phones do
        local p = Config.Phones[i]
        local hay = (p.brand .. ' ' .. p.name .. ' ' .. p.id):lower()

        for b = 1, #banned do
            assertTrue(not hay:find(banned[b], 1, true),
                'qadağan brend tapıldı: ' .. banned[b] .. ' → ' .. p.name)
        end
    end
end)

test('bütün model id-ləri unikaldır', function()
    local seen = {}

    for i = 1, #Config.Phones do
        local id = Config.Phones[i].id
        assertFalse(seen[id], 'təkrar id: ' .. tostring(id))
        seen[id] = true
    end
end)

test('qiymətlər məntiqli diapazondadır (300 - 5000)', function()
    for i = 1, #Config.Phones do
        local p = Config.Phones[i]
        assertTrue(p.price >= 300 and p.price <= 5000,
            ('%s qiyməti diapazondan kənardır: %s'):format(p.name, tostring(p.price)))
    end
end)

test('ən bahalı model ən ucuzdan ən azı 3 dəfə bahadır', function()
    local min, max = math.huge, 0

    for i = 1, #Config.Phones do
        min = math.min(min, Config.Phones[i].price)
        max = math.max(max, Config.Phones[i].price)
    end

    assertTrue(max / min >= 3, ('nisbət: %.1f'):format(max / min))
end)

test('satış faizi 0 ilə 1 arasındadır', function()
    assertTrue(Config.SellRate > 0 and Config.SellRate < 1, 'SellRate: ' .. tostring(Config.SellRate))
end)

test('satış qiyməti həmişə alışdan aşağıdır', function()
    for i = 1, #Config.Phones do
        local p = Config.Phones[i]
        local payout = math.floor(p.price * Config.SellRate)
        assertTrue(payout < p.price, p.name .. ' satışda qazanc verir')
        assertTrue(payout > 0, p.name .. ' satış qiyməti 0-dır')
    end
end)

test('3 mağaza var və hamısı fərqli rayondadır', function()
    assertEq(#Config.Shops, 3, 'mağaza sayı')

    local seen = {}
    for i = 1, #Config.Shops do
        local s = Config.Shops[i]
        assertFalse(seen[s.district], 'təkrar rayon: ' .. tostring(s.district))
        seen[s.district] = true
        assertTrue(s.coords.x ~= nil, 'koordinat yoxdur: ' .. s.id)
    end
end)

test('telefon əşyası inventar cədvəlində mövcud olan addır', function()
    assertEq(Config.PhoneItem, 'phone', 'PhoneItem')
end)

test('cooldown müsbətdir', function()
    assertTrue(Config.Cooldown > 0, 'Cooldown: ' .. tostring(Config.Cooldown))
end)

test('hər modelin yaddaşı və rəngi var', function()
    for i = 1, #Config.Phones do
        local p = Config.Phones[i]
        assertTrue(p.storage and p.storage > 0, p.name .. ' storage yoxdur')
        assertTrue(type(p.colour) == 'string' and #p.colour > 0, p.name .. ' colour yoxdur')
    end
end)
