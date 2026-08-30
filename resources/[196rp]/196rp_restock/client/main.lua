local QBCore = exports['qb-core']:GetCoreObject()

-- Kiosk yanlış olduqda default
local function OpenKioskMenu()
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

    exports['qb-menu']:openMenu(menu, function(selected)
        if selected and selected.params and selected.params.kioskId then
            TriggerServerEvent('196rp_restock:server:do', selected.params.kioskId)
        end
    end)
end

CreateThread(function()
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
                    action = OpenKioskMenu,
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
