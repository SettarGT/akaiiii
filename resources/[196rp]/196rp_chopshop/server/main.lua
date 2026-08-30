local QBCore = exports['qb-core']:GetCoreObject()

local busy = {}
local lastChop = {}

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

-- ── Söküm başlat ──
RegisterNetEvent('196rp_chopshop:server:start', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    plate = tostring(plate or ''):upper()

    if busy[src] then return end
    local now = os.time()
    if lastChop[src] and (now - lastChop[src]) < Config.Chop.Cooldown then
        Notify(src, ('Söküm sexi soyuyur — %d saniyə gözləyin.'):format(Config.Chop.Cooldown - (now - lastChop[src])), 'error')
        return
    end

    -- Öz maşını deyil?
    MySQL.query('SELECT plate FROM player_vehicles WHERE plate = ? AND citizenid = ?', { plate, Player.PlayerData.citizenid }, function(r)
        if r and #r > 0 then
            Notify(src, 'Öz avtomobilinizi sökə bilməzsiniz!', 'error')
            return
        end

        lastChop[src] = now
        busy[src] = true
        Notify(src, '🔧 Söküm başladı... (45 saniyə)', 'primary')

        -- Polis xəbərdarlığı
        for _, p in ipairs(QBCore.Functions.GetPlayers()) do
            local P = QBCore.Functions.GetPlayer(p)
            if P and P.PlayerData.job.type == 'leo' and P.PlayerData.job.onduty then
                TriggerClientEvent('QBCore:Notify', p, ('🚨 SÖKÜM SEXİ: maşın sökülür (%s)!'):format(plate), 'error')
            end
        end

        if GetResourceState('196rp_stress') == 'started' then
            exports['196rp_stress']:AddStress(src, Config.StressIncrease)
        end

        SetTimeout(Config.Chop.Time * 1000, function()
            busy[src] = nil
            local P2 = QBCore.Functions.GetPlayer(src)
            if not P2 then return end
            local parts = math.random(Config.Chop.MinParts, Config.Chop.MaxParts)
            local added = P2.Functions.AddItem('scrap_metal', parts, false, false, 'chopshop')
            if added then
                TriggerClientEvent('QBCore:Notify', src, ('🔩 Söküm bitdi: %d metal parçası!'):format(parts), 'success')
                TriggerClientEvent('196rp_chopshop:client:deleteVehicle', src, plate)
            else
                TriggerClientEvent('QBCore:Notify', src, 'Çanta doludur — hissələr itdi!', 'error')
            end
        end)
    end)
end)

-- ── Hissə sat ──
RegisterNetEvent('196rp_chopshop:server:sell', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local item = Player.Functions.GetItemByName('scrap_metal')
    if not item or item.amount <= 0 then
        Notify(src, 'Satmaq üçün metal yoxdur.', 'error')
        return
    end
    local earned = item.amount * Config.Prices.ScrapPrice
    Player.Functions.RemoveItem('scrap_metal', item.amount, false, false, 'chopshop-sell')
    Player.Functions.AddMoney('cash', earned, 'chopshop-sell')
    Notify(src, ('💰 %d metal satıldı: +₣%d'):format(item.amount, earned), 'success')
end)
