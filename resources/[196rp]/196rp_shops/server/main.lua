-- 196 RP | Mağazalar — server tərəfi
-- Alış-veriş (yalnız mağaza yaxınlığında)

local ESX = exports['es_extended']:getSharedObject()

local function FindShop(id)
    for i = 1, #Config.Shops do
        if Config.Shops[i].id == id then
            return Config.Shops[i]
        end
    end
    return nil
end

local function FindItem(shop, itemName)
    for i = 1, #shop.items do
        if shop.items[i].name == itemName then
            return shop.items[i]
        end
    end
    return nil
end

ESX.RegisterServerCallback('196rp_shops:buyItem', function(source, cb, shopId, itemName, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local shop = FindShop(shopId)
    if not shop then
        return cb(false, 'Mağaza tapılmadı!')
    end

    -- Uzaqlıq yoxlaması (client hack qorunması)
    local ped = GetPlayerPed(source)
    local dist = #(GetEntityCoords(ped) - shop.coords)
    if dist > 12.0 then
        return cb(false, 'Mağazaya çox uzaqsınız!')
    end

    local item = FindItem(shop, itemName)
    if not item then
        return cb(false, 'Bu məhsul mağazada satılmır!')
    end

    amount = tonumber(amount) or 1
    amount = math.floor(amount)
    if amount < 1 or amount > 50 then
        return cb(false, 'Yanlış say! (1-50 arası)')
    end

    if not xPlayer.canCarryItem(item.name, amount) then
        return cb(false, 'Çantanızda kifayət qədər yer yoxdur!')
    end

    local total = item.price * amount

    if xPlayer.getMoney() < total then
        return cb(false, ('Kifayət qədər pulunuz yoxdur! Lazımdır: ~y~%s$~s~'):format(total))
    end

    xPlayer.removeMoney(total)
    xPlayer.addInventoryItem(item.name, amount)

    cb(true, '')
end)
