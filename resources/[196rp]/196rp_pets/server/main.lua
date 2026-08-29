-- 196 RP | Ev heyvanları — server tərəfi

local ESX = exports['es_extended']:getSharedObject()

local function FindAnimal(model)
    for i = 1, #Config.Animals do
        if Config.Animals[i].model == model then
            return Config.Animals[i]
        end
    end
    return nil
end

-- ==================== MAĞAZA SİYAHSI ====================

ESX.RegisterServerCallback('196rp_pets:getShop', function(source, cb)
    cb(Config.Animals)
end)

-- ==================== ALIŞ ====================

ESX.RegisterServerCallback('196rp_pets:buy', function(source, cb, model, name)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local animal = FindAnimal(model)
    if not animal then
        return cb(false, 'Belə bir heyvan satılmır!')
    end

    name = tostring(name or ''):gsub('[^%w%s%-]', ''):sub(1, 20)
    if name == '' then
        name = animal.label
    end

    -- Mağazaya yaxınlıq
    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - Config.Shop.coords) > 25.0 then
        return cb(false, 'Heyvan mağazasına yaxın deyilsiniz!')
    end

    -- Maksimum heyvan sayı
    local count = MySQL.scalar.await('SELECT COUNT(*) FROM `196rp_pets` WHERE `owner` = ?', { xPlayer.identifier })
    if (count or 0) >= Config.MaxPets then
        return cb(false, ('Ən çox %s heyvan saxlaya bilərsiniz!'):format(Config.MaxPets))
    end

    local price = animal.price
    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
    else
        local bank = xPlayer.getAccount('bank')
        if bank and bank.money >= price then
            xPlayer.removeAccountMoney('bank', price)
        else
            return cb(false, ('%s qiyməti ~y~%s$~s~-dır. Pulunuz kifayət etmir!'):format(animal.label, price))
        end
    end

    MySQL.insert.await(
        'INSERT INTO `196rp_pets` (`owner`, `name`, `model`, `species`, `hunger`, `happy`) VALUES (?, ?, ?, ?, 100, 100)',
        { xPlayer.identifier, name, animal.model, animal.species }
    )

    cb(true, ('~g~%s~s~ adlı %s aldınız! ~w~/heyvan~s~ ilə çağırın.'):format(name, animal.label))
end)

-- ==================== HEYVANLARIN SİYAHSI ====================

ESX.RegisterServerCallback('196rp_pets:getMyPets', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb({})
    end

    local rows = MySQL.query.await(
        'SELECT `id`, `name`, `model`, `species`, `hunger`, `happy` FROM `196rp_pets` WHERE `owner` = ? ORDER BY `id` ASC',
        { xPlayer.identifier }
    ) or {}

    cb(rows)
end)

-- ==================== YEMLƏMƏ ====================

ESX.RegisterServerCallback('196rp_pets:feed', function(source, cb, petId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local row = MySQL.single.await('SELECT * FROM `196rp_pets` WHERE `id` = ? AND `owner` = ?',
        { tonumber(petId), xPlayer.identifier })

    if not row then
        return cb(false, 'Belə bir heyvanınız yoxdur!')
    end

    local food = Config.FoodItems[row.species] or Config.FoodItems.dog
    local invItem = xPlayer.getInventoryItem(food.item)

    if not invItem or invItem.count < 1 then
        return cb(false, ('Sizdə ~y~%s~s~ yoxdur! Marketdən alın.'):format(food.label))
    end

    xPlayer.removeInventoryItem(food.item, 1)

    local newHunger = math.min(100, (row.hunger or 50) + food.amount)
    local newHappy = math.min(100, (row.happy or 50) + 10)

    MySQL.update.await('UPDATE `196rp_pets` SET `hunger` = ?, `happy` = ? WHERE `id` = ?',
        { newHunger, newHappy, row.id })

    cb(true, ('~g~%s~s~ yemləndi! Aclıq: %s%%'):format(row.name, newHunger))
end)

-- ==================== AXTAR / SAT ====================

ESX.RegisterServerCallback('196rp_pets:sell', function(source, cb, petId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local row = MySQL.single.await('SELECT * FROM `196rp_pets` WHERE `id` = ? AND `owner` = ?',
        { tonumber(petId), xPlayer.identifier })

    if not row then
        return cb(false, 'Belə bir heyvanınız yoxdur!')
    end

    -- Mağazaya yaxınlıq
    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - Config.Shop.coords) > 25.0 then
        return cb(false, 'Heyvanı satmaq üçün mağazaya gedin!')
    end

    local animal = FindAnimal(row.model)
    local refund = math.floor((animal and animal.price or 1000) * 0.6)

    MySQL.update.await('DELETE FROM `196rp_pets` WHERE `id` = ?', { row.id })
    xPlayer.addMoney(refund)

    cb(true, ('~y~%s~s~ mağazaya qaytarıldı. +~g~%s$~s~'):format(row.name, refund))
end)

-- ==================== ACLIQ / SEVİNC AZALMASI ====================

CreateThread(function()
    while true do
        Wait(Config.DecayInterval)

        MySQL.update.await(
            'UPDATE `196rp_pets` SET `hunger` = GREATEST(0, `hunger` - ?), `happy` = GREATEST(0, `happy` - ?)',
            { Config.HungerDecay, Config.HappyDecay }
        )

        -- Ac qalan heyvanlar üçün sahibinə bildiriş
        local hungry = MySQL.query.await('SELECT `owner`, `name` FROM `196rp_pets` WHERE `hunger` <= ?',
            { Config.HungerWarning }) or {}

        for i = 1, #hungry do
            local xOwner = ESX.GetPlayerFromIdentifier(hungry[i].owner)
            if xOwner then
                TriggerClientEvent('esx:showNotification', xOwner.source,
                    ('~r~🐾 %s acdır!~s~ Onu yemləyin (/heyvan).'):format(hungry[i].name), 'warning', 8000)
            end
        end
    end
end)

-- ==================== DİGƏR ====================

exports('GetPetCount', function(identifier)
    return MySQL.scalar.await('SELECT COUNT(*) FROM `196rp_pets` WHERE `owner` = ?', { identifier }) or 0
end)
