-- 196 RP | Bələdiyyə işləri — müştəri tərəfi

local active = nil
local activeUntil = 0
local workBlip = nil
local working = false

RegisterNetEvent('196rp_municipal:sync', function(data, untilTime)
    active = data
    activeUntil = untilTime or 0

    if workBlip and DoesBlipExist(workBlip) then
        RemoveBlip(workBlip)
        workBlip = nil
    end

    if not active then
        return
    end

    local work = Config.WorkTypes[active.workId]
    local loc = Config.Locations[active.location]

    workBlip = AddBlipForCoord(loc.coords.x, loc.coords.y, loc.coords.z)
    SetBlipSprite(workBlip, 407)
    SetBlipColour(workBlip, 5)
    SetBlipScale(workBlip, 0.9)
    SetBlipRoute(workBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(('196 Bələdiyyə — %s (%s)'):format(work.label, loc.label))
    EndTextCommandSetBlipName(workBlip)
end)

CreateThread(function()
    while true do
        local wait = 750

        if active and GetPosixTime() < activeUntil then
            local work = Config.WorkTypes[active.workId]
            local loc = Config.Locations[active.location]
            local ped = PlayerPedId()
            local dist = #(GetEntityCoords(ped) - loc.coords)

            if dist < 40.0 then
                wait = 0
                DrawMarker(1, loc.coords.x, loc.coords.y, loc.coords.z - 1.0, 0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0, 2.0, 2.0, 0.6, 255, 190, 30, 120, false, true, 2, nil, nil, false)
            end

            if dist < 2.2 and not working then
                ESX.TextUI(('[E] — %s %s (+%s$)'):format(work.icon, work.label, work.pay), 'info')

                if IsControlJustPressed(0, 38) then
                    ESX.HideUI()
                    working = true

                    ESX.Progressbar(('%s %s görülür...'):format(work.icon, work.label), work.time, {
                        FreezePlayer = true,
                        animation = { type = 'anim', dict = work.anim.dict, lib = work.anim.lib },
                        onFinish = function()
                            ESX.TriggerServerCallback('196rp_municipal:doWork', function(ok, msg)
                                ESX.ShowNotification(msg, ok and 'success' or 'error', 6000)
                                working = false
                            end, active.workId, active.location)
                        end,
                        onCancel = function()
                            working = false
                        end
                    })
                end
            end
        else
            if active and GetPosixTime() >= activeUntil then
                active = nil
                if workBlip and DoesBlipExist(workBlip) then
                    RemoveBlip(workBlip)
                    workBlip = nil
                end
            end
        end

        if wait == 750 then
            ESX.HideUI()
        end

        Wait(wait)
    end
end)
