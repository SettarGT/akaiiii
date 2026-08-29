-- 196 RP | İş sistemi — server tərəfi
-- İşə başlama / iş maşını / toplama / satış / çatdırma

local ESX = exports['es_extended']:getSharedObject()

-- [source] = { name = 'baliqci', round = 0, vehicle = entityId|nil, lastCollect = 0 }
local activeJobs = {}

-- ==================== KÖMƏKÇİLƏR ====================

local function ClearVehicle(src)
    local data = activeJobs[src]
    if data and data.vehicle then
        local veh = NetworkGetEntityFromNetworkId(data.vehicle)
        if veh ~= 0 then
            DeleteEntity(veh)
        end
    end
    if data then
        data.vehicle = nil
    end
end

local function SpawnJobVehicle(src, job)
    local params = {
        model = job.vehicle,
        coords = { x = job.vehicleSpawn.x, y = job.vehicleSpawn.y, z = job.vehicleSpawn.z },
        heading = job.vehicleHeading or 0.0,
        plate = ('196%04d'):format(math.random(0, 9999)),
        owned = true,
        doorsLocked = 1,
    }
    if job.vehicleColor then
        params.customColor = job.vehicleColor
    end

    local netId = exports['196rp_spawner']:SpawnVehicleAwait(src, params)
    if netId == 0 then
        return nil
    end
    return netId
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
        local netId = SpawnJobVehicle(src, job)
        if not netId then
            activeJobs[src] = nil
            TriggerClientEvent('esx:showNotification', src, 'İş maşını yaradıla bilmədi! Bir az sonra yenidən cəhd edin.', 'error')
            return
        end
        activeJobs[src].vehicle = netId
        TriggerClientEvent('196rp_jobs:vehicleSpawned', src, netId)
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
            if state.vehicle then
                local veh = NetworkGetEntityFromNetworkId(state.vehicle)
                local ped = GetPlayerPed(src)
                if veh ~= 0 and ped and ped ~= 0 then
                    local d = #(GetEntityCoords(ped) - GetEntityCoords(veh))
                    if d > 900.0 then
                        DeleteEntity(veh)
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
