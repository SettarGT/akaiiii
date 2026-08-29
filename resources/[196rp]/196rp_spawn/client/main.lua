local spawnChosen = false
local isOpen = false

-- Spawn seçim ekranını göstər
local function ShowSpawnSelector()
    if isOpen then
        return
    end
    isOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', spawns = Config.Spawns })
end

local function HideSpawnSelector()
    if not isOpen then
        return
    end
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

-- NUI-dən gələn cavablar
RegisterNUICallback('selectSpawn', function(data, cb)
    cb(1)

    local spawn = nil
    for i = 1, #Config.Spawns do
        if Config.Spawns[i].id == data.id then
            spawn = Config.Spawns[i]
            break
        end
    end

    if not spawn then
        HideSpawnSelector()
        return
    end

    spawnChosen = true
    HideSpawnSelector()

    DoScreenFadeOut(300)
    ESX.SetTimeout(400, function()
        local ped = PlayerPedId()
        SetEntityCoords(ped, spawn.coords.x, spawn.coords.y, spawn.coords.z, false, false, false, true)
        SetEntityHeading(ped, spawn.heading)
        DoScreenFadeIn(600)
        ESX.ShowNotification(('~y~%s~s~ rayonuna xoş gəldiniz!'):format(spawn.name), 'success')
    end)
end)

RegisterNUICallback('close', function(_, cb)
    cb(1)
    HideSpawnSelector()
end)

-- Ekran açıq ikən fokusu qoruyur (başqa NUI fokusu oğurlaya bilər — ESC işləməzdi)
CreateThread(function()
    while true do
        Wait(500)
        if isOpen then
            SetNuiFocus(true, true)
            if IsPauseMenuActive() then
                HideSpawnSelector()
            elseif IsControlJustPressed(0, 200) then
                HideSpawnSelector()
            end
        end
    end
end)

-- İlk spawn olduqda seçim ekranını göstər
local isFirstSpawn = true
AddEventHandler('esx:onPlayerSpawn', function()
    if isFirstSpawn and not spawnChosen then
        isFirstSpawn = false
        ESX.SetTimeout(1500, ShowSpawnSelector)
    end
end)

-- Yenidən girişdə (relog) yenidən göstərilməsi üçün
AddEventHandler('esx:onPlayerLogout', function()
    isFirstSpawn = true
end)

-- Admin komandası: /spawn ilə yenidən açmaq (isteğe bağlı)
RegisterCommand('spawn', function()
    ShowSpawnSelector()
end, false)
