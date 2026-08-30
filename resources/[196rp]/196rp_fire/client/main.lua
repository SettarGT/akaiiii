local QBCore = exports['qb-core']:GetCoreObject()
local burningVehicles = {}
local callBlips = {}
local busy = false

local function IsFF()
    return QBCore.Functions.GetPlayerData().job.name == 'fire'
end

local function NearestVehicle(range)
    local pos = GetEntityCoords(PlayerPedId())
    local best, bestD = nil, range
    for _, v in ipairs(GetGamePool('CVehicle')) do
        local d = #(pos - GetEntityCoords(v))
        if d < bestD then best, bestD = v, d end
    end
    return best
end

-- ── /yangin — yanğın zəngi ──
RegisterCommand('yangin', function()
    local veh = NearestVehicle(30.0)
    if veh then
        SetEntityOnFire(veh, true)
        local vp = GetEntityCoords(veh)
        burningVehicles[veh] = GetGameTimer() + 300000
        TriggerServerEvent('196rp_fire:server:call', vp.x, vp.y, vp.z)
    else
        QBCore.Functions.Notify('Yaxınlıqda yandırıla bilən avtomobil yoxdur.', 'primary')
    end
end, false)

-- ── /sondur — yanğınsöndürən ──
RegisterCommand('sondur', function()
    if not IsFF() then return QBCore.Functions.Notify('Bu əmr yalnız yanğınsöndürən üçündür.', 'error') end
    if busy then return end

    -- yanan avtomobili tap
    local pos = GetEntityCoords(PlayerPedId())
    local target, targetId = nil, nil
    local closest = { d = Config.Range, veh = nil }
    for veh, expiry in pairs(burningVehicles) do
        if DoesEntityExist(veh) and GetEntityOnFire(veh) and GetGameTimer() < expiry then
            local d = #(pos - GetEntityCoords(veh))
            if d < closest.d then closest = { d = d, veh = veh } end
        end
    end

    if not closest.veh then
        QBCore.Functions.Notify('Yaxınlıqda yanan avtomobil yoxdur.', 'primary')
        return
    end

    busy = true
    FreezeEntityPosition(PlayerPedId(), true)
    QBCore.Functions.Progressbar('196fire', '🔥 Yanğın söndürülür...', Config.ProgressTime * 1000, false, true, {
        disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true,
    }, {}, {}, {}, function()
        FreezeEntityPosition(PlayerPedId(), false)
        busy = false
        TriggerServerEvent('196rp_fire:server:extinguish')
    end, function()
        FreezeEntityPosition(PlayerPedId(), false)
        busy = false
    end)
end, false)

-- ── Yanğın zəngi (blip) ──
RegisterNetEvent('196rp_fire:client:newCall', function(data)
    if not IsFF() then return end
    if callBlips[data.id] then RemoveBlip(callBlips[data.id]) end
    local blip = AddBlipForCoord(data.coords)
    SetBlipSprite(blip, 436)
    SetBlipColour(blip, 46)
    SetBlipScale(blip, 1.1)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Yanğın #' .. data.id)
    EndTextCommandSetBlipName(blip)
    callBlips[data.id] = blip
    QBCore.Functions.Notify(('🚨 Yanğın zəngi #%d!'):format(data.id), 'error')
end)

RegisterNetEvent('196rp_fire:client:removeCall', function(data)
    if callBlips[data.id] then
        RemoveBlip(callBlips[data.id])
        callBlips[data.id] = nil
    end
end)

-- ── Söndürüldü ──
RegisterNetEvent('196rp_fire:client:stopFire', function()
    for veh, expiry in pairs(burningVehicles) do
        if DoesEntityExist(veh) and GetEntityOnFire(veh) then
            SetEntityOnFire(veh, false)
        end
    end
    burningVehicles = {}
end)

-- ── Təsadüfi yanğın ──
RegisterNetEvent('196rp_fire:client:igniteRandom', function()
    local veh = NearestVehicle(80.0)
    if veh then
        SetEntityOnFire(veh, true)
        local vp = GetEntityCoords(veh)
        burningVehicles[veh] = GetGameTimer() + 300000
        TriggerServerEvent('196rp_fire:server:call', vp.x, vp.y, vp.z)
    end
end)

-- ── Yanğın maşını ──
RegisterNetEvent('196rp_fire:client:spawnTruck', function()
    local model = 'firetruk'
    RequestModel(model)
    local t = 0
    while not HasModelLoaded(model) and t < 100 do
        Wait(20)
        t = t + 1
    end
    if HasModelLoaded(model) then
        local s = Config.Station.engineSpawn
        local veh = CreateVehicle(model, s.x, s.y, s.z, Config.Station.engineHeading, true, false)
        SetVehicleNumberPlateText(veh, '196FD')
        SetVehicleFuelLevel(veh, 100.0)
        QBCore.Functions.Notify('🚒 Yanğın maşını stansiyadadır!', 'success')
    end
end)

-- ── Stansiya kiosku ──
CreateThread(function()
    local s = Config.Station
    local blip = AddBlipForCoord(s.coords)
    SetBlipSprite(blip, 436)
    SetBlipColour(blip, 5)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(s.label)
    EndTextCommandSetBlipName(blip)

    exports['qb-target']:AddBoxZone('196fire_station', s.coords, 3.0, 3.0, {
        name = '196fire_station', heading = s.heading, debugPoly = false,
        minZ = s.coords.z - 1, maxZ = s.coords.z + 4,
    }, {
        options = {
            {
                label = '[E] ' .. s.label,
                icon = 'fas fa-fire-extinguisher',
                job = { 'fire' },
                action = function()
                    exports['qb-menu']:openMenu({
                        { header = '🚒 196 Yanğınsöndürmə', isMenuHeader = true, icon = 'fas fa-fire-extinguisher' },
                        {
                            header = '🚒 Yanğın maşını götür',
                            txt = 'Stansiya yanında hazır olur',
                            icon = 'fas fa-truck',
                            params = { eng = true },
                        },
                    }, function(selected)
                        if selected and selected.params and selected.params.eng then
                            TriggerServerEvent('196rp_fire:server:engine')
                        end
                    end)
                end,
            },
        },
        distance = 3.0,
    })
end)
