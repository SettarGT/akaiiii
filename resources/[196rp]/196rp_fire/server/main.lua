local QBCore = exports['qb-core']:GetCoreObject()

local calls = {}      -- id -> { coords, expires }
local callSeq = 0

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

local function IsFirefighter(Player)
    return Player and Player.PlayerData.job.name == 'fire'
end

local function Broadcast(ev, data)
    for _, src in ipairs(QBCore.Functions.GetPlayers()) do
        local P = QBCore.Functions.GetPlayer(src)
        if P and IsFirefighter(P) then
            TriggerClientEvent(ev, src, data)
        end
    end
end

-- ── Zəng (istənilən oyunçu: 911 yanğın) ──
RegisterNetEvent('196rp_fire:server:call', function(x, y, z)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    callSeq = callSeq + 1
    local id = callSeq
    calls[id] = { coords = vector3(x or 0, y or 0, z or 0), expires = os.time() + Config.CallLife }

    Broadcast('196rp_fire:client:newCall', { id = id, coords = calls[id].coords, reporter = src })
    Notify(src, '🚒 Yanğın briqadası xəbərdar edildi!')
end)

-- ── Söndür ──
RegisterNetEvent('196rp_fire:server:extinguish', function(callId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not IsFirefighter(Player) then return end

    callId = tonumber(callId)
    local foundClosest = false
    for id, c in pairs(calls) do
        if c then
            local d = #(GetEntityCoords(GetPlayerPed(src)) - c.coords)
            if d < Config.ExtinguishRange and (not callId or id == callId) then
                calls[id] = nil
                foundClosest = true
                break
            end
        end
    end

    if not foundClosest then
        Notify(src, 'Yaxınlıqda aktiv yanğın zəngi yoxdur.', 'error')
        return
    end

    Player.Functions.AddMoney('cash', Config.ExtinguishPay, 'fire-extinguish')
    TriggerClientEvent('196rp_fire:client:extinguishDone', src, callId)
    Notify(src, ('🔥 Yanğın söndürüldü: +₣%d'):format(Config.ExtinguishPay), 'success')
    TriggerEvent('196rp_logs:server:vehEvent', 'YANĞIN', 'Söndürüldü', ('+₣%d'):format(Config.ExtinguishPay))
end)

-- ── Yanğın maşını ──
RegisterNetEvent('196rp_fire:server:engine', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not IsFirefighter(Player) then return end
    TriggerClientEvent('196rp_fire:client:spawnTruck', src)
end)

-- ── Təsadüfi yanğınlar (firefighter onlayn olduqda) ──
CreateThread(function()
    while true do
        Wait(Config.RandomFireInterval[1] * 1000)
        local ffs = {}
        for _, src in ipairs(QBCore.Functions.GetPlayers()) do
            local P = QBCore.Functions.GetPlayer(src)
            if P and IsFirefighter(P) then ffs[#ffs + 1] = src end
        end
        if #ffs > 0 and math.random(100) <= Config.RandomFireChance then
            -- təsadüfi oyunçunun avtomobili yanır
            local targets = {}
            for _, src in ipairs(QBCore.Functions.GetPlayers()) do
                local P = QBCore.Functions.GetPlayer(src)
                if P and not IsFirefighter(P) then targets[#targets + 1] = src end
            end
            if #targets > 0 then
                local victim = targets[math.random(#targets)]
                TriggerClientEvent('196rp_fire:client:igniteNearby', victim)
                -- zəng client tərəfdən yanan obyektin REAL koordinatından gəlir
            end
        end
    end
end)

-- ── Call ömrü ──
CreateThread(function()
    while true do
        Wait(10000)
        local now = os.time()
        for id, c in pairs(calls) do
            if c.expires and c.expires < now then
                calls[id] = nil
                Broadcast('196rp_fire:client:removeCall', { id = id })
            end
        end
    end
end)
