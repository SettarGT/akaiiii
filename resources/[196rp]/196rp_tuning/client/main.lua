-- 196 RP | Tuninq — client tərəfi
-- Emalatxanaya yaxın + maşında sürücü yerində: [E] ilə menyu açılır.
-- Bütün vizual native-lər client-dədir (server yalnız ödənişi yoxlayır).

local uiShown = false

-- ==================== BLİPLƏR ====================

CreateThread(function()
    for _, shop in ipairs(Config.Shops) do
        local blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)
        SetBlipSprite(blip, Config.BlipSprite)
        SetBlipColour(blip, Config.BlipColor)
        SetBlipScale(blip, 0.8)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(shop.name)
        EndTextCommandSetBlipName(blip)
    end
end)

-- ==================== TƏTBİQ ====================

local function ApplyMod(veh, slot, level)
    SetVehicleModKit(veh, 0)
    SetVehicleMod(veh, slot, level - 1, false)
end

local function ApplyStock(veh)
    SetVehicleModKit(veh, 0)
    for _, cat in ipairs(Config.Categories) do
        RemoveVehicleMod(veh, cat.slot)
    end
    ToggleVehicleMod(veh, 18, false) -- turbo
    ToggleVehicleMod(veh, 22, false) -- ksenon
end

local function Buy(price, label, applyFn)
    ESX.TriggerServerCallback('196rp_tuning:pay', function(ok)
        if ok and applyFn then
            applyFn()
        end
    end, price, label)
end

-- ==================== MENYULAR ====================

local function OpenColorMenu(veh)
    local menu = {
        { icon = 'fas fa-palette', title = 'Rəng seçin', unselectable = true },
        { icon = 'fas fa-angle-left', title = 'Geri', name = 'back' },
    }
    for i, col in ipairs(Config.Colors) do
        menu[#menu + 1] = { icon = 'fas fa-circle', title = col.label, name = tostring(i) }
    end

    exports['esx_context']:Open('right', menu, function(selected)
        if selected.name == 'back' then
            OpenTuningMenu(veh)
            return
        end
        local col = Config.Colors[tonumber(selected.name) or 0]
        if col then
            SetVehicleModKit(veh, 0)
            SetVehicleColours(veh, col.c1, col.c2)
            ESX.ShowNotification(('~g~Rəng dəyişdirildi:~s~ %s'):format(col.label), 'success')
        end
    end)
end

local function OpenCatMenu(veh, catIndex)
    local cat = Config.Categories[catIndex]
    local menu = {
        { icon = 'fas fa-cog', title = cat.label, unselectable = true },
        { icon = 'fas fa-angle-left', title = 'Geri', name = 'back' },
    }
    for i = 1, cat.maxLevel do
        menu[#menu + 1] = {
            icon = 'fas fa-angle-right',
            title = ('%s — %s$'):format(cat.levels[i], cat.prices[i]),
            name = tostring(i),
        }
    end

    exports['esx_context']:Open('right', menu, function(selected)
        if selected.name == 'back' then
            OpenTuningMenu(veh)
            return
        end
        local level = tonumber(selected.name)
        if not level then
            return
        end
        Buy(cat.prices[level], cat.label .. ' ' .. cat.levels[level], function()
            ApplyMod(veh, cat.slot, level)
        end)
    end)
end

function OpenTuningMenu(veh)
    local menu = {
        { icon = 'fas fa-wrench', title = 'Tuninq emalatxanası', unselectable = true },
    }

    for i, cat in ipairs(Config.Categories) do
        menu[#menu + 1] = { icon = 'fas fa-angle-right', title = cat.label, name = 'cat_' .. i }
    end

    menu[#menu + 1] = { icon = 'fas fa-bolt', title = ('Turbo — %s$'):format(Config.TurboPrice), name = 'turbo' }
    menu[#menu + 1] = { icon = 'fas fa-lightbulb', title = ('Ksenon faralar — %s$'):format(Config.XenonPrice), name = 'xenon' }
    menu[#menu + 1] = { icon = 'fas fa-palette', title = 'Rəng', name = 'colors' }
    menu[#menu + 1] = { icon = 'fas fa-undo', title = 'Fabrik vəziyyəti (pulsuz)', name = 'stock' }

    exports['esx_context']:Open('right', menu, function(selected)
        if selected.name and selected.name:sub(1, 4) == 'cat_' then
            OpenCatMenu(veh, tonumber(selected.name:sub(5)) or 1)
        elseif selected.name == 'turbo' then
            Buy(Config.TurboPrice, 'Turbo', function()
                SetVehicleModKit(veh, 0)
                ToggleVehicleMod(veh, 18, true)
            end)
        elseif selected.name == 'xenon' then
            Buy(Config.XenonPrice, 'Ksenon faralar', function()
                SetVehicleModKit(veh, 0)
                ToggleVehicleMod(veh, 22, true)
            end)
        elseif selected.name == 'colors' then
            OpenColorMenu(veh)
        elseif selected.name == 'stock' then
            ApplyStock(veh)
            ESX.ShowNotification('~g~Maşın fabrik vəziyyətinə qaytarıldı.~s~', 'success')
        end
    end)
end

-- ==================== YAXINLIQ + [E] ====================

CreateThread(function()
    while true do
        Wait(300)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local veh = GetVehiclePedIsIn(ped, false)

        local near = nil
        for i = 1, #Config.Shops do
            if #(coords - Config.Shops[i].coords) < Config.InteractDist then
                near = Config.Shops[i]
                break
            end
        end

        if near and veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then
            if not uiShown then
                uiShown = true
                exports['esx_textui']:TextUI(('[E] Tuninq — %s'):format(near.name), 'info')
            end
            if IsControlJustPressed(0, 38) then
                OpenTuningMenu(veh)
            end
        elseif uiShown then
            uiShown = false
            exports['esx_textui']:HideUI()
        end
    end
end)
