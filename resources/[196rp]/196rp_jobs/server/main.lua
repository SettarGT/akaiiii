-- 196 RP | İş sistemi — server tərəfi
-- İşə başlama / iş maşını / toplama / satış / çatdırma

local ESX = exports['es_extended']:getSharedObject()

-- [source] = { name = 'baliqci', round = 0, vehicle = entityId|nil, lastCollect = 0 }
local activeJobs = {}

-- ==================== KÖMƏKÇİLƏR ====================

local function ClearVehicle(src)
    local data = activeJobs[src]
    if data and data.vehicle and DoesEntityExist(data.vehicle) then
        SetEntityAsMissionEntity(data.vehicle, true, true)
        DeleteEntity(data.vehicle)
    end
    if data then
        data.vehicle = nil
    end
end

local function SpawnJobVehicle(src, job)
    local model = GetHashKey(job.vehicle)

    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end

    if not HasModelLoaded(model) then
        return nil
    end

    local veh = CreateVehicle(model, job.vehicleSpawn.x, job.vehicleSpawn.y, job.vehicleSpawn.z,
        job.vehicleHeading or 0.0, true, false)

    if not veh or veh == 0 then
        return nil
    end

    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleOnGroundProperly(veh)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetVehicleNumberPlateText(veh, ('196%04d'):format(math.random(0, 9999)))
    SetVehicleEngineOn(veh, true, true, false)
    SetVehicleDoorsLocked(veh, 1)

    if job.vehicleColor then
        SetVehicleCustomPrimaryColour(veh, job.vehicleColor[1], job.vehicleColor[2], job.vehicleColor[3])
        SetVehicleCustomSecondaryColour(veh, job.vehicleColor[1], job.vehicleColor[2], job.vehicleColor[3])
    end

    SetModelAsNoLongerNeeded(model)

    -- Maşın çox uzaqlaşarsa / məhv olarsa təmizlə
    local netId = NetworkGetNetworkIdFromEntity(veh)
    SetNetworkIdExistsOnAllMachines(netId, true)

    return veh
end

-- ==================== İŞƏ BAŞLAMA ====================

RegisterNetEvent('196rp_jobs:startJob', function(jobName)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        return
    end

    local job = Config.GetJob(jobName)
    if not job then
        TriggerClientEvent('esx:showNotification', src, 'Belə bir iş tapılmadı!', 'error')
        return
    end

    if activeJobs[src] then
        TriggerClientEvent('esx:showNotification', src, 'Artıq bir işdə çalışırsınız! Əvvəl onu dayandırın.', 'error')
        return
    end

    activeJobs[src] = { name = job.name, round = 0, vehicle = nil, lastCollect = 0 }

    if job.type == 'vehicle' then
        local veh = SpawnJobVehicle(src, job)
        if not veh then
            activeJobs[src] = nil
            TriggerClientEvent('esx:showNotification', src, 'İş maşını yaradıla bilmədi! Bir az sonra yenidən cəhd edin.', 'error')
            return
        end
        activeJobs[src].vehicle = veh
        TriggerClientEvent('196rp_jobs:vehicleSpawned', src, NetworkGetNetworkIdFromEntity(veh))
    end

    TriggerClientEvent('196rp_jobs:jobStarted', src, job.name)
end)

-- ==================== İŞİ DAYANDIRMA ====================

RegisterNetEvent('196rp_jobs:stopJob', function()
    local src = source
    if not activeJobs[src] then
        return
    end
    ClearVehicle(src)
    activeJobs[src] = nil
end)

-- ==================== İŞİ BİTİRMƏ (bonus) ====================

RegisterNetEvent('196rp_jobs:finishJob', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not activeJobs[src] then
        return
    end

    local job = Config.GetJob(activeJobs[src].name)
    if job then
        local bonus = (job.pay or 100) * 2
        xPlayer.addMoney(bonus)
        TriggerClientEvent('esx:showNotification', src,
            ('~g~%s işi tamamlandı!~s~ Bonus: ~y~+%s$~s~'):format(job.label, bonus), 'success')
    end

    ClearVehicle(src)
    activeJobs[src] = nil
end)

-- ==================== TOPLAMA ====================

RegisterNetEvent('196rp_jobs:collectItem', function(jobName)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        return
    end

    local state = activeJobs[src]
    if not state or state.name ~= jobName then
        TriggerClientEvent('esx:showNotification', src, 'Bu işdə çalışmırsınız!', 'error')
        return
    end

    local job = Config.GetJob(jobName)
    if not job or job.type ~= 'collect' then
        return
    end

    -- Spam qorunması (client progressbar + 1.5 saniyə əlavə)
    local now = GetGameTimer()
    if now - state.lastCollect < 1500 then
        return
    end
    state.lastCollect = now

    if not xPlayer.canCarryItem(job.item, 1) then
        TriggerClientEvent('esx:showNotification', src, 'Çantanız dolub! Satış nöqtəsinə gedin.', 'error')
        return
    end

    xPlayer.addInventoryItem(job.item, 1)
    TriggerClientEvent('196rp_jobs:collectNotify', src, job.messages)
end)

-- ==================== SATIŞ ====================

ESX.RegisterServerCallback('196rp_jobs:sellItems', function(source, cb, jobName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb({ count = 0, pay = 0 })
    end

    local job = Config.GetJob(jobName)
    if not job then
        return cb({ count = 0, pay = 0 })
    end

    local invItem = xPlayer.getInventoryItem(job.item)
    local count = invItem and invItem.count or 0

    if count <= 0 then
        return cb({ count = 0, pay = 0 })
    end

    local pay = count * (job.price or 10)

    xPlayer.removeInventoryItem(job.item, count)
    xPlayer.addMoney(pay)

    cb({ count = count, pay = pay })
end)

-- ==================== ÇATDIRMA ====================

ESX.RegisterServerCallback('196rp_jobs:deliver', function(source, cb, jobName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(nil)
    end

    local state = activeJobs[source]
    if not state or state.name ~= jobName then
        return cb(nil)
    end

    local job = Config.GetJob(jobName)
    if not job or job.type ~= 'vehicle' then
        return cb(nil)
    end

    if state.round >= (job.rounds or 5) then
        return cb(nil)
    end

    -- Oyunçu həqiqətən iş maşınındadırmı?
    local ped = GetPlayerPed(source)
    local veh = GetVehiclePedIsIn(ped, false)
    if state.vehicle and veh ~= state.vehicle then
        TriggerClientEvent('esx:showNotification', source, 'Çatdırmaq üçün iş maşınında olmalısınız!', 'error')
        return cb(nil)
    end

    state.round = state.round + 1
    local pay = job.pay or 100
    xPlayer.addMoney(pay)

    cb({ pay = pay, round = state.round })
end)

-- ==================== TEMİZLİK ====================

AddEventHandler('playerDropped', function()
    local src = source
    if activeJobs[src] then
        ClearVehicle(src)
        activeJobs[src] = nil
    end
end)

AddEventHandler('esx:playerLogout', function(playerId)
    if activeJobs[playerId] then
        ClearVehicle(playerId)
        activeJobs[playerId] = nil
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then
        return
    end
    for src in pairs(activeJobs) do
        ClearVehicle(src)
    end
end)

-- Sahibsiz iş maşınlarını təmizlə (oyunçu uzaqlaşanda)
CreateThread(function()
    while true do
        Wait(60000)
        for src, state in pairs(activeJobs) do
            if state.vehicle and DoesEntityExist(state.vehicle) then
                local ped = GetPlayerPed(src)
                if ped and ped ~= 0 then
                    local d = #(GetEntityCoords(ped) - GetEntityCoords(state.vehicle))
                    if d > 900.0 then
                        SetEntityAsMissionEntity(state.vehicle, true, true)
                        DeleteEntity(state.vehicle)
                        state.vehicle = nil
                        TriggerClientEvent('esx:showNotification', src,
                            'İş maşını çox uzaqda qaldı — iş dayandırıldı.', 'error')
                        activeJobs[src] = nil
                    end
                end
            end
        end
    end
end)

-- Admin: oyunçunu məcburi işdən çıxart
exports('ForceStopJob', function(playerId)
    if activeJobs[playerId] then
        ClearVehicle(playerId)
        activeJobs[playerId] = nil
        TriggerClientEvent('196rp_jobs:forceStop', playerId)
    end
end)
