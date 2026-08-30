local QBCore = exports['qb-core']:GetCoreObject()
local sitting = false

local function IsMedic()
    local job = QBCore.Functions.GetPlayerData().job.name
    for _, j in ipairs(Config.Jobs) do
        if job == j then return true end
    end
    return false
end

local function NearestPlayer(range)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local target, dist = nil, range or 5.0
    for _, src in ipairs(GetPlayers()) do
        if tonumber(src) ~= GetPlayerServerId(ped) then
            local p = GetPlayerPed(tonumber(src))
            if DoesEntityExist(p) and p ~= ped then
                local d = #(pos - GetEntityCoords(p))
                if d < dist then target, dist = src, d end
            end
        end
    end
    return target
end

local function CommandId(args)
    return tonumber(args[1]) or NearestPlayer(5.0) or 0
end

-- ── Rentgen ──
RegisterCommand('rentgen', function(_, args)
    if not IsMedic() then return QBCore.Functions.Notify('Bu əmr yalnız EMS üçündür.', 'error') end
    TriggerServerEvent('196rp_ems:server:getXray', CommandId(args))
end, false)

-- ── Sarğı / Gips ──
RegisterCommand('sarqi', function(_, args)
    if not IsMedic() then return QBCore.Functions.Notify('Bu əmr yalnız EMS üçündür.', 'error') end
    TriggerServerEvent('196rp_ems:server:treat', CommandId(args), 'bandage')
end, false)

RegisterCommand('gips', function(_, args)
    if not IsMedic() then return QBCore.Functions.Notify('Bu əmr yalnız EMS üçündür.', 'error') end
    TriggerServerEvent('196rp_ems:server:treat', CommandId(args), 'gips')
end, false)

-- ── Cərrahiyyə ──
RegisterCommand('cerrahiye', function(_, args)
    if not IsMedic() then return QBCore.Functions.Notify('Bu əmr yalnız EMS üçündür.', 'error') end
    TriggerServerEvent('196rp_ems:server:startSurgery', CommandId(args))
end, false)

-- ── Dirilt ──
RegisterCommand('dirilt', function(_, args)
    if not IsMedic() then return QBCore.Functions.Notify('Bu əmr yalnız EMS üçündür.', 'error') end
    TriggerServerEvent('196rp_ems:server:revive', CommandId(args))
end, false)

-- ── Xərək (daşıma) ──
RegisterCommand('xertek', function(_, args)
    if not IsMedic() then return QBCore.Functions.Notify('Bu əmr yalnız EMS üçündür.', 'error') end
    TriggerServerEvent('196rp_ems:server:carry', CommandId(args), 'pickup')
end, false)

RegisterCommand('xertekendir', function()
    if not IsMedic() then return end
    TriggerServerEvent('196rp_ems:server:carry', 0, 'drop')
end, false)

RegisterNetEvent('196rp_ems:client:carry', function(action, targetSrc)
    local ped = PlayerPedId()
    if action == 'pickup' then
        local targetPed = GetPlayerPed(tonumber(targetSrc))
        if DoesEntityExist(targetPed) then
            TaskCarryPed(ped, targetPed)
            sitting = true
            QBCore.Functions.Notify('🚑 Xəstə xərəyə alındı — xəstəxanaya aparın!', 'success')
        end
    else
        ClearPedTasks(ped)
        sitting = false
        QBCore.Functions.Notify('Xəstə yerə qoyuldu.', 'primary')
    end
end)

-- ── Rentgen NUI ──
RegisterNetEvent('196rp_ems:client:showXray', function(targetSrc, zones)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'xray',
        target = targetSrc,
        zones = zones,
        zoneMeta = Config.Zones,
        critical = Config.Critical,
        canSurgery = true,
    })
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hide' })
    cb({})
    return true
end)

RegisterNUICallback('startSurgery', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hide' })
    if data and data.target then
        TriggerServerEvent('196rp_ems:server:startSurgery', tonumber(data.target))
    end
    cb({})
    return true
end)

-- ── Cərrahiyyə NUI ──
RegisterNetEvent('196rp_ems:client:startSurgery', function(targetSrc, symbols, steps, stepTime)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'surgery',
        target = targetSrc,
        symbols = symbols,
        steps = steps,
        stepTime = stepTime,
    })
end)

RegisterNUICallback('surgeryDone', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hide' })
    if data then
        TriggerServerEvent('196rp_ems:server:surgeryDone', tonumber(data.target) or 0, data.success == true)
    end
    cb({})
    return true
end)


