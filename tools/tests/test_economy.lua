-- 196rp_economy / config.lua unit testləri

test('vergi dərəcələri 0-1 arasındadır', function()
    for name, rate in pairs(Config.Tax) do
        assertTrue(rate > 0 and rate < 1, 'vergi ' .. name .. ': ' .. tostring(rate))
    end
end)

test('bütün money sink-lər müsbətdir', function()
    local count = 0

    for name, amount in pairs(Config.Sinks) do
        assertTrue(type(amount) == 'number' and amount > 0, 'sink ' .. name)
        count = count + 1
    end

    assertTrue(count >= 6, 'sink sayı azdır: ' .. count)
end)

test('index limitləri məntiqlidir (min < base < max)', function()
    assertTrue(Config.MinIndex < Config.BaseIndex, 'min < base')
    assertTrue(Config.BaseIndex < Config.MaxIndex, 'base < max')
end)

test('Price: baza index-də qiymət dəyişmir', function()
    assertEq(Economy.Price(100, 100.0), 100, 'sabit qiymət')
    assertEq(Economy.Price(1234, 100.0), 1234, 'sabit qiymət 2')
end)

test('Price: index artdıqca qiymət artır', function()
    assertEq(Economy.Price(100, 130.0), 130, '+30%')
    assertEq(Economy.Price(100, 75.0), 75, '-25%')
    assertTrue(Economy.Price(500, 110.0) > 500, 'artım')
end)

test('Price: limitdən kənar index sıxılır', function()
    assertEq(Economy.Price(100, 999.0), Economy.Price(100, Config.MaxIndex), 'yuxarı sıxılma')
    assertEq(Economy.Price(100, -50.0), Economy.Price(100, Config.MinIndex), 'aşağı sıxılma')
end)

test('Price: mənfi/0 baza qiymət 0 qaytarır', function()
    assertEq(Economy.Price(0, 100.0), 0, 'sıfır')
    assertEq(Economy.Price(-50, 100.0), 0, 'mənfi')
end)

test('WithTax: 5% ƏDV əlavə olunur', function()
    assertEq(Economy.WithTax(100), 105, '100 → 105')
    assertEq(Economy.WithTax(1000), 1050, '1000 → 1050')
    assertEq(Economy.WithTax(0), 0, 'sıfır')
end)

test('AfterTax: 10% gəlir vergisi tutulur', function()
    assertEq(Economy.AfterTax(1000), 900, '1000 → 900')
    assertEq(Economy.AfterTax(100), 90, '100 → 90')
    assertTrue(Economy.AfterTax(1000) < 1000, 'vergi tutulmalıdır')
end)

test('TransferFee: 1% köçürmə haqqı', function()
    assertEq(Economy.TransferFee(1000), 10, '1000 → 10')
    assertEq(Economy.TransferFee(0), 0, 'sıfır')
end)

test('NextIndex: alış index-i artırır amma limiti keçmir', function()
    local i = 100.0
    i = Economy.NextIndex(i, 10000)
    assertTrue(i > 100.0, 'artım olmalıdır: ' .. i)

    -- çox böyük alış limiti keçməməlidir
    local big = Economy.NextIndex(100.0, 100000000)
    assertEq(big, Config.MaxIndex, 'limit')
end)

test('NextIndex: kiçik alış index-ə təsir etmir', function()
    assertEq(Economy.NextIndex(100.0, 10), 100.0, 'kiçik məbləğ')
end)

test('Decay: index baza səviyyəyə qayıdır', function()
    local high = Economy.Decay(130.0, 100)
    assertEq(high, Config.BaseIndex, 'yuxarıdan qayıdış')

    local low = Economy.Decay(75.0, 100)
    assertEq(low, Config.BaseIndex, 'aşağıdan qayıdış')

    local partial = Economy.Decay(130.0, 1)
    assertTrue(partial < 130.0 and partial > Config.BaseIndex, 'qismən qayıdış: ' .. partial)
end)

test('ValidAmount: mənfi və sıfır rədd edilir', function()
    local ok1 = Economy.ValidAmount(-100)
    assertFalse(ok1, 'mənfi qəbul edilməməlidir')

    local ok2 = Economy.ValidAmount(0)
    assertFalse(ok2, 'sıfır qəbul edilməməlidir')
end)

test('ValidAmount: limitdən yuxarı məbləğ rədd edilir', function()
    local ok = Economy.ValidAmount(Config.DupeGuard.maxAmountPerTransfer + 1)
    assertFalse(ok, 'limit aşımı qəbul edilməməlidir')
end)

test('ValidAmount: düzgün məbləğ qəbul edilir', function()
    local ok = Economy.ValidAmount(1000)
    assertTrue(ok, '1000 qəbul edilməlidir')
end)

test('ValidAmount: rəqəm olmayan dəyər rədd edilir', function()
    assertFalse(Economy.ValidAmount('1000'), 'sətir qəbul edilməməlidir')
    assertFalse(Economy.ValidAmount(nil), 'nil qəbul edilməməlidir')
end)

test('DupeGuard parametrləri doludur', function()
    assertTrue(Config.DupeGuard.maxTransfersPerMinute > 0, 'dəqiqəlik limit')
    assertTrue(Config.DupeGuard.maxDailyTotal >= Config.DupeGuard.maxAmountPerTransfer,
        'gündəlik limit tək köçürmədən kiçik ola bilməz')
    assertEq(Config.DupeGuard.blockSelf, true, 'özünə köçürmə qadağası')
end)

test('Xəzinə limitləri məntiqlidir', function()
    assertTrue(Config.Treasury.startBalance > 0, 'başlanğıc')
    assertTrue(Config.Treasury.maxBalance > Config.Treasury.startBalance, 'max > start')
end)

test('İnflyasiya ssenarisi: 1 milyon alış index-i maksimuma çatdırır', function()
    local i = Config.BaseIndex

    for _ = 1, 50 do
        i = Economy.NextIndex(i, 100000)
    end

    assertEq(i, Config.MaxIndex, 'maksimuma çatmalıdır')
    -- amma heç vaxt limiti keçmir
    assertTrue(i <= Config.MaxIndex, 'limit pozuldu')
end)
