local fuelBlips = {}
local showingUI = false
local fuelSyncTimer = 0
local lowFuelNotified = false

local function HideUI()
    if showingUI then
        showingUI = false
        ESX.HideUI()
    end
end

-- Bliplər
CreateThread(function()
    for i = 1, #Config.Stations do
        local station = Config.Stations[i]
        local blip = AddBlipForCoord(station.coords.x, station.coords.y, station.coords.z)
        SetBlipSprite(blip, 361)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 1)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(station.name)
        EndTextCommandSetBlipName(blip)
        fuelBlips[i] = blip
    end
end)

local function GetVehicleFuel()
    local fuel = GetVehicleFuelLevel(GetVehiclePedIsIn(PlayerPedId(), false))
    return fuel
end

local function SetVehicleFuel(vehicle, fuel)
    SetVehicleFuelLevel(vehicle, fuel + 0.0)
end

-- Yanacaq sərfiyyatı və sinxronizasiya
CreateThread(function()
    while true do
        Wait(1000)

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle and vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
            local plate = GetVehicleNumberPlateText(vehicle)

            -- Yalnız oyunçunun öz maşınları (196RP...)
            if plate:sub(1, 5) == '196RP' then
                local fuel = GetVehicleFuel()
                local engineOn = GetIsVehicleEngineRunning(vehicle)

                if engineOn then
                    local speed = GetEntitySpeed(vehicle) * 3.6 -- km/saat
                    local consumption = (Config.ConsumptionBase / 60) * (1 + speed / 120)
                    fuel = math.max(0, fuel - consumption)
                    SetVehicleFuel(vehicle, fuel)

                    if fuel <= 0 then
                        SetVehicleEngineOn(vehicle, false, true, true)
                        SetVehicleUndrivable(vehicle, false)
                        ESX.ShowNotification('~r~Yanacaq qurtardı!~s~ Yanacaqdoldurma məntəqəsinə gedin.', 'error', 5000)
                        lowFuelNotified = false
                    elseif fuel < 15 and not lowFuelNotified then
                        lowFuelNotified = true
                        ESX.ShowNotification('~y~Yanacaq azalır!~s~ Doldurmağı unutmayın.', 'warning', 5000)
                    elseif fuel >= 15 then
                        lowFuelNotified = false
                    end

                    -- Hər 10 saniyədən bir serverə göndər
                    if GetGameTimer() - fuelSyncTimer > 10000 then
                        fuelSyncTimer = GetGameTimer()
                        TriggerServerEvent('196rp_fuel:sync', plate, math.floor(fuel * 10) / 10)
                    end
                end
            end
        end
    end
end)

-- Yaxın maşını tap
local function GetClosestOwnedVehicle()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local closest = 0
    local closestDist = 12.0

    local vehicles = ESX.Game.GetVehiclesInArea(coords, 12.0)
    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        local plate = GetVehicleNumberPlateText(vehicle)
        if plate:sub(1, 5) == '196RP' then
            local dist = #(coords - GetEntityCoords(vehicle))
            if dist < closestDist then
                closestDist = dist
                closest = vehicle
            end
        end
    end

    return closest
end

-- Yanacaq doldur
local function Refuel(station)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if not vehicle or vehicle == 0 then
        vehicle = GetClosestOwnedVehicle()
    end

    if not vehicle or vehicle == 0 then
        ESX.ShowNotification('Yaxınlıqda öz maşınınız yoxdur!', 'error')
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    if plate:sub(1, 5) ~= '196RP' then
        ESX.ShowNotification('Bu maşın sizə məxsus deyil!', 'error')
        return
    end

    local currentFuel = GetVehicleFuel()

    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'fuel_amount', {
        title = ('Neçə litr yanacaq doldurmaq istəyirsiniz? (~g~%s$/litr~s~)\nCari: ~b~%s L~s~'):format(Config.FuelPrice, math.floor(currentFuel))
    }, function(data, menu)
        local liters = tonumber(data.value)
        menu.close()

        if not liters or liters <= 0 or liters > 100 then
            ESX.ShowNotification('Yanlış miqdar! (1-100)', 'error')
            return
        end

        if currentFuel + liters > 100 then
            ESX.ShowNotification('Bak 100 litr tutur! Daha az miqdar seçin.', 'error')
            return
        end

        ESX.TriggerServerCallback('196rp_fuel:refuel', function(ok, msg, newFuel)
            if ok then
                SetVehicleFuel(vehicle, newFuel)
            end
            ESX.ShowNotification(msg, ok and 'success' or 'error')
        end, plate, liters)
    end, function(data, menu)
        menu.close()
    end)
end

-- Əsas dövrə (stansiya markerləri)
CreateThread(function()
    while true do
        local wait = 750
        local coords = GetEntityCoords(PlayerPedId())
        local nearest = nil
        local nearestDist = 99.0

        for i = 1, #Config.Stations do
            local station = Config.Stations[i]
            local dist = #(coords - station.coords)
            if dist < 8.0 and dist < nearestDist then
                nearestDist = dist
                nearest = station
            end
        end

        if nearest then
            wait = 0
            showingUI = true
            ESX.TextUI(('[E] — Yanacaq doldur (~y~%s~s~)'):format(nearest.name), 'info')
            if IsControlJustPressed(0, 38) then
                Refuel(nearest)
            end
        else
            HideUI()
        end

        Wait(wait)
    end
end)
