local QBCore = exports['qb-core']:GetCoreObject()

local currentScenario = nil
local currentAnim = nil
local currentProp = nil

local function CleanProp()
    if currentProp and DoesEntityExist(currentProp) then
        DeleteObject(currentProp)
    end
    currentProp = nil
end

local function StopCurrent()
    ClearPedTasksImmediately(PlayerPedId())
    currentScenario = nil
    currentAnim = nil
    CleanProp()
end

local function PlayAnimation(anim)
    local ped = PlayerPedId()
    StopCurrent()
    if anim.type == 'scenario' then
        currentScenario = anim.scenario
        TaskStartScenarioInPlace(ped, anim.scenario, 0, true)
        return
    end

    RequestAnimDict(anim.dict)
    local t = 0
    while not HasAnimDictLoaded(anim.dict) and t < 50 do
        Wait(20)
        t = t + 1
    end
    if not HasAnimDictLoaded(anim.dict) then
        QBCore.Functions.Notify('⚠️ Bu animasiya mövcud deyil.', 'error')
        return
    end

    if anim.type == 'prop' and anim.prop then
        RequestModel(anim.prop)
        t = 0
        while not HasModelLoaded(anim.prop) and t < 50 do
            Wait(20)
            t = t + 1
        end
        if HasModelLoaded(anim.prop) then
            local coords = GetEntityCoords(ped)
            currentProp = CreateObject(GetHashKey(anim.prop), coords.x, coords.y, coords.z, true, true, true)
            local off = anim.offset or vector3(0.11, 0.05, -0.02)
            local rot = anim.rot or vector3(0.0, 0.0, 0.0)
            AttachEntityToEntity(currentProp, ped, anim.bone or 28422, off.x, off.y, off.z, rot.x, rot.y, rot.z, false, false, true, false, 2, true)
        end
    end

    currentAnim = anim
    TaskPlayAnim(ped, anim.dict, anim.anim, 8.0, 8.0, -1, 1, 0, false, false, false)
end

local function OpenMenu()
    local menu = {
        { header = 'Animasiya (152+)', isMenuHeader = true, icon = 'fas fa-person-running' },
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
