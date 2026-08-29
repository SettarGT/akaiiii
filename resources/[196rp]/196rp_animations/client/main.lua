local QBCore = exports['qb-core']:GetCoreObject()

local currentScenario = nil
local currentAnim = nil

local function StopCurrent()
    if currentScenario then
        for _, scenario in ipairs(Config.CancelAnims) do
            if scenario == currentScenario then
                ClearPedTasksImmediately(PlayerPedId())
                break
            end
        end
        currentScenario = nil
    end
    if currentAnim then
        ClearPedTasksImmediately(PlayerPedId())
        currentAnim = nil
    end
end

local function PlayAnimation(anim)
    local ped = PlayerPedId()
    StopCurrent()
    if anim.type == 'scenario' then
        currentScenario = anim.scenario
        TaskStartScenarioInPlace(ped, anim.scenario, 0, true)
    else
        currentAnim = anim
        RequestAnimDict(anim.dict)
        while not HasAnimDictLoaded(anim.dict) do
            Wait(10)
        end
        TaskPlayAnim(ped, anim.dict, anim.anim, 8.0, 8.0, -1, 1, 0, false, false, false)
    end
end

local function OpenMenu()
    local menu = {
        { header = 'Animasiya', isMenuHeader = true, icon = 'fas fa-person-running' },
        { header = 'Animasiyanı dayandır', icon = 'fas fa-ban', txt = 'Cari animasiyanı ləğv et', params = { stop = true } },
    }
    for i, anim in ipairs(Config.Animations) do
        menu[#menu + 1] = {
            header = anim.label,
            icon = 'fas fa-person-walking',
            params = { index = i },
        }
    end
    exports['qb-menu']:openMenu(menu, function(selected)
        if not selected then return end
        if selected.params and selected.params.stop then
            StopCurrent()
            return
        end
        if selected.params and selected.params.index then
            PlayAnimation(Config.Animations[selected.params.index])
        end
    end)
end

RegisterCommand('anim', function()
    OpenMenu()
end, false)

RegisterKeyMapping('anim', 'Animasiya menyusu', 'keyboard', 'U')

CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, Config.Key) then
            OpenMenu()
        end
    end
end)
