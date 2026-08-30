Config = {}

-- Standart vergi dərəcəsi (faiz)
Config.TaxRate = 5.0

-- Vergiyə cəlb olunanlar
Config.ApplyTo = {
    DealerSales = true,   -- avtosalon alışları
    CasinoWins = true,    -- kazino uduşları
    Billing = true,       -- faktura ödənişləri
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
