-- 196 RP | Spawner — server tərəfi
-- FiveM-də SERVER entity YARADA BİLMƏZ (CreateVehicle/CreatePed və s. client natives-dir).
-- Bu resurs spawn istəyini hədəf oyunçunun client-inə göndərir, client yaradır və netId qaytarır.

local pending = {}
local seq = 0

RegisterNetEvent('196rp_spawner:ack', function(reqId, netId)
    local cb = pending[reqId]
    if cb then
        pending[reqId] = nil
        cb(tonumber(netId) or 0)
    end
end)

---Async spawn istəyi
---@param src number hədəf oyunçu id
---@param kind string 'vehicle' | 'ped' | 'object' | 'pedInVehicle'
---@param params table
---@param cb fun(netId: number)
---@param timeoutMs number?
local function RequestSpawn(src, kind, params, cb, timeoutMs)
    src = tonumber(src) or 0
    if src == 0 or not GetPlayerName(src) then
        if cb then cb(0) end
        return 0
    end

    seq = seq + 1
    local id = seq
    local settled = false

    pending[id] = function(netId)
        settled = true
        if cb then cb(netId) end
    end

    TriggerClientEvent('196rp_spawner:spawn', src, id, kind, params)

    SetTimeout(timeoutMs or 8000, function()
        if not settled then
            pending[id] = nil
            if cb then cb(0) end
        end
    end)

    return id
end

---Sinxron (await) wrapper — ESX server callback-ləri coroutine içində işləyir, Wait olar
local function AwaitSpawn(src, kind, params, timeoutMs)
    local done, result = false, 0
    RequestSpawn(src, kind, params, function(netId)
        result = netId
        done = true
    end, timeoutMs)

    local t = 0
    while not done and t < 200 do -- max ~10 san
        Wait(50)
        t = t + 1
    end
    return result
end

exports('RequestSpawn', RequestSpawn)
exports('SpawnVehicleAwait', function(src, params, timeoutMs)
    return AwaitSpawn(src, 'vehicle', params, timeoutMs)
end)
exports('SpawnPedAwait', function(src, params, timeoutMs)
    return AwaitSpawn(src, 'ped', params, timeoutMs)
end)
