local QBCore = exports['qb-core']:GetCoreObject()

local busy = {}

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

local function GetJobCfg(job)
    for _, j in ipairs(Config.Jobs) do
        if j.job == job then return j end
    end
end

-- İş mərkəzi: iş seç
RegisterNetEvent('196rp_jobs:server:setJob', function(job)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if job == Player.PlayerData.job.name then
        Notify(src, 'Bu işdə artıq işləyirsiniz.', 'primary')
        return
    end
    if Player.PlayerData.job.name ~= 'unemployed' then
        Notify(src, 'Əvvəlcə hazırkı işdən çıxın (/is).', 'error')
        return
    end
    local j = GetJobCfg(job)
    if not j then
        Notify(src, 'Naməlum iş.', 'error')
        return
    end
    Player.Functions.SetJob(job)
    Notify(src, ('✅ İş qəbul edildi: %s!'):format(j.label), 'success')
end)

-- İşdən çıx
RegisterCommand('is', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if Player.PlayerData.job.name == 'unemployed' then
        Notify(source, 'Artıq işsizsiniz.', 'primary')
        return
    end
    Player.Functions.SetJob('unemployed')
    Notify(source, '📋 İşdən çıxdınız.', 'primary')
end, false)

-- İş mərkəzi menyusu
RegisterNetEvent('196rp_jobs:server:openCenter', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local jobs = {}
    for _, j in ipairs(Config.Jobs) do
        jobs[#jobs + 1] = { job = j.job, label = j.label, current = Player.PlayerData.job.name == j.job }
    end
    TriggerClientEvent('196rp_jobs:client:showCenter', src, jobs)
end)

-- Alət mağazası
Config.Tools = Config.Tools or {
    { item = 'fishing_rod', label = '🐟 Qarmaq', price = 500 },
    { item = 'pickaxe',     label = '⛏ Pikak',  price = 400 },
    { item = 'axe',         label = '🪓 Balta',  price = 350 },
    { item = 'hammer',      label = '🔨 Çəkic',  price = 300 },
}

RegisterNetEvent('196rp_jobs:server:openTools', function()
    TriggerClientEvent('196rp_jobs:client:showTools', source)
end)

RegisterNetEvent('196rp_jobs:server:buyTool', function(item, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local tool
    for _, t in ipairs(Config.Tools) do
        if t.item == item then tool = t end
    end
    if not tool then return end
    price = tonumber(price) or tool.price
    if (Player.PlayerData.money.cash or 0) < price then
        Notify(src, ('Kifayət qədər pul yoxdur — ₣%d'):format(price), 'error')
        return
    end
    Player.Functions.RemoveMoney('cash', price, 'job-tool')
    Player.Functions.AddItem(item, 1)
    Notify(src, ('🛠 %s alındı (-₣%d)'):format(tool.label, price), 'success')
end)

-- İş zonası: topla (server təsdiqi)
RegisterNetEvent('196rp_jobs:server:collect', function(zoneId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local zone
    for _, z in ipairs(Config.Zones) do
        if z.id == zoneId then zone = z end
    end
    if not zone then return end
    if Player.PlayerData.job.name ~= zone.job then
        Notify(src, 'Bu zona üçün işləməlisiniz.', 'error')
        return
    end
    local jobCfg = GetJobCfg(zone.job)
    if not jobCfg or not jobCfg.tool then return end

    -- alət yoxlanışı
    local hasTool = false
    for _, it in ipairs(Player.PlayerData.items) do
        if it and it.name == jobCfg.tool then hasTool = true end
    end
    if not hasTool then
        Notify(src, ('Alət lazımdır: %s (Avtosalon/şəhər mağazası)'):format(jobCfg.tool), 'error')
        return
    end

    if busy[src] and busy[src] > os.time() then
        Notify(src, 'Bir az gözləyin — əməliyyat davam edir.', 'error')
        return
    end

    Player.Functions.AddItem(zone.item, 1, false, false, zone.id)
    busy[src] = os.time() + jobCfg.time
    Notify(src, ('✅ %s əldə edildi!'):format(zone.item), 'success')
end)

-- İş satışı
RegisterNetEvent('196rp_jobs:server:sell', function(sellId, item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local sp
    for _, s in ipairs(Config.SellPoints) do
        if s.id == sellId then sp = s end
    end
    if not sp or not sp.buys[item] then return end
    if Player.PlayerData.job.name ~= sp.job then
        Notify(src, 'Bu məntəqə yalnız müvafiq iş üçündür.', 'error')
        return
    end

    amount = tonumber(amount) or 1
    amount = math.max(1, math.min(amount, 50))
    local item_count = 0
    for _, it in ipairs(Player.PlayerData.items) do
        if it and it.name == item then item_count = item_count + (it.amount or 0) end
    end
    if item_count < amount then
        Notify(src, ('Əlinizdə kifayət qədər %s yoxdur.'):format(item), 'error')
        return
    end

    local price = sp.buys[item] * amount
    local tax = math.floor(price * Config.IncomeTax / 100)
    local net = price - tax
    Player.Functions.RemoveItem(item, amount, false, false, 'job-sell')
    Player.Functions.AddMoney('cash', net, 'job-sell')
    if tax > 0 then
        Notify(src, ('💰 %d × %s satıldı: +₣%d (gəlir vergisi 5%% = -₣%d)'):format(amount, item, net, tax), 'success')
    else
        Notify(src, ('💰 %d × %s satıldı: +₣%d'):format(amount, item, net), 'success')
    end
end)


-- ✦ Self-Repair stansiyası (mexanik duty yoxdursa — 2.5x)
RegisterNetEvent('196rp_jobs:server:selfRepair', function(plate, damage)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    damage = tonumber(damage) or 0
    if damage <= 0 then
        Notify(src, 'Maşın zədəli deyil.', 'primary')
        return
    end
    local price = math.ceil(Config.Mechanic.RepairPrice * (damage / 100) * Config.Mechanic.SelfRepairMultiplier)
    if (Player.PlayerData.money.cash or 0) < price then
        Notify(src, ('Self-repair qiyməti: ₣%d — kifayət qədər pul yoxdur.'):format(price), 'error')
        return
    end
    Player.Functions.RemoveMoney('cash', price, 'self-repair')
    TriggerClientEvent('196rp_jobs:client:fixVehicle', src, plate)
    Notify(src, ('🔧 Self-repair tamamlandı (-₣%d)'):format(price), 'success')
end)

-- ✦ Mexanik: təmir
RegisterNetEvent('196rp_jobs:server:mechRepair', function(plate, damage)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.job.name ~= 'mechanic' then
        Notify(src, 'Mexanik işi tələb olunur.', 'error')
        return
    end
    damage = tonumber(damage) or 0
    if damage <= 0 then
        Notify(src, 'Maşın zədəli deyil.', 'primary')
        return
    end
    local price = math.ceil(Config.Mechanic.RepairPrice * (damage / 100))
    TriggerClientEvent('196rp_jobs:client:fixVehicle', src, plate)
    Notify(src, ('🔧 Təmir edildi — ödəniş: ₣%d'):format(price), 'success')
end)

-- ✦ Mexanik: benzin + təkər
RegisterNetEvent('196rp_jobs:server:mechBoost', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.job.name ~= 'mechanic' then
        Notify(src, 'Mexanik işi tələb olunur.', 'error')
        return
    end
    TriggerClientEvent('196rp_jobs:client:boostVehicle', src, plate)
    Notify(src, ('⚡ Təkərlər + yanacaq yeniləndi (-₣%d)'):format(Config.Mechanic.BoostPrice), 'success')
end)

-- ✦ Avtosalon: satış
RegisterNetEvent('196rp_jobs:server:cardealerSell', function(model, targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.job.name ~= 'cardealer' then
        Notify(src, 'Avtosalon işi tələb olunur.', 'error')
        return
    end
    local veh
    for _, v in ipairs(Config.CarDealer.Vehicles) do
        if v.model == model then veh = v end
    end
    if not veh then return end

    local Target = QBCore.Functions.GetPlayer(tonumber(targetId))
    if not Target then
        Notify(src, 'Müştəri tapılmadı.', 'error')
        return
    end
    if (Target.PlayerData.money.cash or 0) < veh.price then
        Notify(src, ('Müştərinin kifayət qədər nağd pulu yoxdur (₣%d).'):format(veh.price), 'error')
        return
    end

    -- Plate yarat
    local plate
    repeat
        plate = ('196%d%d%d'):format(math.random(10000, 99999), math.random(0, 9), math.random(0, 9))
    until not MySQL.scalar.await('SELECT 1 FROM player_vehicles WHERE plate = ? LIMIT 1', { plate })

    Target.Functions.RemoveMoney('cash', veh.price, 'cardealer-buy')
    Player.Functions.AddMoney('cash', math.floor(veh.price * 0.9), 'cardealer-sell')

    MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, 0)', {
        Target.PlayerData.license, Target.PlayerData.citizenid, veh.model, joaat(veh.model), '', plate,
    })

    local coords = Config.CarDealer.SaleCenter.coords
    local spawn = CreateVehicleServerSetter(joaat(veh.model), 0, coords.x, coords.y, coords.z, 0.0)
    SetVehicleNumberPlateText(spawn, plate)
    SetVehicleFuelLevel(spawn, 100.0)
    SetEntityHeading(spawn, 180.0)
    TriggerEvent('qb-vehiclekeys:server:GiveVehicleKeys', Target.PlayerData.source, plate)

    Notify(Target.PlayerData.source, ('🚗 %s aldınız! Açarlar verildi — maşın avtosalonun qarşısındadır.'):format(veh.label), 'success')
    Notify(src, ('💰 %s satıldı — komissiya ₣%d'):format(veh.label, math.floor(veh.price * 0.9)), 'success')
end)
