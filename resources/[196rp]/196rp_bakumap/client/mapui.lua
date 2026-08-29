-- 196 RP | Bakı xəritəsi — interaktiv xəritə UI (NUI)
-- Original dizayn: web/index.html + web/css/style.css + web/js/app.js

local isOpen = false

-- Oyun saatı
local function GameClock()
    return string.format('%02d:%02d', GetClockHours(), GetClockMinutes())
end

-- Xəritəyə göndərilən məlumat
local function BuildPayload()
    local stations = {}

    for i = 1, #Config.Stations do
        local s = Config.Stations[i]
        local c = Baku.Coords(s.id)

        stations[#stations + 1] = {
            id = s.id,
            name = s.name,
            line = s.line,
            order = s.order,
            desc = s.desc,
            x = c.x,
            y = c.y,
        }
    end

    local lines = {}

    for id, ln in pairs(Config.Lines) do
        lines[#lines + 1] = { id = id, name = ln.name, colour = ln.colour }
    end

    table.sort(lines, function(a, b) return a.id < b.id end)

    local coords = GetEntityCoords(PlayerPedId())
    local station = Baku.District(coords)

    return {
        stations = stations,
        lines = lines,
        player = { x = coords.x, y = coords.y },
        district = station and station.id or nil,
        clock = GameClock(),
    }
end

local function OpenMap()
    if isOpen then
        return
    end

    isOpen = true

    local data = BuildPayload()
    data.action = 'open'

    SetNuiFocus(true, true)
    SendNUIMessage(data)
end

local function CloseMap()
    if not isOpen then
        return
    end

    isOpen = false

    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

-- Açık ikən oyunçu mövqeyini yeniləyirik (500 ms — xəritə hərəkət edir)
CreateThread(function()
    while true do
        if isOpen then
            local coords = GetEntityCoords(PlayerPedId())
            local station = Baku.District(coords)

            SendNUIMessage({
                action = 'update',
                player = { x = coords.x, y = coords.y },
                district = station and station.id or nil,
                clock = GameClock(),
            })

            -- ESC ilə bağlama
            if IsControlJustReleased(0, 200) then
                CloseMap()
            end

            Wait(500)
        else
            Wait(1000)
        end
    end
end)

-- ƏMR
RegisterCommand('xerite', function()
    if isOpen then
        CloseMap()
    else
        OpenMap()
    end
end, false)

-- NUI-dən bağlanma
RegisterNUICallback('close', function(_, cb)
    CloseMap()
    cb('ok')
end)

-- Resurs dayananda fokusu qaytarırıq (oyunçu ilişib qalmasın)
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    SetNuiFocus(false, false)
    isOpen = false
end)

exports('IsMapOpen', function()
    return isOpen
end)
