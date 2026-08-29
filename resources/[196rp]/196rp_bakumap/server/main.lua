-- 196 RP | Bakı xəritəsi — server tərəfi
-- Rayon təyinatı digər resurslar tərəfindən istifadə olunur

local ESX = exports['es_extended']:getSharedObject()

-- Verilmiş koordinatın rayonunu qaytarır
exports('GetDistrict', function(coords)
    if type(coords) ~= 'vector3' then
        return nil
    end

    local station = Baku.District(coords)

    if not station then
        return nil
    end

    return {
        id = station.id,
        name = station.name,
        line = station.line,
        lineName = (Config.Lines[station.line] or {}).name,
    }
end)

-- Ən yaxın stansiyanı qaytarır
exports('GetNearestStation', function(coords)
    if type(coords) ~= 'vector3' then
        return nil
    end

    local station, dist = Baku.Nearest(coords)

    if not station then
        return nil
    end

    return station.id, station.name, dist
end)

-- Bütün stansiyaları qaytarır (xəritə modu dəyişərsə koordinatlar avtomatik yenilənir)
exports('GetStations', function()
    return Config.Stations
end)

-- Oyunçunun hazırkı rayonu
exports('GetPlayerDistrict', function(src)
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return nil
    end

    local ped = GetPlayerPed(src)

    if not ped or ped == 0 then
        return nil
    end

    return exports(GetCurrentResourceName()):GetDistrict(GetEntityCoords(ped))
end)

-- ==================== ƏMR: /harada ====================
-- Qeyd: bu es_extended versiyasında ESX.RegisterCommand yoxdur,
-- ona görə adi RegisterCommand + ESX.GetPlayerFromId istifadə olunur.

RegisterCommand('harada', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        return
    end

    local ped = GetPlayerPed(source)

    if not ped or ped == 0 then
        TriggerClientEvent('esx:showNotification', source, 'Mövqeyiniz müəyyən edilmədi.', 'info')
        return
    end

    local coords = GetEntityCoords(ped)
    local station = Baku.District(coords)

    if not station then
        TriggerClientEvent('esx:showNotification', source, 'Mövqeyiniz müəyyən edilmədi.', 'info')
        return
    end

    local line = Config.Lines[station.line]
    local dist = #(coords - Baku.Coords(station.id))

    TriggerClientEvent('esx:showNotification', source,
        ('📍 ~y~%s~s~ rayonu\n🚇 %s stansiyası (%s m)\n%s'):format(
            station.name, station.name, math.floor(dist), line and line.name or ''), 'info', 10000)
end, false)
