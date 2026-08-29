-- Admin yardımçı client tərəfi:
-- /tp, /tp2, /goto, /bring və /announce adminlər üçündür

RegisterCommand('goto', function(_, args)
    local target = tonumber(args and args[1])
    if not target then
        ESX.ShowNotification('İstifadə: /goto [id]', 'error')
        return
    end
    TriggerServerEvent('196rp_admin:goto', target)
end, false)

RegisterCommand('bring', function(_, args)
    local target = tonumber(args and args[1])
    if not target then
        ESX.ShowNotification('İstifadə: /bring [id]', 'error')
        return
    end
    TriggerServerEvent('196rp_admin:bring', target)
end, false)

RegisterCommand('tp2', function(_, args)
    local target = tonumber(args and args[1])
    if not target then
        ESX.ShowNotification('İstifadə: /tp2 [id]', 'error')
        return
    end
    TriggerServerEvent('196rp_admin:tp2', target)
end, false)

RegisterNetEvent('196rp_admin:teleport', function(coords, heading)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local entity = vehicle ~= 0 and vehicle or ped
    SetEntityCoords(entity, coords.x, coords.y, coords.z, false, false, false, true)
    if heading then
        SetEntityHeading(entity, heading)
    end
end)
