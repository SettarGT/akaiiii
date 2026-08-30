local QBCore = exports['qb-core']:GetCoreObject()

local lastRelax = {}

local function GetStress(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return 0 end
    return tonumber(Player.PlayerData.metadata.stress) or 0
end

local function SetStress(src, value)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    value = math.max(0, math.min(100, math.floor(value)))
    Player.Functions.SetMeta('stress', value)
    TriggerClientEvent('196rp_stress:client:update', src, value)
end

-- Export: başqa resurslar stress artıra bilər
exports('AddStress', function(src, amount)
    SetStress(src, GetStress(src) + (tonumber(amount) or 0))
end)

exports('GetStress', function(src)
    return GetStress(src)
end)

-- ── /stress ──
RegisterCommand('stress', function(source)
    local src = source
    local s = GetStress(src)
    TriggerClientEvent('QBCore:Notify', src, ('🧠 Stress səviyyəsi: %d/100 %s'):format(s, s > Config.Stress.WarnThreshold and '— diqqət, sakitləşin (/nəfəs)!' or ''), s > Config.Stress.WarnThreshold and 'error' or 'primary')
end, false)

-- ── /nəfəs ──
RegisterCommand('nefes', function(source)
    local src = source
    local now = os.time()
    if lastRelax[src] and (now - lastRelax[src]) < Config.Stress.RelaxCooldown then
        TriggerClientEvent('QBCore:Notify', src, ('Sakitləşmək üçün hələ %d saniyə gözləyin.'):format(Config.Stress.RelaxCooldown - (now - lastRelax[src])), 'error')
        return
    end
    lastRelax[src] = now
    if GetStress(src) <= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Stressiniz onsuz da sıfırdır. 😌', 'primary')
        return
    end
    TriggerClientEvent('196rp_stress:client:relax', src, Config.Stress.RelaxTime)
    SetTimeout(Config.Stress.RelaxTime * 1000, function()
        SetStress(src, GetStress(src) - Config.Stress.RelaxAmount)
        TriggerClientEvent('QBCore:Notify', src, ('😌 Dərin nəfəs — stress -%d.'):format(Config.Stress.RelaxAmount), 'success')
    end)
end, false)

-- ── Yeməklərlə azalma ──
RegisterNetEvent('196rp_stress:server:eatRelax', function(item)
    local src = source
    local amount = Config.RelaxFoods[item]
    if amount and GetStress(src) > 0 then
        SetStress(src, GetStress(src) - amount)
        TriggerClientEvent('QBCore:Notify', src, ('😌 Yemək stressi azaltdı: -%d'):format(amount), 'success')
    end
end)

-- ── Yüksək stress xəbərdarlığı ──
CreateThread(function()
    while true do
        Wait(Config.Stress.CheckInterval * 1000)
        for _, src in ipairs(QBCore.Functions.GetPlayers()) do
            local p = src -- source
            if GetStress(p) >= Config.Stress.WarnThreshold then
                TriggerClientEvent('QBCore:Notify', p, ('⚠️ Stress yüksəkdir (%d/100) — /nəfəs edin!'):format(GetStress(p)), 'error')
            end
        end
    end
end)
