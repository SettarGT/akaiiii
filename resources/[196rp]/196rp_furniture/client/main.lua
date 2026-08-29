-- 196 RP | Ev interyeri — müştəri tərəfi

local spawnedProps = {}   -- furnitureId → prop entity
local loadedHouse = nil
local placing = nil       -- { id, model, obj, rotation }
-- Mebel mağazası interaksiyası
CreateThread(function()
    while true do
        local wait = 750
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local dist = #(coords - Config.Store.coords)

        if dist < 50.0 then
            wait = 0
            DrawMarker(27, Config.Store.coords.x, Config.Store.coords.y, Config.Store.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                1.2, 1.2, 0.6, 140, 90, 200, 170, false, true, 2, nil, nil, false)
        end

        if dist < 2.2 then
            ESX.TextUI('[E] — Mebel Mağazası', 'info')
            if IsControlJustPressed(0, 38) then
                OpenStoreMenu()
            end
        else
            ESX.HideUI()
        end

        Wait(wait)
    end
end)

-- ==================== MAĞAZA ====================

function OpenStoreMenu()
    local menu = {
        { icon = 'fas fa-couch', title = '🛋 Mebel Mağazası', unselectable = true },
        { icon = 'fas fa-info-circle', title = 'Əvvəlcə evə sahib olmalısınız!', unselectable = true },
    }
    for i = 1, #Config.Furniture do
        local f = Config.Furniture[i]
        menu[#menu + 1] = {
            icon = 'fas fa-couch',
            title = ('%s (~g~$%s~s~)'):format(f.label, f.price),
            name = 'buy_' .. f.model,
        }
    end

    exports['esx_context']:Open('right', menu, function(selected)
        local model = selected.name:match('^buy_(.+)$')
        if not model then return end

        -- Ev seç
        ESX.TriggerServerCallback('196rp_housing:getOwnedHouses', function(houses)
            if not houses or #houses == 0 then
                ESX.ShowNotification('~r~Sizə məxsus ev yoxdur!~s~ Əvvəlcə ev alın.', 'error')
                return
            end
            local hmenu = {
                { icon = 'fas fa-home', title = 'Hansı evə mebel alırsınız?', unselectable = true },
            }
            for i = 1, #houses do
                hmenu[#hmenu + 1] = {
                    icon = 'fas fa-home',
                    title = houses[i].house_id,
                    name = 'house_' .. houses[i].house_id,
                }
            end
            exports['esx_context']:Open('right', hmenu, function(hselected)
                local houseId = hselected.name:match('^house_(.+)$')
                if houseId then
                    ESX.TriggerServerCallback('196rp_furniture:buy', function(ok, msg)
                        ESX.ShowNotification(msg, ok and 'success' or 'error', 6000)
                    end, model, houseId)
                end
            end)
        end)
    end)
end

-- ==================== /mebel ƏMRİ ====================

RegisterCommand('mebel', function()
    local coords = GetEntityCoords(PlayerPedId())
    -- Yalnız ev interyerində işləyir
    local dist = #(coords - Config.Interior)
    if dist > 25.0 then
        ESX.ShowNotification('Mebel yerləşdirmək üçün evin interyerində olmalısınız!', 'error')
        return
    end
    OpenFurnitureMenu()
end, false)

function OpenFurnitureMenu()
    -- Ən yaxın ev hansı? (interyer üçün)
    ESX.TriggerServerCallback('196rp_housing:getOwnedHouses', function(houses)
        if not houses or #houses == 0 then
            ESX.ShowNotification('Sizə məxsus ev yoxdur!', 'error')
            return
        end

        local hmenu = {
            { icon = 'fas fa-home', title = 'Evinizi seçin', unselectable = true },
        }
        for i = 1, #houses do
            hmenu[#hmenu + 1] = {
                icon = 'fas fa-home',
                title = houses[i].house_id,
                name = 'house_' .. houses[i].house_id,
            }
        end
        exports['esx_context']:Open('right', hmenu, function(hselected)
            local houseId = hselected.name:match('^house_(.+)$')
            if houseId then
                ManageHouseFurniture(houseId)
            end
        end)
    end)
end

function ManageHouseFurniture(houseId)
    ESX.TriggerServerCallback('196rp_furniture:getHouseFurniture', function(furniture)
        if not furniture then return end

        local menu = {
            { icon = 'fas fa-couch', title = ('Mebellər — %s'):format(houseId), unselectable = true },
        }
        for i = 1, #furniture do
            local f = furniture[i]
            local status = f.placed == 1 and '✅ yerləşdirilib' or '📦 anbarda'
            menu[#menu + 1] = {
                icon = 'fas fa-couch',
                title = ('%s — ~y~%s~s~'):format(f.label, status),
                name = 'item_' .. f.id,
            }
        end

        exports['esx_context']:Open('right', menu, function(selected)
            local fid = selected.name:match('^item_(%d+)$')
            if not fid then return end

            local item = nil
            for i = 1, #furniture do
                if tostring(furniture[i].id) == fid then
                    item = furniture[i]
                    break
                end
            end
            if not item then return end

            local amenu = {
                { icon = 'fas fa-couch', title = item.label, unselectable = true },
            }
            if item.placed == 1 then
                amenu[#amenu + 1] = { icon = 'fas fa-arrows-alt', title = '📍 Yerini dəyiş', name = 'place' }
                amenu[#amenu + 1] = { icon = 'fas fa-box', title = '📦 Anbara yığ', name = 'unplace' }
            else
                amenu[#amenu + 1] = { icon = 'fas fa-arrows-alt', title = '📍 Yerləşdir', name = 'place' }
            end
            amenu[#amenu + 1] = { icon = 'fas fa-dollar-sign', title = '💰 Sat (~g~yarı qiymət~s~)', name = 'sell' }
            amenu[#amenu + 1] = { icon = 'fas fa-arrow-left', title = '⬅ Geri', name = 'back' }

            exports['esx_context']:Open('right', amenu, function(aselected)
                if aselected.name == 'back' then
                    ManageHouseFurniture(houseId)
                elseif aselected.name == 'place' then
                    StartPlacing(houseId, item)
                elseif aselected.name == 'unplace' then
                    ESX.TriggerServerCallback('196rp_furniture:unplace', function(ok)
                        if ok then
                            ESX.ShowNotification('Mebel anbara yığıldı.', 'info')
                            ManageHouseFurniture(houseId)
                        end
                    end, item.id)
                elseif aselected.name == 'sell' then
                    ESX.TriggerServerCallback('196rp_furniture:sell', function(ok, msg)
                        ESX.ShowNotification(msg, ok and 'success' or 'error', 5000)
                        if ok then ManageHouseFurniture(houseId) end
                    end, item.id)
                end
            end)
        end)
    end, houseId)
end

-- ==================== YERLƏŞDİRMƏ ====================

function StartPlacing(houseId, item)
    if placing then return end

    local model = joaat(item.model)
    RequestModel(model)
    local tries = 0
    while not HasModelLoaded(model) and tries < 100 do
        Wait(10)
        tries = tries + 1
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped) + GetEntityForwardVector(ped) * 1.5
    local obj = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
    SetEntityHeading(obj, GetEntityHeading(ped))
    FreezeEntityPosition(obj, true)
    SetEntityCollision(obj, false, false)

    placing = { id = item.id, model = model, obj = obj, rotation = GetEntityHeading(ped), houseId = houseId }

    ESX.ShowNotification('Yerləşdirmək üçün [E], fırlatmaq üçün [R], ləğv üçün [BACKSPACE]', 'info', 6000)
end

CreateThread(function()
    while true do
        Wait(0)
        if placing then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped) + GetEntityForwardVector(ped) * Config.PlaceDistance
            local groundZ = coords.z
            -- yerdən hündürlük
            local _, hitZ = GetGroundZFor_3DCoord(coords.x, coords.y, coords.z + 2.0, false)
            if hitZ ~= 0.0 then groundZ = hitZ end
            coords = vector3(coords.x, coords.y, groundZ)

            SetEntityCoords(placing.obj, coords.x, coords.y, coords.z, true, false, false, false)
            DrawMarker(28, coords.x, coords.y, coords.z + 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8, 0.8, 0.3, 255, 255, 255, 140, false, true, 2, nil, nil, false)

            if IsControlJustPressed(0, Config.RotateKey) then
                placing.rotation = (placing.rotation + 15.0) % 360.0
                SetEntityHeading(placing.obj, placing.rotation)
            end
            if IsControlJustPressed(0, Config.ConfirmKey) then
                local finalCoords = { x = coords.x, y = coords.y, z = coords.z }
                local targetHouse = placing.houseId
                local fId = placing.id
                local fRot = placing.rotation
                ESX.TriggerServerCallback('196rp_furniture:place', function(ok)
                    if ok then
                        ESX.ShowNotification('~g~Mebel yerləşdirildi!~s~', 'success')
                    else
                        ESX.ShowNotification('Yerləşdirmə xətası!', 'error')
                    end
                end, fId, finalCoords, fRot)
                DeleteObject(placing.obj)
                placing = nil
                LoadHouseFurniture(targetHouse)
            elseif IsControlJustPressed(0, Config.CancelKey) then
                DeleteObject(placing.obj)
                placing = nil
                ESX.ShowNotification('Yerləşdirmə ləğv edildi.', 'info')
            end
        end
        Wait(10)
    end
end)

-- ==================== EV İNTERYERİNDƏ MEBELLƏRİ GÖSTƏR ====================

local function ClearProps()
    for id, prop in pairs(spawnedProps) do
        if DoesEntityExist(prop) then
            DeleteObject(prop)
        end
    end
    spawnedProps = {}
    loadedHouse = nil
end

function LoadHouseFurniture(houseId)
    ClearProps()
    if not houseId then return end
    loadedHouse = houseId

    ESX.TriggerServerCallback('196rp_furniture:getHouseFurniture', function(furniture)
        if loadedHouse ~= houseId then return end
        for i = 1, #furniture do
            local f = furniture[i]
            if f.placed == 1 and f.coords then
                local decoded = json.decode(f.coords)
                if decoded then
                    local model = joaat(f.model)
                    RequestModel(model)
                    local tries = 0
                    while not HasModelLoaded(model) and tries < 100 do
                        Wait(10)
                        tries = tries + 1
                    end
                    local obj = CreateObject(model, decoded.x, decoded.y, decoded.z, true, true, false)
                    SetEntityHeading(obj, f.rotation or 0)
                    FreezeEntityPosition(obj, true)
                    SetEntityCollision(obj, false, false)
                    spawnedProps[f.id] = obj
                end
            end
        end
    end, houseId)
end

CreateThread(function()
    while true do
        Wait(2000)
        local coords = GetEntityCoords(PlayerPedId())
        local dist = #(coords - Config.Interior)

        if dist < 25.0 then
            -- Hansı evə aid olduğunu tap (sadə: sahib olduğumuz ilk ev)
            ESX.TriggerServerCallback('196rp_housing:getOwnedHouses', function(houses)
                if houses and #houses > 0 then
                    if loadedHouse ~= houses[1].house_id then
                        LoadHouseFurniture(houses[1].house_id)
                    end
                elseif loadedHouse then
                    ClearProps()
                end
            end)
        elseif loadedHouse then
            ClearProps()
        end
        Wait(2000)
    end
end)
