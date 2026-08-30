local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('196rp_radar:server:plateLookup', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local allowed = false
    for _, job in ipairs(Config.Jobs) do
        if Player.PlayerData.job.name == job then allowed = true end
    end
    if not allowed then return end

    plate = tostring(plate or ''):upper()
    if plate == '' then return end

    local result = MySQL.single('SELECT pv.plate, pv.vehicle, pv.citizenid, pv.garage, pv.state, c.firstname, c.lastname FROM player_vehicles pv LEFT JOIN players c ON c.citizenid = pv.citizenid WHERE pv.plate = ? LIMIT 1', { plate })

    if result then
        local name = ((result.firstname or '?') .. ' ' .. (result.lastname or '?'))
        local owner = result.citizenid or 'naməlum'
        local msg = ('🛡 %s · Sahib: %s (%s) · Qaraj: %s · %s'):format(
            result.plate, name, owner, result.garage or '-', result.state == 1 and 'Dayanıb' or 'Bayırdadır')
        TriggerClientEvent('QBCore:Notify', src, msg, 'primary', 10000)
        TriggerClientEvent('196rp_radar:client:plateResult', src, { plate = result.plate, owner = name, citizenid = owner })
    else
        TriggerClientEvent('QBCore:Notify', src, ('⛔ %s — qeydiyyat tapılmadı.'):format(plate), 'error')
    end
end)
