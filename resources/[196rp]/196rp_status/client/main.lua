-- 196 RP | Həyat statusu — müştəri tərəfi
-- HUD paneli + aclıq/susuzluq/enerji azalması + yemək/içki istifadəsi.

local status = { food = 100, water = 100, energy = 100 }
local hudEnabled = false
local dead = false

-- Statusu serverdən yüklə
local pendingMoney = { cash = nil, bank = nil }

RegisterNetEvent('196rp_status:setStatus', function(newStatus)
    status = newStatus
    hudEnabled = true
    SendNUIMessage({ action = 'showHud', data = {} })
    local hudData = { food = status.food, water = status.water, energy = status.energy }
    if pendingMoney.cash then hudData.cash = pendingMoney.cash end
    if pendingMoney.bank then hudData.bank = pendingMoney.bank end
    SendNUIMessage({ action = 'updateHud', data = hudData })
end)

-- HUD-a hər dəyişiklikdə göndər
local function UpdateHud()
    if hudEnabled then
        SendNUIMessage({ action = 'updateHud', data = status })
    end
end

-- Ölüm vəziyyətini izlə
AddEventHandler('esx:onPlayerDeath', function()
    dead = true
end)

AddEventHandler('esx:onPlayerSpawn', function()
    dead = false
    if hudEnabled then
        SendNUIMessage({ action = 'showHud', data = {} })
        SendNUIMessage({ action = 'updateHud', data = status })
    end
end)

-- ==================== HUD MƏLUMATLARI ====================

-- Can və zireh (hər 700ms)
CreateThread(function()
    while true do
        Wait(700)
        if hudEnabled then
            local ped = PlayerPedId()
            local health = GetEntityHealth(ped)
            local maxHealth = GetEntityMaxHealth(ped)
            local armor = GetPedArmour(ped)
            SendNUIMessage({
                action = 'updateHud',
                data = {
                    health = health / maxHealth * 100,
                    armor = armor,
                }
            })
        end
    end
end)

-- Pul məlumatları (bank hesabı)
RegisterNetEvent('esx:setAccountMoney', function(account)
    if account.name == 'money' then
        pendingMoney.cash = account.money
        if hudEnabled then
            SendNUIMessage({ action = 'updateHud', data = { cash = account.money } })
        end
    elseif account.name == 'bank' then
        pendingMoney.bank = account.money
        if hudEnabled then
            SendNUIMessage({ action = 'updateHud', data = { bank = account.money } })
        end
    end
end)

-- İlkin pul dəyərləri
RegisterNetEvent('esx:playerLoaded', function()
    local accounts = ESX.PlayerData.accounts
    if accounts then
        for i = 1, #accounts do
            if accounts[i].name == 'money' then
                pendingMoney.cash = accounts[i].money
            elseif accounts[i].name == 'bank' then
                pendingMoney.bank = accounts[i].money
            end
        end
    end
    if hudEnabled then
        SendNUIMessage({
            action = 'updateHud',
            data = { cash = pendingMoney.cash or 0, bank = pendingMoney.bank or 0 }
        })
    end
end)

-- Saat
CreateThread(function()
    while true do
        Wait(5000)
        if hudEnabled then
            local hour = GetClockHours()
            local minute = GetClockMinutes()
            SendNUIMessage({
                action = 'updateTime',
                data = { time = ('%02d:%02d'):format(hour, minute) }
            })
        end
    end
end)

-- ==================== STATUS AZALMASI ====================

-- Qaçışda enerji itkisi
CreateThread(function()
    while true do
        Wait(1000)
        if not dead and hudEnabled then
            local ped = PlayerPedId()
            if IsPedSprinting(ped) then
                status.energy = math.max(0, status.energy - Config.Status.sprintEnergy)
                UpdateHud()
            end
        end
    end
end)

-- İstirahətdə enerji artımı
CreateThread(function()
    while true do
        Wait(5000)
        if not dead and hudEnabled then
            local ped = PlayerPedId()
            local isMoving = IsPedWalking(ped) or IsPedRunning(ped) or IsPedSprinting(ped)
            if not isMoving and status.energy < 100 then
                status.energy = math.min(100, status.energy + Config.Status.restEnergy)
                UpdateHud()
            end
        end
    end
end)

-- Aclıq / susuzluq azalması + sağlamlıq effekti
CreateThread(function()
    while true do
        Wait(10000)
        if not dead and hudEnabled then
            status.food = math.max(0, status.food - Config.Status.foodDecay)
            status.water = math.max(0, status.water - Config.Status.waterDecay)
            UpdateHud()

            local ped = PlayerPedId()
            local health = GetEntityHealth(ped)

            -- Aclıq və susuzluq çox aşağıdırsa sağlamlıq azalır
            if status.water < Config.Status.lowWater or status.food < Config.Status.lowFood then
                if health > 60 then
                    SetEntityHealth(ped, health - 3)
                end
                if status.water < 10 or status.food < 10 then
                    ESX.ShowNotification('~r~Diqqət!~s~ Toxluq/su səviyyəniz kritikdir — yemək yeyin!', 'error', 5000)
                end
            end

            -- Yorğunluq
            if status.energy < Config.Status.lowEnergy and math.random(100) < 20 then
                ESX.ShowNotification('~o~Yorğunluqdan gözləriniz qapanır...~s~', 'warning', 4000)
            end
        end
    end
end)

-- Serverə mütəmadi sinxronlaşdır
CreateThread(function()
    while true do
        Wait(Config.SyncInterval)
        TriggerServerEvent('196rp_status:sync', status)
    end
end)

-- İlk yükləmə
CreateThread(function()
    TriggerServerEvent('196rp_status:requestLoad')
end)

-- ==================== YEMƏK / İÇKİ İSTİFADƏSİ ====================

-- Serverdən gəlir: əşya artıq çıxarılıb, effekti göstər
RegisterNetEvent('196rp_status:consume', function(itemName, add, kind)
    local ped = PlayerPedId()

    local anim = kind == 'food'
        and { type = 'Scenario', Scenario = 'PROP_HUMAN_MMSIT' }
        or  { type = 'Scenario', Scenario = 'WORLD_HUMAN_DRINKING' }

    ESX.Progressbar(kind == 'food' and 'Yemək yeyirsiniz...' or 'İçki içirsiniz...', 2500, {
        FreezePlayer = true,
        animation = anim,
        onFinish = function()
            if kind == 'food' then
                status.food = math.min(100, status.food + add)
                ESX.ShowNotification(('~g~Toxluq +%s~s~'):format(add), 'success')
            else
                status.water = math.min(100, status.water + add)
                ESX.ShowNotification(('~b~Su +%s~s~'):format(add), 'success')
            end
            UpdateHud()
            TriggerServerEvent('196rp_status:sync', status)
        end
    })
end)

-- 196 RP status sistemini əl ilə çağırmaq üçün (digər resurslardan)
exports('GetStatus', function()
    return status
end)

exports('AddStatus', function(kind, amount)
    if kind == 'food' then
        status.food = math.min(100, status.food + amount)
    elseif kind == 'water' then
        status.water = math.min(100, status.water + amount)
    elseif kind == 'energy' then
        status.energy = math.min(100, status.energy + amount)
    end
    UpdateHud()
    TriggerServerEvent('196rp_status:sync', status)
end)
