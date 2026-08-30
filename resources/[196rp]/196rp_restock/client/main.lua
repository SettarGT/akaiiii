local QBCore = exports['qb-core']:GetCoreObject()

-- Kiosk yanlış olduqda default
local function OpenKioskMenu(innerKioskId)
    local menu = {
        { header = '📦 196 Restock Kiosk', txt = 'Mağaza anbarını doldur (₣500 · 5 dəq gözləmə)', isMenuHeader = true, icon = 'fas fa-boxes-stacked' },
    }
    for _, k in ipairs(Config.Kiosks) do
        menu[#menu + 1] = {
            header = k.label,
            txt = 'Məhsul ehtiyatı: +10–50 ədəd · ₣' .. Config.Fee,
            icon = 'fas fa-warehouse',
            params = { kioskId = k.id },
        }
    end
    menu[#menu + 1] = {
        header = '🚚 Kuryer sifarişi',
        txt = ('Mağazaya tədarük sifarişi ver (₣%d) — kuryer işi üçün'):format(Config.Courier.OrderFee),
        icon = 'fas fa-truck',
        params = { order = true, kioskId = innerKioskId },
    }
    menu[#menu + 1] = {
        header = '📦 Qutunu təhvil ver',
        txt = 'Əlinizdəki restock qutusunu bu mağazaya çatdır',
        icon = 'fas fa-box',
        params = { deliver = true, kioskId = innerKioskId },
    }

    exports['qb-menu']:openMenu(menu, function(selected)
        if not selected or not selected.params then return end
        if selected.params.order then
            TriggerServerEvent('196rp_restock:server:order', selected.params.kioskId)
        elseif selected.params.deliver then
            TriggerServerEvent('196rp_restock:server:deliver', selected.params.kioskId)
        elseif selected.params.kioskId then
            TriggerServerEvent('196rp_restock:server:do', selected.params.kioskId)
        end
    end)
end

CreateThread(function()
    -- Logistika anbarı (kuryer)
    local w = Config.Warehouse
    exports['qb-target']:AddBoxZone('196warehouse', w.coords, w.radius, w.radius, {
        name = '196warehouse', heading = 0, debugPoly = false,
        minZ = w.coords.z - 1, maxZ = w.coords.z + 3,
    }, {
        options = {
            { label = '[E] ' .. w.label .. ' — sifarişi götür', icon = 'fas fa-truck', action = function()
                TriggerServerEvent('196rp_restock:server:pickup')
            end },
        },
        distance = 2.5,
    })
    local wblip = AddBlipForCoord(w.coords)
    SetBlipSprite(wblip, 478)
    SetBlipColour(wblip, 47)
    SetBlipScale(wblip, 0.8)
    SetBlipAsShortRange(wblip, true)

    for _, k in ipairs(Config.Kiosks) do
        exports['qb-target']:AddBoxZone('196restock_' .. k.id, k.coords, 2.5, 2.5, {
            name = '196restock_' .. k.id,
            heading = 0.0,
            debugPoly = false,
            minZ = k.coords.z - 1,
            maxZ = k.coords.z + 3,
        }, {
            options = {
                {
                    label = '[E] 📦 Restock: ' .. k.label,
                    icon = 'fas fa-boxes-stacked',
                    action = function() OpenKioskMenu(k.id) end,
                },
            },
            distance = 2.5,
        })

        local blip = AddBlipForCoord(k.coords)
        SetBlipSprite(blip, 566)
        SetBlipColour(blip, 5)
        SetBlipScale(blip, 0.6)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName('196 Restock')
        EndTextCommandSetBlipName(blip)
    end
end)
