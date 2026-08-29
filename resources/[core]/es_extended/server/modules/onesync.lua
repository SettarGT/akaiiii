ESX.OneSync = {}

---@param vehicleModel number|string
---@param coords vector3|table
---@param heading number
---@param vehicleProperties table
---@param cb? fun(netId: number)
---@param vehicleType string?
---@return number? netId
function ESX.OneSync.SpawnVehicle(vehicleModel, coords, heading, vehicleProperties, cb, vehicleType)
    if cb and not ESX.IsFunctionReference(cb) then
        error("Invalid callback function")
    end

    vehicleModel = joaat(vehicleModel)

    local promise = not cb and promise.new()

    local function resolve(result)
        if promise then
            promise:resolve(result)
        elseif cb then
            cb(result)
        end

        return result
    end

    local function reject(err)
        if promise then
            promise:reject(err)
        end
        error(err)
    end

    CreateThread(function()
        if not vehicleType then
            local xPlayer = ESX.GetExtendedPlayers()[1]
            if xPlayer then
                vehicleType = ESX.GetVehicleType(vehicleModel, xPlayer.source)
            end
        end

        if not vehicleType then
            return reject("No players found nearby to check vehicle type! Alternatively, you can specify the vehicle type manually.")
        end

        local createdVehicle = CreateVehicleServerSetter(vehicleModel, vehicleType, coords.x, coords.y, coords.z, heading)
        local tries = 0

        local hasNetOwner = next(ESX.OneSync.GetClosestPlayer(coords, 300, nil, 0) or {}) ~= nil

        while not createdVehicle or createdVehicle == 0
            or (hasNetOwner and NetworkGetEntityOwner(createdVehicle) == -1)
            or (not hasNetOwner and not DoesEntityExist(createdVehicle)) do
            Wait(200)
            tries = tries + 1
            if tries > 40 then
                return reject(("Could not spawn vehicle - ^5%s^7!"):format(vehicleModel))
            end
        end

        -- luacheck: ignore
        SetEntityOrphanMode(createdVehicle, 2)
        local networkId = NetworkGetNetworkIdFromEntity(createdVehicle)
        Entity(createdVehicle).state:set("VehicleProperties", vehicleProperties, true)

        resolve(networkId)
    end)

    if promise then
        return Citizen.Await(promise)
    end
end

---@param model number|string
---@param coords vector3|table
---@param heading number
---@param cb? fun(netId: number)
---@return number? netId
function ESX.OneSync.SpawnObject(model, coords, heading, cb)
    if type(model) == "string" then
        model = joaat(model)
    end

    local promise = not cb and promise.new()
    local objectCoords = type(coords) == "vector3" and coords or vector3(coords.x, coords.y, coords.z)

    local function resolve(result)
        if promise then
            promise:resolve(result)
        elseif cb then
            cb(result)
        end
    end

    local function reject(err)
        if promise then
            promise:reject(err)
        end
        error(err)
    end

    CreateThread(function()
        -- CreateObject/SetEntityHeading server-də yoxdur — 196rp_spawner vasitəsilə client-də yaradılır
        local players = GetPlayers()
        if #players == 0 then
            return reject("No players online to spawn object!")
        end
        exports['196rp_spawner']:RequestSpawn(tonumber(players[1]), 'object', {
            model = model,
            coords = { x = objectCoords.x, y = objectCoords.y, z = objectCoords.z },
            heading = heading or 0.0,
        }, function(netId)
            if netId == 0 then
                reject(("Could not spawn object - ^5%s^7!"):format(model))
            else
                resolve(netId)
            end
        end, 10000)
    end)

    if promise then
        return Citizen.Await(promise)
    end
end

---@param model number|string
---@param coords vector3|table
---@param heading number
---@param cb? fun(netId: number)
---@return number? netId
function ESX.OneSync.SpawnPed(model, coords, heading, cb)
    if type(model) == "string" then
        model = joaat(model)
    end

    local promise = not cb and promise.new()

    local function resolve(result)
        if promise then
            promise:resolve(result)
        elseif cb then
            cb(result)
        end
    end

    local function reject(err)
        if promise then
            promise:reject(err)
        end
        error(err)
    end

    CreateThread(function()
        -- CreatePed server-də yoxdur — 196rp_spawner vasitəsilə client-də yaradılır
        local players = GetPlayers()
        if #players == 0 then
            return reject("No players online to spawn ped!")
        end
        exports['196rp_spawner']:RequestSpawn(tonumber(players[1]), 'ped', {
            model = model,
            coords = { x = coords.x, y = coords.y, z = coords.z },
            heading = heading or 0.0,
        }, function(netId)
            if netId == 0 then
                reject(("Could not spawn ped - ^5%s^7!"):format(model))
            else
                resolve(netId)
            end
        end, 10000)
    end)

    if promise then
        return Citizen.Await(promise)
    end
end

---@param model number|string
---@param vehicle number entityId
---@param seat number
---@param cb? fun(netId: number)
---@return number? netId
function ESX.OneSync.SpawnPedInVehicle(model, vehicle, seat, cb)
    if type(model) == "string" then
        model = joaat(model)
    end

    local promise = not cb and promise.new()

    local function resolve(result)
        if promise then
            promise:resolve(result)
        elseif cb then
            cb(result)
        end
    end

    local function reject(err)
        if promise then
            promise:reject(err)
        end
        error(err)
    end

    CreateThread(function()
        -- CreatePedInsideVehicle server-də yoxdur — 196rp_spawner vasitəsilə client-də yaradılır
        local players = GetPlayers()
        if #players == 0 then
            return reject("No players online to spawn ped!")
        end
        exports['196rp_spawner']:RequestSpawn(tonumber(players[1]), 'pedInVehicle', {
            model = model,
            vehNetId = NetworkGetNetworkIdFromEntity(vehicle),
            seat = seat,
        }, function(netId)
            if netId == 0 then
                reject(("Could not spawn ped - ^5%s^7!"):format(model))
            else
                resolve(netId)
            end
        end, 10000)
    end)

    if promise then
        return Citizen.Await(promise)
    end
end
