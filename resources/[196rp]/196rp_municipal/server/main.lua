local QBCore = exports['qb-core']:GetCoreObject()
local exports = exports

-- ═══════════════════════════════════════════════════════════════
-- Yardımçılar
-- ═══════════════════════════════════════════════════════════════

local function GenFIN()
    local fin = Config.FIN.prefix
    for _ = 1, Config.FIN.digits do
        fin = fin .. math.random(0, 9)
    end
    return fin
end

local function GenBlood()
    return Config.BloodTypes[math.random(1, #Config.BloodTypes)]
end

local function HasItem(src, item)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end
    return Player.Functions.GetItemByName(item) ~= nil
end

local function GetMeta(src, key)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return nil end
    return Player.PlayerData.metadata[key]
end

local function SetMeta(src, key, val)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.SetMetaData(key, val)
end

local function GiveCardItem(src, item, info)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    exports['qb-inventory']:AddItem(src, item, 1, false, info, '196rp_municipal')
end

-- ═══════════════════════════════════════════════════════════════
-- Pasport (FİN + qan qrupu)
-- ═══════════════════════════════════════════════════════════════

RegisterNetEvent('196rp_municipal:server:getPassport', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.money.cash < Config.Actions.passport.price then
        TriggerClientEvent('QBCore:Notify', src, ('Kifayət qədər pul yoxdur! (₣%s)'):format(Config.Actions.passport.price), 'error')
        return
    end
    if GetMeta(src, 'fin') then
        -- artıq pasportu var → yenilə
        TriggerClientEvent('196rp_municipal:client:card', src, {
            firstname = Player.PlayerData.charinfo.firstname,
            lastname = Player.PlayerData.charinfo.lastname,
            birthdate = Player.PlayerData.charinfo.birthdate,
            gender = Player.PlayerData.charinfo.gender,
            fin = GetMeta(src, 'fin'),
            blood = GetMeta(src, 'bloodtype') or '—',
        })
        return
    end

    Player.Functions.RemoveMoney('cash', Config.Actions.passport.price, 'bələdiyyə-pasport')
    local fin = GenFIN()
    local blood = GenBlood()
    SetMeta(src, 'fin', fin)
    SetMeta(src, 'bloodtype', blood)

    GiveCardItem(src, 'id_card', {
        citizenid = Player.PlayerData.citizenid,
        firstname = Player.PlayerData.charinfo.firstname,
        lastname = Player.PlayerData.charinfo.lastname,
        birthdate = Player.PlayerData.charinfo.birthdate,
        gender = Player.PlayerData.charinfo.gender,
        fin = fin,
        blood = blood,
    })

    TriggerClientEvent('196rp_municipal:client:card', src, {
        firstname = Player.PlayerData.charinfo.firstname,
        lastname = Player.PlayerData.charinfo.lastname,
        birthdate = Player.PlayerData.charinfo.birthdate,
        gender = Player.PlayerData.charinfo.gender,
        fin = fin,
        blood = blood,
    })
    TriggerClientEvent('QBCore:Notify', src, '🪪 Pasport verildi! FİN: ' .. fin .. ' | Qan qrupu: ' .. blood, 'success')
end)

-- ═══════════════════════════════════════════════════════════════
-- Sürücülük lisenziyası — nəzəri imtahan
-- ═══════════════════════════════════════════════════════════════

RegisterNetEvent('196rp_municipal:server:startDriving', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if GetMeta(src, 'drivinglicense') then
        TriggerClientEvent('QBCore:Notify', src, 'Artıq sürücülük vəsiqəniz var.', 'success')
        return
    end
    if Player.PlayerData.money.cash < Config.Actions.driver.price then
        TriggerClientEvent('QBCore:Notify', src, ('Kifayət qədər pul yoxdur! (₣%s)'):format(Config.Actions.driver.price), 'error')
        return
    end
    -- İmtahanı klientə göndər (suallar serverdə gizli)
    TriggerClientEvent('196rp_municipal:client:exam', src, { questions = Config.DrivingExam.questions })
end)

-- İmtahan nəticəsi (serverdə yoxlanır — clientə güvənmirik)
RegisterNetEvent('196rp_municipal:server:examResult', function(answers)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if GetMeta(src, 'drivinglicense') then return end

    local correct = 0
    for i, q in ipairs(Config.DrivingExam.questions) do
        if tonumber(answers[i]) == q.correct then correct = correct + 1 end
    end
    local percent = math.floor(correct / #Config.DrivingExam.questions * 100)

    if percent < Config.DrivingExam.passPercent then
        TriggerClientEvent('QBCore:Notify', src, ('❌ İmtahan UĞURSUZ! Düzgün: %d/%d (%d%%). Yenidən cəhd edin.'):format(correct, #Config.DrivingExam.questions, percent), 'error')
        return
    end

    -- Praktik mərhələyə keç
    TriggerClientEvent('196rp_municipal:client:practical', src, { route = Config.PracticalRoute, duration = Config.PracticalRoute.duration })
end)

-- Praktik nəticə
RegisterNetEvent('196rp_municipal:server:practicalResult', function(success)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if GetMeta(src, 'drivinglicense') then return end
    if not success then
        TriggerClientEvent('QBCore:Notify', src, '❌ Praktik marşrut tamamlanmadı! Yenidən bələdiyyəyə gəlin.', 'error')
        return
    end

    Player.Functions.RemoveMoney('cash', Config.Actions.driver.price, 'bələdiyyə-sürücülük')
    SetMeta(src, 'drivinglicense', true)
    GiveCardItem(src, 'driver_license', {
        firstname = Player.PlayerData.charinfo.firstname,
        lastname = Player.PlayerData.charinfo.lastname,
        birthdate = Player.PlayerData.charinfo.birthdate,
        type = 'B kateqoriya (196 RP)',
    })
    TriggerClientEvent('QBCore:Notify', src, '✅ Sürücülük vəsiqəsi verildi! Təbriklər!', 'success')
end)

-- ═══════════════════════════════════════════════════════════════
-- Silah lisenziyası
-- ═══════════════════════════════════════════════════════════════

RegisterNetEvent('196rp_municipal:server:getWeaponLicense', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if GetMeta(src, 'weaponlicense') then
        TriggerClientEvent('QBCore:Notify', src, 'Artıq silah lisenziyanız var.', 'success')
        return
    end
    if Player.PlayerData.money.cash < Config.Actions.weapon.price then
        TriggerClientEvent('QBCore:Notify', src, ('Kifayət qədər pul yoxdur! (₣%s)'):format(Config.Actions.weapon.price), 'error')
        return
    end
    Player.Functions.RemoveMoney('cash', Config.Actions.weapon.price, 'bələdiyyə-silah')
    SetMeta(src, 'weaponlicense', true)
    GiveCardItem(src, 'weaponlicense', {
        firstname = Player.PlayerData.charinfo.firstname,
        lastname = Player.PlayerData.charinfo.lastname,
        type = 'Silah lisenziyası (196 RP)',
    })
    TriggerClientEvent('QBCore:Notify', src, '🔫 Silah lisenziyası verildi! (Silah mağazaları üçün tələb olunur)', 'success')
end)


-- ═══════════════════════════════════════════════════════════════
-- Mətbuat və Vəkillik lisenziyaları
-- ═══════════════════════════════════════════════════════════════

RegisterNetEvent('196rp_municipal:server:getPressLicense', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if GetMeta(src, 'presslicense') then
        TriggerClientEvent('QBCore:Notify', src, 'Artıq mətbuat lisenziyanız var.', 'success')
        return
    end
    if Player.PlayerData.money.cash < Config.Actions.press.price then
        TriggerClientEvent('QBCore:Notify', src, ('Kifayət qədər pul yoxdur! (₣%s)'):format(Config.Actions.press.price), 'error')
        return
    end
    Player.Functions.RemoveMoney('cash', Config.Actions.press.price, 'bələdiyyə-mətbuat')
    SetMeta(src, 'presslicense', true)
    GiveCardItem(src, 'presspass', {
        firstname = Player.PlayerData.charinfo.firstname,
        lastname = Player.PlayerData.charinfo.lastname,
        type = 'Mətbuat lisenziyası (196 RP)',
    })
    TriggerClientEvent('QBCore:Notify', src, '📷 Mətbuat lisenziyası verildi!', 'success')
end)

RegisterNetEvent('196rp_municipal:server:getLawyerLicense', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if GetMeta(src, 'lawyerlicense') then
        TriggerClientEvent('QBCore:Notify', src, 'Artıq vəkillik lisenziyanız var.', 'success')
        return
    end
    if Player.PlayerData.money.cash < Config.Actions.lawyer.price then
        TriggerClientEvent('QBCore:Notify', src, ('Kifayət qədər pul yoxdur! (₣%s)'):format(Config.Actions.lawyer.price), 'error')
        return
    end
    Player.Functions.RemoveMoney('cash', Config.Actions.lawyer.price, 'bələdiyyə-vəkillik')
    SetMeta(src, 'lawyerlicense', true)
    GiveCardItem(src, 'lawyerpass', {
        firstname = Player.PlayerData.charinfo.firstname,
        lastname = Player.PlayerData.charinfo.lastname,
        type = 'Vəkillik lisenziyası (196 RP)',
    })
    TriggerClientEvent('QBCore:Notify', src, '⚖️ Vəkillik lisenziyası verildi!', 'success')
end)

-- ═══════════════════════════════════════════════════════════════
-- /pasport — NUI kart göstər
-- ═══════════════════════════════════════════════════════════════

QBCore.Commands.Add('pasport', 'Şəxsiyyət vəsiqəsini göstər (NUI)', {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if not GetMeta(src, 'fin') then
        TriggerClientEvent('QBCore:Notify', src, 'Hələ pasportunuz yoxdur. Bələdiyyəyə gedin (City Hall).', 'error')
        return
    end
    TriggerClientEvent('196rp_municipal:client:card', src, {
        firstname = Player.PlayerData.charinfo.firstname,
        lastname = Player.PlayerData.charinfo.lastname,
        birthdate = Player.PlayerData.charinfo.birthdate,
        gender = Player.PlayerData.charinfo.gender,
        fin = GetMeta(src, 'fin'),
        blood = GetMeta(src, 'bloodtype') or '—',
        license = GetMeta(src, 'drivinglicense') and 'B' or '—',
        weapon = GetMeta(src, 'weaponlicense') and 'VAR' or 'YOX',
    })
end, false)
