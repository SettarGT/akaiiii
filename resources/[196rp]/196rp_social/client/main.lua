-- 196 RP | Sosial sistemlər — müştəri tərəfi
-- Hədiyyə, evlilik, dostluq, missiya sistemi

local activeMission = nil      -- { index, label, target, radius, blip, deadline }
local proposalFrom = nil
local friendBlips = {}

-- ==================== KÖMƏKÇİLƏR ====================

local function Notify(msg, typ, len)
    ESX.ShowNotification(msg, typ or 'info', len or 6000)
end

local function GetClosestPlayer(dist)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local closestId, closestDist = -1, dist

    local players = GetActivePlayers()
    for i = 1, #players do
        local other = GetPlayerPed(players[i])
        if other ~= ped then
            local d = #(coords - GetEntityCoords(other))
            if d < closestDist then
                closestId = GetPlayerServerId(players[i])
                closestDist = d
            end
        end
    end

    return closestId
end

-- ==================== 97. HƏDİYYƏ ====================

RegisterCommand('hediyye', function()
    local target = GetClosestPlayer(Config.Gift.maxDistance)

    if target == -1 then
        Notify('Yaxınlıqda oyunçu yoxdur!', 'error')
        return
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'gift_menu', {
        title = '🎁 Hədiyyə ver',
        align = 'top-left',
        elements = {
            { label = '💵 Pul hədiyyə et', value = 'money' },
            { label = '📦 Əşya hədiyyə et', value = 'item' },
        },
    }, function(data, menu)
        menu.close()

        if data.current.value == 'money' then
            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'gift_money', {
                title = 'Nə qədər pul verirsiniz?'
            }, function(data2, menu2)
                menu2.close()
                local amount = math.floor(tonumber(data2.value) or 0)

                if amount < 1 or amount > Config.Gift.maxMoney then
                    Notify(('Yanlış məbləğ! (1 - %s)'):format(Config.Gift.maxMoney), 'error')
                    return
                end

                ESX.Progressbar('Hədiyyə hazırlanır...', Config.Gift.wrapTime, {
                    FreezePlayer = true,
                    animation = { type = 'Scenario', Scenario = 'WORLD_HUMAN_CLIPBOARD' },
                    onFinish = function()
                        ESX.TriggerServerCallback('196rp_social:giveMoney', function(ok, msg)
                            Notify(msg, ok and 'success' or 'error')
                        end, target, amount)
                    end,
                })
            end)
        else
            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'gift_item', {
                title = 'Əşyanın adı'
            }, function(data2, menu2)
                menu2.close()
                local item = tostring(data2.value or ''):lower():gsub('%s+', '')

                if item == '' then
                    return
                end

                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'gift_item_count', {
                    title = 'Neçə ədəd?'
                }, function(data3, menu3)
                    menu3.close()
                    local count = math.floor(tonumber(data3.value) or 0)

                    ESX.TriggerServerCallback('196rp_social:giveItem', function(ok, msg)
                        Notify(msg, ok and 'success' or 'error')
                    end, target, item, count)
                end)
            end)
        end
    end, function(data, menu)
        menu.close()
    end)
end, false)

-- ==================== 98. EVLİLİK ====================

RegisterCommand('evlilikteklifi', function()
    local target = GetClosestPlayer(Config.Marriage.proposeDistance)

    if target == -1 then
        Notify('Yaxınlıqda oyunçu yoxdur!', 'error')
        return
    end

    ESX.TriggerServerCallback('196rp_social:propose', function(ok, msg)
        Notify(msg, ok and 'success' or 'error', 8000)
    end, target)
end, false)

-- Təklif alan oyunçu
RegisterNetEvent('196rp_social:proposal', function(fromId, fromName)
    proposalFrom = fromId

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'proposal_menu', {
        title = ('💍 ~y~%s~s~ sizə evlilik təklifi edir!'):format(fromName),
        align = 'center',
        elements = {
            { label = '✅ Qəbul et', value = 'yes' },
            { label = '❌ Rədd et', value = 'no' },
        },
    }, function(data, menu)
        menu.close()

        ESX.TriggerServerCallback('196rp_social:proposalResponse', function()
        end, data.current.value == 'yes')
    end, function(data, menu)
        menu.close()
        ESX.TriggerServerCallback('196rp_social:proposalResponse', function()
        end, false)
    end)

    Notify(('~y~%s~s~ sizə evlilik təklifi edir! Qərar verin.'):format(fromName), 'info', 15000)
end)

RegisterNetEvent('196rp_social:proposalResult', function(msg, ok)
    proposalFrom = nil
    Notify(msg, ok and 'success' or 'error', 8000)
end)

RegisterCommand('evlilik', function()
    ESX.TriggerServerCallback('196rp_social:getMarriage', function(row)
        if not row then
            Notify('Siz evli deyilsiniz. /evlilikteklifi [yaxınlıqdakı oyunçu] ilə təklif verin.', 'info', 8000)
            return
        end

        Notify(('💍 Evlisiniz: ~y~%s~s~\nTarix: %s\nToy üçün mərasim meydanına gedin (/toy).'):format(
            row.partnerName, row.marriedAt or '—'), 'success', 12000)
    end)
end, false)

RegisterCommand('toy', function()
    ESX.TriggerServerCallback('196rp_social:ceremony', function(ok, msg)
        Notify(msg, ok and 'success' or 'error', 10000)

        if ok then
            local ped = PlayerPedId()
            RequestAnimDict('mp_common')

            local tries = 0
            while not HasAnimDictLoaded('mp_common') and tries < 40 do
                Wait(50)
                tries = tries + 1
            end

            TaskPlayAnim(ped, 'mp_common', 'givetake1_a', 8.0, -8.0, 4000, 49, 0, false, false, false)
            PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', false, 0, true)
        end
    end)
end, false)

RegisterCommand('bosan', function()
    ESX.TriggerServerCallback('196rp_social:divorce', function(ok, msg)
        Notify(msg, ok and 'success' or 'error', 8000)
    end)
end, false)

-- ==================== 99. DOSTLUQ ====================

RegisterCommand('dost', function()
    local target = GetClosestPlayer(Config.Friend.maxDistance)

    if target == -1 then
        Notify('Yaxınlıqda oyunçu yoxdur!', 'error')
        return
    end

    ESX.TriggerServerCallback('196rp_social:addFriend', function(ok, msg)
        Notify(msg, ok and 'success' or 'error')
    end, target)
end, false)

local function ClearFriendBlips()
    for i = 1, #friendBlips do
        if DoesBlipExist(friendBlips[i]) then
            RemoveBlip(friendBlips[i])
        end
    end
    friendBlips = {}
end

RegisterCommand('dostlar', function()
    ESX.TriggerServerCallback('196rp_social:getFriends', function(list)
        local elements = {}

        if #list == 0 then
            elements[#elements + 1] = { label = 'Dost siyahısı boşdur', value = 'none' }
        end

        for i = 1, #list do
            elements[#elements + 1] = {
                label = ('%s %s%s'):format(
                    list[i].name,
                    list[i].online and ' — ~g~onlayn~s~' or ' — ~r~offlayn~s~',
                    list[i].married and ' 💍' or ''),
                value = list[i].identifier,
            }
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'friend_menu', {
            title = ('👥 Dostlar (%s)'):format(#list),
            align = 'top-left',
            elements = elements,
        }, function(data, menu)
            local identifier = data.current.value

            if identifier == 'none' then
                return
            end

            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'friend_actions', {
                title = data.current.label,
                align = 'top-left',
                elements = {
                    { label = '📍 Xəritədə göstər', value = 'blip' },
                    { label = '💵 Pul göndər', value = 'money' },
                    { label = '❌ Dostluqdan çıxar', value = 'remove' },
                },
            }, function(data2, menu2)
                menu2.close()

                if data2.current.value == 'remove' then
                    ESX.TriggerServerCallback('196rp_social:removeFriend', function(ok, msg)
                        Notify(msg, ok and 'success' or 'error')
                        menu.close()
                    end, identifier)
                elseif data2.current.value == 'money' then
                    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'friend_money', {
                        title = 'Nə qədər pul göndərirsiniz?'
                    }, function(data3, menu3)
                        menu3.close()
                        local amount = math.floor(tonumber(data3.value) or 0)

                        ESX.TriggerServerCallback('196rp_social:sendMoney', function(ok, msg)
                            Notify(msg, ok and 'success' or 'error')
                        end, identifier, amount)
                    end)
                else
                    ESX.TriggerServerCallback('196rp_social:getFriendPosition', function(found, coords, name)
                        if not found then
                            Notify('Bu dost hazırda onlayn deyil!', 'error')
                            return
                        end

                        ClearFriendBlips()

                        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
                        SetBlipSprite(blip, Config.Friend.blipSprite)
                        SetBlipColour(blip, Config.Friend.blipColour)
                        SetBlipAsShortRange(blip, false)
                        BeginTextCommandSetBlipName('STRING')
                        AddTextComponentSubstringPlayerName(('👥 %s'):format(name))
                        EndTextCommandSetBlipName(blip)
                        friendBlips[#friendBlips + 1] = blip

                        Notify(('~g~%s~s~ xəritədə göstərilir.'):format(name), 'success')
                    end, identifier)
                end
            end, function(data2, menu2)
                menu2.close()
            end)
        end, function(data, menu)
            menu.close()
        end)
    end)
end, false)

-- ==================== 100. MİSSİYALAR ====================

local function EndMission(reason)
    if activeMission and activeMission.blip then
        RemoveBlip(activeMission.blip)
    end

    if reason then
        Notify(reason, 'error', 7000)
    end

    activeMission = nil
end

local function StartMission()
    ESX.TriggerServerCallback('196rp_social:startMission', function(ok, mission, msg)
        Notify(msg, ok and 'success' or 'error', 7000)

        if not ok or not mission then
            return
        end

        local blip = AddBlipForCoord(mission.coords.x, mission.coords.y, mission.coords.z)
        SetBlipSprite(blip, Config.Mission.blipSprite)
        SetBlipColour(blip, Config.Mission.blipColour)
        SetBlipRoute(blip, true)
        SetBlipScale(blip, 0.9)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(('📋 %s'):format(mission.label))
        EndTextCommandSetBlipName(blip)

        activeMission = {
            index = mission.index,
            label = mission.label,
            target = mission.coords,
            radius = mission.radius,
            blip = blip,
            deadline = GetGameTimer() + (Config.Mission.timeLimit * 1000),
        }
    end)
end

local function FinishMission(scenario, time)
    ESX.Progressbar('Missiya yerinə yetirilir...', time, {
        FreezePlayer = true,
        animation = { type = 'Scenario', Scenario = scenario },
        onFinish = function()
            local idx = activeMission and activeMission.index

            ESX.TriggerServerCallback('196rp_social:finishMission', function(ok, msg)
                Notify(msg, ok and 'success' or 'error', 8000)
                if ok then
                    EndMission(nil)
                end
            end, idx)
        end,
        onCancel = function()
            Notify('Missiya yarımçıq qaldı.', 'info')
        end,
    })
end

RegisterCommand('missiya', function()
    if activeMission then
        Notify('Artıq aktiv missiyanız var! /missiyadayandır ilə ləğv edin.', 'error')
        return
    end

    StartMission()
end, false)

RegisterCommand('missiyadayandır', function()
    if not activeMission then
        Notify('Aktiv missiya yoxdur.', 'info', 4000)
        return
    end

    ESX.TriggerServerCallback('196rp_social:cancelMission', function()
        EndMission('Missiya ləğv edildi.')
    end)
end, false)

-- ==================== MARKERLƏR ====================

CreateThread(function()
    while true do
        local wait = 750
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        -- Missiya lövhəsi
        local boardDist = #(coords - Config.Mission.board)

        if boardDist < 25.0 then
            wait = 0
            DrawMarker(1, Config.Mission.board.x, Config.Mission.board.y, Config.Mission.board.z - 1.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 0.5, 240, 200, 60, 120, false, true, 2, nil, nil, false)
        end

        if boardDist < Config.Mission.boardDist and not activeMission then
            ESX.TextUI('[E] — Missiya lövhəsi', 'info')
            if IsControlJustPressed(0, 38) then
                ESX.HideUI()
                StartMission()
            end
        end

        -- Toy məkanı
        local venueDist = #(coords - Config.Marriage.venue)

        if venueDist < Config.Marriage.venueDist then
            wait = 0
            DrawMarker(1, Config.Marriage.venue.x, Config.Marriage.venue.y, Config.Marriage.venue.z - 1.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 0.6, 240, 120, 200, 110, false, true, 2, nil, nil, false)

            if venueDist < 2.5 then
                ESX.TextUI('[E] — Toy mərasimi (/toy)', 'info')
                if IsControlJustPressed(0, 38) then
                    ESX.HideUI()

                    ESX.TriggerServerCallback('196rp_social:ceremony', function(ok, msg)
                        Notify(msg, ok and 'success' or 'error', 10000)
                    end)
                end
            end
        end

        -- Aktiv missiya hədəfi
        if activeMission then
            wait = 0

            DrawMarker(1, activeMission.target.x, activeMission.target.y, activeMission.target.z - 1.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                activeMission.radius, activeMission.radius, 1.0, 90, 220, 120, 110, false, true, 2, nil, nil, false)

            if GetGameTimer() > activeMission.deadline then
                EndMission('~r~Missiyanın vaxtı bitdi!~s~')
            elseif #(coords - activeMission.target) < activeMission.radius then
                ESX.TextUI(('[E] — %s'):format(activeMission.label), 'info')

                if IsControlJustPressed(0, 38) then
                    ESX.HideUI()

                    local idx = activeMission.index
                    local m = Config.Missions[idx]

                    if m then
                        FinishMission(m.scenario, m.time)
                    end
                end
            end
        end

        if not activeMission and boardDist >= Config.Mission.boardDist
            and #(coords - Config.Marriage.venue) >= Config.Marriage.venueDist then
            ESX.HideUI()
        end

        Wait(wait)
    end
end)

CreateThread(function()
    local blip = AddBlipForCoord(Config.Mission.board.x, Config.Mission.board.y, Config.Mission.board.z)
    SetBlipSprite(blip, 408)
    SetBlipColour(blip, 5)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, 0.8)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('📋 Missiya lövhəsi')
    EndTextCommandSetBlipName(blip)

    local vblip = AddBlipForCoord(Config.Marriage.venue.x, Config.Marriage.venue.y, Config.Marriage.venue.z)
    SetBlipSprite(vblip, 366)
    SetBlipColour(vblip, 34)
    SetBlipAsShortRange(vblip, true)
    SetBlipScale(vblip, 0.8)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('💍 Toy mərasimi meydanı')
    EndTextCommandSetBlipName(vblip)
end)
