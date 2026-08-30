local QBCore = exports['qb-core']:GetCoreObject()
local droneFlight = false
local lastUse = 0
local flightCam = nil

local function StartFlight()
    local ped = PlayerPedId()
    local forward = GetEntityForwardVector(ped)
    local pos = GetEntityCoords(ped)
    local startPos = pos + forward * 4.0 + vector3(0, 0, Config.Drone.StartHeight)

    RequestModel(Config.Drone.Model)
    local t = 0
    while not HasModelLoaded(Config.Drone.Model) and t < 80 do
        Wait(20)
        t = t + 1
    end

    local drone = CreateObject(Config.Drone.Model, startPos.x, startPos.y, startPos.z, true, true, true)
    flightCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamActive(flightCam, true)
    RenderScriptCams(true, true, 1000, true, true)

    droneFlight = true
    local elapsed = 0
    local vel = { x = 0, y = 0, z = 0 }
    local playerPos = pos

    CreateThread(function()
        while droneFlight do
            -- İdarəetmə
            local spin = GetEntityHeading(drone)
            local forwardV = GetEntityForwardVector(drone)
            local rightV = GetEntityRightVector(drone)

            if IsControlPressed(0, 32) then vel.x = forwardV.x * Config.Drone.Speed; vel.y = forwardV.y * Config.Drone.Speed end
            if IsControlPressed(0, 33) then vel.x = -forwardV.x * Config.Drone.Speed; vel.y = -forwardV.y * Config.Drone.Speed end
            if IsControlPressed(0, 34) then vel.x = -rightV.x * Config.Drone.Speed; vel.y = -rightV.y * Config.Drone.Speed end
            if IsControlPressed(0, 35) then vel.x = rightV.x * Config.Drone.Speed; vel.y = rightV.y * Config.Drone.Speed end
            if vel.x ~= 0 or vel.y ~= 0 then
                SetEntityVelocity(drone, vel.x, vel.y, vel.z)
            end

            -- Hündürlük: E / Q (33/34 zəif; 32/33 fərqli) — Alt/Space əvəzinə Shift+Ctrl
            if IsControlPressed(0, 36) then -- lctrl
                SetEntityVelocity(drone, 0, 0, Config.Drone.AscendSpeed)
            elseif IsControlPressed(0, 19) then -- alt
                SetEntityVelocity(drone, 0, 0, -Config.Drone.DescendSpeed)
            end

            -- Kameranı drona bağla
            SetCamCoord(flightCam, GetEntityCoords(drone))
            PointCamAtCoord(flightCam, GetEntityCoords(drone).x + forwardV.x * 10, GetEntityCoords(drone).y + forwardV.y * 10, GetEntityCoords(drone).z)

            -- Məsafə yoxlaması
            playerPos = GetEntityCoords(PlayerPedId())
            if #(GetEntityCoords(drone) - playerPos) > Config.Drone.MaxRange then
                EndFlight(false)
                QBCore.Functions.Notify('Dron siqnal diapazonundan çıxdı — avtomatik endi.', 'error')
                break
            end

            -- Batareya
            local battery = Config.Drone.Battery - elapsed
            DrawText3D(GetEntityCoords(drone).x, GetEntityCoords(drone).y, GetEntityCoords(drone).z + 0.5, ('🛸 BATAREYA: %ds'):format(math.max(0, battery)))

            elapsed = elapsed + 1
            if elapsed >= Config.Drone.Battery then
                EndFlight(false)
                QBCore.Functions.Notify('🔋 Batareya bitdi — dron endi.', 'error')
                break
            end
            Wait(1000)
        end
    end)
end

function EndFlight(wasManual)
    droneFlight = false
    lastUse = os.time()
    RenderScriptCams(false, true, 500, true, true)
    if flightCam then
        SetCamActive(flightCam, false)
        DestroyCam(flightCam)
        flightCam = nil
    end
    -- Bütün yaradılmış obyektləri silmək üçün track edirik — sadəcə ən son dronu tap
    for _, obj in ipairs(GetGamePool('CObject')) do
        if GetEntityModel(obj) == GetHashKey(Config.Drone.Model) then
            local dronePos = GetEntityCoords(obj)
            local playerPos = GetEntityCoords(PlayerPedId())
            if #(dronePos - playerPos) < 200 then
                DeleteObject(obj)
                break
            end
        end
    end
end

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextCentre(true)
    SetTextColour(255, 217, 122, 220)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y, z)
end

RegisterCommand('dron', function()
    if droneFlight then
        QBCore.Functions.Notify('Dron artıq havadadır! (/dronendir)', 'primary')
        return
    end
    local now = os.time()
    if lastUse > 0 and (now - lastUse) < Config.Drone.Cooldown then
        QBCore.Functions.Notify(('Batareya doldurulur — %d saniyə.'):format(Config.Drone.Cooldown - (now - lastUse)), 'error')
        return
    end
    StartFlight()
end, false)

RegisterCommand('dronendir', function()
    if droneFlight then
        EndFlight(false)
        QBCore.Functions.Notify('🛸 Dron endirildi.', 'primary')
    end
end, false)
