local houseBlips = {}
local showingUI = false
local houseCache = {} -- id -> { owned = boolean, locked = boolean, owner = string }

local function HideUI()
    if showingUI then
        showingUI = false
        ESX.HideUI()
    end
end

-- Bliplər (sahibi olmayan evlər yaşıl, sahibli evlər mavi)
local function RefreshBlips()
    for i = 1, #houseBlips do
        if houseBlips[i] and DoesBlipExist(houseBlips[i]) then
            RemoveBlip(houseBlips[i])
        end
    end
    houseBlips = {}

    for i = 1, #Config.Houses do
        local house = Config.Houses[i]
        local data = houseCache[house.id]
        local owned = data and data.owned or false

        local blip = AddBlipForCoord(house.coords.x, house.coords.y, house.coords.z)
        SetBlipSprite(blip, 40)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, owned and 3 or 2)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(('%s %s'):format(house.name, owned and '(SİZİN)' or '(SATIŞDA)'))
        EndTextCommandSetBlipName(blip)
        houseBlips[i] = blip
    end
end

-- Əmlak agentliyi blipi
CreateThread(function()
    local blip = AddBlipForCoord(Config.Agency.coords.x, Config.Agency.coords.y, Config.Agency.coords.z)
    SetBlipSprite(blip, Config.Agency.blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, Config.Agency.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.Agency.name)
    EndTextCommandSetBlipName(blip)
end)

-- Ev vəziyyətlərini yüklə
local function LoadHouses(cb)
    ESX.TriggerServerCallback('196rp_housing:getHouses', function(houses)
        houseCache = houses or {}
        RefreshBlips()
        if cb then
            cb()
        end
    end)
end

CreateThread(function()
    LoadHouses()
end)

-- ==================== EV ƏMƏLİYYATLARI ====================

local function EnterHouse(house)
    local ped = PlayerPedId()
    DoScreenFadeOut(300)
    ESX.SetTimeout(400, function()
        SetEntityCoords(ped, Config.Interior.x, Config.Interior.y, Config.Interior.z, false, false, false, true)
        SetEntityHeading(ped, 0.0)
        DoScreenFadeIn(500)
        ESX.ShowNotification(('~y~%s~s~ — evinizə xoş gəldiniz!'):format(house.name), 'info')
    end)
end

local function ExitHouse(house)
    local ped = PlayerPedId()
    DoScreenFadeOut(300)
    ESX.SetTimeout(400, function()
        SetEntityCoords(ped, house.coords.x, house.coords.y, house.coords.z, false, false, false, true)
        SetEntityHeading(ped, house.heading or 0.0)
        DoScreenFadeIn(500)
    end)
end

local function OpenOwnedHouseMenu(house)
    local data = houseCache[house.id]

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'house_menu', {
        title = house.name,
        align = 'top-left',
        elements = {
            { label = 'Evinizə daxil olun', value = 'enter' },
            { label = data and data.locked and '~y~Qıfılı aç~s~' or '~g~Qıfılla~s~', value = 'lock' },
            { label = ('Evi sat (~y~%s$~s~)'):format(math.floor(house.price * 0.75)), value = 'sell' },
        }
    }, function(menuData, menu)
        menu.close()
        local action = menuData.current.value

        if action == 'enter' then
            if data and data.locked then
                ESX.ShowNotification('~r~Ev qıfıllıdır!~s~', 'error')
                return
            end
            EnterHouse(house)
        elseif action == 'lock' then
            ESX.TriggerServerCallback('196rp_housing:toggleLock', function(locked)
                houseCache[house.id].locked = locked
                ESX.ShowNotification(locked and '~y~Ev qıfıllandı.~s~' or '~g~Ev açıldı.~s~', locked and 'info' or 'success')
            end, house.id)
        elseif action == 'sell' then
            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'sell_confirm', {
                title = ('Evi ~y~%s$~s~ qiymətinə satmaq istəyirsiniz?\n(hə / yox)'):format(math.floor(house.price * 0.75))
            }, function(data2, menu2)
                menu2.close()
                if string.lower(data2.value or '') == 'hə' or string.lower(data2.value or '') == 'he' then
                    ESX.TriggerServerCallback('196rp_housing:sellHouse', function(ok, msg)
                        if ok then
                            houseCache[house.id] = { owned = false, locked = false }
                            RefreshBlips()
                        end
                        ESX.ShowNotification(msg, ok and 'success' or 'error')
                    end, house.id)
                end
            end, function(data2, menu2)
                menu2.close()
            end)
        end
    end, function(menuData, menu)
        menu.close()
    end)
end

local function OpenGuestHouseMenu(house)
    local data = houseCache[house.id]

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'house_guest_menu', {
        title = ('%s (giriş icazəniz var)'):format(house.name),
        align = 'top-left',
        elements = {
            { label = 'Evə daxil olun', value = 'enter' },
        }
    }, function(menuData, menu)
        menu.close()

        if menuData.current.value == 'enter' then
            if data and data.locked then
                ESX.ShowNotification('~r~Ev qıfıllıdır!~s~', 'error')
                return
            end
            EnterHouse(house)
        end
    end, function(menuData, menu)
        menu.close()
    end)
end

local function BuyHouse(house)
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'buy_confirm', {
        title = ('~y~%s~s~\n%s\nQiymət: ~g~%s$~s~. Almaq istəyirsiniz?\n(hə / yox)'):format(house.name, house.desc, house.price)
    }, function(data, menu)
        menu.close()
        if string.lower(data.value or '') == 'hə' or string.lower(data.value or '') == 'he' then
            ESX.TriggerServerCallback('196rp_housing:buyHouse', function(ok, msg)
                if ok then
                    houseCache[house.id] = { owned = true, locked = false }
                    RefreshBlips()
                end
                ESX.ShowNotification(msg, ok and 'success' or 'error')
            end, house.id)
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- ==================== ƏMLAK AGENTLİYİ ====================

local function OpenAgencyMenu()
    ESX.TriggerServerCallback('196rp_housing:getHouses', function(houses)
        houseCache = houses or {}
        RefreshBlips()

        local elements = {}
        for i = 1, #Config.Houses do
            local house = Config.Houses[i]
            local owned = houseCache[house.id] and houseCache[house.id].owned or false
            if not owned then
                elements[#elements + 1] = {
                    label = ('%s — ~g~%s$~s~'):format(house.name, house.price),
                    value = house.id,
                    house = house
                }
            end
        end

        if #elements == 0 then
            ESX.ShowNotification('Hal-hazırda satışda ev yoxdur.', 'info')
            return
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'agency_menu', {
            title = Config.Agency.name,
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            local house = data.current.house

            -- Baxışa get / al
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'agency_actions', {
                title = house.name,
                align = 'top-left',
                elements = {
                    { label = 'Evə baxış (teleport)', value = 'view' },
                    { label = ('Al — ~g~%s$~s~'):format(house.price), value = 'buy' },
                }
            }, function(data2, menu2)
                menu2.close()
                menu.close()
                if data2.current.value == 'view' then
                    local ped = PlayerPedId()
                    SetEntityCoords(ped, house.coords.x, house.coords.y, house.coords.z, false, false, false, true)
                    ESX.ShowNotification(('Baxış: ~y~%s~s~. Qayıtmaq üçün yenidən agentliyə gedin.'):format(house.name), 'info')
                else
                    BuyHouse(house)
                end
            end, function(data2, menu2)
                menu2.close()
            end)
        end, function(data, menu)
            menu.close()
        end)
    end)
end

-- ==================== ƏSAS DÖVRƏ ====================

CreateThread(function()
    while true do
        local wait = 750
        local coords = GetEntityCoords(PlayerPedId())
        local nearHouse = nil
        local nearHouseDist = 99.0

        -- Ev qapıları
        for i = 1, #Config.Houses do
            local house = Config.Houses[i]
            local dist = #(coords - house.coords)
            if dist < 2.5 and dist < nearHouseDist then
                nearHouseDist = dist
                nearHouse = house
            end
        end

        if nearHouse then
            wait = 0
            local data = houseCache[nearHouse.id]
            showingUI = true

            if data and data.owned then
                ESX.TextUI(('[E] — ~y~%s~s~ (sizin eviniz)'):format(nearHouse.name), 'info')
                if IsControlJustPressed(0, 38) then
                    OpenOwnedHouseMenu(nearHouse)
                end
            elseif data and data.access then
                ESX.TextUI(('[E] — ~y~%s~s~ (giriş icazəniz var)'):format(nearHouse.name), 'info')
                if IsControlJustPressed(0, 38) then
                    OpenGuestHouseMenu(nearHouse)
                end
            else
                ESX.TextUI(('[E] — ~y~%s~s~ — SATIŞDA (~g~%s$~s~)'):format(nearHouse.name, nearHouse.price), 'info')
                if IsControlJustPressed(0, 38) then
                    BuyHouse(nearHouse)
                end
            end
        else
            -- İnteryerdədirsə: çıxış
            if #(coords - Config.Interior) < 5.0 then
                wait = 0
                showingUI = true
                ESX.TextUI('[E] — Evdən çıx', 'info')
                if IsControlJustPressed(0, 38) then
                    -- Sahib olan evi tap
                    for i = 1, #Config.Houses do
                        local house = Config.Houses[i]
                        local data = houseCache[house.id]
                        if data and (data.owned or data.access) then
                            ExitHouse(house)
                            break
                        end
                    end
                end
            else
                -- Əmlak agentliyi
                local agencyDist = #(coords - Config.Agency.coords)
                if agencyDist < 3.0 then
                    wait = 0
                    showingUI = true
                    ESX.TextUI(('[E] — %s (~y~evlər~s~)'):format(Config.Agency.name), 'info')
                    if IsControlJustPressed(0, 38) then
                        OpenAgencyMenu()
                    end
                else
                    HideUI()
                end
            end
        end

        Wait(wait)
    end
end)
