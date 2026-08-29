-- 196 RP | Telefon mağazası — server tərəfi
-- Bütün qiymətlər və validasiya serverdə aparılır (client menyusuna etibar edilmir)

local ESX = exports['es_extended']:getSharedObject()

local lastUse = {}

-- Modeli id-yə görə tapır
local function FindPhone(phoneId)
    if type(phoneId) ~= 'string' then
        return nil
    end

    for i = 1, #Config.Phones do
        if Config.Phones[i].id == phoneId then
            return Config.Phones[i]
        end
    end

    return nil
end

-- Mağazanı id-yə görə tapır
local function FindShop(shopId)
    if type(shopId) ~= 'string' then
        return nil
    end

    for i = 1, #Config.Shops do
        if Config.Shops[i].id == shopId then
            return Config.Shops[i]
        end
    end

    return nil
end

-- Oyunçunun mağazaya yaxın olduğunu yoxlayır (server tərəfi anti-çit)
local function NearShop(src, shopId)
    local shop = FindShop(shopId)

    if not shop then
        return false, nil
    end

    local ped = GetPlayerPed(src)

    if not ped or ped == 0 then
        return false, nil
    end

    local dist = #(GetEntityCoords(ped) - shop.coords)

    if dist > 5.0 then
        return false, nil
    end

    return true, shop
end

-- ==================== KATALOQ ====================

ESX.RegisterServerCallback('196rp_phoneshop:getShop', function(source, cb, shopId)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        cb(nil)
        return
    end

    local ok = NearShop(source, shopId)

    if not ok then
        cb(nil)
        return
    end

    local ownedList = xPlayer.getMeta('ownedPhones') or {}
    local owned = {}

    for i = 1, #ownedList do
        owned[ownedList[i]] = true
    end

    cb({
        phones = Config.Phones,
        owned = owned,
        current = xPlayer.getMeta('phoneModel'),
        money = xPlayer.getMoney(),
    })
end)

-- ==================== SATIN ALMA ====================

ESX.RegisterServerCallback('196rp_phoneshop:buyPhone', function(source, cb, shopId, phoneId)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        cb(false, 'Sessiya tapılmadı.')
        return
    end

    if lastUse[source] and (GetGameTimer() - lastUse[source]) < Config.Cooldown then
        cb(false, 'Bir az gözləyin.')
        return
    end

    local ok, shop = NearShop(source, shopId)

    if not ok then
        cb(false, 'Mağazaya yaxınlaşın.')
        return
    end

    local phone = FindPhone(phoneId)

    if not phone then
        cb(false, 'Belə model yoxdur.')
        return
    end

    local ownedList = xPlayer.getMeta('ownedPhones') or {}

    for i = 1, #ownedList do
        if ownedList[i] == phoneId then
            cb(false, 'Bu telefon artıq sizdədir.')
            return
        end
    end

    if xPlayer.getMoney() < phone.price then
        cb(false, ('Kifayət qədər pulunuz yoxdur. Lazımdır: %s ₼'):format(phone.price))
        return
    end

    if not xPlayer.canCarryItem(Config.PhoneItem, 1) then
        cb(false, 'İnventarınız doludur.')
        return
    end

    lastUse[source] = GetGameTimer()

    xPlayer.removeMoney(phone.price, 'telefon_alindi')

    ownedList[#ownedList + 1] = phoneId
    xPlayer.setMeta('ownedPhones', ownedList)

    -- Telefona sahib olmaq üçün inventarda 'phone' əşyası olmalıdır
    local item = xPlayer.getInventoryItem(Config.PhoneItem)

    if not item or item.count < 1 then
        xPlayer.addInventoryItem(Config.PhoneItem, 1)
    end

    -- İlk telefon avtomatik aktivləşir
    if not xPlayer.getMeta('phoneModel') then
        xPlayer.setMeta('phoneModel', phoneId)
    end

    print(('[196rp_phoneshop] %s (%s) "%s" aldı — %s ₼ [%s]'):format(
        xPlayer.getName(), xPlayer.identifier, phone.name, phone.price, shop.name))

    cb(true, ('✅ %s %s alındı (%s GB, %s)'):format(
        phone.brand, phone.name, phone.storage, phone.colour))
end)

-- ==================== SATIŞ ====================

ESX.RegisterServerCallback('196rp_phoneshop:sellPhone', function(source, cb, shopId, phoneId)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        cb(false, 'Sessiya tapılmadı.')
        return
    end

    if lastUse[source] and (GetGameTimer() - lastUse[source]) < Config.Cooldown then
        cb(false, 'Bir az gözləyin.')
        return
    end

    local ok, shop = NearShop(source, shopId)

    if not ok then
        cb(false, 'Mağazaya yaxınlaşın.')
        return
    end

    local phone = FindPhone(phoneId)

    if not phone then
        cb(false, 'Belə model yoxdur.')
        return
    end

    local ownedList = xPlayer.getMeta('ownedPhones') or {}
    local found = false
    local newList = {}

    for i = 1, #ownedList do
        if ownedList[i] == phoneId then
            found = true
        else
            newList[#newList + 1] = ownedList[i]
        end
    end

    if not found then
        cb(false, 'Bu telefon sizdə yoxdur.')
        return
    end

    lastUse[source] = GetGameTimer()

    local payout = math.floor(phone.price * Config.SellRate)

    xPlayer.setMeta('ownedPhones', newList)
    xPlayer.addMoney(payout, 'telefon_satildi')

    -- Satılan telefon aktiv idisə, siyahıdakı növbəti telefona keçir
    if xPlayer.getMeta('phoneModel') == phoneId then
        xPlayer.setMeta('phoneModel', newList[1])
    end

    print(('[196rp_phoneshop] %s (%s) "%s" satdı — +%s ₼ [%s]'):format(
        xPlayer.getName(), xPlayer.identifier, phone.name, payout, shop.name))

    cb(true, ('💰 %s %s satıldı — +%s ₼'):format(phone.brand, phone.name, payout))
end)

-- ==================== TELEFONU İŞLƏT ====================

ESX.RegisterServerCallback('196rp_phoneshop:equipPhone', function(source, cb, phoneId)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        cb(false, 'Sessiya tapılmadı.')
        return
    end

    local phone = FindPhone(phoneId)

    if not phone then
        cb(false, 'Belə model yoxdur.')
        return
    end

    local ownedList = xPlayer.getMeta('ownedPhones') or {}
    local found = false

    for i = 1, #ownedList do
        if ownedList[i] == phoneId then
            found = true
            break
        end
    end

    if not found then
        cb(false, 'Bu telefon sizdə yoxdur.')
        return
    end

    xPlayer.setMeta('phoneModel', phoneId)

    cb(true, ('📲 %s %s işlədilir.'):format(phone.brand, phone.name))
end)

-- ==================== İXRACLAR ====================

-- Aktiv telefon modelini qaytarır (digər resurslar üçün)
exports('GetPhoneModel', function(src)
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return nil
    end

    return xPlayer.getMeta('phoneModel')
end)

-- Oyunçunun sahib olduğu modellər
exports('GetOwnedPhones', function(src)
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return {}
    end

    return xPlayer.getMeta('ownedPhones') or {}
end)

-- ==================== TƏMİZLƏMƏ ====================

AddEventHandler('playerDropped', function()
    lastUse[source] = nil
end)
