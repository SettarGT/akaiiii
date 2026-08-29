-- 196 RP | Həyat tərzi — server tərəfi
-- Vəziyyətin saxlanması, xəstəxana, bişirmə, qeydlər, ad günü, mövsümlər

local ESX = exports['es_extended']:getSharedObject()

-- ==================== KÖMƏKÇİLƏR ====================

local function Clamp(n, min, max)
    n = tonumber(n) or min
    if n < min then return min end
    if n > max then return max end
    return math.floor(n * 10) / 10
end

local function GetSeason()
    local month = tonumber(os.date('%m'))
    return Config.Seasons.months[month] or 'spring'
end

local function GetState(xPlayer)
    return {
        hygiene = Clamp(xPlayer.getMeta('hygiene') or Config.Hygiene.start, 0, 100),
        stress = Clamp(xPlayer.getMeta('stress') or Config.Stress.start, 0, Config.Stress.max),
        drunk = Clamp(xPlayer.getMeta('drunk') or 0, 0, 100),
        sick = xPlayer.getMeta('sick') == true,
        season = GetSeason(),
    }
end

-- ==================== GİRİŞ ====================

AddEventHandler('esx:playerLoaded', function(source, xPlayer)
    Wait(2000)

    local s = GetState(xPlayer)
    TriggerClientEvent('196rp_lifestyle:setState', source, s)

    -- Mövsüm bildirişi
    TriggerClientEvent('esx:showNotification', source,
        ('📅 Mövsüm: ~y~%s~s~'):format(Config.Seasons.labels[s.season] or s.season), 'info')

    -- AD GÜNÜ (14)
    local dob = xPlayer.get('dateofbirth')
    if dob then
        local day, month
        local d1, m1 = dob:match('^(%d+)[/%-](%d+)')
        if d1 and m1 then
            day, month = tonumber(d1), tonumber(m1)
        end

        if day and month then
            local todayDay = tonumber(os.date('%d'))
            local todayMonth = tonumber(os.date('%m'))

            if day == todayDay and month == todayMonth then
                xPlayer.addAccountMoney('bank', Config.Birthday.gift)
                TriggerClientEvent('esx:showNotification', source,
                    ('%s Hediyyə: ~g~%s$~s~ hesabınıza köçürüldü.'):format(Config.Birthday.message, Config.Birthday.gift),
                    'success', 12000)
            end
        end
    end
end)

-- ==================== SİNXRONİZASİYA ====================

RegisterNetEvent('196rp_lifestyle:sync', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or type(data) ~= 'table' then
        return
    end

    xPlayer.setMeta('hygiene', Clamp(data.hygiene or 100, 0, 100))
    xPlayer.setMeta('stress', Clamp(data.stress or 0, 0, Config.Stress.max))
    xPlayer.setMeta('drunk', Clamp(data.drunk or 0, 0, 100))
end)

-- Huşunu itirmə — xəstələnmə şansı (2)
RegisterNetEvent('196rp_lifestyle:onKnockedOut', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        return
    end

    if xPlayer.getMeta('sick') == true then
        return
    end

    if math.random(1, 100) <= 35 then
        xPlayer.setMeta('sick', true)
        TriggerClientEvent('196rp_lifestyle:updateValue', src, 'sick', true)
    end
end)

-- ==================== SİQARET (5) ====================

ESX.RegisterUsableItem(Config.Smoking.item, function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return
    end

    local inv = xPlayer.getInventoryItem(Config.Smoking.item)
    if not inv or inv.count < 1 then
        return
    end

    xPlayer.removeInventoryItem(Config.Smoking.item, 1)

    -- Sağlamlıq cəriməsi
    local ped = GetPlayerPed(source)
    local health = GetEntityHealth(ped)
    if health > 120 then
        SetEntityHealth(ped, health - Config.Smoking.healthCost)
    end

    TriggerClientEvent('196rp_lifestyle:smoke', source)
end)

-- ==================== ALKOQOL (6) ====================

for itemName, drink in pairs(Config.Alcohol.drinks) do
    ESX.RegisterUsableItem(itemName, function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then
            return
        end

        local inv = xPlayer.getInventoryItem(itemName)
        if not inv or inv.count < 1 then
            return
        end

        xPlayer.removeInventoryItem(itemName, 1)

        local current = Clamp(xPlayer.getMeta('drunk') or 0, 0, 100)
        local newLevel = Clamp(current + drink.level, 0, 100)
        xPlayer.setMeta('drunk', newLevel)

        TriggerClientEvent('196rp_lifestyle:updateValue', source, 'drunk', newLevel)
        TriggerClientEvent('esx:showNotification', source,
            ('~y~🍺 %s içdiniz.~s~ Sərxoşluq: %s%%'):format(drink.label, math.floor(newLevel)), 'info')

        -- Çox içsə huşunu itirir
        if newLevel >= Config.Alcohol.blackoutLevel then
            TriggerClientEvent('esx:showNotification', source,
                '~r~Çox içdiniz!~s~ Huşunuzu itirdiniz...', 'error', 8000)
            xPlayer.setMeta('sick', true)
            TriggerClientEvent('196rp_lifestyle:updateValue', source, 'sick', true)
        end
    end)
end

-- ==================== DƏRMAN ====================

ESX.RegisterUsableItem('derman', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return
    end

    local inv = xPlayer.getInventoryItem('derman')
    if not inv or inv.count < 1 then
        return
    end

    xPlayer.removeInventoryItem('derman', 1)

    if xPlayer.getMeta('sick') == true then
        xPlayer.setMeta('sick', false)
        TriggerClientEvent('196rp_lifestyle:updateValue', source, 'sick', false)
    end

    local ped = GetPlayerPed(source)
    local health = GetEntityHealth(ped)
    SetEntityHealth(ped, math.min(GetEntityMaxHealth(ped), health + 40))

    TriggerClientEvent('esx:showNotification', source, '~g~Dərman qəbul etdiniz.~s~ +40 can', 'success')
end)

-- ==================== XƏSTƏXANA (2) ====================

ESX.RegisterServerCallback('196rp_lifestyle:hospital', function(source, cb, action)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    -- Xəstəxanaya yaxınlıq
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local near = false
    for i = 1, #Config.Hospital.locations do
        if #(coords - Config.Hospital.locations[i].coords) < 20.0 then
            near = true
            break
        end
    end

    if not near then
        return cb(false, 'Xəstəxanaya yaxın deyilsiniz!')
    end

    local price = action == 'heal' and Config.Hospital.healPrice or Config.Hospital.cureSickPrice

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
    else
        local bank = xPlayer.getAccount('bank')
        if bank and bank.money >= price then
            xPlayer.removeAccountMoney('bank', price)
        else
            return cb(false, ('Pulunuz kifayət etmir! Lazımdır: ~y~%s$~s~'):format(price))
        end
    end

    if action == 'cure' then
        xPlayer.setMeta('sick', false)
        TriggerClientEvent('196rp_lifestyle:updateValue', source, 'sick', false)
        return cb(true, ('~g~Həkim sizi müalicə etdi.~s~ Ödəniş: %s$'):format(price))
    end

    return cb(true, ('~g~Tam müalicə olundunuz!~s~ Ödəniş: %s$'):format(price))
end)

-- ==================== BİŞİRMƏ (11) ====================

ESX.RegisterServerCallback('196rp_lifestyle:cook', function(source, cb, recipeIndex)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local recipe = Config.Cooking.recipes[tonumber(recipeIndex) or 0]
    if not recipe then
        return cb(false, 'Belə bir resept yoxdur!')
    end

    -- Mətbəxə yaxınlıq
    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - Config.Cooking.kitchen) > 10.0 then
        return cb(false, 'Mətbəxə yaxın deyilsiniz!')
    end

    -- İnqrediyentlər
    for i = 1, #recipe.ingredients do
        local ing = recipe.ingredients[i]
        local inv = xPlayer.getInventoryItem(ing.item)
        if not inv or inv.count < ing.count then
            return cb(false, ('~y~%s~s~ üçün %s ədəd %s lazımdır!'):format(recipe.label, ing.count, ing.item))
        end
    end

    if not xPlayer.canCarryItem(recipe.output, recipe.count) then
        return cb(false, 'Çantanızda yer yoxdur!')
    end

    for i = 1, #recipe.ingredients do
        local ing = recipe.ingredients[i]
        xPlayer.removeInventoryItem(ing.item, ing.count)
    end

    xPlayer.addInventoryItem(recipe.output, recipe.count)

    cb(true, ('~g~%s~s~ hazırdır! (+%s ədəd)'):format(recipe.label, recipe.count))
end)

-- ==================== QEYDLƏR (12) ====================

ESX.RegisterServerCallback('196rp_lifestyle:addNote', function(source, cb, text)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    text = tostring(text or ''):sub(1, Config.Notes.maxLength)
    if text == '' then
        return cb(false, 'Qeyd boş ola bilməz!')
    end

    local count = MySQL.scalar.await('SELECT COUNT(*) FROM `196rp_notes` WHERE `identifier` = ?', { xPlayer.identifier })
    if (count or 0) >= Config.Notes.max then
        return cb(false, ('Ən çox %s qeyd saxlaya bilərsiniz!'):format(Config.Notes.max))
    end

    MySQL.insert.await('INSERT INTO `196rp_notes` (`identifier`, `note`) VALUES (?, ?)',
        { xPlayer.identifier, text })

    cb(true, '~g~Qeyd saxlanıldı!~s~ /qeydler ilə baxın.')
end)

ESX.RegisterServerCallback('196rp_lifestyle:getNotes', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb({})
    end

    local rows = MySQL.query.await(
        'SELECT `id`, `note`, `created_at` FROM `196rp_notes` WHERE `identifier` = ? ORDER BY `id` DESC',
        { xPlayer.identifier }
    ) or {}

    cb(rows)
end)

ESX.RegisterServerCallback('196rp_lifestyle:deleteNote', function(source, cb, noteId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false)
    end

    MySQL.update.await('DELETE FROM `196rp_notes` WHERE `id` = ? AND `identifier` = ?',
        { tonumber(noteId), xPlayer.identifier })

    cb(true)
end)

-- ==================== DİGƏR RESURSLAR ÜÇÜN ====================

exports('GetPlayerState', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return nil
    end
    return GetState(xPlayer)
end)

exports('SetSick', function(source, value)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false
    end

    xPlayer.setMeta('sick', value == true)
    TriggerClientEvent('196rp_lifestyle:updateValue', source, 'sick', value == true)
    return true
end)

exports('AddStress', function(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false
    end

    local current = Clamp(xPlayer.getMeta('stress') or 0, 0, Config.Stress.max)
    local newVal = Clamp(current + (tonumber(amount) or 0), 0, Config.Stress.max)
    xPlayer.setMeta('stress', newVal)

    TriggerClientEvent('196rp_lifestyle:updateValue', source, 'stress', newVal)
    return true
end)

-- Mövsüm dəyişikliyi (hər saat yoxlanılır)
CreateThread(function()
    local lastSeason = GetSeason()
    while true do
        Wait(3600000)
        local s = GetSeason()
        if s ~= lastSeason then
            lastSeason = s
            TriggerClientEvent('esx:showNotification', -1,
                ('📅 Mövsüm dəyişdi: ~y~%s~s~'):format(Config.Seasons.labels[s] or s), 'info')
        end
    end
end)
