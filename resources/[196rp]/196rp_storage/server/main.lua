local QBCore = exports['qb-core']:GetCoreObject()

local auction = nil   -- { unit, highest = {src, amount}, until }

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

local function IsAdmin(src)
    return IsPlayerAceAllowed(src, 'command') or IsPlayerAceAllowed(src, 'god')
end

-- ── Cari icarə ──
local function GetRental(unit, cb)
    MySQL.single('SELECT citizenid, rented_until FROM 196_storage WHERE unit = ?', { unit }, function(row)
        if row and row.citizenid and row.rented_until and os.time() < tonumber(row.rented_until) then
            cb(row.citizenid)
        else
            cb(nil)
        end
    end)
end

-- ── İcarə ──
RegisterNetEvent('196rp_storage:server:rent', function(unit)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    unit = tonumber(unit)
    if not unit or unit < 1 or unit > Config.Units then return end

    if (Player.PlayerData.money.cash or 0) < Config.RentPrice then
        Notify(src, ('Kifayət qədər pul yoxdur — icarə ₣%d'):format(Config.RentPrice), 'error')
        return
    end

    GetRental(unit, function(owner)
        if owner and owner ~= Player.PlayerData.citizenid then
            Notify(src, 'Bu anbar artıq icarədədir.', 'error')
            return
        end
        Player.Functions.RemoveMoney('cash', Config.RentPrice, 'storage-rent')
        MySQL.insert('INSERT INTO 196_storage (unit, citizenid, rented_until) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE citizenid = VALUES(citizenid), rented_until = VALUES(rented_until)', {
            unit, Player.PlayerData.citizenid, os.time() + 7 * 24 * 3600,
        })
        Notify(src, ('📦 %d nömrəli anbar icarə olundu (7 gün).'):format(unit), 'success')
    end)
end)

-- ── Anbarı aç ──
RegisterNetEvent('196rp_storage:server:open', function(unit)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    unit = tonumber(unit)
    if not unit or unit < 1 or unit > Config.Units then return end

    GetRental(unit, function(owner)
        if not owner then
            Notify(src, 'Bu anbar boşdur — əvvəlcə icarə edin.', 'error')
            return
        end
        if owner ~= Player.PlayerData.citizenid then
            Notify(src, 'Bu anbar sizə aid deyil.', 'error')
            return
        end
        exports['qb-inventory']:OpenInventory(src, 'stash_196_unit_' .. unit, {
            label = ('196 Anbar №%d'):format(unit),
            slots = Config.Slots,
            maxweight = Config.MaxWeight,
        })
    end)
end)

-- ── Storage Wars: hərrac başlat (admin) ──
RegisterCommand('aukstart', function(source, args)
    if source == 0 then return end
    if not IsAdmin(source) then
        Notify(source, 'Bu əmr admin üçündür.', 'error')
        return
    end
    if auction then
        Notify(source, 'Hərrac artıq davam edir.', 'error')
        return
    end
    local unit = tonumber(args[1]) or Config.AuctionUnits[math.random(#Config.AuctionUnits)]
    if not unit or unit < 1 or unit > Config.Units then
        Notify(source, 'Anbar nömrəsi yanlışdır.', 'error')
        return
    end

    GetRental(unit, function(owner)
        if owner then
            Notify(source, 'Bu anbar icarədədir — yalnız boş anbarlar hərraca çıxır.', 'error')
            return
        end
        auction = { unit = unit, highest = nil, ends = os.time() + Config.Auction.Duration }
        TriggerClientEvent('196rp_storage:client:auction', -1, {
            unit = unit, ends = auction.ends, minBid = Config.Auction.MinBid, step = Config.Auction.BidStep,
        })
        TriggerClientEvent('QBCore:Notify', -1, ('🔨 Storage Wars: №%d anbar kor hərraca çıxdı! /auk ilə iştirak et.'):format(unit), 'primary')
    end)
end, false)

RegisterCommand('auk', function(source)
    if auction then
        TriggerClientEvent('196rp_storage:client:auction', source, {
            unit = auction.unit, ends = auction.ends, minBid = Config.Auction.MinBid, step = Config.Auction.BidStep,
            current = auction.highest and auction.highest.amount or 0,
        })
    else
        Notify(source, 'Hazırda aktiv hərrac yoxdur.', 'primary')
    end
end, false)


-- Terminaldan hərrac sorğusu
RegisterNetEvent('196rp_storage:server:auctionRequest', function()
    local src = source
    if auction then
        TriggerClientEvent('196rp_storage:client:auction', src, {
            unit = auction.unit, ends = auction.ends, minBid = Config.Auction.MinBid, step = Config.Auction.BidStep,
            current = auction.highest and auction.highest.amount or 0,
        })
    else
        Notify(src, 'Hazırda aktiv hərrac yoxdur.', 'primary')
    end
end)

-- ── Təklif ──
RegisterNetEvent('196rp_storage:server:bid', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    amount = tonumber(amount)
    if not auction then return end
    if not amount or amount < Config.Auction.MinBid then return end

    local current = auction.highest and auction.highest.amount or 0
    if amount <= current or amount % Config.Auction.BidStep ~= 0 then
        Notify(src, ('Təklif ₣%d-dən başlayır, addım ₣%d.'):format(current + Config.Auction.BidStep, Config.Auction.BidStep), 'error')
        return
    end
    if (Player.PlayerData.money.cash or 0) < amount then
        Notify(src, 'Kifayət qədər nağd pul yoxdur.', 'error')
        return
    end
    auction.highest = { src = src, amount = amount }
    TriggerClientEvent('196rp_storage:client:update', -1, { amount = amount, ends = auction.ends })
    Notify(src, ('📈 Təklifiniz qəbul edildi: ₣%d'):format(amount), 'success')
end)

-- ── Hərrac bağlanması ──
CreateThread(function()
    while true do
        Wait(1000)
        if auction and os.time() >= auction.ends then
            local a = auction
            auction = nil
            if a.highest then
                local Player = QBCore.Functions.GetPlayer(a.highest.src)
                if Player and (Player.PlayerData.money.cash or 0) >= a.highest.amount then
                    Player.Functions.RemoveMoney('cash', a.highest.amount, 'storage-auction-win')
                    MySQL.insert('INSERT INTO 196_storage (unit, citizenid, rented_until) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE citizenid = VALUES(citizenid), rented_until = VALUES(rented_until)', {
                        a.unit, Player.PlayerData.citizenid, os.time() + 7 * 24 * 3600,
                    })
                    TriggerClientEvent('QBCore:Notify', a.highest.src, ('🔨 Qazandınız: №%d anbar (₣%d)!'):format(a.unit, a.highest.amount), 'success')
                else
                    TriggerClientEvent('QBCore:Notify', a.highest.src, 'Təklifi ödəyə bilmədiniz — hərrac ləğv olundu.', 'error')
                end
            else
                TriggerClientEvent('QBCore:Notify', -1, 'Hərrac təklifsiz qaldı — ləğv olundu.', 'primary')
            end
            TriggerClientEvent('196rp_storage:client:auctionEnd', -1)
        end
    end
end)
