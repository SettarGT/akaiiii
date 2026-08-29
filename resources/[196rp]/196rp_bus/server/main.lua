-- 196 RP | Avtobus sistemi — server tərəfi
-- Avtobus simulasiyası CLIENT-dədir (client/sim.lua) — server entity yarada bilməz.
-- Server: sim sahibi təyin edir, mövqe keşi saxlayır, gediş haqqı + taksi məntiqi.

local ESX = exports['es_extended']:getSharedObject()

local simOwner = nil
local busPositions = {}

-- ==================== SIM SAHİBİ ====================

local function AssignSimOwner()
    local ids = {}
    for _, pid in pairs(GetPlayers()) do
        ids[#ids + 1] = tonumber(pid)
    end
    table.sort(ids)
    local newOwner = ids[1]

    if newOwner == simOwner then
        return
    end

    if simOwner then
        TriggerClientEvent('196rp_bus:setSimOwner', simOwner, false)
    end
    simOwner = newOwner
    if simOwner then
        TriggerClientEvent('196rp_bus:setSimOwner', simOwner, true)
        print(('[196rp_bus] simulasiya sahibi: %s'):format(simOwner))
    end
end

CreateThread(function()
    Wait(5000)
    while true do
        if simOwner == nil or not GetPlayerName(simOwner) then
            AssignSimOwner()
        end
        Wait(10000)
    end
end)

AddEventHandler('playerDropped', function()
    if tonumber(source) == simOwner then
        simOwner = nil
        AssignSimOwner()
    end
end)

RegisterNetEvent('196rp_bus:positions', function(list)
    if tonumber(source) == simOwner and type(list) == 'table' then
        busPositions = list
    end
end)

-- ==================== GEDİŞ HAQQI ====================

ESX.RegisterServerCallback('196rp_bus:payFare', function(source, cb, kind)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local price = Config.CityFare

    if xPlayer.getMoney() < price then
        return cb(false, ('Gediş haqqı ~y~%s$~s~-dır. Nağd pulunuz yoxdur!'):format(price))
    end

    xPlayer.removeMoney(price)
    cb(true, ('~g~Gediş haqqı ödənildi: %s$~s~'):format(price))
end)

ESX.RegisterServerCallback('196rp_bus:payIntercity', function(source, cb, destLabel, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    price = tonumber(price) or Config.IntercityFare

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
    else
        local bank = xPlayer.getAccount('bank')
        if bank and bank.money >= price then
            xPlayer.removeAccountMoney('bank', price)
        else
            return cb(false, ('Bilet ~y~%s$~s~-dır. Pulunuz kifayət etmir!'):format(price))
        end
    end

    cb(true, ('~g~%s~s~ üçün bilet alındı.'):format(destLabel))
end)

-- ==================== TAKSİ ÇAĞIRIŞI ====================

ESX.RegisterServerCallback('196rp_bus:callTaxi', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)

    local notified = 0
    for _, pid in pairs(ESX.GetPlayers()) do
        local xTarget = ESX.GetPlayerFromId(pid)
        if xTarget and xTarget.job.name == 'taxi' then
            TriggerClientEvent('196rp_bus:taxiCallBlip', pid, source, coords)
            TriggerClientEvent('esx:showNotification', pid,
                ('~y~🚕 Taksi çağırışı!~s~ ID %s sizi gözləyir (xəritədə işarələndi)'):format(source), 'info')
            notified = notified + 1
        end
    end

    if notified == 0 then
        return cb(false, 'Hal-hazırda növbədə taksi sürücüsü yoxdur! Bir az sonra cəhd edin.')
    end

    cb(true, ('~g~%s taksi sürücüsünə çağırış göndərildi!~s~'):format(notified))
end)

ESX.RegisterServerCallback('196rp_bus:taxiBoard', function(source, cb, driverId)
    local xPassenger = ESX.GetPlayerFromId(source)
    local xDriver = ESX.GetPlayerFromId(tonumber(driverId) or 0)

    if not xPassenger then
        return cb(false, 'Xəta baş verdi!')
    end

    if not xDriver then
        return cb(false, 'Sürücü tapılmadı!')
    end

    if xDriver.job.name ~= 'taxi' then
        return cb(false, 'Bu maşının sürücüsü taksi işçisi deyil!')
    end

    -- Yaxınlıq yoxlaması
    local pPed, dPed = GetPlayerPed(source), GetPlayerPed(xDriver.source)
    if #(GetEntityCoords(pPed) - GetEntityCoords(dPed)) > 12.0 then
        return cb(false, 'Taksiyə çox uzaqsınız!')
    end

    local fare = Config.Taxi.fare
    if xPassenger.getMoney() < fare then
        return cb(false, ('Gediş ~y~%s$~s~-dır. Nağd pulunuz yoxdur!'):format(fare))
    end

    xPassenger.removeMoney(fare)
    xDriver.addMoney(Config.Taxi.driverShare)

    TriggerClientEvent('esx:showNotification', xDriver.source,
        ('~g~Sərnişin mindi!~s~ +%s$'):format(Config.Taxi.driverShare), 'success')

    cb(true, '~g~Taksidə oturursunuz.~s~')
end)

-- ==================== DİGƏR ====================

exports('GetBusPositions', function()
    return busPositions
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then
        return
    end
    if simOwner then
        TriggerClientEvent('196rp_bus:setSimOwner', simOwner, false)
    end
end)
