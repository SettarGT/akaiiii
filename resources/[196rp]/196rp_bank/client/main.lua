local bankBlips = {}
local showingUI = false

local function HideUI()
    if showingUI then
        showingUI = false
        ESX.HideUI()
    end
end

-- Bliplər
CreateThread(function()
    for i = 1, #Config.BankPoints do
        local point = Config.BankPoints[i]
        local blip = AddBlipForCoord(point.coords.x, point.coords.y, point.coords.z)
        SetBlipSprite(blip, point.atm and 431 or 108)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, point.atm and 49 or 49)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(point.name)
        EndTextCommandSetBlipName(blip)
        bankBlips[i] = blip
    end
end)

-- Bank menyusu
local function OpenBank(point)
    ESX.TriggerServerCallback('196rp_bank:getBalance', function(data)
        if not data then
            return
        end

        local elements = {
            { label = ('~g~Nağd pul:~s~ %s$'):format(data.cash), value = 'balance_cash', enabled = false },
            { label = ('~b~Bank hesabı:~s~ %s$'):format(data.bank), value = 'balance_bank', enabled = false },
            { label = 'Pul qoyun', value = 'deposit' },
            { label = 'Pul çıxarın', value = 'withdraw' },
            { label = 'Başqa hesaba köçürün', value = 'transfer' },
        }

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bank_menu', {
            title = point.name,
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            local action = data.current.value

            if action == 'deposit' then
                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'bank_deposit', {
                    title = 'Neçə $ qoymaq istəyirsiniz?'
                }, function(data2, menu2)
                    local amount = tonumber(data2.value)
                    menu2.close()
                    menu.close()
                    if amount and amount > 0 then
                        ESX.TriggerServerCallback('196rp_bank:deposit', function(ok, msg)
                            ESX.ShowNotification(msg, ok and 'success' or 'error')
                        end, amount)
                    end
                end, function(data2, menu2)
                    menu2.close()
                end)
            elseif action == 'withdraw' then
                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'bank_withdraw', {
                    title = 'Neçə $ çıxarmaq istəyirsiniz?'
                }, function(data2, menu2)
                    local amount = tonumber(data2.value)
                    menu2.close()
                    menu.close()
                    if amount and amount > 0 then
                        ESX.TriggerServerCallback('196rp_bank:withdraw', function(ok, msg)
                            ESX.ShowNotification(msg, ok and 'success' or 'error')
                        end, amount)
                    end
                end, function(data2, menu2)
                    menu2.close()
                end)
            elseif action == 'transfer' then
                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'bank_transfer_id', {
                    title = 'Köçürmək istədiyiniz oyunçunun ID-si?'
                }, function(data2, menu2)
                    local target = tonumber(data2.value)
                    menu2.close()

                    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'bank_transfer_amount', {
                        title = 'Köçürüləcək məbləğ ($)?'
                    }, function(data3, menu3)
                        local amount = tonumber(data3.value)
                        menu3.close()
                        menu.close()
                        if target and amount and amount > 0 then
                            ESX.TriggerServerCallback('196rp_bank:transfer', function(ok, msg)
                                ESX.ShowNotification(msg, ok and 'success' or 'error')
                            end, target, amount)
                        end
                    end, function(data3, menu3)
                        menu3.close()
                    end)
                end, function(data2, menu2)
                    menu2.close()
                end)
            end
        end, function(data, menu)
            menu.close()
        end)
    end)
end

-- Əsas dövrə
CreateThread(function()
    while true do
        local wait = 750
        local coords = GetEntityCoords(PlayerPedId())
        local nearest = nil
        local nearestDist = 99.0

        for i = 1, #Config.BankPoints do
            local point = Config.BankPoints[i]
            local dist = #(coords - point.coords)
            if dist < 2.0 and dist < nearestDist then
                nearestDist = dist
                nearest = point
            end
        end

        if nearest then
            wait = 0
            showingUI = true
            ESX.TextUI(('[E] — %s (~y~%s~s~)'):format(nearest.atm and 'Bankomat' or 'Bank', nearest.name), 'info')
            if IsControlJustPressed(0, 38) then
                OpenBank(nearest)
            end
        else
            HideUI()
        end

        Wait(wait)
    end
end)
