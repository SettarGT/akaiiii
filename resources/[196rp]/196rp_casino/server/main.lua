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
        Player.Functions.AddMoney('cash', amount, 'casino-win')
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
