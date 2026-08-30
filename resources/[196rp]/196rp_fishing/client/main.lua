local QBCore = exports['qb-core']:GetCoreObject()
local myBoat = nil
local inSpot = nil
local busy = false

local function Notify(msg, typ)
    QBCore.Functions.Notify(msg, typ or 'primary')
end

-- Qayıq: /qayıq (balıqçı) və /qayıqqaytar
RegisterCommand('qayıq', function()
    if QBCore.PlayerData.job.name ~= Config.Job then
        Notify('Bu əmr yalnız balıqçı işi üçündür.', 'error')
        return
    end
    if myBoat and DoesEntityExist(myBoat) then
        Notify('Artıq qayığınız var.', 'primary')
        return
    end
    local model = Config.Boat.model
    RequestModel(model)
    local t = 0
    while not HasModelLoaded(model) and t < 100 do Wait(20) t = t + 1 end
    if HasModelLoaded(model) then
        local s = Config.Boat.spawnCoords
        myBoat = CreateVehicle(model, s.x, s.y, s.z, s.w, true, false)
        SetEntityAsMissionEntity(myBoat, true, true)
        SetVehicleFuelLevel(myBoat, 100.0)
        SetModelAsNoLongerNeeded(model)
        Notify('🚤 İş qayığı hazırdır — /qayıqqaytar ilə qaytarın.', 'success')
    end
end, false)

RegisterCommand('qayıqqaytar', function()
    if myBoat and DoesEntityExist(myBoat) then
        DeleteVehicle(myBoat)
        myBoat = nil
        Notify('🚤 Qayıq qaytarıldı.', 'primary')
    end
end, false)

local function InOwnBoat()
    local ped = PlayerPedId()
    if not IsPedInAnyBoat(ped) then return false end
    local veh = GetVehiclePedIsIn(ped, false)
    return myBoat and veh == myBoat
end

-- Sahə markerləri + [E] qarmaq
CreateThread(function()
    while true do
        Wait(300)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        inSpot = nil
        for _, spot in ipairs(Config.Spots) do
            local d = #(coords - spot.coords)
            if d < spot.radius then inSpot = spot break end
        end
        if inSpot then
            DrawMarker(1, inSpot.coords.x, inSpot.coords.y, inSpot.coords.z + 0.2, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 1.0, 0, 200, 255, 140, false, true, 2, false, nil, nil, false)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 38) and inSpot and not busy then
            if QBCore.PlayerData.job.name ~= Config.Job then
                Notify('Balıqçı işi tələb olunur.', 'error')
            elseif not InOwnBoat() then
                Notify('Qarmaq üçün /qayıq ilə qayığa minməlisiniz.', 'error')
            else
                busy = true
                QBCore.Functions.Progressbar('196fishing', '🎣 Qarmaq atılır...', 4000, false, true, {
                    disableMovement = true, disableCarMovement = false, disableMouse = false, disableCombat = true,
                }, {}, {}, {}, function()
                    local ok = exports['qb-minigames']:Skillbar(Config.Minigame.Difficulty, Config.Minigame.Keys)
                    if ok then
                        TriggerServerEvent('196rp_fishing:server:catch', inSpot.id)
                    else
                        Notify('🐟 Balıq qaçdı!', 'error')
                    end
                    busy = false
                end, function()
                    busy = false
                    Notify('Qarmaq yarımçıq qaldı.', 'error')
                end)
            end
        end
        Wait(50)
    end
end)
