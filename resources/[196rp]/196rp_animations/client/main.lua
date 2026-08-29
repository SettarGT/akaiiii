-- 196 RP | Animasiya menyusu
-- /anim əmri ilə açılır: kateqoriya → animasiya seç → oynanır.
-- ESC / hərəkət animasiyanı dayandırır.

-- Əvvəlcədən elan (qarşılıqlı çağırışlar üçün)
local OpenAnimMenu

local playing = false
local currentDict = nil

local function StopAnimation()
    if not playing then
        return
    end
    local ped = PlayerPedId()
    ClearPedTasksImmediately(ped)
    if currentDict then
        RemoveAnimDict(currentDict)
        currentDict = nil
    end
    playing = false
end

exports('StopAnimation', StopAnimation)

-- Hərəkət edəndə animasiyanı dayandır
CreateThread(function()
    while true do
        Wait(500)
        if playing then
            local ped = PlayerPedId()
            if IsPedWalking(ped) or IsPedRunning(ped) or IsPedSprinting(ped) or IsPedJumping(ped) or IsPedFalling(ped) then
                StopAnimation()
            end
        end
    end
end)

-- ESC (BACKSPACE) ilə dayandır
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, Config.CancelKey) and playing then
            StopAnimation()
        end
        Wait(50)
    end
end)

local function PlayItem(item)
    if item.scenario then
        local ped = PlayerPedId()
        TaskStartScenarioInPlace(ped, item.scenario, 0, true)
        playing = true
        return
    end

    local dict = item.dict
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        local tries = 0
        while not HasAnimDictLoaded(dict) and tries < 100 do
            Wait(10)
            tries = tries + 1
        end
    end

    if HasAnimDictLoaded(dict) then
        local ped = PlayerPedId()
        TaskPlayAnim(ped, dict, item.lib, 8.0, -8.0, -1, 1, 0, false, false, false)
        currentDict = dict
        playing = true
    else
        ESX.ShowNotification('Animasiya yüklənə bilmədi!', 'error')
    end
end

-- Kateqoriya menyusunu göstər
local function OpenCategoryMenu()
    local menu = {}
    for i = 1, #Config.Categories do
        local cat = Config.Categories[i]
        menu[#menu + 1] = {
            icon = 'fas fa-angle-right',
            title = cat.label,
            name = cat.name,
        }
    end

    exports['esx_context']:Open('left', menu, function(selected)
        for i = 1, #Config.Categories do
            if Config.Categories[i].name == selected.name then
                OpenAnimMenu(i)
                break
            end
        end
    end)
end

-- Kateqoriyanın animasiyalarını göstər
OpenAnimMenu = function(catIndex)
    local cat = Config.Categories[catIndex]
    local menu = {}
    for j = 1, #cat.items do
        local it = cat.items[j]
        menu[#menu + 1] = {
            icon = 'fas fa-play',
            title = it.label,
            name = tostring(j),
        }
    end
    menu[#menu + 1] = {
        icon = 'fas fa-arrow-left',
        title = '⬅ Geri',
        name = 'back',
    }

    exports['esx_context']:Open('left', menu, function(selected)
        if selected.name == 'back' then
            OpenCategoryMenu()
        else
            local idx = tonumber(selected.name)
            if idx and cat.items[idx] then
                PlayItem(cat.items[idx])
            end
        end
    end)
end

RegisterCommand('anim', function()
    if playing then
        StopAnimation()
        return
    end
    OpenCategoryMenu()
end, false)

RegisterKeyMapping('anim', 'Animasiya menyusu', 'keyboard', 'U')
