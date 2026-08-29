local shopBlips = {}
local showingUI = false

local function HideUI()
    if showingUI then
        showingUI = false
        ESX.HideUI()
    end
end

-- Bliplər
CreateThread(function()
    for i = 1, #Config.Shops do
        local shop = Config.Shops[i]
        local blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)
        SetBlipSprite(blip, shop.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, shop.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(shop.name)
        EndTextCommandSetBlipName(blip)
        shopBlips[i] = blip
    end
end)

-- Mağaza menyusu
local function OpenShop(shop)
    local elements = {}

    for i = 1, #shop.items do
        local item = shop.items[i]
        elements[#elements + 1] = {
            label = ('%s — ~g~%s$~s~'):format(item.label, item.price),
            value = item.name,
            itemLabel = item.label,
            price = item.price
        }
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_menu', {
        title = shop.name,
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        local selected = data.current

        -- Miqdar sorğusu
        ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'shop_amount', {
            title = ('Neçə ədəd ~y~%s~s~ almaq istəyirsiniz?'):format(selected.itemLabel)
        }, function(data2, menu2)
            local amount = tonumber(data2.value)
            menu2.close()
            menu.close()

            if amount and amount > 0 and amount <= 100 then
                ESX.TriggerServerCallback('196rp_shops:buyItem', function(ok, reason)
                    if ok then
                        ESX.ShowNotification(('~g~%s ədəd %s aldınız!~s~ (məbləğ: ~y~%s$~s~)'):format(amount, selected.itemLabel, amount * selected.price), 'success')
                    else
                        ESX.ShowNotification(reason or 'Alış uğursuz oldu!', 'error')
                    end
                end, shop.id, selected.value, amount)
            end
        end, function(data2, menu2)
            menu2.close()
        end)
    end, function(data, menu)
        menu.close()
    end)
end

-- Əsas dövrə
CreateThread(function()
    while true do
        local wait = 750
        local coords = GetEntityCoords(PlayerPedId())
        local nearestShop = nil
        local nearestDist = 99.0

        for i = 1, #Config.Shops do
            local shop = Config.Shops[i]
            local dist = #(coords - shop.coords)
            if dist < 2.5 and dist < nearestDist then
                nearestDist = dist
                nearestShop = shop
            end
        end

        if nearestShop then
            wait = 0
            showingUI = true
            ESX.TextUI(('[E] — Mağaza: ~y~%s~s~'):format(nearestShop.name), 'info')
            if IsControlJustPressed(0, 38) then
                OpenShop(nearestShop)
            end
        else
            HideUI()
        end

        Wait(wait)
    end
end)
