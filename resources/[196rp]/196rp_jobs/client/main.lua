local QBCore = exports['qb-core']:GetCoreObject()
local busy = false
local currentJob = 'unemployed'

local JobZones = {}
local SellZones = {}

-- ── Kiçik 3D yazı ──
function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextCentre(true)
    SetTextColour(255, 217, 122, 215)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y, z + 0.3)
end

-- ── İş animasiyası ──
local Anims = {
    fishing      = { dict = 'amb@world_human_stand_fishing@idle_a', name = 'idle_a' },
    mining       = { dict = 'amb@world_human_const_drill@male@drill@base', name = 'base' },
    lumberjack   = { dict = 'amb@world_human_const_bush_trim@male@trim@base', name = 'base' },
    construction = { dict = 'amb@world_human_const_drill@male@drill@base', name = 'base' },
}

local function PlayJobAnim(job, duration)
    local a = Anims[job]
    if not a then return end
    local ped = PlayerPedId()
    RequestAnimDict(a.dict)
    local t = 0
    while not HasAnimDictLoaded(a.dict) and t < 100 do Wait(20) t = t + 1 end
    if HasAnimDictLoaded(a.dict) then
        TaskPlayAnim(ped, a.dict, a.name, 3.0, 3.0, -1, 49, 0, false, false, false)
    end
    SetTimeout(duration * 1000, function()
        if HasAnimDictLoaded(a.dict) then
            ClearPedTasksImmediately(ped)
            RemoveAnimDict(a.dict)
        end
    end)
end

-- ── İş Mərkəzi menyusu ──
local function OpenJobMenu()
    local pData = QBCore.Functions.GetPlayerData()
    local menu = {
        { header = Config.Text.header, isMenuHeader = true, icon = 'fas fa-briefcase' },
        { header = Config.Text.current_job:gsub('%%{job}', pData.job.label or 'Mülki şəxs'), isMenuHeader = false, icon = 'fas fa-user-tie' },
    }
    for jobName, desc in pairs(Config.Jobs) do
        menu[#menu + 1] = {
            header = (QBCore.Shared.Jobs[jobName] and QBCore.Shared.Jobs[jobName].label) or jobName,
            txt = desc,
            icon = 'fas fa-arrow-right',
            params = { job = jobName },
        }
    end
    menu[#menu + 1] = {
        header = Config.Text.quit_job,
        txt = Config.Text.quit_desc,
        icon = 'fas fa-door-open',
        params = { quit = true },
    }
    exports['qb-menu']:openMenu(menu, function(selected)
        if not selected then return end
        if selected.params and selected.params.quit then
            TriggerServerEvent('196rp_jobs:quit')
        elseif selected.params and selected.params.job then
            TriggerServerEvent('196rp_jobs:apply', selected.params.job)
        end
    end)
end

-- ── Qonşu maşını tap (mexanik) ──
local function GetClosestVehicle()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local veh
    for _, v in ipairs(GetAllVehicles()) do
        local d = #(GetEntityCoords(v) - coords)
        if d < 6.0 and (not veh or d < #(GetEntityCoords(veh) - coords)) then
            veh = v
        end
    end
    return veh
end

RegisterCommand('temir', function()
    if currentJob ~= 'mechanic' then
        QBCore.Functions.Notify('Mexanik işində olmalısınız (İş Mərkəzinə gedin)!', 'error')
        return
    end
    local veh = GetClosestVehicle()
    if not veh then
        QBCore.Functions.Notify('Yaxınlıqda maşın yoxdur!', 'error')
        return
    end
    local plate = GetVehicleNumberPlateText(veh)
    local health = GetVehicleBodyHealth(veh)
    local engine = GetVehicleEngineHealth(veh)
    local damage = math.floor((1000 - health) / 10 + (1000 - engine) / 20)
    if damage < 5 then
        QBCore.Functions.Notify('Maşın artıq sağlamdır!', 'success')
        return
    end
    QBCore.Functions.Notify(('Təmir başladı: %d%% zədə...'):format(damage), 'primary')
    TriggerServerEvent('196rp_jobs:server:repairVehicle', plate, damage)
end, false)

RegisterNetEvent('196rp_jobs:client:fixVehicle', function(plate)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    for _, v in ipairs(GetAllVehicles()) do
        if GetVehicleNumberPlateText(v) == plate and #(GetEntityCoords(v) - coords) < 8.0 then
            SetVehicleBodyHealth(v, 1000.0)
            SetVehicleEngineHealth(v, 1000.0)
            SetVehicleFixed(v)
        end
    end
end)

-- ── İş əməliyyatı ──
local function StartWork(job, zoneLabel, isBuild)
    if busy then
        QBCore.Functions.Notify(Config.Text.cooldown, 'primary')
        return
    end
    if currentJob ~= job then
        QBCore.Functions.Notify(Config.Text.wrong_job, 'error')
        return
    end
    busy = true
    exports['progressbar']:Progress({
        name = '196job_' .. job,
        duration = (Config.WorkTime[job == 'construction' and 'build' or job] or 4) * 1000,
        label = Config.Text.working,
        useWhileDead = false,
        canCancel = false,
        controlDisables = { disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true },
    })
    PlayJobAnim(job, Config.WorkTime[job == 'construction' and 'build' or job] or 4)
    TriggerServerEvent('196rp_jobs:server:collect', job, zoneLabel)
    SetTimeout((Config.WorkTime[job == 'construction' and 'build' or job] or 4) * 1000 + 250, function()
        busy = false
    end)
end

-- ── Satış menyusu ──
local function OpenSellMenu(job)
    exports['qb-menu']:openMenu({
        {
            header = 'Satış nöqtəsi',
            isMenuHeader = true,
            icon = 'fas fa-coins',
        },
        {
            header = 'Məhsulları sat',
            txt = 'Çantadakı bütün materialları pul edəcək',
            icon = 'fas fa-hand-holding-usd',
            params = { sell = true },
        },
    }, function(selected)
        if selected and selected.params and selected.params.sell then
            TriggerServerEvent('196rp_jobs:server:sell', job)
        end
    end)
end

-- ── Zonalar ──
CreateThread(function()
    currentJob = QBCore.Functions.GetPlayerData().job.name
    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(jobInfo)
        currentJob = jobInfo.name
    end)

    -- İş mərkəzləri
    for i, loc in ipairs(Config.Locations) do
        exports['qb-target']:AddBoxZone('196jobs_' .. i, loc.coords, 2.0, 2.0, {
            name = '196jobs_' .. i, heading = loc.heading, debugPoly = false,
            minZ = loc.coords.z - 1, maxZ = loc.coords.z + 3,
        }, { options = { { label = '[E] ' .. loc.label, icon = 'fa-solid fa-briefcase', action = OpenJobMenu } } })
    end

    -- İş sahələri
    local defs = {
        fishing = Config.Zones.fishing,
        mining = Config.Zones.mining,
        lumberjack = Config.Zones.lumberjack,
        construction = Config.Zones.construction,
    }
    for jobName, zones in pairs(defs) do
        for i, z in ipairs(zones) do
            local zoneName = ('196work_%s_%d'):format(jobName, i)
            exports['qb-target']:AddBoxZone(zoneName, z.coords, z.radius * 2, z.radius * 2, {
                name = zoneName, heading = 0.0, debugPoly = false,
                minZ = z.coords.z - 2, maxZ = z.coords.z + 3,
            }, { options = { {
                label = ('[E] %s — %s'):format(z.label, Config.Text.collect_label),
                icon = 'fas fa-hammer',
                action = function() StartWork(jobName, z.label) end,
            } } })
        end
    end

    -- Satış nöqtələri
    for i, s in ipairs(Config.SellPoints) do
        local zoneName = '196sell_' .. i
        exports['qb-target']:AddBoxZone(zoneName, s.coords, 2.5, 2.5, {
            name = zoneName, heading = 0.0, debugPoly = false,
            minZ = s.coords.z - 2, maxZ = s.coords.z + 3,
        }, { options = { { label = '[E] ' .. s.label .. ' — ' .. Config.Text.sell_label, icon = 'fas fa-hand-holding-usd', action = function() OpenSellMenu(s.jobs[1]) end } } })
    end

    -- Blips (satış nöqtələri)
    for _, s in ipairs(Config.SellPoints) do
        local blip = AddBlipForCoord(s.coords)
        SetBlipSprite(blip, 566)
        SetBlipColour(blip, 47)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(s.label)
        EndTextCommandSetBlipName(blip)
    end
end)

-- Modullar (məkanda markerlər)
CreateThread(function()
    while true do
        Wait(1000)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        for jobName, zones in pairs(Config.Zones) do
            for _, z in ipairs(zones) do
                local d = #(coords - z.coords)
                if d < 20.0 then
                    DrawMarker(1, z.coords.x, z.coords.y, z.coords.z - 1.0, 0, 0, 0, 0, 0, 0, 1.8, 1.8, 1.0, 60, 180, 110, 160, false, true, 2, false, nil, nil, false)
                end
            end
        end
    end
end)
