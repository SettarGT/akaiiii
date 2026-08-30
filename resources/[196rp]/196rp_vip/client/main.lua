local QBCore = exports['qb-core']:GetCoreObject()
local vip = false

RegisterNetEvent('196rp_vip:client:sync', function(data)
    vip = data and data.vip or false
    if vip then
        QBCore.Functions.Notify('⭐ VIP aktivdir — kosmetika, prioritet növbə və xüsusi plitə sizin üçündür!', 'success')
    else
        QBCore.Functions.Notify('VIP-iniz yoxdur — /vip ilə məlumat alın.', 'primary')
    end
end)

-- /vip — status
RegisterCommand('vip', function()
    if vip then
        QBCore.Functions.Notify('⭐ VIP STATUS: Aktiv — /vipplate <plaka> (VIP plitə)', 'success')
    else
        QBCore.Functions.Notify('VIP: admindən alınır (pay-to-win yoxdur — yalnız kosmetika, prioritet növbə, xüsusi plitə).', 'primary')
    end
end, false)

-- /vipplate — cari maşının plitəsini dəyiş (VIP)
RegisterCommand('vipplate', function(_, args)
    if not vip then
        QBCore.Functions.Notify('Bu əmr VIP üçündür!', 'error')
        return
    end
    local plate = table.concat(args, ' ')
    if plate == '' then
        QBCore.Functions.Notify('Düzgün istifadə: /vipplate <plaka>', 'error')
        return
    end
    TriggerServerEvent('196rp_vip:server:plate', plate)
end, false)

RegisterNetEvent('196rp_vip:client:changePlate', function(plate)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        local driver = GetPedInVehicleSeat(veh, -1)
        if driver == ped then
            SetVehicleNumberPlateText(veh, plate)
            QBCore.Functions.Notify(('🚗 Plitə dəyişdirildi: %s'):format(plate), 'success')
            return
        end
    end
    QBCore.Functions.Notify('Sürücü oturacağında olmalısınız!', 'error')
end)
