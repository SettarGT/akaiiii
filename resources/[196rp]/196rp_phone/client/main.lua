-- 196 RP | Telefon sistemi — müştəri tərəfi

local phoneData = nil
local callActive = false
local callWith = nil
local ringing = false

-- Telefonu aç
local function OpenPhone()
    ESX.TriggerServerCallback('196rp_phone:getPhoneData', function(data)
        if not data then return end
        phoneData = data
        ShowPhoneMenu()
    end)
end

RegisterCommand('telefon', function()
    OpenPhone()
end, false)

RegisterKeyMapping('telefon', 'Telefonu aç', 'keyboard', 'P')

-- /telefon yalnız telefon əşyası ilə? Həm də əşya ilə:
RegisterNetEvent('196rp_phone:open', function()
    OpenPhone()
end)

-- ==================== ƏSAS MENYU ====================

function ShowPhoneMenu()
    local menu = {
        { icon = 'fas fa-mobile-alt', title = ('📱 196 Telefon — ~y~%s~s~'):format(phoneData.number or '?'), unselectable = true },
        { icon = 'fas fa-address-book', title = ('Kontaktlar (~y~%s~s~)'):format(#phoneData.contacts), name = 'contacts' },
        { icon = 'fas fa-sms', title = '✉️ SMS yaz', name = 'sms' },
        { icon = 'fas fa-inbox', title = ('Gələnlər (~y~%s~s~)'):format(#phoneData.messages), name = 'inbox' },
        { icon = 'fas fa-user-plus', title = '➕ Kontakt əlavə et', name = 'add_contact' },
    }

    if callActive then
        menu[#menu + 1] = {
            icon = 'fas fa-phone-slash',
            title = '📵 Zəngi bitir',
            name = 'hangup',
        }
    else
        menu[#menu + 1] = {
            icon = 'fas fa-phone',
            title = '📞 Zəng et',
            name = 'call',
        }
    end

    exports['esx_context']:Open('left', menu, function(selected)
        if selected.name == 'contacts' then ShowContactsMenu() end
        if selected.name == 'sms' then ShowSMSForm() end
        if selected.name == 'inbox' then ShowInboxMenu() end
        if selected.name == 'add_contact' then ShowAddContactForm() end
        if selected.name == 'call' then ShowCallMenu() end
        if selected.name == 'hangup' then
            TriggerServerEvent('196rp_phone:hangup')
        end
    end)
end

-- ==================== KONTAKTLAR ====================

function ShowContactsMenu()
    local menu = {
        { icon = 'fas fa-address-book', title = '📇 Kontaktlar', unselectable = true },
    }
    if #phoneData.contacts == 0 then
        menu[#menu + 1] = {
            icon = 'fas fa-info',
            title = 'Kontakt yoxdur. Əlavə etmək üçün geri qayıdın.',
            unselectable = true,
        }
    else
        for i = 1, #phoneData.contacts do
            local c = phoneData.contacts[i]
            menu[#menu + 1] = {
                icon = 'fas fa-user',
                title = ('%s — ~y~%s~s~'):format(c.name, c.number),
                name = 'contact_' .. c.id,
            }
        end
    end
    menu[#menu + 1] = {
        icon = 'fas fa-arrow-left',
        title = '⬅ Geri',
        name = 'back',
    }

    exports['esx_context']:Open('left', menu, function(selected)
        if selected.name == 'back' then
            ShowPhoneMenu()
            return
        end
        local contactId = selected.name:match('^contact_(%d+)$')
        if contactId then
            local contact = nil
            for i = 1, #phoneData.contacts do
                if tostring(phoneData.contacts[i].id) == contactId then
                    contact = phoneData.contacts[i]
                    break
                end
            end
            if contact then ShowContactActions(contact) end
        end
    end)
end

function ShowContactActions(contact)
    local menu = {
        { icon = 'fas fa-user', title = ('%s — %s'):format(contact.name, contact.number), unselectable = true },
        { icon = 'fas fa-sms', title = '✉️ SMS göndər', name = 'sms' },
        { icon = 'fas fa-phone', title = '📞 Zəng et', name = 'call' },
        { icon = 'fas fa-trash', title = '🗑 Kontaktı sil', name = 'delete' },
        { icon = 'fas fa-arrow-left', title = '⬅ Geri', name = 'back' },
    }
    exports['esx_context']:Open('left', menu, function(selected)
        if selected.name == 'back' then ShowContactsMenu() end
        if selected.name == 'sms' then ShowSMSForm(contact.number) end
        if selected.name == 'call' then MakeCall(contact.number) end
        if selected.name == 'delete' then
            ESX.TriggerServerCallback('196rp_phone:removeContact', function(ok)
                if ok then
                    ESX.ShowNotification('Kontakt silindi.', 'info')
                    OpenPhone()
                end
            end, contact.id)
        end
    end)
end

-- ==================== SMS ====================

function ShowSMSForm(prefillNumber)
    local menu = {
        { icon = 'fas fa-sms', title = '✉️ Yeni SMS', unselectable = true },
        { icon = '', title = 'Nömrə', input = true, inputType = 'text', inputPlaceholder = '0000000', inputValue = prefillNumber or '', name = 'number' },
        { icon = '', title = 'Mesaj', input = true, inputType = 'text', inputPlaceholder = 'Mesajınız...', name = 'message' },
        { icon = 'fas fa-paper-plane', title = 'Göndər', name = 'submit' },
    }

    exports['esx_context']:Open('left', menu, function(selected)
        if selected.name == 'submit' then
            local number = tostring(menu[2].inputValue or '')
            local message = tostring(menu[3].inputValue or '')
            if number == '' or message == '' then
                ESX.ShowNotification('Nömrə və mesaj yazın!', 'error')
                return
            end
            ESX.TriggerServerCallback('196rp_phone:sendSMS', function(ok, msg)
                ESX.ShowNotification(msg, ok and 'success' or 'error', 5000)
            end, number, message)
        end
    end)
end

-- Yeni SMS gəldi
RegisterNetEvent('196rp_phone:newMessage', function(msg)
    ESX.ShowNotification(('📩 ~y~%s~s~ (%s): ~w~%s~s~'):format(msg.from, msg.fromNumber, msg.message), 'info', 7000)
    if phoneData then
        phoneData.messages[#phoneData.messages + 1] = {
            from = msg.from,
            message = msg.message,
            time = 'indi',
        }
    end
end)

function ShowInboxMenu()
    local menu = {
        { icon = 'fas fa-inbox', title = '📥 Gələnlər qutusu', unselectable = true },
    }
    if #phoneData.messages == 0 then
        menu[#menu + 1] = { icon = 'fas fa-info', title = 'Mesaj yoxdur.', unselectable = true }
    else
        for i = 1, math.min(#phoneData.messages, 8) do
            local m = phoneData.messages[i]
            menu[#menu + 1] = {
                icon = 'fas fa-envelope',
                title = ('%s: %s'):format(m.from, m.message),
                description = m.time or '',
                unselectable = true,
            }
        end
    end
    menu[#menu + 1] = {
        icon = 'fas fa-arrow-left',
        title = '⬅ Geri',
        name = 'back',
    }
    exports['esx_context']:Open('left', menu, function(selected)
        if selected.name == 'back' then ShowPhoneMenu() end
    end)
end

-- ==================== KONTAKT ƏLAVƏ ====================

function ShowAddContactForm()
    local menu = {
        { icon = 'fas fa-user-plus', title = '➕ Yeni kontakt', unselectable = true },
        { icon = '', title = 'Nömrə', input = true, inputType = 'text', inputPlaceholder = '0000000', name = 'number' },
        { icon = '', title = 'Ad', input = true, inputType = 'text', inputPlaceholder = 'Ad...', name = 'name' },
        { icon = 'fas fa-check', title = 'Əlavə et', name = 'submit' },
    }
    exports['esx_context']:Open('left', menu, function(selected)
        if selected.name == 'submit' then
            local number = tostring(menu[2].inputValue or '')
            local name = tostring(menu[3].inputValue or '')
            ESX.TriggerServerCallback('196rp_phone:addContact', function(ok, msg)
                ESX.ShowNotification(msg, ok and 'success' or 'error', 5000)
                if ok then OpenPhone() end
            end, number, name)
        end
    end)
end

-- ==================== ZƏNGLƏR ====================

function ShowCallMenu()
    local menu = {
        { icon = 'fas fa-phone', title = '📞 Zəng et', unselectable = true },
    }
    if #phoneData.contacts == 0 then
        menu[#menu + 1] = { icon = 'fas fa-info', title = 'Kontakt yoxdur!', unselectable = true }
    else
        for i = 1, #phoneData.contacts do
            local c = phoneData.contacts[i]
            menu[#menu + 1] = {
                icon = 'fas fa-phone',
                title = ('%s — %s'):format(c.name, c.number),
                name = 'call_' .. c.id,
            }
        end
    end
    menu[#menu + 1] = {
        icon = 'fas fa-arrow-left',
        title = '⬅ Geri',
        name = 'back',
    }
    exports['esx_context']:Open('left', menu, function(selected)
        if selected.name == 'back' then ShowPhoneMenu() return end
        local contactId = selected.name:match('^call_(%d+)$')
        if contactId then
            for i = 1, #phoneData.contacts do
                if tostring(phoneData.contacts[i].id) == contactId then
                    MakeCall(phoneData.contacts[i].number)
                    break
                end
            end
        end
    end)
end

function MakeCall(number)
    if callActive then
        ESX.ShowNotification('Artıq zəngdəsiniz!', 'error')
        return
    end
    TriggerServerEvent('196rp_phone:call', number)
    callActive = true
    ringing = true
    ESX.ShowNotification('Zəng edilir... Telefon menyusundan bitirə bilərsiniz.', 'info', 4000)
end

-- Gələn zəng
RegisterNetEvent('196rp_phone:incomingCall', function(data)
    ringing = true
    ESX.ShowNotification(('📞 ~y~%s~s~ (%s) sizə zəng edir!'):format(data.callerName, data.callerNumber), 'warning', 6000)

    local menu = {
        { icon = 'fas fa-phone', title = ('Zəng: ~y~%s~s~ (%s)'):format(data.callerName, data.callerNumber), unselectable = true },
        { icon = 'fas fa-check', title = '✅ Qəbul et', name = 'accept' },
        { icon = 'fas fa-times', title = '❌ Rədd et', name = 'decline' },
    }
    exports['esx_context']:Open('center', menu, function(selected)
        ringing = false
        if selected.name == 'accept' then
            callActive = true
            callWith = data.callerSrc
            TriggerServerEvent('196rp_phone:callResponse', true, data.callerSrc)
        else
            TriggerServerEvent('196rp_phone:callResponse', false, data.callerSrc)
        end
    end)
end)

RegisterNetEvent('196rp_phone:callStarted', function(otherSrc)
    callActive = true
    callWith = otherSrc
    ringing = false
    ESX.ShowNotification('~g~Zəng bağlandı!~s~ Telefon menyusu ilə bitirin.', 'success', 4000)
end)

RegisterNetEvent('196rp_phone:callEnded', function()
    callActive = false
    callWith = nil
    ringing = false
end)
