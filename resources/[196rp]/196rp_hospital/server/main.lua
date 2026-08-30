local QBCore = exports['qb-core']:GetCoreObject()

local lastRevive = {}

local function GetMoney(Player)
    return Player.PlayerData.money.cash or 0
end

local function TryCharge(Player, amount)
    if GetMoney(Player) >= amount then
        Player.Functions.RemoveMoney('cash', amount, 'hospital-service')
        return true
    end
    return false
end

local function HasInsurance(Player)
    local exp = tonumber(Player.PlayerData.metadata.insurance or 0)
    return exp and exp > os.time()
end

local function HasOnlineEMS()
    for _, src in ipairs(QBCore.Functions.GetPlayers()) do
        local P = QBCore.Functions.GetPlayer(src)
        if P and P.PlayerData.job.name == 'ambulance' and P.PlayerData.job.onduty then
            return true
        end
    end
    return false
end

-- ── Sığorta al ──
RegisterNetEvent('196rp_hospital:server:buyInsurance', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if HasInsurance(Player) then
        TriggerClientEvent('QBCore:Notify', src, 'Sığortanız artıq aktivdir!', 'primary')
        return
    end
    if not TryCharge(Player, Config.Prices.Insurance) then
        TriggerClientEvent('QBCore:Notify', src, ('Kifayət qədər pul yoxdur — sığorta ₣%d-dir'):format(Config.Prices.Insurance), 'error')
        return
    end
    Player.Functions.SetMeta('insurance', os.time() + Config.InsuranceDays * 86400)
    TriggerClientEvent('QBCore:Notify', src, ('✅ Sığorta alındı (%d gün). Müalicə artıq pulsuzdur!'):format(Config.InsuranceDays), 'success')
end)

-- ── Müalicə ──
RegisterNetEvent('196rp_hospital:server:heal', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.metadata.isdead then
        TriggerClientEvent('QBCore:Notify', src, 'Canlandırma xidmətindən istifadə edin!', 'error')
        return
    end
    if not HasInsurance(Player) then
        if not TryCharge(Player, Config.Prices.Heal) then
            TriggerClientEvent('QBCore:Notify', src, ('Kifayət qədər pul yoxdur — müalicə ₣%d-dir'):format(Config.Prices.Heal), 'error')
            return
        end
    end
    TriggerClientEvent('196rp_hospital:client:heal', src)
    TriggerClientEvent('QBCore:Notify', src, HasInsurance(Player) and '✅ Sığorta hesabına müalicə olundunuz!' or ('✅ Müalicə olundunuz (-₣%d)'):format(Config.Prices.Heal), 'success')
end)

-- ── Canlandırma (AED kiosk) — EMS onlayn deyilsə ──
RegisterNetEvent('196rp_hospital:server:revive', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if not Player.PlayerData.metadata.isdead then
        TriggerClientEvent('QBCore:Notify', src, 'Ölməmisiniz — müalicə istifadə edin.', 'primary')
        return
    end
    if HasOnlineEMS() then
        TriggerClientEvent('QBCore:Notify', src, '🚑 EMS növbətçidədir — onları çağırın (112)!', 'error')
        return
    end
    local now = os.time()
    if lastRevive[src] and (now - lastRevive[src]) < Config.ReviveCooldown then
        TriggerClientEvent('QBCore:Notify', src, ('AED yenidən doldurulur — %d saniyə gözləyin.'):format(Config.ReviveCooldown - (now - lastRevive[src])), 'error')
        return
    end
    if not TryCharge(Player, Config.Prices.Revive) then
        TriggerClientEvent('QBCore:Notify', src, ('Kifayət qədər pul yoxdur — canlandırma ₣%d-dir'):format(Config.Prices.Revive), 'error')
        return
    end
    lastRevive[src] = now
    Player.Functions.SetMeta('isdead', false)
    Player.Functions.SetMeta('inlaststand', false)
    TriggerClientEvent('196rp_hospital:client:revive', src)
    TriggerClientEvent('QBCore:Notify', src, ('⚡ AED istifadə olundu (-₣%d). Sağaldınız!'):format(Config.Prices.Revive), 'success')
end)
