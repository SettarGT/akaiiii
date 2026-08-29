-- 196 RP | Qaraj sistemi — server tərəfi
-- Maşınların saxlanması, çıxarılması, qıfıl, servis və müsadirə

local ESX = exports['es_extended']:getSharedObject()

-- [plate] = true/false (qıfıllı)
local vehicleLocks = {}
-- [plate] = entityId (hazırda çıxarılmış maşınlar)
local spawnedVehicles = {}

-- ==================== KÖMƏKÇİLƏR ====================

local function FindGarageById(id)
    for i = 1, #Config.Garages do
        if Config.Garages[i].id == id then
            return Config.Garages[i]
        end
    end
    return nil
end

-- Oyunçuya ən yaxın, verilən tipli qarajı tap
local function NearestGarage(source, gType)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then
        return nil
    end

    local coords = GetEntityCoords(ped)
    local best, bestDist = nil, math.huge

    for i = 1, #Config.Garages do
        local g = Config.Garages[i]
        if not gType or g.type == gType then
            local d = #(coords - g.coords)
            if d < bestDist then
                best, bestDist = g, d
            end
        end
    end

    if bestDist > 25.0 then
        return nil
    end

    return best
end

local function GetOwnedVehicle(identifier, plate)
    return MySQL.single.await(
        'SELECT * FROM `owned_vehicles` WHERE `plate` = ? AND `owner` = ?',
        { plate, identifier }
    )
end

local function VehicleLabel(modelName)
    local row = MySQL.single.await('SELECT `name` FROM `vehicles` WHERE `model` = ? LIMIT 1', { modelName })
    return row and row.name or (modelName or 'Naməlum')
end

local function LoadProps(plate)
    local row = MySQL.single.await('SELECT `props` FROM `196rp_vehicle_props` WHERE `plate` = ?', { plate })
    if not row or not row.props then
        return nil
    end
    local ok, decoded = pcall(json.decode, row.props)
    if ok and type(decoded) == 'table' then
        decoded.plate = plate
        return decoded
    end
    return nil
end

local function SaveProps(plate, propsJson)
    MySQL.prepare.await(
        'INSERT INTO `196rp_vehicle_props` (`plate`, `props`) VALUES (?, ?) ON DUPLICATE KEY UPDATE `props` = VALUES(`props`)',
        { plate, propsJson }
    )
end

local function CreateOwnedVehicle(source, modelName, plate, props)
    local model = GetHashKey(modelName)

    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end
    if not HasModelLoaded(model) then
        return nil
    end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    -- Qaraj çıxışında yaradırıq
    local garage = NearestGarage(source, nil)
    local spawnCoords, spawnHeading = coords, heading
    if garage then
        spawnCoords = garage.coords
        spawnHeading = 0.0
    end

    local veh = CreateVehicle(model, spawnCoords.x + 2.0, spawnCoords.y, spawnCoords.z,
        spawnHeading, true, false)

    SetModelAsNoLongerNeeded(model)

    if not veh or veh == 0 then
        return nil
    end

    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleNumberPlateText(veh, plate)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetVehicleOnGroundProperly(veh)
    SetVehicleEngineOn(veh, true, true, false)
    SetVehicleDoorsLocked(veh, vehicleLocks[plate] and 2 or 1)

    if props then
        if props.color1 then SetVehicleColours(veh, props.color1, props.color2 or props.color1) end
        if props.pearlescentColor then SetVehicleExtraColours(veh, props.pearlescentColor, props.wheelColor or 0) end
    end

    spawnedVehicles[plate] = { veh = veh, owner = source }
    return NetworkGetNetworkIdFromEntity(veh)
end

-- ==================== QARAJDAKI MAŞINLAR ====================

ESX.RegisterServerCallback('196rp_garage:getGarageVehicles', function(source, cb, gType)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb({})
    end

    local rows = MySQL.query.await(
        'SELECT `plate`, `vehicle` FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `stored` = 1',
        { xPlayer.identifier, gType or 'car' }
    ) or {}

    local list = {}
    for i = 1, #rows do
        local row = rows[i]
        local modelName = row.vehicle
        local ok, decoded = pcall(json.decode, row.vehicle or '')
        if ok and type(decoded) == 'table' and decoded.model then
            modelName = decoded.model
            if type(modelName) == 'number' then
                modelName = tostring(modelName)
            end
        end

        list[#list + 1] = {
            plate = row.plate,
            label = VehicleLabel(modelName),
            model = modelName
        }
    end

    cb(list)
end)

-- ==================== MAŞINI ÇIXART ====================

ESX.RegisterServerCallback('196rp_garage:spawnVehicle', function(source, cb, plate, gType)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(nil)
    end

    local row = GetOwnedVehicle(xPlayer.identifier, plate)
    if not row then
        return cb(nil)
    end

    if row.stored == 0 then
        TriggerClientEvent('esx:showNotification', source,
            'Bu maşın artıq küçədədir! Əvvəl onu qaraja qaytarın.', 'error')
        return cb(nil)
    end

    if row.pound then
        TriggerClientEvent('esx:showNotification', source,
            'Maşınınız mühafizə meydançasındadır! Cəriməni ödəyib geri alın.', 'error')
        return cb(nil)
    end

    local modelName = row.vehicle
    local ok, decoded = pcall(json.decode, row.vehicle or '')
    if ok and type(decoded) == 'table' and decoded.model then
        modelName = decoded.model
        if type(modelName) == 'number' then
            modelName = tostring(modelName)
        end
    end

    local netId = CreateOwnedVehicle(source, modelName, plate, LoadProps(plate))
    if not netId then
        return cb(nil)
    end

    MySQL.update.await('UPDATE `owned_vehicles` SET `stored` = 0, `parking` = NULL WHERE `plate` = ?', { plate })

    local props = LoadProps(plate) or { plate = plate, model = modelName }
    props.plate = plate

    cb({ netId = netId, props = props })
end)

-- ==================== MAŞINI QARAJA QOY ====================

ESX.RegisterServerCallback('196rp_garage:parkVehicle', function(source, cb, plate, propsJson)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local row = GetOwnedVehicle(xPlayer.identifier, plate)
    if not row then
        return cb(false, 'Bu maşın sizə məxsus deyil!')
    end

    local garage = NearestGarage(source, nil)
    if not garage then
        return cb(false, 'Qaraja çox uzaqsınız!')
    end

    if type(propsJson) == 'string' then
        local ok = pcall(json.decode, propsJson)
        if ok then
            SaveProps(plate, propsJson)
        end
    end

    MySQL.update.await('UPDATE `owned_vehicles` SET `stored` = 1, `parking` = ?, `pound` = NULL WHERE `plate` = ?',
        { garage.id, plate })

    spawnedVehicles[plate] = nil

    cb(true, ('~g~Maşın %s qarajına saxlanıldı.~s~'):format(garage.name))
end)

-- ==================== MÜHAFİZƏ ====================

ESX.RegisterServerCallback('196rp_garage:getImpoundedVehicles', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb({})
    end

    local rows = MySQL.query.await(
        'SELECT `plate`, `vehicle` FROM `owned_vehicles` WHERE `owner` = ? AND `pound` IS NOT NULL',
        { xPlayer.identifier }
    ) or {}

    local list = {}
    for i = 1, #rows do
        local modelName = rows[i].vehicle
        local ok, decoded = pcall(json.decode, rows[i].vehicle or '')
        if ok and type(decoded) == 'table' and decoded.model then
            modelName = decoded.model
            if type(modelName) == 'number' then
                modelName = tostring(modelName)
            end
        end
        list[#list + 1] = { plate = rows[i].plate, label = VehicleLabel(modelName), model = modelName }
    end

    cb(list)
end)

ESX.RegisterServerCallback('196rp_garage:retrieveVehicle', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local row = GetOwnedVehicle(xPlayer.identifier, plate)
    if not row or not row.pound then
        return cb(false, 'Mühafizədə belə bir maşın yoxdur!')
    end

    -- Mühafizə meydançasına yaxınlıq
    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - Config.Impound.coords) > 30.0 then
        return cb(false, 'Mühafizə meydançasına gedin!')
    end

    local price = Config.Impound.retrievePrice or 300
    if xPlayer.getMoney() < price then
        return cb(false, ('Cərimə üçün ~y~%s$~s~ lazımdır!'):format(price))
    end

    xPlayer.removeMoney(price)

    local modelName = row.vehicle
    local ok, decoded = pcall(json.decode, row.vehicle or '')
    if ok and type(decoded) == 'table' and decoded.model then
        modelName = decoded.model
        if type(modelName) == 'number' then
            modelName = tostring(modelName)
        end
    end

    MySQL.update.await('UPDATE `owned_vehicles` SET `stored` = 0, `pound` = NULL WHERE `plate` = ?', { plate })

    local props = LoadProps(plate) or { plate = plate, model = modelName }
    props.plate = plate

    local netId = CreateOwnedVehicle(source, modelName, plate, props)
    if not netId then
        return cb(false, 'Maşın yaradıla bilmədi! Pulunuz geri qaytarıldı.', nil, nil)
    end

    cb(true, ('~g~Maşın geri alındı!~s~ Cərimə: ~y~%s$~s~'):format(price), netId, props)
end)

-- Polis maşını müsadirə edir (196rp_police-dən çağırılır)
exports('ImpoundVehicle', function(plate)
    if type(plate) ~= 'string' then
        return false
    end

    local row = MySQL.single.await('SELECT `owner` FROM `owned_vehicles` WHERE `plate` = ?', { plate })
    if not row then
        return false
    end

    MySQL.update.await('UPDATE `owned_vehicles` SET `stored` = 1, `pound` = ?, `parking` = NULL WHERE `plate` = ?',
        { 'pound', plate })

    local rec = spawnedVehicles[plate]
    if rec and DoesEntityExist(rec.veh) then
        SetEntityAsMissionEntity(rec.veh, true, true)
        DeleteEntity(rec.veh)
    end
    spawnedVehicles[plate] = nil

    return true
end)

-- ==================== QIFIL ====================

ESX.RegisterServerCallback('196rp_garage:toggleLock', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false)
    end

    local row = GetOwnedVehicle(xPlayer.identifier, plate)
    if not row then
        TriggerClientEvent('esx:showNotification', source, 'Bu maşın sizə məxsus deyil!', 'error')
        return cb(false)
    end

    vehicleLocks[plate] = not vehicleLocks[plate]

    local rec = spawnedVehicles[plate]
    if rec and DoesEntityExist(rec.veh) then
        SetVehicleDoorsLocked(rec.veh, vehicleLocks[plate] and 2 or 1)
        SetVehicleDoorsLockedForAllPlayers(rec.veh, vehicleLocks[plate])
    end

    cb(vehicleLocks[plate])
end)

ESX.RegisterServerCallback('196rp_garage:getVehicleState', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(nil)
    end

    local row = MySQL.single.await('SELECT `owner` FROM `owned_vehicles` WHERE `plate` = ?', { plate })
    if not row then
        return cb(nil)
    end

    cb({ owned = row.owner == xPlayer.identifier, locked = vehicleLocks[plate] or false })
end)

-- ==================== SERVİS (TƏMİR / YUMA) ====================

ESX.RegisterServerCallback('196rp_garage:payService', function(source, cb, serviceType)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local price = serviceType == 'repair' and Config.RepairPrice or Config.WashPrice
    local label = serviceType == 'repair' and 'təmir edildi' or 'yuyuldu'

    -- Servis nöqtəsinə yaxınlıq
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local near = false
    for i = 1, #Config.Services do
        if #(coords - Config.Services[i].coords) < 12.0 then
            near = true
            break
        end
    end

    if not near then
        return cb(false, 'Servis nöqtəsinə yaxın deyilsiniz!')
    end

    if xPlayer.getMoney() < price then
        return cb(false, ('Pulunuz kifayət etmir! Lazımdır: ~y~%s$~s~'):format(price))
    end

    xPlayer.removeMoney(price)
    cb(true, ('~g~Maşın %s!~s~ Ödəniş: ~y~%s$~s~'):format(label, price))
end)

-- ==================== TEMİZLİK ====================

AddEventHandler('playerDropped', function()
    local src = source
    for plate, rec in pairs(spawnedVehicles) do
        if rec.owner == src then
            if DoesEntityExist(rec.veh) then
                SetEntityAsMissionEntity(rec.veh, true, true)
                DeleteEntity(rec.veh)
            end
            spawnedVehicles[plate] = nil
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then
        return
    end
    for _, rec in pairs(spawnedVehicles) do
        if DoesEntityExist(rec.veh) then
            SetEntityAsMissionEntity(rec.veh, true, true)
            DeleteEntity(rec.veh)
        end
    end
end)
