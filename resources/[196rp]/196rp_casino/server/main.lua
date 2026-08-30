local QBCore = exports['qb-core']:GetCoreObject()

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

local function GetBet(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return nil, nil end
    return Player, (Player.PlayerData.money.cash or 0)
end

-- Qəbul: pul yoxlanır, əvvəlcədən silinir (mümkün şübhələr serverdə qalır)
local function Charge(src, amount)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end
    if amount < Config.Limits.MinBet or amount > Config.Limits.MaxBet then
        Notify(src, ('Mərc ₣%d - ₣%d arası olmalıdır.'):format(Config.Limits.MinBet, Config.Limits.MaxBet), 'error')
        return false
    end
    if (Player.PlayerData.money.cash or 0) < amount then
        Notify(src, 'Kifayət qədər nağd pul yoxdur!', 'error')
        return false
    end
    Player.Functions.RemoveMoney('cash', amount, 'casino-bet')
    return true
end

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

-- ── RULet ──
RegisterNetEvent('196rp_casino:server:roulette', function(betType, betValue, amount)
    local src = source
    amount = math.floor(tonumber(amount) or 0)
    if not Charge(src, amount) then return end

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
    end

    TriggerClientEvent('196rp_casino:client:rouletteResult', src, {
        number = number, color = color, won = won, win = winAmount, bet = amount, betType = betType, betValue = betValue,
    })
end)

-- ── Zar ──
RegisterNetEvent('196rp_casino:server:dice', function(choice, amount)
    local src = source
    amount = math.floor(tonumber(amount) or 0)
    if choice ~= 'cute' and choice ~= 'tek' then return end
    if not Charge(src, amount) then return end

    local roll = math.random(1, 6)
    local even = roll % 2 == 0
    local won = (choice == 'cute' and even) or (choice == 'tek' and not even)
    local winAmount = 0
    if won then
        winAmount = math.min(math.floor(amount * Config.Dice.Payout), Config.Limits.MaxProfit)
        PayWinnings(src, winAmount)
    end
    TriggerClientEvent('196rp_casino:client:diceResult', src, { roll = roll, won = won, win = winAmount, bet = amount })
end)

-- ── Slot ──
RegisterNetEvent('196rp_casino:server:slots', function(amount)
    local src = source
    amount = math.floor(tonumber(amount) or 0)
    if not Charge(src, amount) then return end

    local function rollSymbol()
        local r = math.random(1, 100)
        local acc = 0
        for i, w in ipairs(Config.Slots.Weights) do
            acc = acc + w
            if r <= acc then return Config.Slots.Symbols[i] end
        end
        return Config.Slots.Symbols[#Config.Slots.Symbols]
    end

    local a, b, c = rollSymbol(), rollSymbol(), rollSymbol()
    local winAmount = 0
    if a == b and b == c then
        local mult = Config.Slots.Payouts.ThreeSame[a] or 3
        winAmount = math.min(math.floor(amount * mult), Config.Limits.MaxProfit)
    elseif a == b or b == c or a == c then
        winAmount = math.min(math.floor(amount * Config.Slots.Payouts.TwoSame), Config.Limits.MaxProfit)
    end
    if winAmount > 0 then
        PayWinnings(src, winAmount)
    end
    TriggerClientEvent('196rp_casino:client:slotsResult', src, { symbols = { a, b, c }, won = winAmount > 0, win = winAmount, bet = amount })
end)

-- ── Balans (client üçün) ──
RegisterNetEvent('196rp_casino:server:getBalance', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    TriggerClientEvent('196rp_casino:client:balance', src, Player.PlayerData.money.cash or 0)
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

    if result == 'win' or result == 'blackjack' then
        local mult = result == 'blackjack' and Config.Blackjack.BlackjackPayout or Config.Blackjack.Payout
        local win = math.min(math.floor(s.bet * mult), Config.Limits.MaxProfit)
        PayWinnings(src, win)
        state = state or {}
        state.win = win
    elseif result == 'push' then
        -- mərc geri qaytarılır
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            local taxTaken = 0
            if GetResourceState('196rp_tax') == 'started' then
                taxTaken = exports['196rp_tax']:ChargeTax(src, s.bet, 'casino-push')
            end
            Player.Functions.AddMoney('cash', s.bet - taxTaken, 'casino-push')
        end
    end

    TriggerClientEvent('196rp_casino:client:blackjackResult', src, {
        player = state.player or s.player,
        dealer = state.dealer or s.dealer,
        result = result,
        bet = s.bet,
    })
end

RegisterNetEvent('196rp_casino:server:blackjackStart', function(amount)
    local src = source
    amount = math.floor(tonumber(amount) or 0)
    if bjState[src] then
        Notify(src, 'Artıq aktiv oyununuz var.', 'error')
        return
    end
    if not Charge(src, amount) then return end

    local deck = BuildDeck()
    local player = { deck[1], deck[2] }
    local dealer = { deck[3] }
    local s = { bet = amount, deck = deck, idx = 4, player = player, dealer = dealer }
    bjState[src] = s
    TriggerClientEvent('196rp_casino:client:blackjackState', src, { player = player, dealer = dealer, bet = amount })

    local ps = BjSum(player)
    if ps == 21 then
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
        BjResolve(src, 'lose', { player = s.player, dealer = s.dealer })
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
