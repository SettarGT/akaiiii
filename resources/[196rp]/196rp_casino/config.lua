Config = {}

-- Kazino yeri
Config.Casino = {
    coords = vector3(936.0, 47.0, 81.0),
    label = 'Diamond Kazino',
    blip = { sprite = 617, color = 5 },
}

-- Blackjack stolu
Config.BlackjackTable = vector3(945.0, 50.0, 81.0)

-- Rulet stolu
Config.RouletteTable = vector3(928.0, 55.0, 81.0)

-- Lotereya kiosku
Config.LotteryKiosk = vector3(955.0, 60.0, 81.0)

-- Blackjack parametrləri
Config.BlackjackMinBet = 100
Config.BlackjackMaxBet = 10000

-- Rulet parametrləri
Config.RouletteMinBet = 50
Config.RouletteMaxBet = 5000

-- Lotereya parametrləri
Config.LotteryTicketCost = 100
Config.LotteryDrawInterval = 600000     -- 10 dəqiqədən bir
Config.LotteryWinPercent = 0.70         -- mükafat hovuzun 70%-i
Config.LotteryTicketRange = 999         -- 1-999 arası nömrə
