-- 196 RP | Telefon sistemi — premium NUI müştəri tərəfi
-- Server callback/event-ləri dəyişməyib; yalnız interfeys NUI-ə köçürülüb.

local phoneData = nil
local isOpen = false
local callActive = false
local callWith = nil
local incomingSrc = nil
local ringing = false

-- ==================== AÇ / BAĞLA ====================

local function OpenPhone()
    ESX.TriggerServerCallback('196rp_phone:getPhoneData', function(data)
        if not data then
            return
        end

        phoneData = data

        local pd = ESX.GetPlayerData() or {}

        SendNUIMessage({
            action = 'open',
            number = data.number,
            name = pd.name or 'Qonaq',
            money = pd.money or 0,
            contacts = data.contacts or {},
            messages = data.messages or {},
        })

        isOpen = true
        SetNuiFocus(true, true)
    end)
end

local function ClosePhone()
    if not isOpen then
        return
    end

    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterCommand('telefon', function()
    if isOpen then
        ClosePhone()
    else
        OpenPhone()
    end
end, false)

RegisterKeyMapping('telefon', 'Telefonu aç', 'keyboard', 'P')

RegisterNetEvent('196rp_phone:open', function()
    OpenPhone()
end)

-- ==================== NUI CALLBACK-LƏRİ ====================

RegisterNUICallback('close', function(_, cb)
    ClosePhone()
    cb('ok')
end)

RegisterNUICallback('dial', function(data, cb)
    local number = tostring(data.number or '')

    if number == '' then
        cb('ok')
        return
    end

    if callActive then
        ESX.ShowNotification('Artıq zəngdəsiniz!', 'error')
        cb('ok')
        return
    end

    TriggerServerEvent('196rp_phone:call', number)
    callActive = true
    ringing = true
    cb('ok')
end)

RegisterNUICallback('sendSMS', function(data, cb)
    local number = tostring(data.number or '')
    local message = tostring(data.message or '')

    if number == '' or message == '' then
        cb('ok')
        return
    end

    ESX.TriggerServerCallback('196rp_phone:sendSMS', function(ok, msg)
        ESX.ShowNotification(msg, ok and 'success' or 'error', 5000)
    end, number, message)

    cb('ok')
end)

RegisterNUICallback('addContact', function(data, cb)
    ESX.TriggerServerCallback('196rp_phone:addContact', function(ok, msg)
        ESX.ShowNotification(msg, ok and 'success' or 'error', 5000)
    end, tostring(data.number or ''), tostring(data.name or ''))

    cb('ok')
end)

RegisterNUICallback('removeContact', function(data, cb)
    ESX.TriggerServerCallback('196rp_phone:removeContact', function(ok)
        if ok then
            ESX.ShowNotification('Kontakt silindi.', 'info')
        end
    end, tonumber(data.id) or 0)

    cb('ok')
end)

RegisterNUICallback('answer', function(_, cb)
    if incomingSrc then
        callActive = true
        callWith = incomingSrc
        ringing = false
        TriggerServerEvent('196rp_phone:callResponse', true, incomingSrc)
    end

    cb('ok')
end)

RegisterNUICallback('reject', function(_, cb)
    if incomingSrc then
        ringing = false
        TriggerServerEvent('196rp_phone:callResponse', false, incomingSrc)
        incomingSrc = nil
    end

    cb('ok')
end)

RegisterNUICallback('hangup', function(_, cb)
    TriggerServerEvent('196rp_phone:hangup')
    callActive = false
    cb('ok')
end)

-- ==================== GƏLƏN HADİSƏLƏR ====================

-- Yeni SMS
RegisterNetEvent('196rp_phone:newMessage', function(msg)
    ESX.ShowNotification(('📩 ~y~%s~s~ (%s): ~w~%s~s~'):format(
        msg.from, msg.fromNumber, msg.message), 'info', 7000)

    SendNUIMessage({
        action = 'newMessage',
        message = { from = msg.from, fromNumber = msg.fromNumber, message = msg.message },
    })

    if phoneData then
        table.insert(phoneData.messages, 1, {
            from = msg.from,
            fromNumber = msg.fromNumber,
            message = msg.message,
        })
    end
end)

-- Gələn zəng
RegisterNetEvent('196rp_phone:incomingCall', function(data)
    ringing = true
    incomingSrc = data.callerSrc

    SendNUIMessage({
        action = 'incomingCall',
        name = data.callerName,
        number = data.callerNumber,
    })

    if not isOpen then
        ESX.ShowNotification(('📞 ~y~%s~s~ sizə zəng edir! [P] ilə açın'):format(data.callerName), 'warning', 6000)
    end
end)

-- Zəng bağlandı
RegisterNetEvent('196rp_phone:callStarted', function(otherSrc)
    callActive = true
    callWith = otherSrc
    ringing = false
    incomingSrc = nil

    SendNUIMessage({ action = 'callStarted' })
end)

-- Zəng bitdi
RegisterNetEvent('196rp_phone:callEnded', function()
    callActive = false
    callWith = nil
    ringing = false
    incomingSrc = nil

    SendNUIMessage({ action = 'callEnded' })
end)

-- ==================== TƏMİZLƏMƏ ====================

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    SetNuiFocus(false, false)
    isOpen = false
end)

-- ==================== İXRAC ====================

exports('IsOpen', function()
    return isOpen
end)

exports('InCall', function()
    return callActive
end)
