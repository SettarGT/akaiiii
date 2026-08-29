local QBCore = exports['qb-core']:GetCoreObject()

local function ApplyMod(veh, slot, level)
    SetVehicleModKit(veh, 0)
    SetVehicleMod(veh, slot, level - 1, false)
end

local function SetVehicleColor(veh, c1, c2)
    SetVehicleColours(veh, c1, c2)
end

local function ResetVehicle(veh)
    SetVehicleModKit(veh, 0)
    for _, slot in ipairs({ 11, 12, 13, 15, 16 }) do
        RemoveVehicleMod(veh, slot)
    end
    ToggleVehicleMod(veh, 18, false)
    ToggleVehicleMod(veh, 22, false)
end

local function Buy(label, price, applyFn)
    QBCore.Functions.TriggerCallback('196rp_tuning:pay', function(ok)
        if ok then
            applyFn()
            QBCore.Functions.Notify(Config.Text.paid:gsub('%%{price}', tostring(price)), 'success')
        else
            QBCore.Functions.Notify(Config.Text.not_enough, 'error')
        end
    end, price, label)
end

local function OpenColorMenu(veh)
    local menu = {
        { header = Config.Text.color_menu, isMenuHeader = true, icon = 'fas fa-palette' },
        { header = Config.Text.close, icon = 'fas fa-arrow-left', params = { back = true } },
    }
    for i, color in ipairs(Config.Colors) do
        menu[#menu + 1] = {
            header = color.label,
            icon = 'fas fa-circle',
            params = { color = i },
        }
    end
    exports['qb-menu']:openMenu(menu, function(selected)
        if not selected then return end
        if selected.params and selected.params.back then
            OpenTuningMenu(veh)
            return
        end
        local color = Config.Colors[selected.params.color]
        if color then
            Buy(color.label, 300, function()
                SetVehicleColor(veh, color.color1, color.color2)
            end)
        end
    end)
end

local function OpenCatMenu(cat, veh)
    local menu = {
        { header = cat.label, isMenuHeader = true, icon = 'fas fa-cog' },
        { header = Config.Text.close, icon = 'fas fa-arrow-left', params = { back = true } },
    }
    for level, lvl in ipairs(cat.levels) do
        menu[#menu + 1] = {
            header = ('Səviyyə %d — $%d'):format(level, lvl.price),
            icon = 'fas fa-gauge',
            params = { level = level },
        }
    end
    exports['qb-menu']:openMenu(menu, function(selected)
        if not selected then return end
        if selected.params and selected.params.back then
            OpenTuningMenu(veh)
            return
        end
        local level = selected.params.level
        if level then
            Buy(cat.label .. ' ' .. level, cat.levels[level].price, function()
                ApplyMod(veh, cat.slot, level)
            end)
        end
    end)
end

function OpenTuningMenu(veh)
    local menu = {
        { header = Config.Text.header, isMenuHeader = true, icon = 'fas fa-wrench' },
    }
    for i, cat in ipairs(Config.Categories) do
        menu[#menu + 1] = {
            header = cat.label,
            icon = 'fas fa-arrow-right',
            params = { cat = i },
        }
    end
    menu[#menu + 1] = {
        header = Config.Text.turbo .. ' — $' .. Config.TurboPrice,
        icon = 'fas fa-bolt',
        params = { turbo = true },
    }
    menu[#menu + 1] = {
        header = Config.Text.xenon .. ' — $' .. Config.XenonPrice,
        icon = 'fas fa-lightbulb',
        params = { xenon = true },
    }
    menu[#menu + 1] = {
        header = Config.Text.color_menu,
        icon = 'fas fa-palette',
        params = { colors = true },
    }
    menu[#menu + 1] = {
        header = Config.Text.stock,
        icon = 'fas fa-undo',
        params = { stock = true },
    }
    exports['qb-menu']:openMenu(menu, function(selected)
        if not selected or not selected.params then return end
        if selected.params.cat then
            OpenCatMenu(Config.Categories[selected.params.cat], veh)
        elseif selected.params.turbo then
            Buy(Config.Text.turbo, Config.TurboPrice, function()
                ToggleVehicleMod(veh, 18, true)
            end)
        elseif selected.params.xenon then
            Buy(Config.Text.xenon, Config.XenonPrice, function()
                ToggleVehicleMod(veh, 22, true)
            end)
        elseif selected.params.colors then
            OpenColorMenu(veh)
        elseif selected.params.stock then
            ResetVehicle(veh)
            QBCore.Functions.Notify(Config.Text.stock_done, 'success')
        end
    end)
end

CreateThread(function()
    for i, shop in ipairs(Config.Shops) do
        local blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)
        SetBlipSprite(blip, 72)
        SetBlipColour(blip, 5)
        SetBlipScale(blip, 0.8)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(shop.name)
        EndTextCommandSetBlipName(blip)

        exports['qb-target']:AddBoxZone('196tune_' .. i, shop.coords, 3.0, 3.0, {
            name = '196tune_' .. i,
            heading = shop.heading,
            debugPoly = false,
            minZ = shop.coords.z - 1,
            maxZ = shop.coords.z + 3,
        }, {
            options = {
                {
                    label = '[E] ' .. shop.name,
                    icon = 'fa-solid fa-wrench',
                    action = function()
                        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                        if veh == 0 then return end
                        if GetPedInVehicleSeat(veh, -1) ~= PlayerPedId() then
                            QBCore.Functions.Notify(Config.Text.need_driver, 'error')
                            return
                        end
                        OpenTuningMenu(veh)
                    end,
                },
            },
            distance = 2.5,
        })
    end
end)
