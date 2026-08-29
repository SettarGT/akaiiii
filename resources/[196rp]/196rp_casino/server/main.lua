-- 196 RP | Kazino — server tərəfi
-- Blackjack, rulet, lotereya

local ESX = exports['es_extended']:getSharedObject()

-- [source] = { bet = n, player = {cards}, dealer = {cards} }
local blackjackGames = {}

-- ==================== KÖMƏKÇİLƏR ====================

local function CardValue(cards)
    local total, aces = 0, 0
    for i = 1, #cards do
        local c = cards[i]
        if c == 11 or c == 12 or c == 13 then
            total = total + 10
        elseif c == 1 then
            total = total + 11
            aces = aces + 1
        else
            total = total + c
        end
    end
    while total > 21 and aces > 0 do
        total = total - 10
        aces = aces - 1
    end
    return total
end

local function DrawCard()
    return math.random(1, 13)
end

local function AtTable(source)
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    return #(coords - Config.BlackjackTable) < 15.0
        or #(coords - Config.RouletteTable) < 15.0
        or #(coords - Config.Casino.coords) < 40.0
end

local function TakeMoney(xPlayer, amount)
    if xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount)
        return true
    end
    local bank = xPlayer.getAccount('bank')
    if bank and bank.money >= amount then
        xPlayer.removeAccountMoney('bank', amount)
        return true
    end
    return false
end

-- ==================== BLACKJACK ====================

ESX.RegisterServerCallback('196rp_casino:blackjackStart', function(source, cb, bet)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(nil)
    end

    bet = math.floor(tonumber(bet) or 0)
    if bet < Config.BlackjackMinBet or bet > Config.BlackjackMaxBet then
        return cb(nil)
    end

    if not AtTable(source) then
        return cb(nil)
    end

    if not TakeMoney(xPlayer, bet) then
        return cb(nil)
    end

    local game = {
        bet = bet,
        player = { DrawCard(), DrawCard() },
        dealer = { DrawCard(), DrawCard() }
    }
    blackjackGames[source] = game

    local pVal = CardValue(game.player)
    local dVal = CardValue(game.dealer)

    -- Təbii blackjack
    if pVal == 21 then
        xPlayer.addMoney(math.floor(bet * 2.5))
        blackjackGames[source] = nil
        return cb('blackjack', pVal, dVal)
    end

    cb('ok', pVal, dVal)
end)

ESX.RegisterServerCallback('196rp_casino:blackjackHit', function(source, cb)
    local game = blackjackGames[source]
    if not game then
        return cb('bust', 0)
    end

    game.player[#game.player + 1] = DrawCard()
    local pVal = CardValue(game.player)

    if pVal > 21 then
        blackjackGames[source] = nil
        return cb('bust', pVal)
    end

    cb('ok', pVal)
end)

ESX.RegisterServerCallback('196rp_casino:blackjackStand', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local game = blackjackGames[source]
    if not xPlayer or not game then
        return cb('lose', 0, 0)
    end

    -- Diler 17-yə qədər çəkir
    while CardValue(game.dealer) < 17 do
        game.dealer[#game.dealer + 1] = DrawCard()
    end

    local pVal = CardValue(game.player)
    local dVal = CardValue(game.dealer)

    local result
    if dVal > 21 or pVal > dVal then
        result = 'win'
        xPlayer.addMoney(game.bet * 2)
    elseif pVal == dVal then
        result = 'draw'
        xPlayer.addMoney(game.bet)
    else
        result = 'lose'
    end

    blackjackGames[source] = nil
    cb(result, pVal, dVal)
end)

-- ==================== RULET ====================

local RED_NUMBERS = { 1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36 }

local function RouletteColor(number)
    if number == 0 then
        return 'green'
    end
    for i = 1, #RED_NUMBERS do
        if RED_NUMBERS[i] == number then
            return 'red'
        end
    end
    return 'black'
end

ESX.RegisterServerCallback('196rp_casino:roulette', function(source, cb, color, bet)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false)
    end

    bet = math.floor(tonumber(bet) or 0)
    if bet < Config.RouletteMinBet or bet > Config.RouletteMaxBet then
        return cb(false)
    end

    if color ~= 'red' and color ~= 'black' and color ~= 'green' then
        return cb(false)
    end

    if not AtTable(source) then
        return cb(false)
    end

    if not TakeMoney(xPlayer, bet) then
        return cb(false)
    end

    local number = math.random(0, 36)
    local resultColor = RouletteColor(number)
    local win = resultColor == color
    local payout = 0

    if win then
        payout = color == 'green' and (bet * 14) or (bet * 2)
        xPlayer.addMoney(payout)
    end

    cb(true, number, resultColor, win, payout)
end)

-- ==================== LOTEREYA ====================

local lottery = { round = 1, pool = 0, ticketCount = 0 }

-- Cari turu bazadan yüklə
CreateThread(function()
    local maxRound = MySQL.scalar.await('SELECT MAX(`round`) FROM `196rp_lottery`')
    if maxRound then
        lottery.round = maxRound
    end

    local pool = MySQL.scalar.await('SELECT COUNT(*) FROM `196rp_lottery` WHERE `round` = ?', { lottery.round })
    lottery.ticketCount = (pool or 0)
    lottery.pool = lottery.ticketCount * Config.LotteryTicketCost
end)

ESX.RegisterServerCallback('196rp_casino:lotteryStatus', function(source, cb)
    cb({ round = lottery.round, pool = lottery.pool, ticketCount = lottery.ticketCount })
end)

ESX.RegisterServerCallback('196rp_casino:lotteryBuy', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local cost = Config.LotteryTicketCost
    if not TakeMoney(xPlayer, cost) then
        return cb(false, ('Pulunuz kifayət etmir! Bilet: ~y~%s$~s~'):format(cost))
    end

    local ticket = math.random(1, 9999)
    MySQL.insert.await('INSERT INTO `196rp_lottery` (`round`, `identifier`, `ticket`) VALUES (?, ?, ?)',
        { lottery.round, xPlayer.identifier, ticket })

    lottery.ticketCount = lottery.ticketCount + 1
    lottery.pool = lottery.pool + cost

    cb(true, ('Bilet nömrəniz: ~y~%04d~s~ (tur #%s)'):format(ticket, lottery.round))
end)

-- Uduşlu tur
local function DrawLottery()
    if lottery.ticketCount == 0 then
        return
    end

    local rows = MySQL.query.await('SELECT `identifier`, `ticket` FROM `196rp_lottery` WHERE `round` = ?',
        { lottery.round }) or {}

    if #rows == 0 then
        return
    end

    local winner = rows[math.random(1, #rows)]
    local prize = math.floor(lottery.pool * Config.LotteryWinPercent)

    local xWinner = ESX.GetPlayerFromIdentifier(winner.identifier)
    if xWinner then
        xWinner.addAccountMoney('bank', prize)
        TriggerClientEvent('esx:showNotification', xWinner.source,
            ('~g~🎟 LOTEREYANI QAZANDINIZ!~s~ Mükafat: ~y~%s$~s~ (bilet %04d)'):format(prize, winner.ticket), 'success')
    end

    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 200, 0 },
        multiline = true,
        args = { '196 Kazino', ('Lotereya turu #%s bitdi! Hovuz: %s$. Qazanan bilet: %04d'):format(
            lottery.round, lottery.pool, winner.ticket) }
    })

    lottery.round = lottery.round + 1
    lottery.pool = 0
    lottery.ticketCount = 0
end

CreateThread(function()
    while true do
        Wait(Config.LotteryDrawInterval or 600000)
        DrawLottery()
    end
end)

exports('DrawLotteryNow', function()
    DrawLottery()
end)

AddEventHandler('playerDropped', function()
    blackjackGames[source] = nil
end)
