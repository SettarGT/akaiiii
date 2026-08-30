local QBCore = exports['qb-core']:GetCoreObject()

local function OpenWorkshop()
    local menu = {
        { header = '🔧 Gizli Emalatxana', isMenuHeader = true, icon = 'fas fa-gear' },
    }
    for i, p in ipairs(Config.Parts) do
        menu[#menu + 1] = {
            header = p.label,
            txt = ('Metal: %d ədəd · %d san'):format(p.scrap, p.time),
            icon = 'fas fa-cog',
            params = { part = i },
        }
    end
    menu[#menu + 1] = {
        header = '🔫 ' .. Config.Assemble.label,
        txt = 'Çərçivə + Sürüşmə + Tetik (seriya yox)',
        icon = 'fas fa-gun',
        params = { assemble = true },
    }

    exports['qb-menu']:openMenu(menu, function(selected)
        if not selected or not selected.params then return end
        if selected.params.assemble then
            QBCore.Functions.Progressbar('ghost_assemble', 'Silah yığılır...', Config.Assemble.time * 1000, false, true, {
                disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true,
            }, function()
                TriggerServerEvent('196rp_ghostguns:server:assemble')
            end)
        elseif selected.params.part then
            QBCore.Functions.Progressbar('ghost_craft', 'Hissə hazırlanır...', Config.Parts[selected.params.part].time * 1000, false, true, {
                disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true,
            }, function()
                TriggerServerEvent('196rp_ghostguns:server:craft', selected.params.part)
            end)
        end
    end)
end

-- 911 ötürücüsü (dispatch varsa)
RegisterNetEvent('196rp_ghostguns:client:911', function(message)
    TriggerServerEvent('196rp_dispatch:server:911', message)
end)

CreateThread(function()
    local w = Config.Workshop
    local blip = AddBlipForCoord(w.coords)
    SetBlipSprite(blip, 566)
    SetBlipColour(blip, 1)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('?')
    EndTextCommandSetBlipName(blip)

    exports['qb-target']:AddBoxZone('196ghost', w.coords, 2.5, 2.5, {
        name = '196ghost', heading = 0, debugPoly = false,
        minZ = w.coords.z - 1, maxZ = w.coords.z + 3,
    }, {
        options = {
            { label = '[E] ' .. w.label, icon = 'fas fa-gear', action = OpenWorkshop },
        },
        distance = 2.5,
    })
end)
