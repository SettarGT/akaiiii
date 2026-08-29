local shopBlips = {}
local showingUI = false
local testVehicle = 0
local testSpawn = nil

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
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, shop.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(shop.name)
        EndTextCommandSetBlipName(blip)
        shopBlips[i] = blip
    end
end)

local function DeleteTestVehicle()
    if testVehicle and DoesEntityExist(testVehicle) then
        ESX.Game.DeleteVehicle(testVehicle)
    end
    testVehicle = 0
    testSpawn = nil
end

-- Sınaq maşınının təmizlənməsi
CreateThread(function()
    while true do
        Wait(2000)

        if testVehicle and DoesEntityExist(testVehicle) then
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)

            if veh ~= testVehicle and #(GetEntityCoords(ped) - testSpawn) > 40.0 then
                DeleteTestVehicle()
                ESX.ShowNotification('Sınaq sürüşü bitdi.', 'info')
            end
        end
    end
end)

local function TestDrive(shop, vehicleConfig)
    DeleteTestVehicle()

    ESX.Game.SpawnVehicle(vehicleConfig.model, shop.coords, shop.heading, function(vehicle)
        testVehicle = vehicle
        testSpawn = shop.coords
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetVehicleOnGroundProperly(vehicle)
        SetVehicleNumberPlateText(vehicle, 'SINAQ')
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        ESX.ShowNotification(('Sınaq sürüşü: ~y~%s~s~. Maşından çıxıb 40m uzaqlaşsanız, sınaq bitəcək.'):format(vehicleConfig.name), 'info', 7000)
    end)
end

local function BuyVehicle(shop, vehicleConfig)
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'buy_confirm', {
        title = ('~y~%s~s~ maşınını ~g~%s$~s~ qiymətinə almaq istəyirsiniz?\n(hə / yox)'):format(vehicleConfig.name, vehicleConfig.price)
    }, function(data, menu)
        menu.close()
        if string.lower(data.value or '') == 'hə' or string.lower(data.value or '') == 'he' then
            DeleteTestVehicle()
            ESX.TriggerServerCallback('196rp_vehicleshop:buyVehicle', function(ok, msg)
                ESX.ShowNotification(msg, ok and 'success' or 'error')
            end, shop.id, vehicleConfig.model)
        end
    end, function(data, menu)
        menu.close()
    end)
end

local function OpenVehicleMenu(shop, category)
    local elements = {}
    local categoryLabel = Config.CategoryLabels[category] or category

    for i = 1, #Config.Vehicles do
        local vehicle = Config.Vehicles[i]
        if vehicle.category == category then
            elements[#elements + 1] = {
                label = ('%s — ~g~%s$~s~'):format(vehicle.name, vehicle.price),
                value = vehicle.model
            }
        end
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_menu', {
        title = ('%s — %s'):format(shop.name, categoryLabel),
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        local vehicleConfig = Config.GetVehicle(data.current.value)
        if not vehicleConfig then
            return
        end

        -- Al və ya sına
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_actions', {
            title = vehicleConfig.name,
            align = 'top-left',
            elements = {
                { label = ('Al — ~g~%s$~s~'):format(vehicleConfig.price), value = 'buy' },
                { label = 'Sınaq sürüşü', value = 'test' },
            }
        }, function(data2, menu2)
            menu2.close()
            menu.close()
            if data2.current.value == 'buy' then
                BuyVehicle(shop, vehicleConfig)
            else
                TestDrive(shop, vehicleConfig)
            end
        end, function(data2, menu2)
            menu2.close()
        end)
    end, function(data, menu)
        menu.close()
    end)
end

local function OpenShopMenu(shop)
    local elements = {}
    for i = 1, #shop.categories do
        local category = shop.categories[i]
        local count = 0
        for j = 1, #Config.Vehicles do
            if Config.Vehicles[j].category == category then
                count = count + 1
            end
        end
        if count > 0 then
            elements[#elements + 1] = {
                label = ('%s (~b~%d maşın~s~)'):format(Config.CategoryLabels[category] or category, count),
                value = category
            }
        end
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_menu', {
        title = shop.name,
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        OpenVehicleMenu(shop, data.current.value)
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
            if dist < 3.0 and dist < nearestDist then
                nearestDist = dist
                nearestShop = shop
            end
        end

        if nearestShop then
            wait = 0
            showingUI = true
            ESX.TextUI(('[E] — %s (~y~maşınlar~s~)'):format(nearestShop.name), 'info')
            if IsControlJustPressed(0, 38) then
                OpenShopMenu(nearestShop)
            end
        else
            HideUI()
        end

        Wait(wait)
    end
end)
