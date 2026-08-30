local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('196rp_hybrid:server:status', function()
    local src = source
    local list = {}
    for _, job in ipairs(Config.Jobs) do
        local onDuty = {}
        local count = 0
        for _, p in ipairs(QBCore.Functions.GetPlayers()) do
            local Player = QBCore.Functions.GetPlayer(p)
            if Player and Player.PlayerData.job.name == job.name and Player.PlayerData.job.onduty then
                count = count + 1
                onDuty[#onDuty + 1] = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
            end
        end
        list[#list + 1] = {
            name = job.name, label = job.label, icon = job.icon, color = job.color,
            count = count, onDuty = onDuty,
        }
    end
    TriggerClientEvent('196rp_hybrid:client:status', src, list)
end)
