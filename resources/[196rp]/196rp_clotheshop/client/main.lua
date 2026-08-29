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
    for i = 1, #Config.ClothesShops do
        local shop = Config.ClothesShops[i]
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

-- Görünüş dəyişmə (soyunma kabinəsi təcrübəsi)
local function OpenDressingRoom(shop)
    local ped = PlayerPedId()

    ESX.ShowNotification('~y~Soyunma kabinəsinə daxil olursunuz...~s~', 'info')
    DoScreenFadeOut(400)
    ESX.SetTimeout(500, function()
        -- Kabinəyə keç
        SetEntityCoords(ped, shop.dressingRoom.x, shop.dressingRoom.y, shop.dressingRoom.z, false, false, false, true)
        SetEntityHeading(ped, 0.0)

        -- Kabinədə güzgü qarşısında dayan
        ESX.SetTimeout(600, function()
            DoScreenFadeIn(600)
            ESX.ShowNotification('Güzgü qarşısında görünüşünüzü dəyişin. ~b~Q & E~s~ ilə ətrafa baxın.', 'info', 6000)

            TriggerEvent('esx_skin:openSaveableMenu', function()
                -- Saxlandı
                DoScreenFadeOut(400)
                ESX.SetTimeout(600, function()
                    SetEntityCoords(ped, shop.coords.x, shop.coords.y, shop.coords.z, false, false, false, true)
                    DoScreenFadeIn(600)
                    ESX.ShowNotification('~g~Yeni görünüşünüz hazırdır!~s~ Dəbdəsən!', 'success')
                end)
            end, function()
                -- Ləğv edildi
                DoScreenFadeOut(400)
                ESX.SetTimeout(600, function()
                    SetEntityCoords(ped, shop.coords.x, shop.coords.y, shop.coords.z, false, false, false, true)
                    DoScreenFadeIn(600)
                end)
            end)
        end)
    end)
end

-- Əsas dövrə
CreateThread(function()
    while true do
        local wait = 750
        local coords = GetEntityCoords(PlayerPedId())
        local nearestShop = nil
        local nearestDist = 99.0

        for i = 1, #Config.ClothesShops do
            local shop = Config.ClothesShops[i]
            local dist = #(coords - shop.coords)
            if dist < 3.0 and dist < nearestDist then
                nearestDist = dist
                nearestShop = shop
            end
        end

        if nearestShop then
            wait = 0
            showingUI = true
            ESX.TextUI(('[E] — Paltarını dəyiş (~y~%s~s~)'):format(nearestShop.name), 'info')
            if IsControlJustPressed(0, 38) then
                OpenDressingRoom(nearestShop)
            end
        else
            HideUI()
        end

        Wait(wait)
    end
end)
