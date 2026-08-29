-- 196 RP | Nəqliyyat — server tərəfi
-- Açar sistemi, kilidlər, icarə müqavilələri, motodeliver sifarişləri

local ESX = exports['es_extended']:getSharedObject()

local locks = {}       -- plate → bool (yaddaşda, DB-yə də yazılır)
local orders = {}      -- source → {label, coords, dist, startedAt}
local lastOrder = {}   -- source → timestamp

-- ==================== KÖMƏKÇİLƏR ====================

local function IsOwner(identifier, plate)
    local n = MySQL.scalar.await(
        'SELECT COUNT(*) FROM `owned_vehicles` WHERE `plate` = ? AND `owner` = ?',
        { plate, identifier })
    return (tonumber(n) or 0) > 0
end

local function HasKey(identifier, plate)
    local n = MySQL.scalar.await(
        'SELECT COUNT(*) FROM `196rp_vehicle_keys` WHERE `plate` = ? AND `identifier` = ?',
        { plate, identifier })
    return (tonumber(n) or 0) > 0
end

local function IsLockStored(plate)
    local n = MySQL.scalar.await('SELECT COUNT(*) FROM `196rp_vehicle_locks` WHERE `plate` = ?', { plate })
    return (tonumber(n) or 0) > 0
end

local function SetLock(plate, locked)
    locks[plate] = locked

    if IsLockStored(plate) then
        MySQL.update.await('UPDATE `196rp_vehicle_locks` SET `locked` = ? WHERE `plate` = ?', { locked and 1 or 0, plate })
    else
        MySQL.insert.await('INSERT INTO `196rp_vehicle_locks` (`plate`, `locked`) VALUES (?, ?)', { plate, locked and 1 or 0 })
    end

    TriggerClientEvent('196rp_vehicle:lockState', -1, plate, locked)
end

local function SendKeys(xPlayer)
    local rows = MySQL.query.await([[
        SELECT `plate` FROM `owned_vehicles` WHERE `owner` = ?
        UNION
        SELECT `plate` FROM `196rp_vehicle_keys` WHERE `identifier` = ?
    ]], { xPlayer.identifier, xPlayer.identifier }) or {}

    local plates = {}
    for i = 1, #rows do
        plates[#plates + 1] = rows[i].plate
    end

    TriggerClientEvent('196rp_vehicle:keysChanged', xPlayer.source, plates)
end

local function Charge(xPlayer, amount)
    if xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount)
        return true
    end

    local bank = xPlayer.getAccount('bank')
    if bank and bank.money >= amount then
        xPlayer.removeAccountMoney('bank', amount)
        return true
    end

    return false
end

-- ==================== GİRİŞ / ÇIXIŞ ====================

AddEventHandler('esx:playerLoaded', function(source, xPlayer)
    Wait(1500)
    SendKeys(xPlayer)
end)

CreateThread(function()
    Wait(3000)
    local rows = MySQL.query.await('SELECT `plate`, `locked` FROM `196rp_vehicle_locks`') or {}
    for i = 1, #rows do
        locks[rows[i].plate] = rows[i].locked == 1
    end

    for plate, locked in pairs(locks) do
        if locked then
            TriggerClientEvent('196rp_vehicle:lockState', -1, plate, true)
        end
    end
end)

AddEventHandler('esx:playerDropped', function(source)
    orders[source] = nil
    lastOrder[source] = nil
end)

-- ==================== 45. AÇARLAR ====================

ESX.RegisterServerCallback('196rp_vehicle:toggleLock', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or type(plate) ~= 'string' then
        return cb(false, 'Xəta baş verdi!')
    end

    plate = (plate:gsub('%s+', '')):upper()

    if not IsOwner(xPlayer.identifier, plate) and not HasKey(xPlayer.identifier, plate) then
        return cb(false, 'Bu maşının açarı sizdə yoxdur!')
    end

    local locked = not locks[plate]
    SetLock(plate, locked)

    cb(true, locked and '🔒 Maşın kilidləndi.' or '🔓 Maşın açıldı.', locked)
end)

ESX.RegisterServerCallback('196rp_vehicle:getKeyList', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb({})
    end

    local owned = MySQL.query.await('SELECT `plate` FROM `owned_vehicles` WHERE `owner` = ?', { xPlayer.identifier }) or {}
    local shared = MySQL.query.await('SELECT `plate` FROM `196rp_vehicle_keys` WHERE `identifier` = ?', { xPlayer.identifier }) or {}

    local list = {}
    for i = 1, #owned do
        list[#list + 1] = { plate = owned[i].plate, label = 'Şəxsi nəqliyyat', owner = true }
    end
    for i = 1, #shared do
        list[#list + 1] = { plate = shared[i].plate, label = 'Verilmiş açar', owner = false }
    end

    cb(list)
end)

ESX.RegisterServerCallback('196rp_vehicle:giveKey', function(source, cb, plate, targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local target = ESX.GetPlayerFromId(tonumber(targetId) or 0)

    if not xPlayer or not target then
        return cb(false, 'Oyunçu tapılmadı!')
    end

    plate = (tostring(plate or ''):gsub('%s+', '')):upper()

    if not IsOwner(xPlayer.identifier, plate) then
        return cb(false, 'Yalnız öz maşınızın açarını verə bilərsiniz!')
    end

    if target.identifier == xPlayer.identifier then
        return cb(false, 'Özünüzə açar verə bilməzsiniz!')
    end

    if HasKey(target.identifier, plate) then
        return cb(false, 'Bu oyunçuda artıq açar var!')
    end

    MySQL.insert.await('INSERT INTO `196rp_vehicle_keys` (`plate`, `identifier`) VALUES (?, ?)',
        { plate, target.identifier })

    SendKeys(target)

    cb(true, ('~g~%s~s~ nömrəli maşının açarı ~y~%s~s~ adlı oyunçuya verildi.'):format(
        plate, target.getName()))
end)

-- Başqa resurslar yoxlaya bilər (məsələn qaraj, polis)
exports('HasVehicleKey', function(source, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false
    end

    plate = (tostring(plate or ''):gsub('%s+', '')):upper()
    return IsOwner(xPlayer.identifier, plate) or HasKey(xPlayer.identifier, plate)
end)

-- Qanunsuz yollarla açma (196rp_illegal üçün)
exports('ForceUnlock', function(plate)
    plate = (tostring(plate or ''):gsub('%s+', '')):upper()

    if plate == '' then
        return false
    end

    locks[plate] = nil
    MySQL.update.await('DELETE FROM `196rp_vehicle_locks` WHERE `plate` = ?', { plate })
    TriggerClientEvent('196rp_vehicle:lockState', -1, plate, false)

    return true
end)

exports('IsVehicleLocked', function(plate)
    plate = (tostring(plate or ''):gsub('%s+', '')):upper()
    return locks[plate] == true
end)

-- ==================== 47/48/49/52. İCARƏ ====================

local function GenPlate(prefix)
    for i = 1, 30 do
        local plate = ('%s%03d'):format(prefix:sub(1, 5), math.random(1, 999))
        local exists = MySQL.scalar.await('SELECT COUNT(*) FROM `196rp_rentals` WHERE `plate` = ? AND `returned` = 0', { plate })
        if (tonumber(exists) or 0) == 0 then
            return plate
        end
    end
    return ('%s%03d'):format(prefix:sub(1, 5), math.random(1, 999))
end

ESX.RegisterServerCallback('196rp_vehicle:rent', function(source, cb, stationIndex, modelIndex, prefix)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, nil, 'Xəta baş verdi!')
    end

    local station = Config.Rentals[tonumber(stationIndex) or 0]
    if not station then
        return cb(false, nil, 'Belə bir icarə məntəqəsi yoxdur!')
    end

    local veh = station.vehicles[tonumber(modelIndex) or 0]
    if not veh then
        return cb(false, nil, 'Belə bir nəqliyyat yoxdur!')
    end

    -- Məsafə yoxlanışı
    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - station.coords) > 15.0 then
        return cb(false, nil, 'İcarə məntəqəsindən uzaqdasınız!')
    end

    -- Qayıq icarəsi üçün qayıq vəsiqəsi tələb olunur (bənd 1)
    if station.kind == 'boat' then
        local lic = MySQL.scalar.await(
            'SELECT COUNT(*) FROM `user_licenses` WHERE `type` = ? AND `owner` = ?',
            { 'boat', xPlayer.identifier })
        if (tonumber(lic) or 0) == 0 then
            return cb(false, nil, '~r~Qayıq vəsiqəniz yoxdur!~s~ DMV-dən alın.')
        end
    end

    -- Aktiv icarə limiti
    local active = MySQL.scalar.await(
        'SELECT COUNT(*) FROM `196rp_rentals` WHERE `identifier` = ? AND `returned` = 0',
        { xPlayer.identifier })
    if (tonumber(active) or 0) >= Config.MaxActiveRentals then
        return cb(false, nil, 'Artıq aktiv icarəniz var! Əvvəlcə onu qaytarın.')
    end

    local deposit = math.floor(station.pricePerDay * Config.RentalDepositMult)
    local total = station.pricePerDay + deposit

    if not Charge(xPlayer, total) then
        return cb(false, nil, ('Pulunuz kifayət etmir! Lazımdır: ~y~%s$~s~'):format(total))
    end

    local plate = GenPlate(tostring(prefix or 'KR'))

    MySQL.insert.await([[
        INSERT INTO `196rp_rentals`
        (`identifier`, `kind`, `model`, `plate`, `price_per_day`, `deposit`, `started_at`, `returned`)
        VALUES (?, ?, ?, ?, ?, ?, ?, 0)
    ]], { xPlayer.identifier, station.kind, veh.model, plate, station.pricePerDay, deposit, os.time() })

    cb(true, plate, ('~g~%s~s~ icarəyə götürüldü! Ödəniş: %s$ (depozit daxil)'):format(veh.label, total))
end)

ESX.RegisterServerCallback('196rp_vehicle:returnRental', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!', 0)
    end

    local row = MySQL.single.await(
        'SELECT * FROM `196rp_rentals` WHERE `identifier` = ? AND `returned` = 0 ORDER BY `id` DESC LIMIT 1',
        { xPlayer.identifier })

    if not row then
        return cb(false, 'Sizin aktiv icarəniz yoxdur!', 0)
    end

    -- İcarə maşını yaxınlıqdamı?
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local veh = GetClosestVehicle(coords.x, coords.y, coords.z, 20.0, 0, 71)
    local plate = ''

    if veh and veh ~= 0 then
        plate = (GetVehicleNumberPlateText(veh):gsub('%s+', '')):upper()
    end

    if plate ~= row.plate then
        return cb(false, ('İcarə maşını (%s) yaxınlıqda deyil!'):format(row.plate), 0)
    end

    local usedSeconds = os.time() - (row.started_at or os.time())
    local days = math.max(1, math.ceil((usedSeconds / 60) / Config.RentalDayMinutes))
    local extra = math.max(0, (days - 1) * (row.price_per_day or 0))
    local refund = math.max(0, (row.deposit or 0) - extra)

    MySQL.update.await('UPDATE `196rp_rentals` SET `returned` = 1 WHERE `id` = ?', { row.id })

    if refund > 0 then
        xPlayer.addAccountMoney('bank', refund)
    end

    cb(true, ('~g~Nəqliyyat qaytarıldı.~s~ İstifadə: %s gün. Depozitdən qaytarıldı: ~y~%s$~s~'):format(days, refund), refund)
end)

-- ==================== 50. MOTODELİVER ====================

ESX.RegisterServerCallback('196rp_vehicle:startOrder', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, nil, 'Xəta baş verdi!')
    end

    if xPlayer.job.name ~= Config.Delivery.job then
        return cb(false, nil, ('Bu iş yalnız ~y~%s~s~ üçün açıqdır.'):format(Config.Delivery.jobLabel))
    end

    if orders[source] then
        return cb(false, nil, 'Sizdə artıq aktiv sifariş var!')
    end

    local now = os.time()
    if lastOrder[source] and now - lastOrder[source] < Config.Delivery.cooldown then
        return cb(false, nil, ('%s saniyə gözləyin.'):format(Config.Delivery.cooldown - (now - lastOrder[source])))
    end

    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - Config.Delivery.depot) > 15.0 then
        return cb(false, nil, 'Sifariş mərkəzindən uzaqdasınız!')
    end

    local dest = Config.Delivery.destinations[math.random(1, #Config.Delivery.destinations)]
    local dist = #(dest.coords - Config.Delivery.depot)

    orders[source] = {
        label = dest.label,
        coords = { x = dest.coords.x, y = dest.coords.y, z = dest.coords.z },
        dist = dist,
        startedAt = now,
    }
    lastOrder[source] = now

    cb(true, orders[source], ('~g~Sifariş:~s~ %s (%s m)'):format(dest.label, math.floor(dist)))
end)

ESX.RegisterServerCallback('196rp_vehicle:finishOrder', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local order = orders[source]

    if not xPlayer or not order then
        return cb(false, 0, 0, 'Aktiv sifariş yoxdur!')
    end

    if os.time() - order.startedAt > Config.Delivery.orderTimeout then
        orders[source] = nil
        return cb(false, 0, 0, '~r~Vaxt bitdi!~s~ Sifariş ləğv olundu.')
    end

    -- Məsafə yoxlanışı
    local ped = GetPlayerPed(source)
    local target = vector3(order.coords.x, order.coords.y, order.coords.z)
    if #(GetEntityCoords(ped) - target) > 12.0 then
        return cb(false, 0, 0, 'Çatdırılma ünvanından uzaqdasınız!')
    end

    local pay = math.floor(Config.Delivery.basePay + (order.dist / 1000) * Config.Delivery.payPerKm)
    local tip = 0

    if math.random(1, 100) <= Config.Delivery.tipChance then
        tip = Config.Delivery.tipAmount
    end

    xPlayer.addAccountMoney('bank', pay + tip)
    orders[source] = nil

    cb(true, pay, tip, ('~g~Sifariş çatdırıldı!~s~ Ödəniş: ~y~%s$~s~%s'):format(
        pay, tip > 0 and (' + məsləhət ~y~%s$~s~'):format(tip) or ''))
end)
