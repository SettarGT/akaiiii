local QBCore = exports['qb-core']:GetCoreObject()
local radarOn = false
local lastUpdate = 0

local function IsCop()
    local job = QBCore.Functions.GetPlayerData().job.name
    for _, j in ipairs(Config.Jobs) do
        if job == j then return true end
    end
    return false
end

-- ── Radar ──
RegisterCommand('radar', function()
    if not IsCop() then return QBCore.Functions.Notify('Bu əmr yalnız polis üçündür.', 'error') end
    radarOn = not radarOn
    SendNUIMessage({ action = radarOn and 'show' or 'hide' })
    QBCore.Functions.Notify(radarOn and '📡 Radar açıldı.' or '📡 Radar bağlandı.', 'primary')
end, false)

CreateThread(function()
    while true do
        Wait(Config.Radar.UpdateRate)
        if radarOn and IsCop() then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            local best, bestD = nil, Config.Radar.Range
            for _, veh in ipairs(GetGamePool('CVehicle')) do
                if veh ~= GetVehiclePedIsIn(ped, false) then
                    local vp = GetEntityCoords(veh)
                    local d = #(pos - vp)
                    if d < bestD then
                        local ang = math.deg(math.atan2(vp.y - pos.y, vp.x - pos.x))
                        local diff = (ang - heading) % 360
                        if diff > 180 then diff = 360 - diff end
                        if diff < Config.Radar.FOV then
                            best, bestD = veh, d
                        end
                    end
                end
            end
            if best then
                local kmh = math.floor(GetEntitySpeed(best) * 3.6)
                local plate = GetVehicleNumberPlateText(best)
                local model = GetDisplayNameFromVehicleModel(GetEntityModel(best))
                SendNUIMessage({ action = 'update', speed = kmh, plate = plate, model = model })
            else
                SendNUIMessage({ action = 'update', speed = 0, plate = '', model = '' })
            end
        end
    end
end)

-- ── Plate scanner ──
RegisterCommand('plate', function()
    if not IsCop() then return QBCore.Functions.Notify('Bu əmr yalnız polis üçündür.', 'error') end
    local pos = GetEntityCoords(PlayerPedId())
    local best, bestD = nil, Config.PlateRange
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        local d = #(pos - GetEntityCoords(veh))
        if d < bestD then best, bestD = veh, d end
    end
    if best then
        TriggerServerEvent('196rp_radar:server:plateLookup', GetVehicleNumberPlateText(best))
    else
        QBCore.Functions.Notify('Yaxınlıqda avtomobil yoxdur.', 'primary')
    end
end, false)

-- ── NUI cavabı ──
RegisterNetEvent('196rp_radar:client:plateResult', function(data)
    SendNUIMessage({ action = 'plate', plate = data.plate, owner = data.owner, citizenid = data.citizenid })
end)

-- ── Çıxışda radarı bağla ──
AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        SendNUIMessage({ action = 'hide' })
    end
end)
