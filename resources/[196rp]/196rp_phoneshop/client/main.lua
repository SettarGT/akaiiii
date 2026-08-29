-- 196 RP | Telefon mağazası — müştəri tərəfi

local activeShop = nil
local lastInteract = 0

-- ==================== BLİP + PED + MARKER ====================

CreateThread(function()
    for i = 1, #Config.Shops do
        local shop = Config.Shops[i]
        local c = shop.coords

        local blip = AddBlipForCoord(c.x, c.y, c.z)
        SetBlipSprite(blip, Config.Blip.sprite)
        SetBlipColour(blip, Config.Blip.colour)
        SetBlipScale(blip, Config.Blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(Config.Blip.label)
        EndTextCommandSetBlipName(blip)
    end
end)

-- Satıcı NPC-lər
CreateThread(function()
    for i = 1, #Config.Shops do
        local shop = Config.Shops[i]
        local model = GetHashKey(shop.ped.model)

        RequestModel(model)
        local timeout = 0

        while not HasModelLoaded(model) and timeout < 50 do
            Wait(100)
            timeout = timeout + 1
        end

        if HasModelLoaded(model) then
            local c = shop.coords
            local ped = CreatePed(4, model, c.x, c.y, c.z - 1.0, c.w or 0.0, false, false)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            TaskStartScenarioInPlace(ped, shop.ped.scenario, 0, true)
            SetModelAsNoLongerNeeded(model)
        end
    end
end)

-- Marker döngüsü (uzaqda olarkən 1000 ms gözləyir — FPS itkisi yoxdur)
CreateThread(function()
    while true do
        local wait = 1000
        local coords = GetEntityCoords(PlayerPedId())

        for i = 1, #Config.Shops do
            local shop = Config.Shops[i]
            local c = shop.coords
            local dist = #(coords - c)

            if dist < Config.Marker.drawDistance then
                wait = 0

                DrawMarker(1, c.x, c.y, c.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    1.4, 1.4, 0.5, 30, 200, 90, 120, false, true, 2, nil, nil, false)

                if dist < Config.Marker.interactDistance then
                    activeShop = shop
                    ESX.TextUI(('📱 ~y~%s~s~\n[E] — telefon kataloqu'):format(shop.name), 'info')

                    if IsControlJustReleased(0, 38) then
                        OpenCatalog(shop)
                    end
                end
            end
        end

        if wait == 1000 and activeShop then
            activeShop = nil
            ESX.HideUI()
        end

        Wait(wait)
    end
end)

-- ==================== KATALOQ ====================

function OpenCatalog(shop)
    if (GetGameTimer() - lastInteract) < Config.Cooldown then
        ESX.ShowNotification('Bir az gözləyin.', 'info')
        return
    end

    lastInteract = GetGameTimer()

    ESX.TriggerServerCallback('196rp_phoneshop:getShop', function(data)
        if not data then
            return
        end

        local elements = {}
        local models = data.phones
        local owned = data.owned or {}
        local current = data.current

        for i = 1, #models do
            local p = models[i]
            local isOwned = owned[p.id] == true

            elements[#elements + 1] = {
                label = ('%s %s — %s, %s GB — %s ₼%s'):format(
                    p.brand, p.name, p.colour, p.storage,
                    ESX.Math.GroupDigits(p.price), isOwned and '   ✅ ALINIB' or ''),
                value = p.id,
                icon = 'mobile-screen-button',
                description = isOwned and 'Satmaq və ya istifadə etmək üçün seçin'
                    or 'Satın almaq üçün seçin',
                name = p.id,
            }
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'phone_shop', {
            title = ('📱 %s — telefon kataloqu (pulunuz: %s ₼)'):format(
                shop.name, ESX.Math.GroupDigits(data.money)),
            align = 'top-left',
            elements = elements,
        }, function(d, menu)
            menu.close()
            OpenModelMenu(shop, d.current.value, owned, current)
        end, function(d, menu)
            menu.close()
        end)
    end, shop.id)
end

-- Seçilmiş model üçün əməliyyat menyusu
function OpenModelMenu(shop, phoneId, owned, current)
    local isOwned = owned[phoneId] == true
    local isCurrent = current == phoneId
    local elements = {}

    if not isOwned then
        elements[#elements + 1] = { label = '💳 Satın al', action = 'buy' }
    else
        if not isCurrent then
            elements[#elements + 1] = { label = '📲 Bu telefonu işlət', action = 'equip' }
        else
            elements[#elements + 1] = {
                label = '📲 Hazırda işlədilir',
                action = 'none',
            }
        end

        elements[#elements + 1] = { label = '💰 Sat (50%)', action = 'sell' }
    end

    if #elements == 0 then
        return
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'phone_actions', {
        title = '📱 Əməliyyat',
        align = 'top-left',
        elements = elements,
    }, function(d, menu)
        menu.close()
        local action = d.current.action

        if action == 'buy' then
            ESX.TriggerServerCallback('196rp_phoneshop:buyPhone', function(ok, msg)
                ESX.ShowNotification(msg, ok and 'success' or 'error', 6000)
            end, shop.id, phoneId)
        elseif action == 'equip' then
            ESX.TriggerServerCallback('196rp_phoneshop:equipPhone', function(ok, msg)
                ESX.ShowNotification(msg, ok and 'success' or 'error', 6000)
            end, phoneId)
        elseif action == 'sell' then
            ESX.TriggerServerCallback('196rp_phoneshop:sellPhone', function(ok, msg)
                ESX.ShowNotification(msg, ok and 'success' or 'error', 6000)
            end, shop.id, phoneId)
        end
    end, function(d, menu)
        menu.close()
        OpenCatalog(shop)
    end)
end

-- ==================== ƏMR ====================

RegisterCommand('telefondukan', function()
    local coords = GetEntityCoords(PlayerPedId())
    local nearest = nil
    local best = 25.0

    for i = 1, #Config.Shops do
        local shop = Config.Shops[i]
        local dist = #(coords - shop.coords)

        if dist < best then
            best = dist
            nearest = shop
        end
    end

    if not nearest then
        ESX.ShowNotification('Ən yaxın 196 Mobil mağazasına gedin (xəritədə 📱 nişanı).', 'info', 6000)
        return
    end

    OpenCatalog(nearest)
end, false)

-- ==================== İXRAC ====================

exports('GetShopCoords', function()
    local list = {}

    for i = 1, #Config.Shops do
        list[#list + 1] = Config.Shops[i].coords
    end

    return list
end)
