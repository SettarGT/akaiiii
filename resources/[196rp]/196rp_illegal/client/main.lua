-- 196 RP | Qanunsuz fəaliyyətlər — müştəri tərəfi
-- Qıfıl açarı, şom, rehin alma, dələduzluq, müsadirə basqını, gizli yer, zibil ərazisi

local inHideout = false
local isHostage = false
local lastTool = 0

-- ==================== KÖMƏKÇİLƏR ====================

local function GetPlate(veh)
    if not veh or not DoesEntityExist(veh) then
        return nil
    end
    return (GetVehicleNumberPlateText(veh):gsub('%s+', '')):upper()
end

local function GetClosestVehicle(dist)
    local c = GetEntityCoords(PlayerPedId())
    local veh = GetClosestVehicle(c.x, c.y, c.z, dist, 0, 71)
    if veh and veh ~= 0 and DoesEntityExist(veh) then
        return veh
    end
    return nil
end

local function ToolReady(ms)
    local now = GetGameTimer()
    if now - lastTool < (ms or 2000) then
        return false
    end
    lastTool = now
    return true
end

-- ==================== 66. QIFIL AÇARI ====================

RegisterNetEvent('196rp_illegal:useLockpick', function()
    if not ToolReady(2000) then
        return
    end

    local veh = GetClosestVehicle(Config.Tools.lockpick.maxDistance)
    if not veh then
        ESX.ShowNotification('Yaxınlıqda maşın yoxdur!', 'error', 4000)
        return
    end

    local plate = GetPlate(veh)
    if not plate then
        return
    end

    ESX.Progressbar('Qıfıl açılır...', Config.Tools.lockpick.time, {
        FreezePlayer = true,
        animation = { type = 'anim', dict = 'anim@amb@nightclub@lazlow@hi_idles@', lib = 'idle_a' },
        onFinish = function()
            ESX.TriggerServerCallback('196rp_illegal:breakIn', function(ok, msg)
                ESX.ShowNotification(msg, ok and 'success' or 'error', 5000)

                if ok then
                    SetVehicleDoorsLocked(veh, 1)
                    SetVehicleDoorsLockedForAllPlayers(veh, false)
                    SetVehicleEngineOn(veh, true, true, false)
                    TriggerEvent('196rp_vehicle:lockState', plate, false)
                end
            end, plate)
        end,
        onCancel = function()
            ESX.ShowNotification('Açma ləğv edildi.', 'info', 3000)
        end,
    })
end)

-- ==================== 66/68. ŞOM ====================

RegisterNetEvent('196rp_illegal:useCrowbar', function()
    if not ToolReady(2000) then
        return
    end

    local coords = GetEntityCoords(PlayerPedId())

    -- Müsadirə anbarı basqını
    if #(coords - Config.ImpoundRaid.gate) < 6.0 then
        ESX.Progressbar('Şomla anbar qapısı qırılır...', Config.ImpoundRaid.time, {
            FreezePlayer = true,
            animation = { type = 'Scenario', Scenario = 'WORLD_HUMAN_CONST_DRILL' },
            onFinish = function()
                ESX.TriggerServerCallback('196rp_illegal:raidImpound', function(ok, info, msg)
                    ESX.ShowNotification(msg, ok and 'success' or 'error', 7000)

                    if ok and info then
                        ESX.Game.SpawnVehicle(info.model, Config.ImpoundRaid.spawn, Config.ImpoundRaid.heading,
                            function(veh)
                                if not veh or veh == 0 then
                                    return
                                end
                                SetVehicleNumberPlateText(veh, info.plate)
                                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                                ESX.ShowNotification(
                                    ('~g~Maşın oğurlandı: ~y~%s~s~\nNömrə: ~y~%s~s~'):format(info.model, info.plate),
                                    'success', 8000)
                            end)
                    end
                end)
            end,
        })
        return
    end

    -- Adi maşın qapısı
    local veh = GetClosestVehicle(Config.Tools.crowbar.maxDistance)
    if not veh then
        ESX.ShowNotification('Yaxınlıqda maşın və ya anbar qapısı yoxdur!', 'error', 4000)
        return
    end

    local plate = GetPlate(veh)

    ESX.Progressbar('Şomla qapı qırılır...', Config.Tools.crowbar.time, {
        FreezePlayer = true,
        animation = { type = 'Scenario', Scenario = 'WORLD_HUMAN_CONST_DRILL' },
        onFinish = function()
            ESX.TriggerServerCallback('196rp_illegal:breakIn', function(ok, msg)
                ESX.ShowNotification(msg, ok and 'success' or 'error', 5000)
                if ok then
                    SetVehicleDoorsLocked(veh, 1)
                    SetVehicleDoorsLockedForAllPlayers(veh, false)
                    TriggerEvent('196rp_vehicle:lockState', plate, false)
                end
            end, plate)
        end,
    })
end)

-- ==================== 65. REHİN ALMA ====================

RegisterCommand('rehin', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local closestPlayer, closestDist = -1, Config.Hostage.maxDistance

    local players = GetActivePlayers()
    for i = 1, #players do
        local other = GetPlayerPed(players[i])
        if other ~= ped then
            local d = #(coords - GetEntityCoords(other))
            if d < closestDist then
                closestPlayer = GetPlayerServerId(players[i])
                closestDist = d
            end
        end
    end

    if closestPlayer == -1 then
        ESX.ShowNotification('Yaxınlıqda oyunçu yoxdur!', 'error', 4000)
        return
    end

    ESX.TriggerServerCallback('196rp_illegal:takeHostage', function(ok, msg)
        ESX.ShowNotification(msg, ok and 'success' or 'error', 7000)
    end, closestPlayer)
end, false)

-- Rehin alınan oyunçu üçün
RegisterNetEvent('196rp_illegal:hostageStart', function()
    isHostage = true
    ESX.ShowNotification('~r~Sizi rehin aldılar!~s~ Polis xəbərdar edildi.', 'error', 10000)
    SetPedCanSwitchWeapon(PlayerPedId(), false)
end)

RegisterNetEvent('196rp_illegal:hostageEnd', function(msg)
    isHostage = false
    ESX.ShowNotification(msg or 'Rehinəlik bitdi.', 'info', 7000)
    SetPedCanSwitchWeapon(PlayerPedId(), true)
    ClearPedTasksImmediately(PlayerPedId())
end)

-- Rehin alan oyunçu üçün: qurbanı izlə
RegisterNetEvent('196rp_illegal:hostageFollow', function(targetServerId)
    local target = GetPlayerPed(GetPlayerFromServerId(targetServerId))

    CreateThread(function()
        local lastTask = 0

        while isHostage do
            Wait(300)

            if DoesEntityExist(target) then
                local d = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(target))

                if d > Config.Hostage.followDistance and GetGameTimer() - lastTask > 3000 then
                    lastTask = GetGameTimer()
                    TaskFollowToOffsetOfEntity(PlayerPedId(), target, 0.0, -1.0, 0.0, 1.5, -1, 1.0, true)
                end

                if d > 30.0 then
                    ESX.ShowNotification('~r~Rehinə qaçdı!~s~', 'error', 6000)
                    TriggerServerEvent('196rp_illegal:hostageLost', targetServerId)
                    break
                end
            else
                break
            end
        end
    end)
end)

-- ==================== 69. GİZLİ YER ====================

-- Anbar menyusu
local function OpenStash()
    exports['esx_context']:Open('right', {
        { icon = 'fas fa-box', title = '📦 Gizli anbar', unselectable = true },
        { icon = 'fas fa-arrow-down', title = 'Əşya qoy', name = 'deposit' },
        { icon = 'fas fa-arrow-up', title = 'Əşya götür', name = 'withdraw' },
        { icon = 'fas fa-list', title = 'Siyahıya bax', name = 'list' },
    }, function(selected)
        if selected.name == 'list' then
            ESX.TriggerServerCallback('196rp_illegal:getStash', function(items)
                local menu = {
                    { icon = 'fas fa-box', title = ('📦 Anbar (%s əşya)'):format(#items), unselectable = true },
                }
                if #items == 0 then
                    menu[#menu + 1] = { icon = 'fas fa-info', title = 'Anbar boşdur', unselectable = true }
                end
                for i = 1, #items do
                    menu[#menu + 1] = {
                        icon = 'fas fa-cube',
                        title = ('%s — %s ədəd'):format(items[i].label or items[i].item, items[i].count),
                        name = 'take_' .. items[i].item,
                    }
                end
                exports['esx_context']:Open('right', menu, function(sel)
                    local item = sel.name:match('^take_(.+)$')
                    if item then
                        ESX.TriggerServerCallback('196rp_illegal:withdrawItem', function(ok, msg)
                            ESX.ShowNotification(msg, ok and 'success' or 'error')
                        end, item)
                    end
                end)
            end)
        elseif selected.name == 'deposit' then
            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stash_item', {
                title = 'Əşyanın adı'
            }, function(data, menu)
                local item = tostring(data.value or ''):lower():gsub('%s+', '')
                menu.close()

                if item == '' then
                    return
                end

                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stash_count', {
                    title = 'Neçə ədəd?'
                }, function(data2, menu2)
                    menu2.close()
                    local count = math.floor(tonumber(data2.value) or 0)

                    ESX.TriggerServerCallback('196rp_illegal:depositItem', function(ok, msg)
                        ESX.ShowNotification(msg, ok and 'success' or 'error')
                    end, item, count)
                end)
            end)
        elseif selected.name == 'withdraw' then
            ESX.TriggerServerCallback('196rp_illegal:getStash', function(items)
                if #items == 0 then
                    ESX.ShowNotification('Anbar boşdur.', 'info')
                    return
                end

                ESX.TriggerServerCallback('196rp_illegal:withdrawItem', function(ok, msg)
                    ESX.ShowNotification(msg, ok and 'success' or 'error')
                end, items[1].item)
            end)
        end
    end)
end


local function FadeAndTeleport(dest)
    DoScreenFadeOut(600)
    Wait(700)
    SetEntityCoords(PlayerPedId(), dest.x, dest.y, dest.z, false, false, false, false)
    Wait(400)
    DoScreenFadeIn(600)
end

CreateThread(function()
    while true do
        local wait = 750
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        if not inHideout then
            local dist = #(coords - Config.Hideout.entrance)

            if dist < 20.0 then
                wait = 0
                DrawMarker(1, Config.Hideout.entrance.x, Config.Hideout.entrance.y, Config.Hideout.entrance.z - 1.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 0.5, 180, 30, 30, 100, false, true, 2, nil, nil, false)
            end

            if dist < 1.8 then
                ESX.TextUI('[E] — Gizli yerə gir', 'info')
                if IsControlJustPressed(0, 38) then
                    ESX.HideUI()
                    FadeAndTeleport(Config.Hideout.interior)
                    inHideout = true
                end
            end
        else
            wait = 0
            local dExit = #(coords - Config.Hideout.interiorExit)
            local dStash = #(coords - Config.Hideout.stash)

            DrawMarker(1, Config.Hideout.interiorExit.x, Config.Hideout.interiorExit.y, Config.Hideout.interiorExit.z - 1.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 0.5, 90, 180, 90, 100, false, true, 2, nil, nil, false)
            DrawMarker(1, Config.Hideout.stash.x, Config.Hideout.stash.y, Config.Hideout.stash.z - 1.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 0.5, 200, 180, 40, 100, false, true, 2, nil, nil, false)

            if dExit < 1.8 then
                ESX.TextUI('[E] — Gizli yerdən çıx', 'info')
                if IsControlJustPressed(0, 38) then
                    ESX.HideUI()
                    FadeAndTeleport(Config.Hideout.exitTo)
                    inHideout = false
                end
            elseif dStash < 1.8 then
                ESX.TextUI('[E] — Gizli anbar', 'info')
                if IsControlJustPressed(0, 38) then
                    ESX.HideUI()
                    OpenStash()
                end
            end
        end

        Wait(wait)
    end
end)

-- ==================== 67. DƏLƏDUZLUQ ====================

CreateThread(function()
    while true do
        local wait = 750

        if inHideout then
            wait = 0
            local coords = GetEntityCoords(PlayerPedId())
            local dist = #(coords - Config.Fraud.table)

            DrawMarker(27, Config.Fraud.table.x, Config.Fraud.table.y, Config.Fraud.table.z - 1.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 0.4, 160, 60, 200, 120, false, true, 2, nil, nil, false)

            if dist < 2.0 then
                ESX.TextUI('[E] — Saxta pul hazırla', 'info')
                if IsControlJustPressed(0, 38) then
                    ESX.HideUI()

                    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'fraud_amount', {
                        title = 'Nə qədər təmiz pul verirsiniz? (ən azı 100$)'
                    }, function(data, menu)
                        menu.close()
                        local amount = math.floor(tonumber(data.value) or 0)

                        if amount < 100 or amount > Config.Fraud.maxPerOperation then
                            ESX.ShowNotification(('Yanlış miqdar! (100 - %s)'):format(Config.Fraud.maxPerOperation), 'error')
                            return
                        end

                        ESX.Progressbar('Saxta pul çap olunur...', Config.Fraud.time, {
                            FreezePlayer = true,
                            animation = { type = 'Scenario', Scenario = 'PROP_HUMAN_PARKING_METER' },
                            onFinish = function()
                                ESX.TriggerServerCallback('196rp_illegal:fraud', function(ok, msg)
                                    ESX.ShowNotification(msg, ok and 'success' or 'error', 7000)
                                end, amount)
                            end,
                        })
                    end)
                end
            end
        end

        Wait(wait)
    end
end)

-- ==================== 70. ZİBİL ƏRAZİSİ ====================

CreateThread(function()
    while true do
        local wait = 750
        local coords = GetEntityCoords(PlayerPedId())
        local dist = #(coords - Config.Junkyard.coords)

        if dist < Config.Junkyard.radius + 20.0 then
            wait = 0
            DrawMarker(1, Config.Junkyard.coords.x, Config.Junkyard.coords.y, Config.Junkyard.coords.z - 1.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 0.6, 120, 120, 120, 100, false, true, 2, nil, nil, false)
        end

        if dist < 4.0 then
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
                ESX.TextUI('[E] — Maşını zibilə təhvil ver', 'info')
                if IsControlJustPressed(0, 38) then
                    ESX.HideUI()

                    ESX.Progressbar('Maşın doğranır...', Config.Junkyard.time, {
                        FreezePlayer = true,
                        animation = { type = 'Scenario', Scenario = 'WORLD_HUMAN_CONST_DRILL' },
                        onFinish = function()
                            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                            local plate = GetPlate(veh)

                            ESX.TriggerServerCallback('196rp_illegal:scrapVehicle', function(ok, msg)
                                ESX.ShowNotification(msg, ok and 'success' or 'error', 7000)

                                if ok then
                                    TaskLeaveVehicle(PlayerPedId(), veh, 16)
                                    Wait(1200)
                                    if DoesEntityExist(veh) then
                                        DeleteEntity(veh)
                                    end
                                end
                            end, plate)
                        end,
                    })
                end
            end
        end

        Wait(wait)
    end
end)

CreateThread(function()
    local blip = AddBlipForCoord(Config.Junkyard.coords.x, Config.Junkyard.coords.y, Config.Junkyard.coords.z)
    SetBlipSprite(blip, 318)
    SetBlipColour(blip, 5)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, 0.8)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Zibil Ərazisi (doğrama)')
    EndTextCommandSetBlipName(blip)
end)

-- Polis xəbərdarlığı: müvəqqəti blip
RegisterNetEvent('196rp_illegal:policeAlert', function(coords, label)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 303)
    SetBlipColour(blip, 1)
    SetBlipFlashes(blip, true)
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(('🚨 %s'):format(label or 'Hadisə'))
    EndTextCommandSetBlipName(blip)

    SetTimeout(45000, function()
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end)
end)

exports('IsInHideout', function()
    return inHideout
end)
