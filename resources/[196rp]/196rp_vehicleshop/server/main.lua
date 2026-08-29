-- 196 RP | Avtosalon — server tərəfi
-- Maşın alışı (nömrə 196RP ilə başlayır)

local ESX = exports['es_extended']:getSharedObject()

local function FindVehicleConfig(model)
    for i = 1, #Config.Vehicles do
        if Config.Vehicles[i].model == model then
            return Config.Vehicles[i]
        end
    end
    return nil
end

local function VehicleType(category)
    if category == 'boat' then
        return 'boat'
    elseif category == 'aircraft' then
        return 'aircraft'
    end
    return 'car'
end

-- Unikal nömrə: 196RP + 3 rəqəm
local function GeneratePlate()
    for _ = 1, 40 do
        local plate = ('196RP%03d'):format(math.random(0, 999))
        local exists = MySQL.scalar.await('SELECT 1 FROM `owned_vehicles` WHERE `plate` = ?', { plate })
        if not exists then
            return plate
        end
    end
    return nil
end

ESX.RegisterServerCallback('196rp_vehicleshop:buyVehicle', function(source, cb, shopId, model)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local vConfig = FindVehicleConfig(model)
    if not vConfig then
        return cb(false, 'Belə bir maşın satılmır!')
    end

    -- Mağazaya yaxınlıq
    local shop = nil
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    for i = 1, #Config.Shops do
        if Config.Shops[i].id == shopId then
            shop = Config.Shops[i]
            break
        end
    end

    if not shop or #(coords - shop.coords) > 40.0 then
        return cb(false, 'Avtosalona yaxın deyilsiniz!')
    end

    -- Kateqoriya bu mağazada satılırmı?
    local allowed = false
    for i = 1, #shop.categories do
        if shop.categories[i] == vConfig.category then
            allowed = true
            break
        end
    end
    if not allowed then
        return cb(false, 'Bu maşın bu salonda satılmır!')
    end

    local price = vConfig.price

    -- Bank hesabından alınır
    local bank = xPlayer.getAccount('bank')
    local bankMoney = bank and bank.money or 0

    if bankMoney >= price then
        xPlayer.removeAccountMoney('bank', price)
    elseif xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
    else
        return cb(false, ('Pulunuz kifayət etmir! Qiymət: ~y~%s$~s~'):format(price))
    end

    local plate = GeneratePlate()
    if not plate then
        return cb(false, 'Nömrə yaradıla bilmədi! Bir az sonra cəhd edin.')
    end

    MySQL.insert.await(
        'INSERT INTO `owned_vehicles` (`owner`, `plate`, `vehicle`, `type`, `job`, `stored`, `parking`, `pound`) VALUES (?, ?, ?, ?, NULL, 1, ?, NULL)',
        { xPlayer.identifier, plate, model, VehicleType(vConfig.category), 'garage_center' }
    )

    cb(true, ('~g~Təbriklər!~s~ %s aldınız.\nNömrə: ~y~%s~s~\nMaşın ~b~Mərkəzi Qarajda~s~ sizi gözləyir.'):format(vConfig.name, plate))
end)
