local QBCore = exports['qb-core']:GetCoreObject()

local busy = {}

-- ── İşə düzəl ──
RegisterNetEvent('196rp_jobs:apply', function(jobName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not Config.Jobs[jobName] then
        TriggerClientEvent('QBCore:Notify', src, Config.Text.not_open, 'error')
        return
    end
    if Player.PlayerData.job.name == jobName then
        TriggerClientEvent('QBCore:Notify', src, Config.Text.already, 'error')
        return
    end

    Player.Functions.SetJob(jobName, 0)
    local label = Config.Jobs[jobName].label or jobName

    local tool = Config.Tools[jobName]
    if tool then
        Player.Functions.AddItem(tool, 1, false, false, '196rp_jobs:apply')
    end

    TriggerClientEvent('QBCore:Notify', src, Config.Text.applied:gsub('%%{job}', label), 'success')
end)

-- ── İşdən çıx ──
RegisterNetEvent('196rp_jobs:quit', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local tool = Config.Tools[Player.PlayerData.job.name]
    if tool then
        Player.Functions.RemoveItem(tool, 1, false, false, '196rp_jobs:quit')
    end

    Player.Functions.SetJob('unemployed', 0)
    TriggerClientEvent('QBCore:Notify', src, Config.Text.quit_msg, 'success')
end)

-- ── İş əməliyyatı (server-side vaxt yoxlaması + məhsul) ──
RegisterNetEvent('196rp_jobs:server:collect', function(job, zoneLabel)
    local src = source
    if busy[src] then return end
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.PlayerData.job.name ~= job then
        TriggerClientEvent('QBCore:Notify', src, Config.Text.wrong_job, 'error')
        return
    end

    local tool = Config.Tools[job]
    if tool and not Player.Functions.GetItemByName(tool) then
        TriggerClientEvent('QBCore:Notify', src, Config.Text.need_tool, 'error')
        return
    end

    local result = {}
    if job == 'fisher' then
        result = { item = 'fish', count = math.random(1, 2), time = Config.WorkTime.fisher }
    elseif job == 'miner' then
        local r = math.random(100)
        result = r < 55 and { item = 'stone', count = 1, time = Config.WorkTime.miner }
              or r < 95 and { item = 'coal', count = 1, time = Config.WorkTime.miner }
              or { item = 'stone', count = 3, time = Config.WorkTime.miner }
    elseif job == 'lumberjack' then
        result = { item = 'wood', count = math.random(1, 2), time = Config.WorkTime.lumberjack }
    elseif job == 'construction' then
        local mat = Config.Construction.Materials[math.random(#Config.Construction.Materials)]
        result = { item = mat, count = 1, time = Config.WorkTime.construction }
    else
        return
    end

    busy[src] = true

    SetTimeout(result.time * 1000, function()
        busy[src] = nil
        local p = QBCore.Functions.GetPlayer(src)
        if not p then return end
        local added = p.Functions.AddItem(result.item, result.count, false, false, '196rp_jobs:collect')
        if added then
            local label = (QBCore.Shared.Items[result.item] and QBCore.Shared.Items[result.item].label) or result.item
            TriggerClientEvent('QBCore:Notify', src, Config.Text.got_item:gsub('%%{item}', ('%s x%d'):format(label, result.count)), 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Çantanız doludur!', 'error')
        end

        if job == 'construction' then
            Config._sites = Config._sites or {}
            local key = zoneLabel or 'site'
            Config._sites[key] = (Config._sites[key] or 0) + 1
            TriggerClientEvent('QBCore:Notify', src, Config.Text.site_progress
                :gsub('%%{step}', Config._sites[key])
                :gsub('%%{total}', Config.Construction.StepsPerSite), 'primary')
            if Config._sites[key] >= Config.Construction.StepsPerSite then
                Config._sites[key] = 0
                p.Functions.AddMoney('cash', Config.Construction.Bonus, 'construction-site-bonus')
                TriggerClientEvent('QBCore:Notify', src, Config.Text.site_done:gsub('%%{bonus}', Config.Construction.Bonus), 'success')
            end
        end
    end)
end)

-- ── Satış ──
RegisterNetEvent('196rp_jobs:server:sell', function(job)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local items = { fisher = { 'fish' }, miner = { 'stone', 'coal' }, lumberjack = { 'wood' }, construction = { 'brick', 'cement' } }
    if not items[job] then return end

    local earned = 0
    for _, item in ipairs(items[job]) do
        local info = Player.Functions.GetItemByName(item)
        local count = info and info.amount or 0
        if count > 0 then
            local price = Config.Prices[item] or 20
            earned = earned + (price * count)
            Player.Functions.RemoveItem(item, count, false, false, '196rp_jobs:sell')
            local label = (QBCore.Shared.Items[item] and QBCore.Shared.Items[item].label) or item
            TriggerClientEvent('QBCore:Notify', src, Config.Text.sold
                :gsub('%%{item}', label):gsub('%%{count}', count):gsub('%%{money}', price * count), 'success')
        end
    end

    if earned == 0 then
        TriggerClientEvent('QBCore:Notify', src, Config.Text.no_items, 'error')
        return
    end
    Player.Functions.AddMoney('cash', earned, '196rp_jobs:sell')
end)

-- ── Mexanik təmiri (/temir) ──
RegisterNetEvent('196rp_jobs:server:repairVehicle', function(plate, damage)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.job.name ~= 'mechanic' then return end

    local price = Config.Repair.BasePrice + math.ceil(damage or 0) * Config.Repair.PricePerDamage
    if price > Config.Repair.MaxPrice then price = Config.Repair.MaxPrice end

    if Player.Functions.GetMoney('cash') >= price then
        Player.Functions.RemoveMoney('cash', price, 'mechanic-repair')
        TriggerClientEvent('196rp_jobs:client:fixVehicle', src, plate)
        TriggerClientEvent('QBCore:Notify', src, ('✅ Maşın təmir olundu: -₣%d'):format(price), 'success')
        TriggerEvent('196rp_logs:server:vehEvent', plate, 'Mexanik təmir', ('-₣%d'):format(price))
    else
        TriggerClientEvent('QBCore:Notify', src, ('Kifayət qədər pul yoxdur — təmir ₣%d-dir'):format(price), 'error')
    end
end)

-- ── Avtosalon: satış maşını çağır (/avtomobil) ──
RegisterNetEvent('196rp_jobs:server:dealerCar', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.job.name ~= 'cardealer' then
        TriggerClientEvent('QBCore:Notify', src, 'Bu əmr yalnız avtosalon işçisi üçündür.', 'error')
        return
    end

    local model = Config.Dealer.Models[math.random(#Config.Dealer.Models)]
    local veh = QBCore.Shared.Vehicles[model]
    local price = math.floor((veh and veh.price or 15000) * Config.Dealer.PriceMultiplier)

    local plate = '196SAT' .. math.random(100, 999)
    TriggerClientEvent('196rp_jobs:client:dealerSpawn', src, model, Config.Dealer.SpawnAt, Config.Dealer.SpawnHeading, plate, price)
end)

-- ── Avtosalon: yaxın oyunçuya sat (/sat) ──
RegisterNetEvent('196rp_jobs:server:sellCar', function(price, plate, model)
    local src = source
    local dealer = QBCore.Functions.GetPlayer(src)
    if not dealer or dealer.PlayerData.job.name ~= 'cardealer' then return end

    -- dealer-in yaxınlığında alıcı tap (citizenid ilə)
    local buyer, buyerDist
    for _, target in ipairs(QBCore.Functions.GetPlayers()) do
        if target ~= src then
            local p = QBCore.Functions.GetPlayer(target)
            if p then
                local coords = GetEntityCoords(GetPlayerPed(target))
                local d = #(coords - Config.Dealer.SpawnAt)
                if not buyerDist or d < buyerDist then
                    buyer, buyerDist = p, d
                end
            end
        end
    end

    if not buyer or buyerDist > Config.Dealer.Radius then
        TriggerClientEvent('QBCore:Notify', src, 'Yaxınlıqda alıcı yoxdur.', 'error')
        return
    end

    price = tonumber(price) or 0
    if buyer.PlayerData.money.cash < price then
        TriggerClientEvent('QBCore:Notify', src, 'Alıcının kifayət qədər pulu yoxdur.', 'error')
        return
    end

    buyer.Functions.RemoveMoney('cash', price, 'car-dealer-buy')
    dealer.Functions.AddMoney('cash', price, 'car-dealer-sell')

    -- Oyunçuya qeydiyyat (player_vehicles: vehicle = model adı)
    model = model or 'sultan'
    MySQL.insert('INSERT INTO player_vehicles (license, citizenid, plate, vehicle, garage, state) VALUES (?, ?, ?, ?, ?, ?)', {
        buyer.PlayerData.license, buyer.PlayerData.citizenid, plate, model, 'airportp', 1,
    })

    TriggerClientEvent('196rp_jobs:client:dealerSell', src, buyer.PlayerData.citizenid)
    TriggerClientEvent('QBCore:Notify', src, ('💰 Avtomobil satıldı: +₣%d'):format(price), 'success')
    TriggerClientEvent('QBCore:Notify', buyer.PlayerData.source, ('🚗 Yeni avtomobiliniz qarajdadır (plate: %s)'):format(plate), 'success')
    TriggerEvent('196rp_logs:server:vehEvent', plate, 'Avtosalon satış', ('₣%d'):format(price))
end)
