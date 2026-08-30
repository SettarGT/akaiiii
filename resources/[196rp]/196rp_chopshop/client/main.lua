local QBCore = exports['qb-core']:GetCoreObject()
local chopping = false

local function GetClosestVehicle()
    local coords = GetEntityCoords(PlayerPedId())
    local veh
    for _, v in ipairs(GetAllVehicles()) do
        local d = #(GetEntityCoords(v) - coords)
        if d < Config.Chop.MaxDistance and (not veh or d < #(GetEntityCoords(veh) - coords)) then
            veh = v
        end
    end
    return veh
end

local function OpenChop()
    if chopping then return end
    local veh = GetClosestVehicle()
    if not veh then
        QBCore.Functions.Notify('Yaxınlıqda maşın yoxdur! (8m içində)', 'error')
        return
    end
    local plate = GetVehicleNumberPlateText(veh)
    exports['qb-menu']:openMenu({
        { header = '🔧 Söküm sexi', isMenuHeader = true, icon = 'fas fa-car-crash' },
        { header = '🚗 Maşını sök', txt = string.format('Plitə: %s · %d saniyə · polis xəbərdarlığı', plate, Config.Chop.Time), icon = 'fas fa-hammer', params = { act = 'chop' } },
    }, function(selected)
        if selected and selected.params and selected.params.act == 'chop' then
            chopping = true
            exports['progressbar']:Progress({
                name = '196chop',
                duration = Config.Chop.Time * 1000,
                label = 'Maşın sökülür...',
                useWhileDead = false,
                canCancel = false,
                controlDisables = { disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true },
            })
            TriggerServerEvent('196rp_chopshop:server:start', plate)
            SetTimeout(Config.Chop.Time * 1000 + 300, function()
                chopping = false
            end)
        end
    end)
end

local function OpenSell()
    exports['qb-menu']:openMenu({
        { header = '💰 Qara bazar', isMenuHeader = true, icon = 'fas fa-coins' },
        { header = 'Metal hissələri sat', txt = string.format('₣%d / ədəd', Config.Prices.ScrapPrice), icon = 'fas fa-hand-holding-usd', params = { act = 'sell' } },
    }, function(selected)
        if selected and selected.params and selected.params.act == 'sell' then
            TriggerServerEvent('196rp_chopshop:server:sell')
        end
    end)
end

RegisterNetEvent('196rp_chopshop:client:deleteVehicle', function(plate)
    for _, v in ipairs(GetAllVehicles()) do
        if GetVehicleNumberPlateText(v) == plate and #(GetEntityCoords(v) - GetEntityCoords(PlayerPedId())) < 15 then
            DeleteVehicle(v)
            break
        end
    end
end)

CreateThread(function()
    local loc = Config.Location
    local blip = AddBlipForCoord(loc.coords)
    SetBlipSprite(blip, 566)
    SetBlipColour(blip, 46)
    SetBlipScale(blip, 0.7)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(loc.label)
    EndTextCommandSetBlipName(blip)

    exports['qb-target']:AddBoxZone('196chop', loc.coords, 4.0, 3.0, {
        name = '196chop', heading = loc.heading, debugPoly = false,
        minZ = loc.coords.z - 1, maxZ = loc.coords.z + 3,
    }, { options = { { label = '[E] ' .. loc.label, icon = 'fas fa-car-crash', action = OpenChop } } })

    exports['qb-target']:AddBoxZone('196chopsell', Config.SellPoint.coords, 2.0, 2.0, {
        name = '196chopsell', heading = 0.0, debugPoly = false,
        minZ = Config.SellPoint.coords.z - 1, maxZ = Config.SellPoint.coords.z + 2,
    }, { options = { { label = '[E] ' .. Config.SellPoint.label, icon = 'fas fa-coins', action = OpenSell } } })
end)
