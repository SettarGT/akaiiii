local QBCore = exports['qb-core']:GetCoreObject()

local chipsCache = {}   -- citizenid -> { chips, loss, day }

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

-- ── Fiş balansı ──
local function LoadChips(Player)
    local cid = Player.PlayerData.citizenid
    local c = chipsCache[cid]
    if c then return c end

    local row = MySQL.single('SELECT * FROM 196_chips WHERE citizenid = ?', { cid })
    if row then
        c = { chips = tonumber(row.chips) or 0, loss = tonumber(row.daily_loss) or 0, day = row.last_loss_day or os.date('%Y-%m-%d') }
    else
        MySQL.insert('INSERT INTO 196_chips (citizenid, chips, daily_loss, last_loss_day) VALUES (?, 0, 0, ?) ON DUPLICATE KEY UPDATE citizenid = VALUES(citizenid)', {
            cid, os.date('%Y-%m-%d'),
        })
        c = { chips = 0, loss = 0, day = os.date('%Y-%m-%d') }
    end
    -- gün dəyişibsə itkini sıfırla
    if c.day ~= os.date('%Y-%m-%d') then
        c.loss, c.day = 0, os.date('%Y-%m-%d')
        MySQL.update('UPDATE 196_chips SET daily_loss = 0, last_loss_day = ? WHERE citizenid = ?', { c.day, cid })
    end
    chipsCache[cid] = c
    return c
end

local function SaveChips(Player, c)
    MySQL.update('UPDATE 196_chips SET chips = ?, daily_loss = ?, last_loss_day = ? WHERE citizenid = ?', {
        c.chips, c.loss, c.day, Player.PlayerData.citizenid,
    })
end

-- ── Mərc qəbulu (fiş ödənilir) ──
local function Charge(src, amount)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false, Player end
    if amount < Config.Limits.MinBet or amount > Config.Limits.MaxBet then
        Notify(src, ('Mərc ₣%d - ₣%d arası olmalıdır.'):format(Config.Limits.MinBet, Config.Limits.MaxBet), 'error')
        return false, Player
    end
    local c = LoadChips(Player)
    if c.loss >= Config.Limits.DailyLoss then
        Notify(src, ('Günlük itki limiti çatdı (%s). Sabah yenidən gəlin.'):format(Config.Limits.DailyLoss), 'error')
        return false, Player
    end
    if c.chips < amount then
        Notify(src, ('Fiş kifayət deyil — fiş alın (/fiş). Balans: %d'):format(c.chips), 'error')
        return false, Player
    end
    c.chips = c.chips - amount
    SaveChips(Player, c)
    return true, Player
end

-- ── Uduş (nağd, vergi ilə) ──
local function PayWinnings(src, amount)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and amount > 0 then
        local net = amount
        local taxTaken = 0
        if GetResourceState('196rp_tax') == 'started' then
            taxTaken = exports['196rp_tax']:ChargeTax(src, amount, 'casino-win')
        end
        net = amount - taxTaken
        Player.Functions.AddMoney('cash', net, 'casino-win')
        if taxTaken > 0 then
            Notify(src, ('Vergi çıxıldı: -₣%d (%s%%)'):format(taxTaken, exports['196rp_tax']:GetRate()), 'primary')
        end
    end
end

-- ── İtki qeydi (uduzan əməliyyatlar) ──
local function RecordLoss(Player, amount)
    local c = LoadChips(Player)
    c.loss = c.loss + amount
    SaveChips(Player, c)
end

-- ══════════════════════════════════════
--  FİŞ ƏMƏLİYYATLARI
-- ══════════════════════════════════════
RegisterNetEvent('196rp_casino:server:buyChips', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    amount = math.floor(tonumber(amount) or 0)
    if amount < Config.Limits.MinBet then
        Notify(src, ('Minimum fiş: ₣%d'):format(Config.Limits.MinBet), 'error')
        return
    end
    if (Player.PlayerData.money.cash or 0) < amount then
        Notify(src, 'Kifayət qədər nağd pul yoxdur.', 'error')
        return
    end
    Player.Functions.RemoveMoney('cash', amount, 'casino-buy-chips')
    local c = LoadChips(Player)
    c.chips = c.chips + amount
    SaveChips(Player, c)
    Notify(src, ('🪙 %d fiş alındı!'):format(amount), 'success')
    TriggerClientEvent('196rp_casino:client:balance', src, Player.PlayerData.money.cash or 0, c.chips)
end)

RegisterNetEvent('196rp_casino:server:sellChips', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    amount = math.floor(tonumber(amount) or 0)
    local c = LoadChips(Player)
    if c.chips < amount or amount <= 0 then
        Notify(src, 'Kifayət qədər fiş yoxdur.', 'error')
        return
    end
    local cash = math.floor(amount * Config.Chips.Fee)
    c.chips = c.chips - amount
    SaveChips(Player, c)
    Player.Functions.AddMoney('cash', cash, 'casino-sell-chips')
    Notify(src, ('🪙 %d fiş → ₣%d'):format(amount, cash), 'success')
    TriggerClientEvent('196rp_casino:client:balance', src, Player.PlayerData.money.cash or 0, c.chips)
end)

-- ── Balans ──
RegisterNetEvent('196rp_casino:server:getBalance', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local c = LoadChips(Player)
    TriggerClientEvent('196rp_casino:client:balance', src, Player.PlayerData.money.cash or 0, c.chips)
end)

-- ══════════════════════════════════════
--  RULet
-- ══════════════════════════════════════
RegisterNetEvent('196rp_casino:server:roulette', function(betType, betValue, amount)
    local src = source
    amount = math.floor(tonumber(amount) or 0)
    local ok, Player = Charge(src, amount)
    if not ok then return end

    local number = math.random(0, Config.Roulette.Numbers)
    local color = nil
    if number > 0 then
        for _, n in ipairs(Config.Roulette.Red) do
            if n == number then color = 'qirmizi' end
        end
        if not color then color = 'qara' end
    else
        color = 'yashil'
    end

    local won = false
    local multiplier = 0
    if betType == 'number' and tonumber(betValue) == number then
        won = true; multiplier = 35
    elseif betType == 'color' and betValue == color then
        won = true; multiplier = 2
    elseif betType == 'evenodd' then
        if number > 0 and ((betValue == 'cute' and number % 2 == 0) or (betValue == 'tek' and number % 2 == 1)) then
            won = true; multiplier = 2
        end
    end

    local winAmount = 0
    if won then
        winAmount = math.min(amount * multiplier, Config.Limits.MaxProfit)
        PayWinnings(src, winAmount)
    else
        RecordLoss(Player, amount)
    end

    TriggerClientEvent('196rp_casino:client:rouletteResult', src, {
        number = number, color = color, won = won, win = winAmount, bet = amount, betType = betType, betValue = betValue,
    })
    TriggerClientEvent('196rp_casino:client:balance', src, Player.PlayerData.money.cash or 0, LoadChips(Player).chips)
end)

-- ══════════════════════════════════════
--  Zar
-- ══════════════════════════════════════
RegisterNetEvent('196rp_casino:server:dice', function(choice, amount)
    local src = source
    amount = math.floor(tonumber(amount) or 0)
    if choice ~= 'cute' and choice ~= 'tek' then return end
    local ok, Player = Charge(src, amount)
    if not ok then return end

    local roll = math.random(1, 6)
    local even = roll % 2 == 0
    local won = (choice == 'cute' and even) or (choice == 'tek' and not even)
    local winAmount = 0
    if won then
        winAmount = math.min(math.floor(amount * Config.Dice.Payout), Config.Limits.MaxProfit)
        PayWinnings(src, winAmount)
    else
        RecordLoss(Player, amount)
    end
    TriggerClientEvent('196rp_casino:client:diceResult', src, { roll = roll, won = won, win = winAmount, bet = amount })
    TriggerClientEvent('196rp_casino:client:balance', src, Player.PlayerData.money.cash or 0, LoadChips(Player).chips)
end)

-- ══════════════════════════════════════
--  Slot
-- ══════════════════════════════════════
RegisterNetEvent('196rp_casino:server:slots', function(amount)
    local src = source
    amount = math.floor(tonumber(amount) or 0)
    local ok, Player = Charge(src, amount)
    if not ok then return end

    local symbols = {}
    for i = 1, 3 do
        local r = math.random(100)
        local idx = 1
        local acc = 0
        for w, weight in ipairs(Config.Slots.Weights) do
            acc = acc + weight
            if r <= acc then idx = w break end
        end
        symbols[i] = Config.Slots.Symbols[idx]
    end

    local winAmount = 0
    if symbols[1] == symbols[2] and symbols[2] == symbols[3] then
        winAmount = math.min(math.floor(amount * (Config.Slots.Payouts.ThreeSame[symbols[1]] or 1)), Config.Limits.MaxProfit)
        PayWinnings(src, winAmount)
    elseif symbols[1] == symbols[2] or symbols[2] == symbols[3] or symbols[1] == symbols[3] then
        winAmount = math.min(math.floor(amount * Config.Slots.Payouts.TwoSame), Config.Limits.MaxProfit)
        PayWinnings(src, winAmount)
    else
        RecordLoss(Player, amount)
    end

    TriggerClientEvent('196rp_casino:client:slotsResult', src, { symbols = symbols, won = winAmount > 0, win = winAmount, bet = amount })
    TriggerClientEvent('196rp_casino:client:balance', src, Player.PlayerData.money.cash or 0, LoadChips(Player).chips)
end)

-- ═══════════ BLACKJACK (21) ═══════════
local bjState = {}
local bjSuits = { '♠', '♥', '♦', '♣' }

local function BuildDeck()
    local deck = {}
    for _ = 1, Config.Blackjack.Decks do
        for _, suit in ipairs(bjSuits) do
            for v = 1, 13 do
                local label = ({ 'A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K' })[v]
                local val = v > 10 and 10 or v
                deck[#deck + 1] = { label = label, suit = suit, val = val }
            end
        end
    end
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
    return deck
end

local function BjSum(hand)
    local sum, aces = 0, 0
    for _, c in ipairs(hand) do
        sum = sum + c.val
        if c.label == 'A' then aces = aces + 1 end
    end
    while sum > 21 and aces > 0 do
        sum = sum - 10
        aces = aces - 1
    end
    return sum
end

local function BjResolve(src, result, state)
    local s = bjState[src]
    if not s then return end
    bjState[src] = nil
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        if result == 'win' or result == 'blackjack' then
            local mult = result == 'blackjack' and Config.Blackjack.BlackjackPayout or Config.Blackjack.Payout
            local win = math.min(math.floor(s.bet * mult), Config.Limits.MaxProfit)
            PayWinnings(src, win)
        elseif result == 'push' then
            local c = LoadChips(Player)
            c.chips = c.chips + s.bet
            SaveChips(Player, c)
        else
            RecordLoss(Player, s.bet)
        end
    end

    TriggerClientEvent('196rp_casino:client:blackjackResult', src, {
        player = (state and state.player) or s.player,
        dealer = (state and state.dealer) or s.dealer,
        result = result,
        bet = s.bet,
    })
    if Player then
        TriggerClientEvent('196rp_casino:client:balance', src, Player.PlayerData.money.cash or 0, LoadChips(Player).chips)
    end
end

RegisterNetEvent('196rp_casino:server:blackjackStart', function(amount)
    local src = source
    amount = math.floor(tonumber(amount) or 0)
    if bjState[src] then
        Notify(src, 'Artıq aktiv oyununuz var.', 'error')
        return
    end
    local ok, Player = Charge(src, amount)
    if not ok then return end

    local deck = BuildDeck()
    local player = { deck[1], deck[2] }
    local dealer = { deck[3] }
    bjState[src] = { bet = amount, deck = deck, idx = 4, player = player, dealer = dealer }
    TriggerClientEvent('196rp_casino:client:blackjackState', src, { player = player, dealer = dealer, bet = amount })

    if BjSum(player) == 21 then
        BjResolve(src, 'blackjack', { player = player, dealer = { dealer[1] } })
    end
end)

RegisterNetEvent('196rp_casino:server:blackjackHit', function()
    local src = source
    local s = bjState[src]
    if not s then return end
    s.player[#s.player + 1] = s.deck[s.idx]
    s.idx = s.idx + 1

    local sum = BjSum(s.player)
    if sum > 21 then
        BjResolve(src, 'lose')
        return
    end
    TriggerClientEvent('196rp_casino:client:blackjackState', src, { player = s.player, dealer = s.dealer, bet = s.bet, sum = sum })
end)

RegisterNetEvent('196rp_casino:server:blackjackStand', function()
    local src = source
    local s = bjState[src]
    if not s then return end

    while BjSum(s.dealer) < Config.Blackjack.DealerMin do
        s.dealer[#s.dealer + 1] = s.deck[s.idx]
        s.idx = s.idx + 1
    end

    local ps, ds = BjSum(s.player), BjSum(s.dealer)
    local result = 'push'
    if ds > 21 or ps > ds then result = 'win' end
    if ds > ps and ds <= 21 then result = 'lose' end
    BjResolve(src, result)
end)

-- ═══════════ AT YARIŞI ═══════════
RegisterNetEvent('196rp_casino:server:horse', function(horseIndex, amount)
    local src = source
    amount = math.floor(tonumber(amount) or 0)
    horseIndex = tonumber(horseIndex)
    local horse = Config.Horses[horseIndex]
    if not horse then return end

    local ok, Player = Charge(src, amount)
    if not ok then return end

    -- qalib seçim (çəki əsaslı)
    local totalChance = 0
    for _, h in ipairs(Config.Horses) do totalChance = totalChance + h.chance end
    local r = math.random(0, totalChance)
    local winner, acc = 1, 0
    for i, h in ipairs(Config.Horses) do
        acc = acc + h.chance
        if r <= acc then winner = i break end
    end

    local odds = math.max(Config.HorseRace.MinOdds, math.min(Config.HorseRace.MaxOdds, 100 / horse.chance))
    local won = winner == horseIndex
    local winAmount = 0

    -- mərc artıq çıxılıb — uduşu gecikdirilmiş veririk
    SetTimeout(Config.HorseRace.Duration, function()
        if won then
            winAmount = math.min(math.floor(amount * odds), Config.Limits.MaxProfit)
            PayWinnings(src, winAmount)
        else
            RecordLoss(Player, amount)
        end
        TriggerClientEvent('196rp_casino:client:horseResult', src, {
            winner = winner, chosen = horseIndex, odds = odds, won = won, win = winAmount, bet = amount,
        })
        local p2 = QBCore.Functions.GetPlayer(src)
        if p2 then
            TriggerClientEvent('196rp_casino:client:balance', src, p2.PlayerData.money.cash or 0, LoadChips(p2).chips)
        end
    end)
end)
