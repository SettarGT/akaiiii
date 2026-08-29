-- 196 RP | Telefon — server tərəfi
-- Nömrə, kontaktlar, SMS, zənglər

local ESX = exports['es_extended']:getSharedObject()

-- [source] = { with = source, started = os.time() }
local calls = {}

-- ==================== NÖMRƏ ====================

local function GetOrCreateNumber(identifier)
    local row = MySQL.single.await('SELECT `phone_number` FROM `users` WHERE `identifier` = ?', { identifier })

    if row and row.phone_number and row.phone_number ~= '' then
        return row.phone_number
    end

    local number
    for _ = 1, 30 do
        local candidate = tostring(math.random(Config.NumberRange.min, Config.NumberRange.max))
        local taken = MySQL.scalar.await('SELECT 1 FROM `users` WHERE `phone_number` = ?', { candidate })
        if not taken then
            number = candidate
            break
        end
    end

    if not number then
        number = tostring(os.time()):sub(-7)
    end

    MySQL.update.await('UPDATE `users` SET `phone_number` = ? WHERE `identifier` = ?', { number, identifier })
    return number
end

local function NameOf(xPlayer)
    if not xPlayer then
        return 'Naməlum'
    end
    return ('%s %s'):format(xPlayer.get('firstName') or '?', xPlayer.get('lastName') or '?')
end

-- ==================== TELEFON MƏLUMATLARI ====================

ESX.RegisterServerCallback('196rp_phone:getPhoneData', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(nil)
    end

    local number = GetOrCreateNumber(xPlayer.identifier)

    local contacts = MySQL.query.await(
        'SELECT `id`, `number`, `name` FROM `196rp_phone_contacts` WHERE `owner` = ? ORDER BY `name` ASC',
        { xPlayer.identifier }
    ) or {}

    local rows = MySQL.query.await(
        'SELECT `id`, `sender`, `message`, `created_at` FROM `196rp_phone_messages` WHERE `receiver` = ? ORDER BY `id` DESC LIMIT ?',
        { xPlayer.identifier, Config.MaxMessages or 50 }
    ) or {}

    local messages = {}
    for i = 1, #rows do
        local sender = ESX.GetPlayerFromIdentifier(rows[i].sender)
        local senderRow = MySQL.single.await('SELECT `firstname`, `lastname`, `phone_number` FROM `users` WHERE `identifier` = ?',
            { rows[i].sender })

        messages[#messages + 1] = {
            id = rows[i].id,
            from = sender and NameOf(sender)
                or ((senderRow and senderRow.firstname or '?') .. ' ' .. (senderRow and senderRow.lastname or '?')),
            fromNumber = (senderRow and senderRow.phone_number) or '?',
            message = rows[i].message,
            created_at = rows[i].created_at
        }
    end

    cb({ number = number, contacts = contacts, messages = messages })
end)

-- ==================== KONTAKTLAR ====================

ESX.RegisterServerCallback('196rp_phone:addContact', function(source, cb, number, name)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    number = tostring(number or ''):gsub('%s', '')
    name = tostring(name or ''):sub(1, 40)

    if number == '' or name == '' then
        return cb(false, 'Nömrə və ad yazın!')
    end

    if #number < 4 or #number > 12 then
        return cb(false, 'Nömrə 4-12 rəqəm olmalıdır!')
    end

    MySQL.insert.await(
        'INSERT INTO `196rp_phone_contacts` (`owner`, `number`, `name`) VALUES (?, ?, ?)',
        { xPlayer.identifier, number, name }
    )

    cb(true, ('~g~%s~s~ kontaktlara əlavə olundu.'):format(name))
end)

ESX.RegisterServerCallback('196rp_phone:removeContact', function(source, cb, contactId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false)
    end

    MySQL.update.await('DELETE FROM `196rp_phone_contacts` WHERE `id` = ? AND `owner` = ?',
        { tonumber(contactId), xPlayer.identifier })

    cb(true)
end)

-- ==================== SMS ====================

ESX.RegisterServerCallback('196rp_phone:sendSMS', function(source, cb, number, message)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    number = tostring(number or ''):gsub('%s', '')
    message = tostring(message or ''):sub(1, 200)

    if number == '' or message == '' then
        return cb(false, 'Nömrə və mesaj yazın!')
    end

    local myNumber = GetOrCreateNumber(xPlayer.identifier)
    if number == myNumber then
        return cb(false, 'Özünüzə mesaj göndərə bilməzsiniz!')
    end

    local receiver = MySQL.single.await('SELECT `identifier`, `phone_number` FROM `users` WHERE `phone_number` = ?',
        { number })

    if not receiver then
        return cb(false, 'Bu nömrədə abunəçi yoxdur!')
    end

    MySQL.insert.await(
        'INSERT INTO `196rp_phone_messages` (`sender`, `receiver`, `message`) VALUES (?, ?, ?)',
        { xPlayer.identifier, receiver.identifier, message }
    )

    -- Alıcı onlayndırsa dərhal bildir
    local xReceiver = ESX.GetPlayerFromIdentifier(receiver.identifier)
    if xReceiver then
        TriggerClientEvent('196rp_phone:newMessage', xReceiver.source, {
            from = NameOf(xPlayer),
            fromNumber = myNumber,
            message = message
        })
    end

    cb(true, '~g~Mesaj göndərildi!~s~')
end)

-- ==================== ZƏNGLƏR ====================

RegisterNetEvent('196rp_phone:call', function(number)
    local src = source
    local xCaller = ESX.GetPlayerFromId(src)
    if not xCaller then
        return
    end

    if calls[src] then
        return
    end

    number = tostring(number or ''):gsub('%s', '')
    local myNumber = GetOrCreateNumber(xCaller.identifier)

    if number == myNumber then
        TriggerClientEvent('esx:showNotification', src, 'Özünüzə zəng edə bilməzsiniz!', 'error')
        return
    end

    local row = MySQL.single.await('SELECT `identifier` FROM `users` WHERE `phone_number` = ?', { number })
    if not row then
        TriggerClientEvent('esx:showNotification', src, 'Bu nömrədə abunəçi yoxdur!', 'error')
        return
    end

    local xTarget = ESX.GetPlayerFromIdentifier(row.identifier)
    if not xTarget then
        TriggerClientEvent('esx:showNotification', src, 'Abunəçi hazırda əlçatan deyil!', 'error')
        return
    end

    calls[src] = { with = xTarget.source, started = os.time(), accepted = false }

    TriggerClientEvent('196rp_phone:incomingCall', xTarget.source, {
        callerSrc = src,
        callerName = NameOf(xCaller),
        callerNumber = myNumber
    })
end)

RegisterNetEvent('196rp_phone:callResponse', function(accepted, callerSrc)
    local src = source
    callerSrc = tonumber(callerSrc)

    if not callerSrc or not calls[callerSrc] then
        return
    end

    if accepted then
        calls[callerSrc].accepted = true
        TriggerClientEvent('196rp_phone:callStarted', src, callerSrc)
        TriggerClientEvent('196rp_phone:callStarted', callerSrc, src)
    else
        TriggerClientEvent('esx:showNotification', callerSrc, '~r~Zəng rədd edildi.~s~', 'error')
        TriggerClientEvent('196rp_phone:callEnded', src)
        calls[callerSrc] = nil
    end
end)

RegisterNetEvent('196rp_phone:hangup', function()
    local src = source
    local call = calls[src]

    if call then
        TriggerClientEvent('196rp_phone:callEnded', call.with)
        calls[src] = nil
        return
    end

    -- Qarşı tərəfin zəngini bitir
    for caller, data in pairs(calls) do
        if data.with == src then
            TriggerClientEvent('196rp_phone:callEnded', caller)
            calls[caller] = nil
            break
        end
    end
end)

-- Cavab verilməyən zənglər (30 saniyə)
CreateThread(function()
    while true do
        Wait(5000)
        local now = os.time()
        for src, data in pairs(calls) do
            if not data.accepted and now - data.started > math.floor((Config.CallTimeout or 30000) / 1000) then
                TriggerClientEvent('196rp_phone:callEnded', src)
                TriggerClientEvent('196rp_phone:callEnded', data.with)
                calls[src] = nil
            end
        end
    end
end)

-- ==================== DİGƏR ====================

exports('GetPlayerNumber', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return nil
    end
    return GetOrCreateNumber(xPlayer.identifier)
end)

exports('SendServiceSMS', function(number, fromName, message)
    local row = MySQL.single.await('SELECT `identifier` FROM `users` WHERE `phone_number` = ?', { number })
    if not row then
        return false
    end

    local xTarget = ESX.GetPlayerFromIdentifier(row.identifier)
    if not xTarget then
        return false
    end

    TriggerClientEvent('196rp_phone:newMessage', xTarget.source, {
        from = fromName or '196 RP',
        fromNumber = '0000000',
        message = message
    })

    return true
end)

AddEventHandler('playerDropped', function()
    local src = source
    if calls[src] then
        TriggerClientEvent('196rp_phone:callEnded', calls[src].with)
        calls[src] = nil
    end
    for caller, data in pairs(calls) do
        if data.with == src then
            TriggerClientEvent('196rp_phone:callEnded', caller)
            calls[caller] = nil
        end
    end
end)
