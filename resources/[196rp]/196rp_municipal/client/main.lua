local QBCore = exports['qb-core']:GetCoreObject()
local menuOpen = false
local examOpen = false
local practical = false
local blips = {}

-- ═══════════════════════════════════════════════════════════════
-- Blip-lər
-- ═══════════════════════════════════════════════════════════════

CreateThread(function()
    for _, office in ipairs(Config.Offices) do
        local b = AddBlipForCoord(office.coords.x, office.coords.y, office.coords.z)
        SetBlipSprite(b, office.sprite)
        SetBlipColour(b, office.color)
        SetBlipScale(b, office.scale)
        SetBlipAsShortRange(b, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(office.label)
        EndTextCommandSetBlipName(b)
        table.insert(blips, b)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- Bələdiyyə markeri + menyu
-- ═══════════════════════════════════════════════════════════════

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local dist = 999
        local closest = nil
        for _, office in ipairs(Config.Offices) do
            local d = #(GetEntityCoords(ped) - office.coords)
            if d < dist then dist = d; closest = office end
        end
        if closest and dist < 3.0 and not menuOpen and not examOpen then
            DrawMarker(1, closest.coords.x, closest.coords.y, closest.coords.z - 1.0, 0, 0, 0, 0, 0, 0, 1.6, 1.6, 0.8, 247, 183, 51, 150, false, true, 2, false, nil, nil, false)
            DrawText3D(closest.coords.x, closest.coords.y, closest.coords.z + 0.3, '[E] Bələdiyyə xidmətləri')
            if IsControlJustReleased(0, 38) then
                OpenMenu()
            end
        end
        Wait(dist < 20 and 0 or 500)
    end
end)

function OpenMenu()
    menuOpen = true
    local menu = {
        {
            header = '🏛️ Bələdiyyə — 196 RP',
            icon = 'city',
            isMenuHeader = true,
        },
        {
            header = Config.Actions.passport.label,
            txt = Config.Actions.passport.desc .. ' | Qiymət: ₣' .. Config.Actions.passport.price,
            icon = 'id-card',
            params = { event = '196rp_municipal:server:getPassport' },
        },
        {
            header = Config.Actions.driver.label,
            txt = Config.Actions.driver.desc .. ' | Qiymət: ₣' .. Config.Actions.driver.price,
            icon = 'car-side',
            params = { event = '196rp_municipal:server:startDriving' },
        },
        {
            header = Config.Actions.weapon.label,
            txt = Config.Actions.weapon.desc .. ' | Qiymət: ₣' .. Config.Actions.weapon.price,
            icon = 'gun',
            params = { event = '196rp_municipal:server:getWeaponLicense' },
        },
        {
            header = '✖ Bağla',
            icon = 'xmark',
            params = { event = '196rp_municipal:client:closeMenu' },
        },
    }
    exports['qb-menu']:openMenu(menu)
end

RegisterNetEvent('196rp_municipal:client:closeMenu', function()
    menuOpen = false
    exports['qb-menu']:closeMenu()
end)

-- ═══════════════════════════════════════════════════════════════
-- NƏZƏRİ İMTAHAN (NUI)
-- ═══════════════════════════════════════════════════════════════

RegisterNetEvent('196rp_municipal:client:exam', function(data)
    menuOpen = false
    exports['qb-menu']:closeMenu()
    examOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'exam',
        data = { questions = data.questions, title = '🚗 Sürücülük Nəzəri İmtahanı — 196 RP' },
    })
end)

RegisterNUICallback('examSubmit', function(data, cb)
    TriggerServerEvent('196rp_municipal:server:examResult', data.answers)
    examOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hide', data = {} })
    cb({})
end)

RegisterNUICallback('examClose', function(_, cb)
    examOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hide', data = {} })
    QBCore.Functions.Notify('İmtahan ləğv edildi.', 'error')
    cb({})
end)

-- ═══════════════════════════════════════════════════════════════
-- PRAKTİK MARŞRUT (checkpoints)
-- ═══════════════════════════════════════════════════════════════

RegisterNetEvent('196rp_municipal:client:practical', function(data)
    practical = true
    local started = GetGameTimer()
    local next = 1

    -- Sürücülük vəsiqəsi verilən yerdən (bələdiyyə qarşısı) marşrut
    QBCore.Functions.Notify('🚗 Praktik imtahan başladı! Xəritədəki nöqtələrə get (3 nöqtə).', 'primary')

    CreateThread(function()
        while practical do
            local ped = PlayerPedId()
            -- Müddət bitdi?
            if (GetGameTimer() - started) > data.duration * 1000 then
                practical = false
                TriggerServerEvent('196rp_municipal:server:practicalResult', false)
                QBCore.Functions.Notify('⏰ Vaxt bitdi! İmtahan uğursuz.', 'error')
                return
            end

            if next > #data.route then
                practical = false
                TriggerServerEvent('196rp_municipal:server:practicalResult', true)
                QBCore.Functions.Notify('✅ Bütün nöqtələr tamamlandı!', 'success')
                return
            end

            local point = data.route[next]
            local dist = #(GetEntityCoords(ped) - point.coords)

            DrawMarker(1, point.coords.x, point.coords.y, point.coords.z - 1.0, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 1.0, 0, 255, 100, 180, false, true, 2, false, nil, nil, false)
            DrawText3D(point.coords.x, point.coords.y, point.coords.z + 0.3, point.label)

            if dist < 7.0 then
                QBCore.Functions.Notify(('✅ %s keçildi!'):format(point.label), 'success')
                next = next + 1
                -- Xəritədə növbəti nöqtə
                if next <= #data.route then
                    SetNewWaypoint(data.route[next].coords.x, data.route[next].coords.y)
                else
                    SetNewWaypoint(0.0, 0.0)
                end
            end
            Wait(0)
        end
    end)
end)

-- ═══════════════════════════════════════════════════════════════
-- PASPORT NUI kart
-- ═══════════════════════════════════════════════════════════════

RegisterNetEvent('196rp_municipal:client:card', function(data)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'card', data = data })
end)

RegisterNUICallback('cardClose', function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hide', data = {} })
    cb({})
end)

-- ═══════════════════════════════════════════════════════════════
-- Yardımçılar
-- ═══════════════════════════════════════════════════════════════

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    AddTextComponentString(text)
    SetTextCentre(true)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end
