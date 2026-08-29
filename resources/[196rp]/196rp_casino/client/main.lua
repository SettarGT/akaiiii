-- 196 RP | Kazino və Lotereya — müştəri tərəfi

local blips = {}

CreateThread(function()
    local blip = AddBlipForCoord(Config.Casino.coords.x, Config.Casino.coords.y, Config.Casino.coords.z)
    SetBlipSprite(blip, Config.Casino.blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, Config.Casino.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.Casino.label)
    EndTextCommandSetBlipName(blip)
end)

-- Kazino interaksiyası
CreateThread(function()
    while true do
        local wait = 750
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        local bjDist = #(coords - Config.BlackjackTable)
        local rlDist = #(coords - Config.RouletteTable)
        local ltDist = #(coords - Config.LotteryKiosk)

        if bjDist < 50.0 then
            wait = 0
            DrawMarker(29, Config.BlackjackTable.x, Config.BlackjackTable.y, Config.BlackjackTable.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.5, 60, 200, 120, 160, false, true, 2, nil, nil, false)
        end
        if rlDist < 50.0 then
            wait = 0
            DrawMarker(29, Config.RouletteTable.x, Config.RouletteTable.y, Config.RouletteTable.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.5, 200, 60, 60, 160, false, true, 2, nil, nil, false)
        end
        if ltDist < 50.0 then
            wait = 0
            DrawMarker(27, Config.LotteryKiosk.x, Config.LotteryKiosk.y, Config.LotteryKiosk.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.5, 255, 215, 60, 170, false, true, 2, nil, nil, false)
        end

        if bjDist < 2.2 then
            ESX.TextUI('[E] — Blackjack', 'info')
            if IsControlJustPressed(0, 38) then OpenBlackjackMenu() end
        elseif rlDist < 2.2 then
            ESX.TextUI('[E] — Rulet', 'info')
            if IsControlJustPressed(0, 38) then OpenRouletteMenu() end
        elseif ltDist < 2.2 then
            ESX.TextUI('[E] — Lotereya kiosku', 'info')
            if IsControlJustPressed(0, 38) then OpenLotteryMenu() end
        else
            ESX.HideUI()
        end

        Wait(wait)
    end
end)

-- ==================== BLACKJACK ====================

local function OpenBlackjackMenu()
    local menu = {
        { icon = 'fas fa-dice', title = '🃏 Blackjack', unselectable = true },
        { icon = 'fas fa-info-circle', title = 'Məqsəd: 21-ə yaxın olmaq. Dileri keçin!', unselectable = true },
    }
    for _, bet in ipairs({ 100, 500, 1000, 5000 }) do
        menu[#menu + 1] = {
            icon = 'fas fa-coins',
            title = ('Mərc: ~g~$%s~s~'):format(bet),
            name = 'bet_' .. bet,
        }
    end

    exports['esx_context']:Open('right', menu, function(selected)
        local bet = tonumber(selected.name:match('^bet_(%d+)$'))
        if not bet then return end
        StartBlackjack(bet)
    end)
end

local function StartBlackjack(bet)
    ESX.TriggerServerCallback('196rp_casino:blackjackStart', function(result, playerValue, dealerValue)
        if result == 'blackjack' then
            ESX.ShowNotification('~g~BLACKJACK! ~y~$' .. math.floor(bet * 2.5) .. '~s~ uddunuz!', 'success', 6000)
            return
        end
        if not result then
            ESX.ShowNotification('Mərc qəbul edilmədi! (min $' .. Config.BlackjackMinBet .. ')', 'error')
            return
        end
        ESX.ShowNotification(('Sizin: ~w~%s~s~ | Diler: ~w~%s~s~'):format(playerValue, dealerValue), 'info', 4000)
        BlackjackActionMenu(bet)
    end, bet)
end

local function BlackjackActionMenu(bet)
    local menu = {
        { icon = 'fas fa-hand-paper', title = 'Daha kart (Hit)', name = 'hit' },
        { icon = 'fas fa-hand-peace', title = 'Dayan (Stand)', name = 'stand' },
    }
    exports['esx_context']:Open('right', menu, function(selected)
        if selected.name == 'hit' then
            ESX.TriggerServerCallback('196rp_casino:blackjackHit', function(result, value)
                if result == 'bust' then
                    ESX.ShowNotification(('~r~Bank! (Cəm: %s)~s~'):format(value), 'error', 5000)
                elseif result == 'ok' then
                    ESX.ShowNotification(('Sizin cəm: ~w~%s~s~'):format(value), 'info', 3500)
                    BlackjackActionMenu(bet)
                else
                    ESX.ShowNotification('Oyun bitdi!', 'info')
                end
            end)
        elseif selected.name == 'stand' then
            ESX.TriggerServerCallback('196rp_casino:blackjackStand', function(result, playerValue, dealerValue)
                if result == 'win' then
                    ESX.ShowNotification(('~g~QAZANDINIZ!~s~ Siz: %s | Diler: %s | ~g~+$%s~s~'):format(playerValue, dealerValue, bet * 2), 'success', 6000)
                elseif result == 'draw' then
                    ESX.ShowNotification(('Berabərə! Siz: %s | Diler: %s (mərc geri qayıtdı)'):format(playerValue, dealerValue), 'info', 5000)
                elseif result == 'lose' then
                    ESX.ShowNotification(('~r~Uduzdunuz.~s~ Siz: %s | Diler: %s'):format(playerValue, dealerValue), 'error', 5000)
                else
                    ESX.ShowNotification('Oyun bitdi!', 'info')
                end
            end)
        end
    end)
end

-- ==================== RULET ====================

local function OpenRouletteMenu()
    local menu = {
        { icon = 'fas fa-circle-notch', title = '🎡 Rulet — Rəngə mərc', unselectable = true },
        { icon = 'fas fa-circle', title = '🔴 Qırmızı (x2)', name = 'red' },
        { icon = 'fas fa-circle', title = '⚫ Qara (x2)', name = 'black' },
        { icon = 'fas fa-circle', title = '🟢 Yaşıl (x14)', name = 'green' },
    }
    exports['esx_context']:Open('right', menu, function(selected)
        local color = selected.name
        if color ~= 'red' and color ~= 'black' and color ~= 'green' then return end
        AskRouletteBet(color)
    end)
end

local function AskRouletteBet(color)
    local menu = {
        { icon = 'fas fa-coins', title = 'Mərc məbləği:', unselectable = true },
        { icon = '', title = '$ məbləğ', input = true, inputType = 'number', inputPlaceholder = '100', inputValue = 100, inputMin = Config.RouletteMinBet, inputMax = Config.RouletteMaxBet, name = 'amount' },
        { icon = 'fas fa-check', title = 'Mərc et', name = 'submit' },
    }
    exports['esx_context']:Open('right', menu, function(selected)
        if selected.name == 'submit' then
            local bet = tonumber(menu[2].inputValue) or 100
            ESX.TriggerServerCallback('196rp_casino:roulette', function(ok, number, resultColor, win, payout)
                if not ok then
                    ESX.ShowNotification('Mərc qəbul edilmədi!', 'error')
                    return
                end
                local colorLabel = resultColor == 'red' and '🔴' or (resultColor == 'black' and '⚫' or '🟢')
                if win then
                    ESX.ShowNotification(('🎡 %s%d %s — ~g~QAZANDINIZ! +$%s~s~'):format(colorLabel, number, resultColor, payout), 'success', 6000)
                else
                    ESX.ShowNotification(('🎡 %s%d %s — ~r~Uduzdunuz.~s~'):format(colorLabel, number, resultColor), 'error', 5000)
                end
            end, color, bet)
        end
    end)
end

-- ==================== LOTEREYA ====================

local function OpenLotteryMenu()
    ESX.TriggerServerCallback('196rp_casino:lotteryStatus', function(status)
        local menu = {
            { icon = 'fas fa-ticket-alt', title = '🎟 Lotereya', unselectable = true },
            { icon = 'fas fa-info-circle', title = ('Tur: ~y~#%s~s~ | Hovuz: ~g~$%s~s~ | Biletlər: %s'):format(status.round, status.pool, status.ticketCount), unselectable = true },
            { icon = 'fas fa-ticket-alt', title = ('Bilet al (~g~$%s~s~)'):format(Config.LotteryTicketCost), name = 'buy' },
        }
        exports['esx_context']:Open('right', menu, function(selected)
            if selected.name == 'buy' then
                ESX.TriggerServerCallback('196rp_casino:lotteryBuy', function(ok, msg)
                    if ok then
                        ESX.ShowNotification(('~g~Bilet alındı!~s~ %s'):format(msg), 'success', 6000)
                    else
                        ESX.ShowNotification(msg or 'Bilet alına bilmədi!', 'error', 6000)
                    end
                end)
            end
        end)
    end)
end
