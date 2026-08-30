local QBCore = exports['qb-core']:GetCoreObject()
local calls = {}
local seq = 0

local function GetSrcName(src)
    local P = QBCore.Functions.GetPlayer(src)
    if not P then return '?' end
    local c = P.PlayerData.charinfo
    return (c.firstname or '?') .. ' ' .. (c.lastname or '?')
end

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

local function PushAll()
    local list = {}
    for id, c in pairs(calls) do
        list[#list + 1] = {
            id = id, message = c.message, coords = c.coords,
            caller = c.caller, acceptedBy = c.acceptedBy,
            created = c.created, status = c.acceptedBy and 'accepted' or 'new',
        }
    end
    table.sort(list, function(a, b) return a.id < b.id end)

    for _, src in ipairs(QBCore.Functions.GetPlayers()) do
        local P = QBCore.Functions.GetPlayer(src)
        if P then
            local allowed = IsPlayerAceAllowed(src, Config.AdminPerm)
            for _, job in ipairs(Config.Jobs) do
                if P.PlayerData.job.name == job then allowed = true end
            end
            if allowed then
                TriggerClientEvent('196rp_dispatch:client:push', src, list)
            end
        end
    end
end

-- ── 911 zəngi ──
RegisterNetEvent('196rp_dispatch:server:911', function(message)
    local src = source
    local P = QBCore.Functions.GetPlayer(src)
    if not P then return end

    seq = seq + 1
    calls[seq] = {
        message = tostring(message or '') ~= '' and tostring(message) or 'Zəng',
        coords = GetEntityCoords(GetPlayerPed(src)),
        caller = GetSrcName(src),
        acceptedBy = nil,
        created = os.time(),
    }
    PushAll()
    TriggerClientEvent('QBCore:Notify', src, '📞 911 qəbul edildi — briqada xəbərdar edildi!', 'success')
end)

-- ── Qəbul ──
RegisterNetEvent('196rp_dispatch:server:accept', function(id)
    local src = source
    local P = QBCore.Functions.GetPlayer(src)
    if not P then return end
    local allowed = IsPlayerAceAllowed(src, Config.AdminPerm)
    for _, job in ipairs(Config.Jobs) do
        if P.PlayerData.job.name == job then allowed = true end
    end
    if not allowed then return end

    id = tonumber(id)
    if calls[id] then
        calls[id].acceptedBy = GetSrcName(src)
        PushAll()
    end
end)

-- ── Bitdi ──
RegisterNetEvent('196rp_dispatch:server:done', function(id)
    local src = source
    local P = QBCore.Functions.GetPlayer(src)
    if not P then return end
    id = tonumber(id)
    if calls[id] then
        calls[id] = nil
        PushAll()
    end
end)

-- ── Ömür təmizliyi ──
CreateThread(function()
    while true do
        Wait(30000)
        local now = os.time()
        for id, c in pairs(calls) do
            if now - c.created > Config.CallLife then
                calls[id] = nil
            end
        end
        PushAll()
    end
end)
