local QBCore = exports['qb-core']:GetCoreObject()
local busy = false

local function DrawText3D(coords, text)
    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 217, 122, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(coords.x, coords.y, coords.z)
end

local function DoWork(zone)
    if busy then return end
    busy = true
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)

    local eff = Config.Effects[zone.id] or {}
    if eff.anim then
        RequestAnimDict(eff.anim)
        local t = 0
        while not HasAnimDictLoaded(eff.anim) and t < 50 do
            Wait(20)
            t = t + 1
        end
        if HasAnimDictLoaded(eff.anim) then
            TaskPlayAnim(ped, eff.anim, eff.animName or 'base', 3.0, 3.0, -1, 1, 0, false, false, false)
        end
    end

    QBCore.Functions.Progressbar('196prison_' .. zone.id, 'İşlənir...', Config.WorkTime * 1000, false, true, {
        disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true,
    }, {}, {}, {}, function()
        ClearPedTasksImmediately(ped)
        FreezeEntityPosition(ped, false)
        busy = false
        TriggerServerEvent('196rp_prison:server:work', zone.id)
    end, function()
        ClearPedTasksImmediately(ped)
        FreezeEntityPosition(ped, false)
        busy = false
    end)
end

CreateThread(function()
    while true do
        Wait(1000)
        if not busy then
            local meta = QBCore.Functions.GetPlayerData().metadata
            if (tonumber(meta.injail) or 0) > 0 then
                local pos = GetEntityCoords(PlayerPedId())
                for _, zone in ipairs(Config.WorkZones) do
                    if #(pos - zone.coords) < 3.5 then
                        DrawText3D(zone.coords + vector3(0, 0, 1.3), zone.label .. '\n[E] İşlə (-' .. (Config.Effects[zone.id] and Config.Effects[zone.id].seconds or 30) .. ' san)')
                        if IsControlJustReleased(0, 38) then
                            DoWork(zone)
                            break
                        end
                    end
                end
            end
        end
    end
end)
