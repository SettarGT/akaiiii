-- 196 RP | İqtisadiyyat mərkəzi
-- Məqsəd: inflyasiyanın qarşısını almaq, pulun dövriyyəsini bağlamaq,
-- əşya/pul kopyalamağa (dupe) qarşı qorunma.
--
-- Bütün riyazi funksiyalar BURADADIR (shared) ki, unit testlərlə yoxlanılsın:
--   python3 tools/tests/run_tests.py

Config = {}

-- ==================== QİYMƏT İNDEKSİ ====================
-- 100 = sabit qiymət. Bazar çox pul udanda index düşür (deflyasiya təzyiqi),
-- pul çox buraxılanda qalxır. Limitlər inflyasiyanın qaçmasının qarşısını alır.

Config.BaseIndex = 100.0
Config.MinIndex = 75.0        -- qiymətlər ən çox 25% ucuzlaşa bilər
Config.MaxIndex = 130.0       -- qiymətlər ən çox 30% bahalaşa bilər

-- Hər alış-veriş index-i bir az dəyişir (tələb-təklif simulyasiyası)
Config.Dynamic = {
    enabled = true,
    perPurchase = 0.0015,     -- alınan hər 1 ₼ üçün index artımı
    decayPerHour = 0.35,      -- saatda baza səviyyəyə qayıtma
    minAmount = 50,           -- bu məbləğdən aşağı alışlar index-ə təsir etmir
}

-- ==================== VERGİLƏR (money sink) ====================

Config.Tax = {
    income = 0.10,   -- maaş/gəlir vergisi (dövlətə gedir)
    sales = 0.05,    -- mağaza alışlarında ƏDV
    property = 0.02, -- ev kirayəsi əlavəsi
    transfer = 0.01, -- oyunçular arası pul köçürməsi
}

-- ==================== PUL UDUMLARI (money sinks) ====================
-- Pulun sistemdən çıxış yolları. Bunlar olmadan iqtisadiyyat şişir.

Config.Sinks = {
    rent = 250,             -- gündəlik ev kirayəsi
    license = 500,          -- lisenziya rüsumu
    impound = 750,          -- cərimə meydançasından çıxarma
    hospital = 400,         -- xəstəxana xidməti
    repair = 300,           -- təmir
    fuel = 120,             -- yanacaq (ortalama)
    respawn = 150,          -- nəqliyyat bərpası
    fine = 200,             -- orta cərimə
}

-- ==================== DUPE QORUNMASI ====================

Config.DupeGuard = {
    enabled = true,
    maxTransfersPerMinute = 5,       -- bir oyunçu dəqiqədə ən çox neçə köçürmə edə bilər
    maxAmountPerTransfer = 50000,    -- tək köçürmə limiti
    maxDailyTotal = 500000,          -- gündəlik ümumi köçürmə limiti
    blockSelf = true,                -- özünə köçürmə qadağandır
    blockNegative = true,            -- mənfi məbləğ qadağandır
    logAll = true,                   -- bütün köçürmələr bazaya yazılır
    alertAdminOnBreach = true,       -- limit pozulanda adminə xəbər
}

-- ==================== DÖVLƏT XƏZİNƏSİ ====================

Config.Treasury = {
    startBalance = 2000000,   -- başlanğıc dövlət büdcəsi
    maxBalance = 50000000,    -- yuxarı limit (sonsuz artımın qarşısı)
}

-- ==================== RİYAZİ FUNKSİYALAR (unit test olunur) ====================

Economy = {}

-- İndeksi icazə verilən aralığa sıxır
function Economy.ClampIndex(index)
    if type(index) ~= 'number' then
        return Config.BaseIndex
    end

    if index < Config.MinIndex then
        return Config.MinIndex
    end

    if index > Config.MaxIndex then
        return Config.MaxIndex
    end

    return index
end

-- Baza qiyməti cari index-ə görə hesablayır (yuxarı yuvarlaqlaşdırma)
function Economy.Price(basePrice, index)
    basePrice = tonumber(basePrice) or 0
    index = Economy.ClampIndex(index or Config.BaseIndex)

    if basePrice <= 0 then
        return 0
    end

    return math.floor((basePrice * index) / 100.0 + 0.5)
end

-- Satış vergisi ilə son qiymət
function Economy.WithTax(amount)
    amount = tonumber(amount) or 0

    if amount <= 0 then
        return 0
    end

    return math.floor(amount * (1.0 + Config.Tax.sales) + 0.5)
end

-- Vergidən sonra ələ keçən məbləğ
function Economy.AfterTax(amount)
    amount = tonumber(amount) or 0

    if amount <= 0 then
        return 0
    end

    return math.floor(amount * (1.0 - Config.Tax.income))
end

-- Köçürmə vergisi
function Economy.TransferFee(amount)
    amount = tonumber(amount) or 0

    if amount <= 0 then
        return 0
    end

    return math.floor(amount * Config.Tax.transfer + 0.5)
end

-- Yeni index dəyəri (limitlərlə)
function Economy.NextIndex(currentIndex, purchaseAmount)
    currentIndex = Economy.ClampIndex(currentIndex)

    if not Config.Dynamic.enabled then
        return Config.BaseIndex
    end

    purchaseAmount = tonumber(purchaseAmount) or 0

    if purchaseAmount < Config.Dynamic.minAmount then
        return currentIndex
    end

    return Economy.ClampIndex(currentIndex + (purchaseAmount * Config.Dynamic.perPurchase))
end

-- Saatlıq normallaşma (baza səviyyəyə qayıdış)
function Economy.Decay(currentIndex, hours)
    currentIndex = Economy.ClampIndex(currentIndex)
    hours = tonumber(hours) or 1

    local diff = Config.BaseIndex - currentIndex

    if math.abs(diff) < 0.01 then
        return Config.BaseIndex
    end

    local step = Config.Dynamic.decayPerHour * hours

    if diff > 0 then
        return Economy.ClampIndex(currentIndex + math.min(step, diff))
    end

    return Economy.ClampIndex(currentIndex - math.min(step, -diff))
end

-- Məbləğin düzgün olduğunu yoxlayır (dupe qorunmasının birinci qatı)
function Economy.ValidAmount(amount)
    if type(amount) ~= 'number' then
        return false, 'məbləğ rəqəm deyil'
    end

    if Config.DupeGuard.blockNegative and amount <= 0 then
        return false, 'məbləğ müsbət olmalıdır'
    end

    if amount > Config.DupeGuard.maxAmountPerTransfer then
        return false, 'limitdən yuxarı məbləğ'
    end

    if amount ~= amount then -- NaN yoxlaması
        return false, 'məbləğ NaN-dır'
    end

    return true
end
