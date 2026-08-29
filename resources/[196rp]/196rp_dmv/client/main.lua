-- 196 RP | Sürücülük məktəbi — müştəri tərəfi

local hasLicense = false
local licenseChecked = false
local drivingTest = false
local testVeh = 0
local theoryStep = 0
local theoryAnswers = {}
local theoryCorrect = 0
local lastWarnTime = 0

-- Vəsiqə vəziyyətini öyrən
local function CheckLicense()
    ESX.TriggerServerCallback('196rp_dmv:hasLicense', function(has)
        hasLicense = has
        licenseChecked = true
    end)
end

AddEventHandler('esx:playerLoaded', function()
    licenseChecked = false
    drivingTest = false
    CheckLicense()
end)

CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(200) end
    CheckLicense()
end)

-- Blip
CreateThread(function()
    local blip = AddBlipForCoord(Config.DMV.coords.x, Config.DMV.coords.y, Config.DMV.coords.z)
    SetBlipSprite(blip, Config.DMV.blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.85)
    SetBlipColour(blip, Config.DMV.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.DMV.label)
    EndTextCommandSetBlipName(blip)
end)

-- Marker + interaksiya
CreateThread(function()
    while true do
        local wait = 750
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local dist = #(coords - Config.DMV.coords)

        if dist < 50.0 then
            wait = 0
            DrawMarker(27, Config.DMV.coords.x, Config.DMV.coords.y, Config.DMV.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                1.2, 1.2, 0.6, 66, 135, 245, 170, false, true, 2, nil, nil, false)
        end

        if dist < 2.2 then
            ESX.TextUI('[E] — Sürücülük Məktəbi', 'info')
            if IsControlJustPressed(0, 38) then
                OpenDMVMenu()
            end
        else
            ESX.HideUI()
        end

        Wait(wait)
    end
end)

function OpenDMVMenu()
    local menu = {
        {
            icon = 'fas fa-id-card',
            title = hasLicense and '✅ Sürücülük vəsiqəniz var' or '❌ Sürücülük vəsiqəniz yoxdur',
            unselectable = true,
        },
    }

    if not hasLicense then
        menu[#menu + 1] = {
            icon = 'fas fa-file-alt',
            title = '📝 Yazılı imtahan (~g~$' .. Config.TheoryCost .. '~s~)',
            description = '8 sual — ən azı 6 düzgün cavab tələb olunur',
            name = 'theory',
        }
        menu[#menu + 1] = {
            icon = 'fas fa-car',
            title = '🚗 Sürmə imtahanı (~g~$' .. Config.DrivingCost .. '~s~)',
            description = 'Yoldakı 8 yoxlama nöqtəsini keçin',
            name = 'driving',
        }
    else
        menu[#menu + 1] = {
            icon = 'fas fa-check-circle',
            title = 'Vəsiqəniz artıq qeydiyyatdadır',
            description = 'Sürücülük vəsiqəsi yenilənmə tələb etmir',
            unselectable = true,
        }
    end

    exports['esx_context']:Open('right', menu, function(selected)
        if selected.name == 'theory' then
            StartTheoryExam()
        elseif selected.name == 'driving' then
            StartDrivingTest()
        end
    end)
end

-- ==================== YAZILI İMTAHAN ====================

local function AskQuestion()
    theoryStep = theoryStep + 1
    local q = Config.Questions[theoryStep]
    if not q then
        FinishTheoryExam()
        return
    end

    local menu = {
        { icon = 'fas fa-question-circle', title = ('Sual %s/%s'):format(theoryStep, #Config.Questions), unselectable = true },
        { icon = 'fas fa-info', title = q.q, unselectable = true },
    }
    for i = 1, #q.options do
        menu[#menu + 1] = {
            icon = i == q.answer and 'fas fa-circle' or 'fas fa-circle-o',
            title = q.options[i],
            name = tostring(i),
        }
    end

    exports['esx_context']:Open('center', menu, function(selected)
        theoryAnswers[theoryStep] = tonumber(selected.name)
        AskQuestion()
    end)
end

local function StartTheoryExam()
    theoryStep = 0
    theoryAnswers = {}
    theoryCorrect = 0
    ESX.ShowNotification('Yazılı imtahan başlayır! Diqqətli olun.', 'info', 4000)
    AskQuestion()
end

local function FinishTheoryExam()
    ESX.TriggerServerCallback('196rp_dmv:submitExam', function(passed, correct)
        theoryCorrect = correct
        if passed then
            ESX.ShowNotification(('~g~İmtahandan keçdiniz! (%s/%s düzgün)~s~'):format(correct, #Config.Questions), 'success', 6000)
            ESX.ShowNotification('İndi sürmə imtahanına keçin!', 'info', 5000)
        else
            ESX.ShowNotification(('~r~İmtahan keçilmədi. (%s/%s düzgün)~s~'):format(correct, #Config.Questions), 'error', 6000)
        end
    end, theoryAnswers)
end

-- ==================== SÜRMƏ İMTAHANI ====================

function StartDrivingTest()
    ESX.TriggerServerCallback('196rp_dmv:startDrivingTest', function(netId)
        if not netId then
            ESX.ShowNotification('Pulunuz kifayət deyil! (~y~$' .. Config.DrivingCost .. '~s~)', 'error')
            return
        end

        drivingTest = true
        testVeh = NetToVeh(netId)
        local tries = 0
        while not DoesEntityExist(testVeh) and tries < 50 do
            Wait(50)
            testVeh = NetToVeh(netId)
            tries = tries + 1
        end

        if DoesEntityExist(testVeh) then
            TaskWarpPedIntoVehicle(PlayerPedId(), testVeh, -1)
            ESX.ShowNotification('Sürmə imtahanı başladı! Bütün yoxlama nöqtələrini keçin.', 'info', 6000)
        end
    end)
end

-- Yoxlama nöqtələri
CreateThread(function()
    while true do
        local wait = 750
        if drivingTest and DoesEntityExist(testVeh) then
            wait = 0
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local inVehicle = IsPedInVehicle(ped, testVeh, false)

            for i = 1, #Config.Checkpoints do
                local cp = Config.Checkpoints[i]
                local dist = #(coords - cp)
                if dist < 60.0 then
                    DrawMarker(1, cp.x, cp.y, cp.z - 1.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                        4.0, 4.0, 0.6, 255, 190, 60, 140, false, true, 2, nil, nil, false)
                end
                if dist < 12.0 and inVehicle then
                    TriggerServerEvent('196rp_dmv:checkpoint', i, coords.x, coords.y, coords.z)
                end
            end

            -- İmtahanı bitir (son nöqtəyə çatdıqdan sonra avtomobildən düş)
            local lastCp = Config.Checkpoints[#Config.Checkpoints]
            local lastDist = #(coords - lastCp)
            if lastDist < 8.0 and not IsPedInAnyVehicle(ped, false) then
                FinishDrivingTest()
            end
        end
        Wait(wait)
    end
end)

local function FinishDrivingTest()
    if not drivingTest then return end
    drivingTest = false

    ESX.TriggerServerCallback('196rp_dmv:finishDrivingTest', function(passed)
        if passed then
            hasLicense = true
            ESX.ShowNotification('~g~Sürmə imtahanından keçdiniz! Sürücülük vəsiqəniz verildi!~s~', 'success', 7000)
            ESX.ShowNotification('🎉 Artıq rəsmi sürücüsünüz!', 'success', 5000)
        else
            ESX.ShowNotification('~r~Sürmə imtahanı keçilmədi. Bütün nöqtələri keçməlisiniz!~s~', 'error', 6000)
        end
    end)

    if DoesEntityExist(testVeh) then
        ESX.Game.DeleteVehicle(testVeh)
    end
    testVeh = 0
end

-- ==================== VƏSİQƏSİZ SÜRMƏ XƏBƏRDARLIĞI ====================

CreateThread(function()
    while true do
        Wait(15000)
        if licenseChecked and not hasLicense then
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) and IsVehicleDrivable(GetVehiclePedIsIn(ped, false)) then
                local speed = GetEntitySpeed(GetVehiclePedIsIn(ped, false)) * 3.6
                if speed > 10 and GetGameTimer() - lastWarnTime > 20000 then
                    lastWarnTime = GetGameTimer()
                    ESX.ShowNotification('~r~Diqqət!~s~ Sürücülük vəsiqəniz yoxdur! Polis cərimə edə bilər.', 'warning', 6000)
                end
            end
        end
    end
end)

-- Polis üçün: hədəf oyunçunun vəsiqəsini yoxla
exports('HasLicense', function()
    return hasLicense
end)
