local QBCore = exports['qb-core']:GetCoreObject()
local stress = 0

RegisterNetEvent('196rp_stress:client:update', function(value)
    stress = tonumber(value) or 0
end)

-- /nəfəs animasiya
RegisterNetEvent('196rp_stress:client:relax', function(seconds)
    local ped = PlayerPedId()
    exports['progressbar']:Progress({
        name = '196relax',
        duration = seconds * 1000,
        label = 'Dərin nəfəs...',
        useWhileDead = false,
        canCancel = false,
        controlDisables = { disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true },
    })
    RequestAnimDict('amb@world_human_yoga@male@base')
    local t = 0
    while not HasAnimDictLoaded('amb@world_human_yoga@male@base') and t < 60 do
        Wait(20)
        t = t + 1
    end
    TaskPlayAnim(ped, 'amb@world_human_yoga@male@base', 'base_b', 3.0, 3.0, -1, 49, 0, false, false, false)
    SetTimeout(seconds * 1000, function()
        ClearPedTasksImmediately(ped)
    end)
end)

-- HUD: stress göstəricisi (kiçik)
CreateThread(function()
    while true do
        Wait(1000)
        if stress >= Config.Stress.WarnThreshold then
            -- ekran effekti (yüngül)
            SetPedMotionBlur(PlayerPedId(), true)
        else
            SetPedMotionBlur(PlayerPedId(), false)
        end
    end
end)
