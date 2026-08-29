local QBCore = exports['qb-core']:GetCoreObject()

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
    local label = (QBCore.Shared.Jobs[jobName] and QBCore.Shared.Jobs[jobName].label) or jobName
    TriggerClientEvent('QBCore:Notify', src, Config.Text.applied:gsub('%%{job}', label), 'success')
end)

RegisterNetEvent('196rp_jobs:quit', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.SetJob('unemployed', 0)
    TriggerClientEvent('QBCore:Notify', src, Config.Text.quit_msg, 'success')
end)
