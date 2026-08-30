local QBCore = exports['qb-core']:GetCoreObject()
local calls = {}
local seq = 0

local function IsFF(Player)
    return Player and Player.PlayerData.job.name == 'fire'
end

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

local function BroadcastToFF(ev, data)
    for _, src in ipairs(QBCore.Functions.GetPlayers()) do
        local P = QBCore.Functions.GetPlayer(src)
        if IsFF(P) then
            TriggerClientEvent(ev, src, data)
        end
    end
end

-- ── Zəng (hər kəs) ──
RegisterNetEvent('196rp_fire:server:call', function(x, y, z)
    local src = source
    seq = seq + 1
    local id = seq
    calls[id] = { coords = vector3(x or 0, y or 0, z or 0), src = src, expires = os.time() + Config.CallLife }
    BroadcastToFF('196rp_fire:client:newCall', { id = id, coords = calls[id].coords })
    Notify(src, '🚒 Yanğın briqadası xəbərdar edildi!', 'success')
end)

-- ── Söndür ──
RegisterNetEvent('196rp_fire:server:extinguish', function(callId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not IsFF(Player) then return end

    local found, closest = false, nil
    callId = tonumber(callId)
    for id, c in pairs(calls) do
        if c then
            local d = #(GetEntityCoords(GetPlayerPed(src)) - c.coords)
            if (not callId or id == callId) and d < Config.Range then
                if not closest or d < closest.dist then
                    closest = { id = id, dist = d }
                end
            end
        end
    end

    if not closest then
        Notify(src, 'Yaxınlıqda aktiv yanğın zəngi yoxdur.', 'error')
        return
    end

    calls[closest.id] = nil
    BroadcastToFF('196rp_fire:client:removeCall', { id = closest.id })
    Player.Functions.AddMoney('cash', Config.ExtinguishPay, 'fire-extinguish')
    TriggerClientEvent('196rp_fire:client:stopFire', src)
    Notify(src, ('🔥 Yanğın söndürüldü: +₣%d'):format(Config.ExtinguishPay), 'success')
    TriggerEvent('196rp_logs:server:vehEvent', 'YANĞIN', 'Söndürüldü', ('+₣%d'):format(Config.ExtinguishPay))
end)

-- ── Yanğın maşını ──
RegisterNetEvent('196rp_fire:server:engine', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not IsFF(Player) then return end
    TriggerClientEvent('196rp_fire:client:spawnTruck', src)
end)

-- ── Təsadüfi yanğın (FF online-i üçün) ──
CreateThread(function()
    while true do
        Wait(Config.RandomInterval[1] * 1000)
        local ffs = {}
        for _, src in ipairs(QBCore.Functions.GetPlayers()) do
            local P = QBCore.Functions.GetPlayer(src)
            if IsFF(P) then ffs[#ffs + 1] = src end
        end
        if #ffs > 0 then
            -- təsadüfi mülki oyunçuya yanğın tapşır
            local civilians = {}
            for _, src in ipairs(QBCore.Functions.GetPlayers()) do
                local P = QBCore.Functions.GetPlayer(src)
                if P and not IsFF(P) then civilians[#civilians + 1] = src end
            end
            if #civilians > 0 then
                TriggerClientEvent('196rp_fire:client:igniteRandom', civilians[math.random(#civilians)])
            end
        end
    end
end)

-- ── Zəng ömrü ──
CreateThread(function()
    while true do
        Wait(30000)
        local now = os.time()
        for id, c in pairs(calls) do
            if now > c.expires then
                calls[id] = nil
                BroadcastToFF('196rp_fire:client:removeCall', { id = id })
            end
        end
    end
end)
