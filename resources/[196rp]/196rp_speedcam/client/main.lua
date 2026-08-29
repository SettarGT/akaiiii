-- 196 RP | Sürət kameraları — müştəri tərəfi
-- Kameraya 100 m qalmış: xəritədə işarə + bildiriş + səs

local warned = {}       -- [kamera indeksi] = true (bu keçiddə xəbərdarlıq verilib)
local camBlips = {}     -- [kamera indeksi] = { base = blip, warn = blip }
local currentZone = nil

-- ==================== KAMERA BLİPLƏRİ ====================

CreateThread(function()
    for i = 1, #Config.Cameras do
        local cam = Config.Cameras[i]

        local blip = AddBlipForCoord(cam.coords.x, cam.coords.y, cam.coords.z)
        SetBlipSprite(blip, 184)
        SetBlipColour(blip, 1)
        SetBlipScale(blip, 0.6)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(('Sürət kamerası — %s km/s (%s)'):format(cam.limit, cam.name))
        EndTextCommandSetBlipName(blip)

        camBlips[i] = { base = blip, warn = nil }
    end
end)

local function ShowWarnBlip(index)
    local cam = Config.Cameras[index]
    if camBlips[index].warn and DoesBlipExist(camBlips[index].warn) then
        return
    end

    local blip = AddBlipForCoord(cam.coords.x, cam.coords.y, cam.coords.z)
    SetBlipSprite(blip, 184)
    SetBlipColour(blip, 5)
    SetBlipScale(blip, 1.1)
    SetBlipFlashes(blip, true)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(('⚠ QARŞIDA KAMERA — %s km/s'):format(cam.limit))
    EndTextCommandSetBlipName(blip)

    camBlips[index].warn = blip
end

local function HideWarnBlip(index)
    local w = camBlips[index] and camBlips[index].warn
    if w and DoesBlipExist(w) then
        RemoveBlip(w)
    end
    if camBlips[index] then
        camBlips[index].warn = nil
    end
end

-- ==================== ƏSAS DÖVRƏ ====================

CreateThread(function()
    while true do
        local wait = 500
        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped, false) then
            wait = 200
            local veh = GetVehiclePedIsIn(ped, false)
            local vehCoords = GetEntityCoords(veh)
            local speedKmh = math.floor(GetEntitySpeed(veh) * 3.6)
            local forward = GetEntityForwardVector(veh)

            for i = 1, #Config.Cameras do
                local cam = Config.Cameras[i]
                local toCam = cam.coords - vehCoords
                local dist = #toCam

                if dist < 250.0 then
                    -- Kamera qarşıdadırmı? (istiqamət vektoru ilə)
                    local dirX, dirY = toCam.x / dist, toCam.y / dist
                    local dot = (forward.x * dirX) + (forward.y * dirY)

                    if dot > 0.80 then
                        -- 100 metr qalıb — xəbərdarlıq
                        if dist <= Config.WarnDistance and dist > 12.0 and not warned[i] then
                            warned[i] = true
                            ShowWarnBlip(i)

                            PlaySoundFrontend(-1, 'Event_Start_Text', 'GTAO_FM_Events_Soundset', true)

                            ESX.ShowNotification(
                                ('~r~⚠ QARŞIDA SÜRƏT KAMERASI!~s~\n%s — limit ~y~%s km/s~s~\nSizin sürət: ~w~%s km/s~s~')
                                    :format(cam.name, cam.limit, speedKmh), 'warning', 6000)
                        end

                        -- Kameranın yanından keçid
                        if dist < 12.0 and warned[i] then
                            if speedKmh > cam.limit then
                                ESX.TriggerServerCallback('196rp_speedcam:fine', function(paid, msg)
                                    if msg then
                                        ESX.ShowNotification(msg, paid and 'error' or 'warning', 8000)
                                    end
                                end, cam.name, cam.limit, speedKmh)
                            else
                                ESX.ShowNotification(('~g~Kamera keçildi~s~ (%s km/s — limit %s)')
                                    :format(speedKmh, cam.limit), 'success', 2500)
                            end

                            warned[i] = nil
                            HideWarnBlip(i)
                        end
                    elseif dist > 160.0 then
                        warned[i] = nil
                        HideWarnBlip(i)
                    end
                else
                    warned[i] = nil
                    HideWarnBlip(i)
                end
            end

            -- Sürət həddi zonaları (yol nişanları)
            local zone = nil
            for i = 1, #Config.SpeedZones do
                local z = Config.SpeedZones[i]
                if #(vehCoords - z.coords) <= z.radius then
                    if not zone or #(vehCoords - z.coords) < #(vehCoords - zone.coords) then
                        zone = z
                    end
                end
            end

            if zone and currentZone ~= zone.label then
                currentZone = zone.label
                ESX.ShowNotification(('~y~🚸 Yol nişanı:~s~ %s — sürət həddi ~w~%s km/s~s~')
                    :format(zone.label, zone.limit), 'info', 5000)
            elseif not zone then
                currentZone = nil
            end
        else
            -- Piyadaykən xəbərdarlıqları sıfırla
            for i in pairs(warned) do
                warned[i] = nil
                HideWarnBlip(i)
            end
        end

        Wait(wait)
    end
end)
