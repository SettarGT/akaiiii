-- 196 RP | Bakı xəritəsi — müştəri tərəfi
-- Metro stansiyaları, rayon bildirişləri, /metro və /xerite

local currentDistrict = nil
local stationBlips = {}

-- ==================== STANSİYA BLİPLƏRİ ====================

CreateThread(function()
    for i = 1, #Config.Stations do
        local s = Config.Stations[i]
        local coords = Baku.Coords(s.id)
        local line = Config.Lines[s.line]

        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, Config.Blip.sprite)
        SetBlipColour(blip, line and line.colour or 0)
        SetBlipScale(blip, Config.Blip.scale)
        SetBlipAsShortRange(blip, Config.Blip.shortRange)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(('🚇 %s (%s)'):format(s.name, line and line.name or ''))
        EndTextCommandSetBlipName(blip)

        stationBlips[#stationBlips + 1] = blip
    end
end)

-- ==================== MARKER + METRO XƏTLƏRİ ====================

CreateThread(function()
    local textShown = false

    while true do
        local wait = Config.Perf.idleWait
        local nearStation = false
        local coords = GetEntityCoords(PlayerPedId())

        for i = 1, #Config.Stations do
            local s = Config.Stations[i]
            local c = Baku.Coords(s.id)
            local dist = #(coords - c)

            if dist < Config.Perf.markerDrawDistance then
                wait = Config.Perf.nearWait
                nearStation = true

                DrawMarker(1, c.x, c.y, c.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    2.5, 2.5, 0.6, 30, 120, 220, 120, false, true, 2, nil, nil, false)

                if dist < 2.0 then
                    local line = Config.Lines[s.line]
                    ESX.TextUI(('🚇 %s stansiyası — %s\n%s'):format(
                        s.name, line and line.name or '', s.desc), 'info')
                    textShown = true
                end

                -- Metro xəttini yalnız yaxınlıqda çəkirik (performans üçün)
                if dist < Config.Perf.lineDrawDistance then
                    local list = Baku.LineStations(s.line)

                    for j = 1, #list - 1 do
                        local a = Baku.Coords(list[j].id)
                        local b = Baku.Coords(list[j + 1].id)

                        if #(coords - a) < Config.Perf.lineDrawDistance
                            and #(coords - b) < Config.Perf.lineDrawDistance then
                            local col = Config.Lines[s.line]
                            DrawLine(a.x, a.y, a.z + 0.3, b.x, b.y, b.z + 0.3,
                                col and col.colour == 1 and 200 or 60,
                                col and col.colour == 3 and 200 or 120,
                                col and col.colour == 7 and 200 or 220, 120)
                        end
                    end
                end
            end
        end

        if not nearStation and textShown then
            ESX.HideUI()
            textShown = false
        end

        Wait(wait)
    end
end)

-- ==================== RAYON BİLDİRİŞİ ====================

CreateThread(function()
    while true do
        Wait(2500)

        if Config.NotifyOnDistrictChange then
            local station = Baku.District(GetEntityCoords(PlayerPedId()))
            local id = station and station.id or nil

            if id ~= currentDistrict then
                currentDistrict = id

                if station then
                    local line = Config.Lines[station.line]
                    ESX.ShowNotification(('📍 ~y~%s~s~ rayonuna xoş gəldiniz\n🚇 %s'):format(
                        station.name, line and line.name or ''), 'info', 6000)
                end
            end
        end
    end
end)

-- ==================== ƏMRLƏR ====================

RegisterCommand('metro', function()
    local station, dist = Baku.Nearest(GetEntityCoords(PlayerPedId()))

    if not station then
        ESX.ShowNotification('Yaxınlıqda stansiya yoxdur.', 'info')
        return
    end

    local line = Config.Lines[station.line]
    local list = Baku.LineStations(station.line)
    local names = {}

    for i = 1, #list do
        names[#names + 1] = list[i].name
    end

    ESX.ShowNotification(('🚇 ~y~%s~s~ stansiyası (%s m)\n%s: %s'):format(
        station.name, math.floor(dist), line and line.name or '',
        table.concat(names, ' → ')), 'info', 12000)
end, false)

-- Qeyd: /xerite əmri artıq interaktiv NUI xəritəsini açır — bax: client/mapui.lua

-- ==================== İXRACLAR ====================

exports('GetCurrentDistrict', function()
    return currentDistrict and Baku.GetStation(currentDistrict) or nil
end)
