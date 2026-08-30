local QBCore = exports['qb-core']:GetCoreObject()
local busy = false
local dealerVehicle = nil

local function DrawText3D(coords, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 217, 122, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(coords.x, coords.y, coords.z)
end

-- ── İş mərkəzi menyusu ──
local function OpenJobMenu()
    local pData = QBCore.Functions.GetPlayerData()
    local menu = { { header = '🏢 İş Mərkəzi', isMenuHeader = true, icon = 'fas fa-briefcase' } }

    menu[#menu + 1] = {
        header = 'Hazırkı iş: ' .. (pData.job.label or pData.job.name),
        txt = 'Aşağıdan yeni iş seçə bilərsiniz',
        isDisabled = true,
        icon = 'fas fa-id-badge',
    }

    for jobId, job in pairs(Config.Jobs) do
        local marker = pData.job.name == jobId and '✅ ' or '👔 '
        menu[#menu + 1] = {
            header = marker .. job.label,
            txt = job.desc or '',
            icon = job.icon or 'fas fa-briefcase',
            params = { job = jobId },
        }
    end

    menu[#menu + 1] = {
        header = '📤 İşdən çıx',
        txt = 'Mülki vətəndaş ol',
        icon = 'fas fa-sign-out-alt',
        params = { quit = true },
    }

    exports['qb-menu']:openMenu(menu, function(selected)
        if not selected or not selected.params then return end
        if selected.params.quit then
            TriggerServerEvent('196rp_jobs:quit')
        elseif selected.params.job then
            TriggerServerEvent('196rp_jobs:apply', selected.params.job)
        end
    end)
end

-- İş mərkəzləri
CreateThread(function()
    for _, center in ipairs(Config.Locations) do
        exports['qb-target']:AddBoxZone('196jobs_' .. center.label, center.coords, 3.0, 3.0, {
            name = '196jobs_' .. center.label,
            heading = center.heading or 0.0,
            debugPoly = false,
            minZ = center.coords.z - 1,
            maxZ = center.coords.z + 4,
        }, {
            options = {
                { label = '[E] ' .. center.label, icon = 'fas fa-city', action = OpenJobMenu },
            },
            distance = 3.0,
        })

        local blip = AddBlipForCoord(center.coords)
        SetBlipSprite(blip, 351)
        SetBlipColour(blip, 5)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(center.label)
        EndTextCommandSetBlipName(blip)
    end
end)

-- ── İş əməliyyatı (animasiya + server vaxt yoxlaması) ──
local function RunCollect(job, zoneLabel, coords)
    if busy then return end
    busy = true
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    TaskTurnPedToFaceCoord(ped, coords.x, coords.y, coords.z)

    local anim = Config.Animations[job] or Config.Animations.default
    RequestAnimDict(anim.dict)
    local t = 0
    while not HasAnimDictLoaded(anim.dict) and t < 50 do
        Wait(20)
        t = t + 1
    end
    if HasAnimDictLoaded(anim.dict) then
        TaskPlayAnim(ped, anim.dict, anim.name, 3.0, 3.0, -1, 1, 0, false, false, false)
    end

    local duration = (Config.WorkTime[job] or 5) * 1000
    QBCore.Functions.Progressbar('196jobs_' .. job, Config.Text.working, duration, false, true, {
        disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true,
    }, {}, {}, {}, function()
        ClearPedTasksImmediately(ped)
        FreezeEntityPosition(ped, false)
        busy = false
    end, function()
        ClearPedTasksImmediately(ped)
        FreezeEntityPosition(ped, false)
        busy = false
    end)

    -- Server eyni vaxtı server tərəfdə ölçür (client sürətləndirə bilməz)
    TriggerServerEvent('196rp_jobs:server:collect', job, zoneLabel)
end

-- ── İş zonaları + satış nöqtələri ──
CreateThread(function()
    while true do
        Wait(500)
        if not busy then
            local pData = QBCore.Functions.GetPlayerData()
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)

            -- İş zonaları
            local zones = Config.Zones[pData.job.name]
            if zones then
                for _, zone in ipairs(zones) do
                    if #(pos - zone.coords) < zone.radius then
                        DrawText3D(zone.coords + vector3(0, 0, 1.3), zone.label .. '\n[E] ' .. (Config.Text.collect_label or 'İşlə'))
                        if IsControlJustReleased(0, 38) then
                            local tool = Config.Tools[pData.job.name]
                            if tool and not QBCore.Functions.HasItem(tool) then
                                QBCore.Functions.Notify(Config.Text.need_tool, 'error')
                            else
                                RunCollect(pData.job.name, zone.label, zone.coords)
                            end
                            break
                        end
                    end
                end
            end

            -- Satış nöqtəsi
            local sell = Config.SellPoints[pData.job.name]
            if sell and #(pos - sell.coords) < 3.0 then
                DrawText3D(sell.coords + vector3(0, 0, 1.2), '💰 ' .. sell.label .. '\n[E] Şat')
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent('196rp_jobs:server:sell', pData.job.name)
                end
            end
        end
    end
end)

-- ── Mexanik ──
RegisterNetEvent('196rp_jobs:client:fixVehicle', function(plate)
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        if GetVehicleNumberPlateText(veh) == plate then
            SetVehicleFixed(veh)
            SetVehicleDirtLevel(veh, 0.0)
            SetVehicleFuelLevel(veh, 100.0)
            return
        end
    end
end)

RegisterCommand('temir', function()
    local pData = QBCore.Functions.GetPlayerData()
    if pData.job.name ~= 'mechanic' then
        QBCore.Functions.Notify('Bu əmr yalnız mexanik üçündür.', 'error')
        return
    end
    local pos = GetEntityCoords(PlayerPedId())
    local closest, dist = nil, 6.0
    for _, veh in ipairs(GetGamePool('CVehicle')) do
        local d = #(pos - GetEntityCoords(veh))
        if d < dist then closest, dist = veh, d end
    end
    if closest then
        local damage = 100 - GetVehicleBodyHealth(closest)
        TriggerServerEvent('196rp_jobs:server:repairVehicle', GetVehicleNumberPlateText(closest), math.max(0, damage))
    else
        QBCore.Functions.Notify('Yaxınlıqda avtomobil yoxdur.', 'primary')
    end
end, false)

-- ── Avtosalon ──
RegisterNetEvent('196rp_jobs:client:dealerSpawn', function(model, coords, heading, plate, price)
    if dealerVehicle and DoesEntityExist(dealerVehicle) then
        DeleteEntity(dealerVehicle)
    end
    RequestModel(model)
    local t = 0
    while not HasModelLoaded(model) and t < 100 do
        Wait(20)
        t = t + 1
    end
    if not HasModelLoaded(model) then return end
    dealerVehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
    SetVehicleNumberPlateText(dealerVehicle, plate)
    SetVehicleFuelLevel(dealerVehicle, 100.0)
    QBCore.Functions.Notify(('🚗 Satış maşını hazır — qiymət ₣%d. Alıcıya /sat deyin!'):format(price), 'success')
end)

RegisterCommand('avtomobil', function()
    local pData = QBCore.Functions.GetPlayerData()
    if pData.job.name ~= 'cardealer' then
        QBCore.Functions.Notify('Bu əmr yalnız avtosalon işçisi üçündür.', 'error')
        return
    end
    TriggerServerEvent('196rp_jobs:server:dealerCar')
end, false)

RegisterCommand('sat', function()
    local pData = QBCore.Functions.GetPlayerData()
    if pData.job.name ~= 'cardealer' then
        QBCore.Functions.Notify('Bu əmr yalnız avtosalon işçisi üçündür.', 'error')
        return
    end
    if not dealerVehicle or not DoesEntityExist(dealerVehicle) then
        QBCore.Functions.Notify('Əvvəlcə /avtomobil ilə satış maşını çağırın.', 'primary')
        return
    end
    local model = GetEntityModel(dealerVehicle)
    local vehName
    for k, v in pairs(QBCore.Shared.Vehicles) do
        if model == joaat(k) then vehName = k break end
    end
    local price = math.floor((QBCore.Shared.Vehicles[vehName] and QBCore.Shared.Vehicles[vehName].price or 15000) * Config.Dealer.PriceMultiplier)
    TriggerServerEvent('196rp_jobs:server:sellCar', price, GetVehicleNumberPlateText(dealerVehicle), vehName)
end, false)

RegisterNetEvent('196rp_jobs:client:dealerSell', function(buyerCid)
    if dealerVehicle and DoesEntityExist(dealerVehicle) then
        DeleteEntity(dealerVehicle)
    end
    dealerVehicle = nil
end)
