local QBCore = exports['qb-core']:GetCoreObject()
local enabled = false

RegisterCommand('streamer', function()
    enabled = not enabled
    TriggerServerEvent('196rp_streamer:server:set', enabled)
    if enabled then
        QBCore.Functions.Notify('🛡 Streamer rejimi AÇIQ — RP mesajlarında adınız gizlədilir.', 'primary')
    else
        QBCore.Functions.Notify('Streamer rejimi bağlıdır.', 'primary')
    end
end, false)

-- RP adı: streamer rejimində gizli ad qaytarır
exports('Name', function()
    if enabled then
        return Config.HiddenName
    end
    return GetPlayerName(PlayerId())
end)

exports('Enabled', function()
    return enabled
end)
