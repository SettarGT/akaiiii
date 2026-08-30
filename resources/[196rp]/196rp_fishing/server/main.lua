local QBCore = exports['qb-core']:GetCoreObject()

-- Qarmaq nəticəsi (klient mini-game-dən sonra çağırır)
RegisterNetEvent('196rp_fishing:server:catch', function(spotId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.job.name ~= Config.Job then
        TriggerClientEvent('QBCore:Notify', src, 'Bu fəaliyyət yalnız balıqçı işi üçündür.', 'error')
        return
    end
    if not Player.Functions.GetItemByName('fishing_rod') then
        TriggerClientEvent('QBCore:Notify', src, 'Balıqçı çubuğu lazımdır (iş mərkəzi: ₣500).', 'error')
        return
    end

    local spot = nil
    for _, s in ipairs(Config.Spots) do
        if s.id == spotId then spot = s break end
    end
    if not spot then return end

    if math.random(100) <= Config.Minigame.EmptyChance then
        TriggerClientEvent('QBCore:Notify', src, '🐟 Bu dəfə qarmaq boş gəldi...', 'primary')
        return
    end

    local total = 0
    for _, c in ipairs(spot.catches) do total = total + c.chance end
    local roll = math.random(total)
    local picked = spot.catches[#spot.catches].item
    for _, c in ipairs(spot.catches) do
        roll = roll - c.chance
        if roll <= 0 then picked = c.item break end
    end

    local ok = Player.Functions.AddItem(picked, 1, false, false, 'fishing-catch')
    if not ok then
        TriggerClientEvent('QBCore:Notify', src, 'Envanter doludur!', 'error')
        return
    end
    local label = QBCore.Shared.Items[picked] and QBCore.Shared.Items[picked].label or picked
    TriggerClientEvent('QBCore:Notify', src, ('🐟 Tutuldu: %s!'):format(label), 'success')
    TriggerEvent('196rp_logs:server:vehEvent', 'BALIQÇILIQ', 'Tutuldu', label)
end)

-- Qayığı yoxla (klient sorğu: dünyada qayığım varmı?)
QBCore.Functions.CreateCallback('196rp_fishing:server:getBoat', function(source, cb)
    cb(Config.Boat)
end)
