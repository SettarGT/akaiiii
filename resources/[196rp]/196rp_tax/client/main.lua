local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('196rp_tax:client:stats', function(data)
    QBCore.Functions.Notify(('📊 VERGİ PANELİ | Dərəcə: %s%% | Bu gün: ₣%s | Cəmi: ₣%s (%s əməliyyat)'):format(
        data.rate,
        tostring(data.totals.today),
        tostring(data.totals.total),
        tostring(data.totals.count)
    ), 'primary')
end)
