local QBCore = exports['qb-core']:GetCoreObject()

local function HasItem(item)
    local data = QBCore.Functions.GetPlayerData()
    for _, it in ipairs(data.items or {}) do
        if it and it.name == item then return true end
    end
    return false
end

local function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextDropShadow()
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y, z)
end

-- ── İş mərkəzi ──
local function OpenJobCenter()
    TriggerServerEvent('196rp_jobs:server:openCenter')
end

RegisterNetEvent('196rp_jobs:client:showCenter', function(jobs)
    local menu = { { header = '💼 196 İş Mərkəzi', isMenuHeader = true, icon = 'fas fa-briefcase' } }
    for _, j in ipairs(jobs) do
        menu[#menu + 1] = {
            header = j.label .. (j.current and ' ✓' or ''),
            icon = 'fas fa-id-badge',
            params = { job = j.job },
        }
    end
    exports['qb-menu']:openMenu(menu, function(selected)
        if not selected or not selected.params then return end
        TriggerServerEvent('196rp_jobs:server:setJob', selected.params.job)
    end)
end)

-- ── Alət mağazası (İş Mərkəzində) ──
local JobTools = {
    { item = 'fishing_rod', label = '🐟 Qarmaq',   price = 500 },
    { item = 'pickaxe',     label = '⛏ Pikak',    price = 400 },
    { item = 'axe',         label = '🪓 Balta',    price = 350 },
    { item = 'hammer',      label = '🔨 Çəkic',    price = 300 },
}

RegisterNetEvent('196rp_jobs:client:showTools', function()
    local menu = { { header = '🛠 Alət Mağazası', isMenuHeader = true, icon = 'fas fa-store' } }
    for _, t in ipairs(JobTools) do
        menu[#menu + 1] = {
            header = t.label,
            txt = ('₣%d'):format(t.price),
            icon = 'fas fa-toolbox',
            params = { item = t.item, price = t.price },
        }
    end
    exports['qb-menu']:openMenu(menu, function(selected)
        if not selected or not selected.params then return end
        TriggerServerEvent('196rp_jobs:server:buyTool', selected.params.item, selected.params.price)
    end)
end)

-- ── İş zonası ──
local function StartCollect(zone)
    local jobCfg
    for _, j in ipairs(Config.Jobs) do
        if j.job == zone.job then jobCfg = j end
    end
    if not jobCfg or not jobCfg.tool then return end
    if QBCore.Functions.GetPlayerData().job.name ~= zone.job then
        QBCore.Functions.Notify('Bu zona üçün işləməlisiniz (İş Mərkəzi).', 'error')
        return
    end
    if not HasItem(jobCfg.tool) then
        QBCore.Functions.Notify(('Alət lazımdır: %s'):format(jobCfg.tool), 'error')
        return
    end

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    RequestAnimDict(jobCfg.anim.dict)
    local t = 0
    while not HasAnimDictLoaded(jobCfg.anim.dict) and t < 250 do
        Wait(20)
        t = t + 1
    end
    if HasAnimDictLoaded(jobCfg.anim.dict) then
        TaskPlayAnim(ped, jobCfg.anim.dict, jobCfg.anim.name, 8.0, 8.0, jobCfg.time, jobCfg.anim.flags, 0, false, false, false)
    end

    QBCore.Functions.Progressbar('job_collect', jobCfg.label .. ' — işləyir...', jobCfg.time * 1000, false, true, {
        disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true,
    }, function()
        FreezeEntityPosition(ped, false)
        ClearPedTasks(ped)
        TriggerServerEvent('196rp_jobs:server:collect', zone.id)
    end, function()
        FreezeEntityPosition(ped, false)
        ClearPedTasks(ped)
    end)
end

-- Satış nöqtəsi
local function OpenSellPoint(sp)
    local menu = { { header = '💰 ' .. sp.label, isMenuHeader = true, icon = 'fas fa-coins' } }
    for item, price in pairs(sp.buys) do
        menu[#menu + 1] = {
            header = ('Sat: %s (₣%d)'):format(item, price),
            icon = 'fas fa-tag',
            params = { sellId = sp.id, item = item },
        }
    end
    exports['qb-menu']:openMenu(menu, function(selected)
        if not selected or not selected.params then return end
        TriggerServerEvent('196rp_jobs:server:sell', selected.params.sellId, selected.params.item, 1)
    end)
end

-- ── Mexanik ──
local function EnumerateVehicles()
    local list = {}
    for _, v in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(v) then list[#list + 1] = v end
    end
    local i = 0
    return function()
        i = i + 1
        return list[i]
    end
end

local function GetClosestVehicle()
    local pos = GetEntityCoords(PlayerPedId())
    local closest, dist = nil, Config.Mechanic.MaxDistance
    for veh in EnumerateVehicles() do
        local d = #(GetEntityCoords(veh) - pos)
        if d < dist then closest, dist = veh, d end
    end
    return closest
end

RegisterCommand('temir', function()
    local pData = QBCore.Functions.GetPlayerData()
    if pData.job.name ~= 'mechanic' then
        QBCore.Functions.Notify('Mexanik işi tələb olunur.', 'error')
        return
    end
    local veh = GetClosestVehicle()
    if not veh then
        QBCore.Functions.Notify('Yaxınlıqda maşın tapılmadı.', 'error')
        return
    end
    local plate = GetVehicleNumberPlateText(veh)
    local health = GetEntityHealth(veh)
    local body = GetVehicleBodyHealth(veh)
    local broken = math.max(100 - math.floor(body / 10), 0)

    local menu = {
        { header = '🔧 Mexanik Xidmət', isMenuHeader = true, icon = 'fas fa-wrench' },
        { header = ('🚗 Maşın: %s | Zədə: %d%%'):format(plate, broken), isMenuHeader = true },
        { header = '🔩 Təmir', txt = ('Zədə əsasında ₣%d'):format(math.ceil(Config.Mechanic.RepairPrice * (broken / 100))), icon = 'fas fa-screwdriver', params = { action = 'repair', plate = plate, damage = broken } },
        { header = '⚡ Təkər + Yanacaq', txt = ('₣%d'):format(Config.Mechanic.BoostPrice), icon = 'fas fa-gas-pump', params = { action = 'boost', plate = plate } },
    }
    exports['qb-menu']:openMenu(menu, function(selected)
        if not selected or not selected.params then return end
        local p = selected.params
        if p.action == 'repair' then
            TriggerServerEvent('196rp_jobs:server:mechRepair', p.plate, p.damage)
        elseif p.action == 'boost' then
            TriggerServerEvent('196rp_jobs:server:mechBoost', p.plate)
        end
    end)
end, false)

RegisterNetEvent('196rp_jobs:client:fixVehicle', function(plate)
    for veh in EnumerateVehicles() do
        if GetVehicleNumberPlateText(veh) == plate then
            SetVehicleBodyHealth(veh, 1000.0)
            SetVehicleEngineHealth(veh, 1000.0)
            SetVehicleFixed(veh)
            return
        end
    end
end)

RegisterNetEvent('196rp_jobs:client:boostVehicle', function(plate)
    for veh in EnumerateVehicles() do
        if GetVehicleNumberPlateText(veh) == plate then
            SetVehicleFuelLevel(veh, 100.0)
            SetVehicleModKit(veh, 0)
            return
        end
    end
end)

-- ── Avtosalon ──
local function OpenDealerMenu()
    local pData = QBCore.Functions.GetPlayerData()
    if pData.job.name ~= 'cardealer' then
        QBCore.Functions.Notify('Avtosalon işi tələb olunur.', 'error')
        return
    end
    local menu = { { header = '🚗 196 Avtosalon (Satış)', isMenuHeader = true, icon = 'fas fa-car' } }
    for _, v in ipairs(Config.CarDealer.Vehicles) do
        menu[#menu + 1] = {
            header = v.label,
            txt = ('₣%d · Müştəri ID: /id'):format(v.price),
            icon = 'fas fa-car-side',
            params = { model = v.model },
        }
    end
    exports['qb-menu']:openMenu(menu, function(selected)
        if not selected or not selected.params then return end
        local targetId = tonumber(InputDlg('Müştərinin oyunçu ID-si'))
        if not targetId then return end
        TriggerServerEvent('196rp_jobs:server:cardealerSell', selected.params.model, targetId)
    end)
end

RegisterCommand('avtosalon', OpenDealerMenu, false)
RegisterCommand('avtomobil', OpenDealerMenu, false)
RegisterCommand('sat', OpenDealerMenu, false)

function InputDlg(label)
    local input = lib and lib.inputDialog and lib.inputDialog('196 RP', { { type = 'number', label = label } })
    if input then return input[1] end
    local result = nil
    AddTextEntry('196_INPUT', label)
    DisplayOnscreenKeyboard(1, '196_INPUT', '', '', '', '', '', 10)
    local t = 0
    while t < 200 do
        DisableControlAction(0, 177, true)
        if UpdateOnscreenKeyboard() == 1 then
            result = GetOnscreenKeyboardResult()
            break
        elseif UpdateOnscreenKeyboard() == 2 then
            break
        end
        Wait(10)
        t = t + 1
    end
    return result
end

-- ── Dünya obyektləri ──
CreateThread(function()
    -- İş mərkəzləri blipləri + target
    for _, c in ipairs(Config.JobCenters) do
        local blip = AddBlipForCoord(c.coords)
        SetBlipSprite(blip, 566)
        SetBlipColour(blip, 49)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(c.label)
        EndTextCommandSetBlipName(blip)
    end
    local center = Config.JobCenters[1]
    exports['qb-target']:AddBoxZone('196jobcenter', center.coords, 4.0, 4.0, {
        name = '196jobcenter', heading = 0, debugPoly = false,
        minZ = center.coords.z - 1, maxZ = center.coords.z + 4,
    }, {
        options = {
            { label = '[E] ' .. center.label, icon = 'fas fa-briefcase', action = OpenJobCenter },
            { label = '[E] Alət Mağazası', icon = 'fas fa-store', action = function() TriggerServerEvent('196rp_jobs:server:openTools') end },
        },
        distance = 2.5,
    })

    -- İş zonaları
    for _, z in ipairs(Config.Zones) do
        exports['qb-target']:AddCircleZone(z.id, z.coords, z.radius + 0.5, {
            name = z.id, debugPoly = false, useZ = true,
        }, {
            options = {
                { label = ('[E] %s — topla'):format(z.marker), icon = 'fas fa-hammer', action = function() StartCollect(z) end },
            },
            distance = 2.5,
        })
    end

    -- Satış nöqtələri
    for _, sp in ipairs(Config.SellPoints) do
        exports['qb-target']:AddBoxZone('sell_' .. sp.id, vector3(sp.coords.x, sp.coords.y, sp.coords.z), 2.5, 2.5, {
            name = 'sell_' .. sp.id, heading = 0, debugPoly = false,
            minZ = sp.coords.z - 1, maxZ = sp.coords.z + 3,
        }, {
            options = {
                { label = ('[E] ' .. sp.label), icon = 'fas fa-coins', action = function() OpenSellPoint(sp) end },
            },
            distance = 2.5,
        })
    end

    -- Avtosalon blipi
    local d = Config.CarDealer.SaleCenter
    local blip = AddBlipForCoord(d.coords)
    SetBlipSprite(blip, 225)
    SetBlipColour(blip, 5)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('196 Avtosalon')
    EndTextCommandSetBlipName(blip)
end)

-- Marker yazıları
CreateThread(function()
    while true do
        local pos = GetEntityCoords(PlayerPedId())
        for _, z in ipairs(Config.Zones) do
            if #(pos - z.coords) < 6 then
                DrawText3D(z.coords.x, z.coords.y, z.coords.z + 1.2, z.marker)
            end
        end
        for _, sp in ipairs(Config.SellPoints) do
            if #(pos - sp.coords) < 6 then
                DrawText3D(sp.coords.x, sp.coords.y, sp.coords.z + 1.2, sp.label)
            end
        end
        Wait(150)
    end
end)
