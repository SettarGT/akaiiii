-- 196 RP | Əlavə vəsiqələr — server tərəfi
-- Motosiklet, yük maşını, təyyarə və qayıq imtahanlarının yoxlanması

local ESX = exports['es_extended']:getSharedObject()

local tests = {}   -- source → { type, startedAt }

-- ==================== KÖMƏKÇİLƏR ====================

local function HasLicense(identifier, licenseType)
    local n = MySQL.scalar.await(
        'SELECT COUNT(*) FROM `user_licenses` WHERE `owner` = ? AND `type` = ?',
        { identifier, licenseType })
    return (tonumber(n) or 0) > 0
end

local function LicenseLabel(licenseType)
    local lic = Config.GetLicense(licenseType)
    return lic and lic.label or licenseType
end

-- ==================== VƏZİYYƏT ====================

ESX.RegisterServerCallback('196rp_licenses:getStatus', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb({})
    end

    local list = {}

    for i = 1, #Config.Licenses do
        local lic = Config.Licenses[i]
        local owned = HasLicense(xPlayer.identifier, lic.type)
        local canTake = true
        local requiresLabel = nil

        if lic.requires and not HasLicense(xPlayer.identifier, lic.requires) then
            canTake = false
            requiresLabel = LicenseLabel(lic.requires)
        end

        list[#list + 1] = {
            type = lic.type,
            label = lic.label,
            price = lic.price,
            owned = owned,
            canTake = canTake,
            requiresLabel = requiresLabel,
        }
    end

    cb(list)
end)

-- ==================== İMTAHAN ====================

ESX.RegisterServerCallback('196rp_licenses:startTest', function(source, cb, licenseType)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Xəta baş verdi!')
    end

    local lic = Config.GetLicense(tostring(licenseType or ''))
    if not lic then
        return cb(false, 'Belə bir vəsiqə növü yoxdur!')
    end

    if HasLicense(xPlayer.identifier, lic.type) then
        return cb(false, 'Bu vəsiqə sizdə artıq var!')
    end

    if lic.requires and not HasLicense(xPlayer.identifier, lic.requires) then
        return cb(false, ('Əvvəlcə ~y~%s~s~ almalısınız!'):format(LicenseLabel(lic.requires)))
    end

    if tests[source] then
        return cb(false, 'Artıq imtahandasınız! /imtahandayandır ilə ləğv edin.')
    end

    local ped = GetPlayerPed(source)
    if #(GetEntityCoords(ped) - Config.DMV.coords) > 25.0 then
        return cb(false, 'Sürücülük məktəbindən uzaqdasınız!')
    end

    if xPlayer.getMoney() >= lic.price then
        xPlayer.removeMoney(lic.price)
    else
        local bank = xPlayer.getAccount('bank')
        if bank and bank.money >= lic.price then
            xPlayer.removeAccountMoney('bank', lic.price)
        else
            return cb(false, ('Pulunuz kifayət etmir! Lazımdır: ~y~%s$~s~'):format(lic.price))
        end
    end

    tests[source] = { type = lic.type, startedAt = os.time() }

    cb(true, ('~g~%s imtahanı başladı!~s~ Hədəf: %s'):format(lic.label, lic.targetLabel))
end)

ESX.RegisterServerCallback('196rp_licenses:finishTest', function(source, cb, licenseType)
    local xPlayer = ESX.GetPlayerFromId(source)
    local data = tests[source]

    if not xPlayer or not data then
        return cb(false, 'Aktiv imtahan yoxdur!')
    end

    local lic = Config.GetLicense(data.type)
    if not lic or data.type ~= tostring(licenseType or '') then
        return cb(false, 'İmtahan uyğun gəlmir!')
    end

    local elapsed = os.time() - data.startedAt

    if elapsed > lic.timeLimit then
        tests[source] = nil
        return cb(false, ('~r~Vaxt bitdi!~s~ Limit: %s saniyə'):format(lic.timeLimit))
    end

    if elapsed < 10 then
        return cb(false, 'İmtahan çox tez bitdi — hədəfə çatmadınız!')
    end

    local ped = GetPlayerPed(source)
    local dist = #(GetEntityCoords(ped) - lic.target)

    if dist > lic.targetRadius then
        return cb(false, 'Hədəf nöqtəsindən uzaqdasınız!')
    end

    MySQL.update.await(
        'INSERT INTO `user_licenses` (`type`, `owner`) VALUES (?, ?)',
        { lic.type, xPlayer.identifier })

    tests[source] = nil

    cb(true, ('~g~Təbriklər!~s~ %s alındı.'):format(lic.label))
end)

ESX.RegisterServerCallback('196rp_licenses:cancelTest', function(source, cb)
    tests[source] = nil
    cb(true)
end)

-- ==================== ÇIXIŞ ====================

AddEventHandler('playerDropped', function()
    tests[source] = nil
end)

-- ==================== DİGƏR RESURSLAR ÜÇÜN ====================

exports('HasLicense', function(source, licenseType)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false
    end
    return HasLicense(xPlayer.identifier, tostring(licenseType or ''))
end)
