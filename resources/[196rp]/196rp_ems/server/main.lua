local QBCore = exports['qb-core']:GetCoreObject()

local injuries = {}   -- src -> {head, thorax, larm, rarm, lleg, rleg}
local carries = {}    -- emsSrc -> targetSrc

local function Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or 'primary')
end

local function IsMedic(Player)
    if not Player then return false end
    for _, job in ipairs(Config.Jobs) do
        if Player.PlayerData.job.name == job then return true end
    end
    return false
end

local function NewInjuries()
    return { head = 0, thorax = 0, larm = 0, rarm = 0, lleg = 0, rleg = 0 }
end

local function Sum(inj)
    local s = 0
    for _, v in pairs(inj or {}) do s = s + v end
    return s
end

-- ── qb-ambulancejob zədə məlumatlarını güzgülə ──
RegisterNetEvent('hospital:server:SyncInjuries', function(data)
    injuries[source] = type(data) == 'table' and data or NewInjuries()
end)

RegisterNetEvent('hospital:server:SetWeaponDamage', function(data)
    if type(data) ~= 'table' then return end
    local t = injuries[source] or NewInjuries()
    for _, z in ipairs(Config.Zones) do
        if data[z.id] then
            t[z.id] = math.min(100, (t[z.id] or 0) + math.floor(tonumber(data[z.id]) or 0))
        end
    end
    injuries[source] = t
end)

-- ── Ölümdə zon zədə yarat ──
RegisterNetEvent('hospital:server:SetDeathStatus', function(isDead)
    if not isDead then return end
    local src = source
    local t = injuries[src] or NewInjuries()
    local n = math.random(1, 2)
    for _ = 1, n do
        local z = Config.Zones[math.random(#Config.Zones)]
        t[z.id] = math.min(100, (t[z.id] or 0) + math.random(20, 45))
    end
    injuries[src] = t
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function()
    injuries[source] = nil
    carries[source] = nil
end)

-- ── Rentgen (EMS skan) ──
RegisterNetEvent('196rp_ems:server:getXray', function(targetSrc)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not IsMedic(Player) then return end
    targetSrc = tonumber(targetSrc) or 0
    if targetSrc == 0 then targetSrc = src end
    local t = injuries[targetSrc] or NewInjuries()
    TriggerClientEvent('196rp_ems:client:showXray', src, targetSrc, t)
end)

-- ── Müalicə: sarğı / gips ──
RegisterNetEvent('196rp_ems:server:treat', function(targetSrc, kind)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not IsMedic(Player) then return end
    targetSrc = tonumber(targetSrc) or 0
    if targetSrc == 0 then return end

    local item = kind == 'gips' and 'firstaid' or 'bandage'
    if not Player.Functions.GetItemByName(item) then
        Notify(src, ('Sizdə %s yoxdur!'):format(QBCore.Shared.Items[item] and QBCore.Shared.Items[item].label or item), 'error')
        return
    end

    local t = injuries[targetSrc] or NewInjuries()
    local reduce = kind == 'gips' and Config.SplintReduce or Config.BandageReduce

    -- ən ağır zonanı tap
    local worst, worstVal = nil, -1
    for _, z in ipairs(Config.Zones) do
        if t[z.id] > worstVal then worst, worstVal = z.id, t[z.id] end
    end
    if not worst or worstVal <= 0 then
        Notify(src, 'Xəstənin müalicəyə ehtiyacı yoxdur.', 'primary')
        return
    end

    Player.Functions.RemoveItem(item, 1, false, false, 'ems:treat')
    t[worst] = math.max(0, t[worst] - reduce)
    injuries[targetSrc] = t

    local label = ''
    for _, z in ipairs(Config.Zones) do if z.id == worst then label = z.label end end
    Notify(src, ('🩹 %s müalicə edildi (-%d)'):format(label, reduce), 'success')
    TriggerClientEvent('QBCore:Notify', targetSrc, ('EMS sizə %s müalicəsi etdi.'):format(label), 'primary')
end)

-- ── Cərrahiyyə başlat ──
RegisterNetEvent('196rp_ems:server:startSurgery', function(targetSrc)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not IsMedic(Player) then return end
    targetSrc = tonumber(targetSrc) or 0
    if targetSrc == 0 then return end

    local t = injuries[targetSrc] or NewInjuries()
    local critical = false
    for _, z in ipairs(Config.Zones) do
        if t[z.id] >= Config.Critical then critical = true end
    end
    if not critical then
        Notify(src, 'Xəstədə kritik zədə yoxdur — cərrahiyyə lazım deyil.', 'primary')
        return
    end
    TriggerClientEvent('196rp_ems:client:startSurgery', src, targetSrc, Config.SurgerySymbols, Config.SurgerySteps, Config.SurgeryTime)
end)

-- ── Cərrahiyyə nəticəsi ──
RegisterNetEvent('196rp_ems:server:surgeryDone', function(targetSrc, success)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not IsMedic(Player) then return end
    targetSrc = tonumber(targetSrc) or 0
    if targetSrc == 0 then return end

    if success then
        injuries[targetSrc] = NewInjuries()
        TriggerClientEvent('QBCore:Notify', targetSrc, '🩺 Cərrahiyyə uğurlu — bütün zədələr sağaldı.', 'success')
        exports['196rp_stress']:AddStress(targetSrc, -20)
        Notify(src, '🎉 Cərrahiyyə uğurla tamamlandı.', 'success')
    else
        local t = injuries[targetSrc] or NewInjuries()
        local z = Config.Zones[math.random(#Config.Zones)]
        t[z.id] = math.min(100, (t[z.id] or 0) + 10)
        injuries[targetSrc] = t
        exports['196rp_stress']:AddStress(targetSrc, 15)
        TriggerClientEvent('QBCore:Notify', targetSrc, '⚠️ Cərrahiyyə uğursuz — vəziyyət ağırlaşdı.', 'error')
        Notify(src, '❌ Cərrahiyyə uğursuz oldu.', 'error')
    end
end)

-- ── Diriltmə (zədələr təmizlənibsə) ──
RegisterNetEvent('196rp_ems:server:revive', function(targetSrc)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not IsMedic(Player) then return end
    targetSrc = tonumber(targetSrc) or 0
    if targetSrc == 0 then return end

    local t = injuries[targetSrc] or NewInjuries()
    if Sum(t) > Config.ReviveMaxSum then
        Notify(src, 'Zədələr çox ağır — əvvəlcə müalicə/cərrahiyyə lazımdır.', 'error')
        return
    end

    local Patient = QBCore.Functions.GetPlayer(targetSrc)
    if not Patient then return end

    injuries[targetSrc] = nil
    Patient.Functions.SetMetaData('isdead', false)
    Patient.Functions.SetMetaData('inlaststand', false)
    TriggerClientEvent('hospital:client:Revive', targetSrc)
    TriggerClientEvent('hospital:client:HealInjuries', targetSrc, 'full')
    Notify(src, '✅ Xəstə dirildildi.', 'success')
    TriggerClientEvent('QBCore:Notify', targetSrc, '🩺 EMS sizi diriltdi!', 'success')
end)

-- ── Xərək / daşıma ──
RegisterNetEvent('196rp_ems:server:carry', function(targetSrc, action)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not IsMedic(Player) then return end
    targetSrc = tonumber(targetSrc) or 0
    if targetSrc == 0 or targetSrc == src then return end

    if action == 'pickup' then
        if carries[src] then return end
        local Target = QBCore.Functions.GetPlayer(targetSrc)
        if not Target then return end
        if not Target.PlayerData.metadata.isdead then
            Notify(src, 'Xəstə ölü (yıxılmış) vəziyyətdə deyil.', 'error')
            return
        end
        carries[src] = targetSrc
        TriggerClientEvent('196rp_ems:client:carry', src, 'pickup', targetSrc)
    else
        if carries[src] then
            carries[src] = nil
            TriggerClientEvent('196rp_ems:client:carry', src, 'drop')
        end
    end
end)
