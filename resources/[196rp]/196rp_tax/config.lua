Config = {}

-- Standart vergi dərəcəsi (faiz)
Config.TaxRate = 5.0

-- Vergiyə cəlb olunanlar
Config.ApplyTo = {
    DealerSales = true,   -- avtosalon alışları
    CasinoWins = true,    -- kazino uduşları
    Billing = true,       -- faktura ödənişləri
}

-- Gəlir vergisi (iş ödənişlərindən kəsmə, %)
Config.IncomeTax = 5.0

-- Gəlir sayılan AddMoney səbəbləri (qb-core içində tax tətbiq edilir)
Config.IncomeReasons = {
    'job-sell', 'cardealer-sell', 'sold hotdog', 'Bus job', 'trucker-salary',
    'Taxi payout', 'tow-salary', 'garbage-payslip', 'qb-vineyard:sellItems',
    'qb-diving:server:SellCorals', 'sold vehicle used lot', 'sold vehicle back',
    'recycle-sell', 'news-payslip', 'salary',
}

-- Həftəlik vergilər
Config.Weekly = {
    Enabled = true,
    VehicleTax = 250,     -- ₣ / avtomobil / həftə
    HouseTax = 500,       -- ₣ / ev / həftə
    CheckInterval = 600,  -- 10 dəqiqəlik yoxlama
    WeekSeconds = 604800, -- 7 gün
}

-- Admin əmri üçün ace
Config.AdminAce = 'command'
