Config = {}

-- Kazino yeri
Config.Location = { label = '196 Kazino', coords = vector3(928.64, 46.23, 81.1), heading = 100.0 }

-- Limitlər
Config.Limits = {
    MinBet = 100,        -- minimum mərc (₣)
    MaxBet = 100000,     -- maksimum mərc (₣)
    MaxProfit = 500000,  -- bir oyunda maksimum uduş (₣)
}

-- Rulet xüsusiyyətləri
Config.Roulette = {
    Numbers = 36,
    Red = { 1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36 },
}

-- Zar (50/50, cüt/tək seçimi)
Config.Dice = {
    Payout = 2.0,   -- mərc x2 (50/50)
}

-- Slot: 3 bölmə, hər bölmədə eyni şanslı simvol
Config.Slots = {
    Symbols = { '🍒', '🍋', '🔔', '⭐', '7️⃣' },
    -- Hər simvolun çəki şansı (faiz cərgəsində, cəmi 100)
    Weights = { 45, 25, 15, 10, 5 },
    -- Uduş əmsalları: [iki eyni, üç eyni]
    Payouts = { TwoSame = 1.5, ThreeSame = { ['🍒'] = 5, ['🍋'] = 8, ['🔔'] = 15, ['⭐'] = 30, ['7️⃣'] = 100 } },
}

-- Blackjack (21)
Config.Blackjack = {
    Decks = 2,
    Payout = 1.0,        -- qalib: mərc x2 (mərc + uduş)
    BlackjackPayout = 2.5, -- 2 karta 21: mərc x2.5
    DealerMin = 17,      -- dealer bu dəyərə qədər kart çəkir
}
