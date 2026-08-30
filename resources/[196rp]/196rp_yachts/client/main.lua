local QBCore = exports['qb-core']:GetCoreObject()
local activeYacht = nil

local function OpenMarina()
    QBCore.Functions.TriggerCallback('196rp_yachts:server:getOwned', function(owned)
        owned = owned or {}
        local menu = {
            { header = '🛥 196 Marina', isMenuHeader = true, icon = 'fas fa-ship' },
        }
        for _, y in ipairs(Config.Yachts) do
            local isOwned = false
            for _, m in ipairs(owned) do if m == y.model then isOwned = true end end
            menu[#menu + 1] = {
                header = y.label .. (isOwned and ' ⭐' or ''),
                txt = string.format('İcarə: ₣%d/%d dəq · Alış: ₣%d', y.rentPrice, math.floor(y.rentTime / 60), y.buyPrice),
                icon = 'fas fa-ship',
                params = { model = y.model, owned = isOwned },
            }
        end
        menu[#menu + 1] = { header = '↩️ Yaxtanı qaytar', icon = 'fas fa-undo', params = { action = 'return' } }

        exports['qb-menu']:openMenu(menu, function(selected)
            if not selected or not selected.params then return end
            local p = selected.params
            if p.action == 'return' then
                TriggerServerEvent('196rp_yachts:server:return')
            elseif p.model and p.owned then
                TriggerServerEvent('196rp_yachts:server:call', p.model)
            elseif p.model then
                TriggerServerEvent('196rp_yachts:server:rent', p.model)
            end
        end)
    end)
end

RegisterCommand('yaxta', function()
    if #(GetEntityCoords(PlayerPedId()) - Config.Kiosk.coords) < 30.0 then
        OpenMarina()
    else
        QBCore.Functions.Notify('Kiosk yaxınlığında olmalısınız (196 Marina).', 'primary')
    end
end, false)

RegisterNetEvent('196rp_yachts:client:spawn', function(model)
    if activeYacht and DoesEntityExist(activeYacht) then
        DeleteEntity(activeYacht)
        activeYacht = nil
    end
    RequestModel(model)
    local t = 0
    while not HasModelLoaded(model) and t < 200 do Wait(20) t = t + 1 end
    if not HasModelLoaded(model) then
        QBCore.Functions.Notify('Yaxta modeli yüklənə bilmədi!', 'error')
        return
    end
    local spawn = Config.SpawnPoints[math.random(#Config.SpawnPoints)]
    activeYacht = CreateVehicle(model, spawn.x, spawn.y, spawn.z, Config.SpawnHeading, true, false)
    SetVehicleNumberPlateText(activeYacht, '196YHT')
    SetBoatAnchor(activeYacht, true)
    SetEntityHeading(activeYacht, Config.SpawnHeading)
    QBCore.Functions.Notify('🛥 Yaxta limanda — minib sürmək üçün [G].', 'success')
end)

RegisterNetEvent('196rp_yachts:client:despawn', function()
    if activeYacht and DoesEntityExist(activeYacht) then
        DeleteEntity(activeYacht)
    end
    activeYacht = nil
end)

CreateThread(function()
    local kiosk = Config.Kiosk
    local blip = AddBlipForCoord(kiosk.coords)
    SetBlipSprite(blip, 455)
    SetBlipColour(blip, 5)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('196 Marina')
    EndTextCommandSetBlipName(blip)

    local kioskEntity = CreateObject(GetHashKey(kiosk.prop), kiosk.coords.x, kiosk.coords.y, kiosk.coords.z, true, true, false)
    SetEntityHeading(kioskEntity, kiosk.heading)
    FreezeEntityPosition(kioskEntity, true)

    exports['qb-target']:AddTargetEntity(kioskEntity, {
        options = {
            { label = '[E] ' .. kiosk.label, icon = 'fas fa-ship', action = OpenMarina },
        },
        distance = 2.5,
    })
end)
