-- 196 RP | Sürücülük məktəbi (DMV) — server tərəfi
-- Yazılı imtahan + sürmə imtahanı + vəsiqə verilməsi

local ESX = exports['es_extended']:getSharedObject()

-- [source] = { checkpoints = { [i] = true }, vehicle = entity, started = os.time() }
local tests = {}

-- ==================== VƏSİQƏ YOXLAMASI ====================

ESX.RegisterServerCallback('196rp_dmv:hasLicense', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false)
    end

    local row = MySQL.single.await(
        'SELECT `type` FROM `user_licenses` WHERE `owner` = ? AND `type` = ?',
        { xPlayer.identifier, Config.LicenseType }
    )

    cb(row ~= nil)
end)

-- ==================== YAZILI İMTAHAN ====================

ESX.RegisterServerCallback('196rp_dmv:submitExam', function(source, cb, answers)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 0)
    end

    -- DMV-yə yaxınlıq
    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - Config.DMV.coords) > 60.0 then
        return cb(false, 0)
    end

    if type(answers) ~= 'table' then
        return cb(false, 0)
    end

    local correct = 0
    for i = 1, #Config.Questions do
        if tonumber(answers[i]) == Config.Questions[i].answer then
            correct = correct + 1
        end
    end

    local passed = correct >= Config.PassScore

    if passed then
        -- Yazılı imtahan haqqı
        if xPlayer.getMoney() >= Config.TheoryCost then
            xPlayer.removeMoney(Config.TheoryCost)
        else
            local bank = xPlayer.getAccount('bank')
            if bank and bank.money >= Config.TheoryCost then
                xPlayer.removeAccountMoney('bank', Config.TheoryCost)
            else
                TriggerClientEvent('esx:showNotification', source,
                    ('İmtahan haqqı üçün ~y~%s$~s~ lazımdır!'):format(Config.TheoryCost), 'error')
                return cb(false, correct)
            end
        end
    end

    cb(passed, correct)
end)

-- ==================== SÜRMƏ İMTAHANI ====================

ESX.RegisterServerCallback('196rp_dmv:startDrivingTest', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(nil)
    end

    if tests[source] then
        return cb(nil)
    end

    -- Ödəniş
    if xPlayer.getMoney() >= Config.DrivingCost then
        xPlayer.removeMoney(Config.DrivingCost)
    else
        local bank = xPlayer.getAccount('bank')
        if bank and bank.money >= Config.DrivingCost then
            xPlayer.removeAccountMoney('bank', Config.DrivingCost)
        else
            return cb(nil)
        end
    end

local function DeleteTestVehicle(test)
    if test and test.vehicleNet then
        local veh = NetworkGetEntityFromNetworkId(test.vehicleNet)
        if veh ~= 0 then
            DeleteEntity(veh)
        end
        test.vehicleNet = nil
    end
end

    local start = Config.Checkpoints[1]

    local netId = exports['196rp_spawner']:SpawnVehicleAwait(source, {
        model = Config.TestVehicle,
        coords = { x = start.x + 3.0, y = start.y, z = start.z },
        heading = 0.0,
        plate = '196DMV',
    })

    if netId == 0 then
        return cb(nil)
    end

    tests[source] = { checkpoints = {}, vehicleNet = netId, started = os.time() }

    cb(netId)
end)

RegisterNetEvent('196rp_dmv:checkpoint', function(index, x, y, z)
    local src = source
    if not tests[src] then
        return
    end

    index = tonumber(index)
    if not index or index < 1 or index > #Config.Checkpoints then
        return
    end

    local cp = Config.Checkpoints[index]
    local dist = #(vector3(tonumber(x) or 0.0, tonumber(y) or 0.0, tonumber(z) or 0.0) - cp)
    if dist > 25.0 then
        return
    end

    tests[src].checkpoints[index] = true
end)

ESX.RegisterServerCallback('196rp_dmv:finishDrivingTest', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false)
    end

    local test = tests[source]
    if not test then
        return cb(false)
    end

    local hit = 0
    for i = 1, #Config.Checkpoints do
        if test.checkpoints[i] then
            hit = hit + 1
        end
    end

    local passed = hit >= #Config.Checkpoints

    if passed then
        local exists = MySQL.single.await(
            'SELECT `id` FROM `user_licenses` WHERE `owner` = ? AND `type` = ?',
            { xPlayer.identifier, Config.LicenseType }
        )
        if not exists then
            MySQL.insert.await(
                'INSERT INTO `user_licenses` (`type`, `owner`) VALUES (?, ?)',
                { Config.LicenseType, xPlayer.identifier }
            )
        end
    else
        TriggerClientEvent('esx:showNotification', source,
            ('Nöqtələrin hamısını keçmədiniz: %s/%s'):format(hit, #Config.Checkpoints), 'error')
    end

    DeleteTestVehicle(test)
    tests[source] = nil

    cb(passed)
end)

-- İmtahanı yarımçıq qoyanlar üçün təmizlik (10 dəqiqə)
CreateThread(function()
    while true do
        Wait(60000)
        local now = os.time()
        for src, test in pairs(tests) do
            if now - test.started > 600 then
                DeleteTestVehicle(test)
                tests[src] = nil
            end
        end
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    if tests[src] then
        DeleteTestVehicle(tests[src])
        tests[src] = nil
    end
end)
