local QBCore = exports['qb-core']:GetCoreObject()
local feeding = {}

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

-- ── Satın al ──
RegisterNetEvent('196rp_pets:server:buy', function(model)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local pet
    for _, p in ipairs(Config.Pets) do
        if p.model == model then pet = p end
    end
    if not pet then return end

    if (Player.PlayerData.money.cash or 0) < pet.price then
        Notify(src, ('Kifayət qədər pul yoxdur — ₣%d'):format(pet.price), 'error')
        return
    end

    local count = MySQL.scalar('SELECT COUNT(*) FROM 196_pets WHERE citizenid = ?', { Player.PlayerData.citizenid })
    if count >= 3 then
        Notify(src, 'Maksimum 3 heyvan ola bilər.', 'error')
        return
    end

    Player.Functions.RemoveMoney('cash', pet.price, 'pet-buy')
    MySQL.insert('INSERT INTO 196_pets (citizenid, model, name, created_at) VALUES (?, ?, ?, NOW())', {
        Player.PlayerData.citizenid, pet.model, pet.label,
    })
    Notify(src, ('🐾 %s alındı! (/heyvan ilə çağır)'):format(pet.label), 'success')
end)

-- ── Heyvanı çağır ──
RegisterNetEvent('196rp_pets:server:call', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local pet = MySQL.single('SELECT * FROM 196_pets WHERE citizenid = ? ORDER BY id DESC LIMIT 1', { Player.PlayerData.citizenid })
    if pet then
        TriggerClientEvent('196rp_pets:client:spawn', src, pet.model, pet.name)
    else
        Notify(src, 'Heyvanınız yoxdur — mağazadan alın.', 'primary')
    end
end)

-- ── Heyvanı geri qaytar ──
RegisterNetEvent('196rp_pets:server:return', function()
    TriggerClientEvent('196rp_pets:client:despawn', source)
end)

-- ── Qulluq (besle) ──
RegisterNetEvent('196rp_pets:server:feed', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if feeding[src] and feeding[src] > os.time() then
        Notify(src, 'Heyvanınız hələ toxdur. 🙂', 'primary')
        return
    end
    feeding[src] = os.time() + Config.FeedCooldown
    if GetResourceState('196rp_stress') == 'started' then
        exports['196rp_stress']:AddStress(src, -Config.FeedReduce)
    end
    Notify(src, ('🐾 Heyvanınızı bəslədiniz — stress -%d'):format(Config.FeedReduce), 'success')
end)

-- ── Ad dəyiş ──
RegisterNetEvent('196rp_pets:server:rename', function(name)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    name = tostring(name or ''):sub(1, 20)
    if name == '' then return end
    MySQL.update('UPDATE 196_pets SET name = ? WHERE citizenid = ? ORDER BY id DESC LIMIT 1', { name, Player.PlayerData.citizenid })
    Notify(src, ('🐾 Heyvanın adı: %s'):format(name), 'success')
end)
