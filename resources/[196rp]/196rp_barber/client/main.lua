-- 196 RP | Bərbər və Döymə salonu — müştəri tərəfi

local myTattoos = {}   -- saxlanmış döymə overlays
local blips = {}

-- Bliplər
CreateThread(function()
    for i = 1, #Config.Barbers do
        local loc = Config.Barbers[i]
        local blip = AddBlipForCoord(loc.coords.x, loc.coords.y, loc.coords.z)
        SetBlipSprite(blip, 71)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 17)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(loc.name)
        EndTextCommandSetBlipName(blip)
        blips[i] = blip
    end
    for i = 1, #Config.Tattoos do
        local loc = Config.Tattoos[i]
        local blip = AddBlipForCoord(loc.coords.x, loc.coords.y, loc.coords.z)
        SetBlipSprite(blip, 75)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 4)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(loc.name)
        EndTextCommandSetBlipName(blip)
        blips[#blips + 1] = blip
    end
end)

-- Saxlanmış döymələri tətbiq et
local function ApplyTattoos(overlays)
    local ped = PlayerPedId()
    ClearPedDecorations(ped)
    for i = 1, #overlays do
        local t = overlays[i]
        if t.collection and t.overlay then
            local coll = GetHashKey(t.collection)
            local ovl = GetHashKey(t.overlay)
            if not HasDecorationLoaded(coll, ovl) then
                RequestDecoration(coll, ovl)
                local tries = 0
                while not HasDecorationLoaded(coll, ovl) and tries < 50 do
                    Wait(10)
                    tries = tries + 1
                end
            end
            if HasDecorationLoaded(coll, ovl) then
                AddPedDecorationFromHashes(ped, coll, ovl)
            end
        end
    end
end

-- Girişdə döymələri yüklə
AddEventHandler('esx:playerLoaded', function()
    ESX.TriggerServerCallback('196rp_barber:getTattoos', function(overlays)
        myTattoos = overlays or {}
        local tries = 0
        while not DoesEntityExist(PlayerPedId()) and tries < 100 do
            Wait(50)
            tries = tries + 1
        end
        ApplyTattoos(myTattoos)
    end)
end)

-- Marker + interaksiya
CreateThread(function()
    while true do
        local wait = 750
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local nearest = nil
        local nearestType = nil
        local nearestDist = 999.0

        for i = 1, #Config.Barbers do
            local loc = Config.Barbers[i]
            local dist = #(coords - loc.coords)
            if dist < 50.0 then
                wait = 0
                DrawMarker(20, loc.coords.x, loc.coords.y, loc.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.6, 255, 200, 100, 170, false, true, 2, nil, nil, false)
            end
            if dist < 2.0 and dist < nearestDist then
                nearestDist = dist
                nearest = loc
                nearestType = 'barber'
            end
        end

        for i = 1, #Config.Tattoos do
            local loc = Config.Tattoos[i]
            local dist = #(coords - loc.coords)
            if dist < 50.0 then
                wait = 0
                DrawMarker(20, loc.coords.x, loc.coords.y, loc.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.6, 255, 100, 200, 170, false, true, 2, nil, nil, false)
            end
            if dist < 2.0 and dist < nearestDist then
                nearestDist = dist
                nearest = loc
                nearestType = 'tattoo'
            end
        end

        if nearest then
            ESX.TextUI(('[E] — ~y~%s~s~'):format(nearest.name), 'info')
            if IsControlJustPressed(0, 38) then
                if nearestType == 'barber' then
                    OpenBarberMenu()
                else
                    OpenTattooMenu()
                end
            end
        else
            ESX.HideUI()
        end

        Wait(wait)
    end
end)

-- ==================== BƏRBƏR ====================

function OpenBarberMenu()
    -- esx_skin-in məhdud menyusunu aç (yalnız saç/saqqal/makiyaj)
    TriggerEvent('esx_skin:openSaveableRestrictedMenu', function()
        ESX.ShowNotification('~g~Görünüşünüz yeniləndi!~s~', 'success')
    end, function()
    end, Config.BarberRestrict)
end

-- ==================== DÖYMƏ ====================

function OpenTattooMenu()
    local menu = {
        { icon = 'fas fa-paint-brush', title = 'Döymə seçin', unselectable = true },
    }
    for i = 1, #Config.TattooCategories do
        local cat = Config.TattooCategories[i]
        menu[#menu + 1] = {
            icon = 'fas fa-angle-right',
            title = cat.label,
            name = cat.name,
        }
    end
    menu[#menu + 1] = {
        icon = 'fas fa-eraser',
        title = 'Bütün döymələri sil',
        name = 'clear',
    }

    exports['esx_context']:Open('right', menu, function(selected)
        if selected.name == 'clear' then
            ClearPedDecorations(PlayerPedId())
            myTattoos = {}
            TriggerServerEvent('196rp_barber:saveTattoos', myTattoos)
            ESX.ShowNotification('~y~Bütün döymələr silindi.~s~', 'info')
            return
        end

        for i = 1, #Config.TattooCategories do
            if Config.TattooCategories[i].name == selected.name then
                OpenTattooCategory(i)
                break
            end
        end
    end)
end

function OpenTattooCategory(catIndex)
    local cat = Config.TattooCategories[catIndex]
    local menu = {}
    for j = 1, #cat.items do
        local it = cat.items[j]
        menu[#menu + 1] = {
            icon = 'fas fa-paint-brush',
            title = ('%s (~g~$%s~s~)'):format(it.label, Config.TattooPrice),
            name = tostring(j),
        }
    end
    menu[#menu + 1] = {
        icon = 'fas fa-arrow-left',
        title = '⬅ Geri',
        name = 'back',
    }

    exports['esx_context']:Open('right', menu, function(selected)
        if selected.name == 'back' then
            OpenTattooMenu()
            return
        end
        local idx = tonumber(selected.name)
        local item = cat.items[idx]
        if not item then return end

        -- Döyməni tətbiq et və yadda saxla
        local already = false
        for k = 1, #myTattoos do
            if myTattoos[k].overlay == item.overlay then
                already = true
                break
            end
        end

        if already then
            ESX.ShowNotification('Bu döymə artıq var!', 'info')
            return
        end

        ESX.TriggerServerCallback('196rp_barber:buyTattoo', function(ok)
            if ok then
                myTattoos[#myTattoos + 1] = { collection = item.collection, overlay = item.overlay }
                ApplyTattoos(myTattoos)
                TriggerServerEvent('196rp_barber:saveTattoos', myTattoos)
                ESX.ShowNotification(('~g~Döymə vuruldu! -$%s~s~'):format(Config.TattooPrice), 'success')
            else
                ESX.ShowNotification('Pulunuz kifayət deyil! (~g~$' .. Config.TattooPrice .. '~s~)', 'error')
            end
        end)
    end)
end
