Config = {}

-- Anbar terminali (Port anbarları)
Config.Kiosk = {
    label = '196 Self-Storage | Terminal',
    coords = vector3(1100.5, -3080.5, 5.9),
    heading = 90.0,
    prop = 'prop_atm_02',
}

-- Anbar vahidləri
Config.Units = 16
Config.RentPrice = 1500       -- ₣ / həftə
Config.Slots = 25
Config.MaxWeight = 80000

-- Storage Wars (kor hərrac)
Config.Auction = {
    Duration = 60,            -- saniyə
    MinBid = 500,             -- ₣
    BidStep = 250,            -- ₣
    RewardPerUnit = true,     -- qalib anbara sahib olur (məzmunu ilə)
}

-- Qarışıq (hərrac üçün boş anbarlar)
Config.AuctionUnits = { 13, 14, 15, 16 }
