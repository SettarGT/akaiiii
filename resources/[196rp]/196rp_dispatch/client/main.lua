local QBCore = exports['qb-core']:GetCoreObject()
local panelOpen = false

local function IsAllowed()
    if QBCore.Functions.HasPermission('admin') then return true end
    local job = QBCore.Functions.GetPlayerData().job.name
    for _, j in ipairs(Config.Jobs) do
        if job == j then return true end
    end
    return false
end

-- ── /911 ──
RegisterCommand('911', function(_, args)
    local msg = table.concat(args, ' ')
    if msg == '' then
        QBCore.Functions.Notify('Düzgün istifadə: /911 <mətn>', 'error')
        return
    end
    TriggerServerEvent('196rp_dispatch:server:911', msg)
end, false)

-- ── Panel ──
RegisterCommand('dispatch', function()
    if not IsAllowed() then
        QBCore.Functions.Notify('Bu əmr yalnız xidmət işçiləri üçündür.', 'error')
        return
    end
    panelOpen = not panelOpen
    SetNuiFocus(panelOpen, panelOpen)
    SendNUIMessage({ action = panelOpen and 'open' or 'hide' })
end, false)

RegisterNUICallback('accept', function(data, cb)
    TriggerServerEvent('196rp_dispatch:server:accept', data.id)
    cb({})
    return true
end)

RegisterNUICallback('done', function(data, cb)
    TriggerServerEvent('196rp_dispatch:server:done', data.id)
    cb({})
    return true
end)

RegisterNUICallback('close', function(_, cb)
    panelOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hide' })
    cb({})
    return true
end)

-- ── Server yeniləməsi ──
RegisterNetEvent('196rp_dispatch:client:push', function(list)
    if panelOpen then
        SendNUIMessage({ action = 'update', list = list })
    else
        -- Səsli bildiriş: yeni zəng
        for _, c in ipairs(list) do
            if c.status == 'new' then
                QBCore.Functions.Notify(('📞 ZƏNG #%d: %s'):format(c.id, c.message), 'error', 8000)
            end
        end
    end
end)

-- ── Çıxanda bağla ──
AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
