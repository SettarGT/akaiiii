local QBCore = exports['qb-core']:GetCoreObject()
local burningEntities = {}   -- handle -> expiry
local callBlips = {}
local isFirefighter = false
local busy = false

local function DrawText3D(coords, text)
    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 217, 122, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(coords.x, coords.y, coords.z)
end

local function UpdateFirefighter()
    isFirefighter = QBCore.Functions.GetPlayerData().job.name == 'fire'
end
UpdateFirefighter()
RegisterNetEvent('QBCore:Client:OnJobUpdate', UpdateFirefighter)

-- ── Yanğına zəng et (/yangin) ──
RegisterCommand('yangin', function()
    if busy then return end
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    -- yaxın avtomobili tap və yandır (əgər varsa)
    local veh, dist = nil, 30.0
    for _, v in ipairs(GetGamePool('CVehicle')) do
        local d = #(pos - GetEntityCoords(v))
        if d < dist then veh, dist = v, d end
    end
    if veh then
        SetEntityOnFire(veh, true)
        burningEntities[veh] = GetGameTimer() + 180000
        QBCore.Functions.Notify('🔥 Yaxınlıqdakı avtomobil alov aldı — 911 çağırıldı!', 'primary')
    else
        QBCore.Functions.Notify('Yaxınlıqda yanan obyekt yoxdur.', 'primary')
    end
    TriggerServerEvent('196rp_fire:server:call', pos.x, pos.y, pos.z)
end, false)

-- ── Təsadüfi yanğın (server tapşırığı) ──
RegisterNetEvent('196rp_fire:client:igniteNearby', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local veh, dist = nil, 60.0
    for _, v in ipairs(GetGamePool('CVehicle')) do
        local d = #(pos - GetEntityCoords(v))
        if d < dist then veh, dist = v, d end
    end
    if veh then
        local vp = GetEntityCoords(veh)
        SetEntityOnFire(veh, true)
        burningEntities[veh] = GetGameTimer() + 180000
        TriggerServerEvent('196rp_fire:server:call', vp.x, vp.y, vp.z)
    end
end)

-- ── Yanğın zəngləri (blip) ──
RegisterNetEvent('196rp_fire:client:newCall', function(data)
    if not isFirefighter then return end
    local id = data.id
    if callBlips[id] then
        RemoveBlip(callBlips[id])
    end
    local blip = AddBlipForCoord(data.coords)
    SetBlipSprite(blip, 436)
    SetBlipColour(blip, 46)
    SetBlipScale(blip, 1.1)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Yanğın #' .. id)
    EndTextCommandSetBlipName(blip)
    callBlips[id] = blip
    QBCore.Functions.Notify(('🚨 Yeni yanğın zəngi #%d!'):format(id), 'error')
end)

RegisterNetEvent('196rp_fire:client:removeCall', function(data)
    if callBlips[data.id] then
        RemoveBlip(callBlips[data.id])
        callBlips[data.id] = nil
    end
end)

-- ── Söndür (/sondur) ──
RegisterCommand('sondur', function()
    if isFirefighter and not busy then
        busy = true
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local target, dist = nil, Config.ExtinguishRange
        for handle, expiry in pairs(burningEntities) do
            if DoesEntityExist(handle) and GetGameTimer() < expiry then
                local d = #(pos - GetEntityCoords(handle))
                if d < dist then target, dist = handle, d end
            end
        end
        if not target then
            busy = false
            QBCore.Functions.Notify('Yaxınlıqda yanan obyekt yoxdur.', 'primary')
            return
        end

        FreezeEntityPosition(ped, true)
        QBCore.Functions.Progressbar('196fire', 'Yanğın söndürülür...', 6000, false, true, {
            disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true,
        }, {}, {}, {}, function()
            FreezeEntityPosition(ped, false)
            busy = false
            TriggerServerEvent('196rp_fire:server:extinguish')
        end, function()
            FreezeEntityPosition(ped, false)
            busy = false
        end)
    else
        QBCore.Functions.Notify('Bu əmr yalnız yanğınsöndürən üçündür.', 'error')
    end
end, false)

-- ── Söndürüldü (client təsiri) ──
RegisterNetEvent('196rp_fire:client:extinguishDone', function()
    for handle, expiry in pairs(burningEntities) do
        if DoesEntityExist(handle) and GetEntityOnFire(handle) then
            SetEntityOnFire(handle, false)
        end
    end
    burningEntities = {}
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
        local s = Config.Station.truckSpawn
        local veh = CreateVehicle(model, s.x, s.y, s.z, Config.Station.truckHeading, true, false)
        SetVehicleNumberPlateText(veh, '196FD')
        SetVehicleFuelLevel(veh, 100.0)
        QBCore.Functions.Notify('🚒 Yanğın maşını stansiyada hazır!', 'success')
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
                            txt = 'Stansiya yanında spawn olur',
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

-- ── Yanan obyektləri izlə (müddət bitəndə söndür) ──
CreateThread(function()
    while true do
        Wait(5000)
        local now = GetGameTimer()
        for handle, expiry in pairs(burningEntities) do
            if GetGameTimer() >= expiry or not DoesEntityExist(handle) then
                if DoesEntityExist(handle) and GetEntityOnFire(handle) then
                    SetEntityOnFire(handle, false)
                end
                burningEntities[handle] = nil
            end
        end
    end
end)
