local activeJob = nil      -- aktiv iş (ad)
local jobVehicle = nil     -- iş maşını (entitiy)
local jobDestBlip = nil    -- çatdırma blipi
local jobDestLabel = ''
local jobRound = 0
local showingUI = false

local function HideUI()
    if showingUI then
        showingUI = false
        ESX.HideUI()
    end
end

local function ShowUI(msg, typ)
    showingUI = true
    ESX.TextUI(msg, typ or 'info')
end

local function distance(coords)
    return #(GetEntityCoords(PlayerPedId()) - coords)
end

local function IsKeyPressed()
    return IsControlJustPressed(0, 38) -- E
end

-- ==================== İŞ MAŞINI ====================

local function RemoveJobBlip()
    if jobDestBlip and DoesBlipExist(jobDestBlip) then
        RemoveBlip(jobDestBlip)
    end
    jobDestBlip = nil
end

local function SetJobDest(label, coords)
    jobDestLabel = label
    RemoveJobBlip()
    jobDestBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(jobDestBlip, 1)
    SetBlipColour(jobDestBlip, 66)
    SetBlipScale(jobDestBlip, 0.9)
    SetBlipRoute(jobDestBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(('📦 %s'):format(label))
    EndTextCommandSetBlipName(jobDestBlip)
end

RegisterNetEvent('196rp_jobs:vehicleSpawned', function(netId)
    if not netId then
        return
    end
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 then
        return
    end
    jobVehicle = vehicle
    SetVehicleNumberPlateText(vehicle, ('196%s'):format(math.random(1000, 9999)))
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleOnGroundProperly(vehicle)
    ESX.ShowNotification('~y~İş maşınınız hazırdır!~s~ Sürücü oturacağına keçin.', 'info')
end)

-- ==================== İŞƏ BAŞLAMA / DAYANDIRMA ====================

local function StartJob(job)
    TriggerServerEvent('196rp_jobs:startJob', job.name)

    activeJob = job.name
    jobRound = 0
    RemoveJobBlip()

    if job.type == 'collect' then
        ESX.ShowNotification(('~y~%s~s~ işinə başladınız!\nİşləmək üçün ~b~iş zonasına~s~ gedin, satmaq üçün ~g~satış nöqtəsinə~s~ gedin.'):format(job.label), 'success', 6000)
    else
        ESX.ShowNotification(('~y~%s~s~ işinə başladınız!\nİş maşınınız ~b~HQ yaxınlığında~s~ sizi gözləyir.'):format(job.label), 'success', 6000)
    end
end

local function StopJob(force)
    if activeJob and not force then
        local job = Config.GetJob(activeJob)
        if job and job.type == 'vehicle' and jobVehicle then
            ESX.ShowNotification('Əvvəlcə iş maşınını HQ-ya qaytarın!', 'error')
            return
        end
    end

    if jobVehicle and DoesEntityExist(jobVehicle) then
        ESX.Game.DeleteVehicle(jobVehicle)
    end
    jobVehicle = nil
    RemoveJobBlip()

    if activeJob then
        TriggerServerEvent('196rp_jobs:stopJob')
        ESX.ShowNotification('İşi dayandırdınız.', 'error')
    end
    activeJob = nil
end

-- ==================== ƏSAS DÖVRƏ ====================

CreateThread(function()
    while true do
        local wait = 750
        local nearSomething = false

        for i = 1, #Config.Jobs do
            local job = Config.Jobs[i]

            -- HQ interaksiyası
            local hqDist = distance(job.hq)
            if hqDist < 3.5 then
                nearSomething = true
                wait = 0

                if not activeJob then
                    ShowUI(('[E] — İşə başla: ~y~%s~s~ (%s)'):format(job.label, job.icon))
                    if IsKeyPressed() then
                        StartJob(job)
                    end
                elseif activeJob == job.name and job.type == 'collect' then
                    ShowUI('[E] — İşi dayandır')
                    if IsKeyPressed() then
                        StopJob()
                    end
                elseif activeJob == job.name and job.type == 'vehicle' and not jobVehicle then
                    ShowUI('[E] — İş maşınını götür və işə başla')
                    if IsKeyPressed() then
                        TriggerServerEvent('196rp_jobs:startJob', job.name)
                    end
                end
            end

            -- Aktiv işin iş/satış nöqtələri
            if activeJob == job.name then
                if job.type == 'collect' then
                    -- İş zonası
                    for j = 1, #job.workPoints do
                        if distance(job.workPoints[j]) < 2.2 then
                            nearSomething = true
                            wait = 0
                            ShowUI(('[E] — İşlə (~y~%s~s~)'):format(job.label))
                            if IsKeyPressed() then
                                local ok = ESX.Progressbar(('İşləyirsiniz... %s'):format(job.icon), job.workTime, {
                                    FreezePlayer = true,
                                    animation = job.anim and {
                                        type = 'anim',
                                        dict = job.anim.dict,
                                        lib = job.anim.lib
                                    } or nil
                                })
                                if ok then
                                    TriggerServerEvent('196rp_jobs:collectItem', job.name)
                                end
                            end
                            break
                        end
                    end

                    -- Satış nöqtəsi
                    for j = 1, #job.sellPoints do
                        if distance(job.sellPoints[j]) < 3.0 then
                            nearSomething = true
                            wait = 0
                            ShowUI(('[E] — Hamısını sat (~y~%s~s~)'):format(job.label))
                            if IsKeyPressed() then
                                ESX.TriggerServerCallback('196rp_jobs:sellItems', function(data)
                                    if data and data.count > 0 then
                                        ESX.ShowNotification(('~g~+%s$~s~ (%s ədəd satıldı)'):format(data.pay, data.count), 'success')
                                    else
                                        ESX.ShowNotification('Satmaq üçün məhsulunuz yoxdur! Əvvəlcə işləyin.', 'error')
                                    end
                                end, job.name)
                            end
                            break
                        end
                    end
                end

                -- Nəqliyyat işi: çatdırma nöqtəsi
                if job.type == 'vehicle' and jobVehicle and jobDestBlip then
                    local dest = nil
                    for j = 1, #job.destinations do
                        if job.destinations[j].label == jobDestLabel then
                            dest = job.destinations[j]
                            break
                        end
                    end
                    if dest and distance(dest.coords) < 12.0 then
                        nearSomething = true
                        wait = 0
                        ShowUI(('[E] — Çatdır: ~y~%s~s~'):format(dest.label))
                        if IsKeyPressed() then
                            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                            if veh ~= jobVehicle then
                                ESX.ShowNotification('Çatdırmaq üçün iş maşınında olmalısınız!', 'error')
                            else
                                ESX.TriggerServerCallback('196rp_jobs:deliver', function(data)
                                    if not data then
                                        return
                                    end
                                    if data.pay then
                                        ESX.ShowNotification(('~g~+%s$~s~ — %s çatdırıldı!'):format(data.pay, jobDestLabel), 'success')
                                    end
                                    jobRound = data.round or jobRound
                                    if jobRound >= job.rounds then
                                        RemoveJobBlip()
                                        ESX.ShowNotification('~y~Bütün çatdırmalar tamamlandı!~s~ İş maşınını ~b~HQ-ya~s~ qaytarın.', 'info', 7000)
                                    else
                                        PickRandomDestination(job)
                                        ESX.ShowNotification(('Növbəti dayanacaq: ~y~%s~s~'):format(jobDestLabel), 'info')
                                    end
                                end, job.name)
                            end
                        end
                    end
                end

                -- Nəqliyyat işi: HQ-ya qayıt
                if job.type == 'vehicle' and jobVehicle and jobRound >= job.rounds and hqDist < 6.0 then
                    nearSomething = true
                    wait = 0
                    ShowUI('[E] — Maşını təhvil ver və işi bitir')
                    if IsKeyPressed() then
                        TriggerServerEvent('196rp_jobs:finishJob')
                        if jobVehicle and DoesEntityExist(jobVehicle) then
                            ESX.Game.DeleteVehicle(jobVehicle)
                        end
                        jobVehicle = nil
                        RemoveJobBlip()
                        activeJob = nil
                        ESX.ShowNotification(('~g~%s işi tamamlandı! Bonus: ~y~+%s$~s~'):format(job.label, job.pay * 2), 'success', 7000)
                    end
                end
            end
        end

        if not nearSomething then
            HideUI()
        end

        Wait(wait)
    end
end)

-- ==================== NƏQLİYYAT KÖMƏKÇİLƏRİ ====================

function PickRandomDestination(job)
    if not job or #job.destinations == 0 then
        return
    end
    local dest = job.destinations[math.random(1, #job.destinations)]
    SetJobDest(dest.label, dest.coords)
end

RegisterNetEvent('196rp_jobs:jobStarted', function(jobName)
    local job = Config.GetJob(jobName)
    if not job then
        return
    end
    if job.type == 'vehicle' then
        jobRound = 0
        PickRandomDestination(job)
    end
end)

RegisterNetEvent('196rp_jobs:collectNotify', function(messages)
    if messages and #messages > 0 then
        ESX.ShowNotification(messages[math.random(1, #messages)], 'success')
    end
end)

RegisterNetEvent('196rp_jobs:forceStop', function()
    if jobVehicle and DoesEntityExist(jobVehicle) then
        ESX.Game.DeleteVehicle(jobVehicle)
    end
    jobVehicle = nil
    RemoveJobBlip()
    activeJob = nil
end)

-- Oyunçudan çıxanda təmizlik
AddEventHandler('esx:onPlayerLogout', function()
    if jobVehicle and DoesEntityExist(jobVehicle) then
        ESX.Game.DeleteVehicle(jobVehicle)
    end
    jobVehicle = nil
    RemoveJobBlip()
    activeJob = nil
end)
