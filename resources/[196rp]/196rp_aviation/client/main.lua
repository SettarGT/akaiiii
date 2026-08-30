local QBCore = exports['qb-core']:GetCoreObject()
local rentedPlane = nil

local function OpenHangar()
    local pData = QBCore.Functions.GetPlayerData()
    local menu = {
        { header = '✈️ 196 Aviasiya Hangar', isMenuHeader = true, icon = 'fas fa-plane' },
    }
    if not (pData.metadata.drivinglicense or pData.metadata.driving_license) then
        menu[#menu + 1] = { header = '⚠️ Lisenziya tələb olunur', txt = 'Sürücülük lisenziyası — Bələdiyyə (₣1500)', icon = 'fas fa-exclamation', isDisabled = true }
    end
    for _, p in ipairs(Config.Planes) do
        menu[#menu + 1] = {
            header = p.label,
            txt = string.format('İcarə: ₣%d · %d dəq', p.price, math.floor(p.time / 60)),
            icon = 'fas fa-plane-up',
            params = { model = p.model },
        }
    end
    exports['qb-menu']:openMenu(menu, function(selected)
        if selected and selected.params and selected.params.model then
            TriggerServerEvent('196rp_aviation:server:rent', selected.params.model)
        end
    end)
end

RegisterCommand('planqaytar', function()
    TriggerServerEvent('196rp_aviation:server:return')
end, false)

RegisterNetEvent('196rp_aviation:client:spawn', function(model, seconds)
    -- Köhnə varsa sil
    if rentedPlane and DoesEntityExist(rentedPlane) then
        DeleteEntity(rentedPlane)
    end
    RequestModel(model)
    local t = 0
    while not HasModelLoaded(model) and t < 200 do
        Wait(20)
        t = t + 1
    end
    if not HasModelLoaded(model) then
        QBCore.Functions.Notify('Təyyarə modeli yüklənə bilmədi!', 'error')
        return
    end
    local r = Config.Hangar.runway
    rentedPlane = CreateVehicle(model, r.x, r.y, r.z, Config.Hangar.runwayHeading, true, false)
    SetVehicleNumberPlateText(rentedPlane, '196PLT')
    SetVehicleFuelLevel(rentedPlane, 100.0)
    SetEntityHeading(rentedPlane, Config.Hangar.runwayHeading)
    QBCore.Functions.Notify('✈️ Təyyarəniz uçuş zolağındadır!', 'success')
end)

RegisterNetEvent('196rp_aviation:client:despawn', function()
    if rentedPlane and DoesEntityExist(rentedPlane) then
        DeleteEntity(rentedPlane)
    end
    rentedPlane = nil
end)

CreateThread(function()
    local h = Config.Hangar
    local blip = AddBlipForCoord(h.coords)
    SetBlipSprite(blip, 423)
    SetBlipColour(blip, 5)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(h.label)
    EndTextCommandSetBlipName(blip)

    exports['qb-target']:AddBoxZone('196aviation', h.coords, 4.0, 4.0, {
        name = '196aviation', heading = h.heading, debugPoly = false,
        minZ = h.coords.z - 1, maxZ = h.coords.z + 4,
    }, { options = { { label = '[E] ' .. h.label, icon = 'fas fa-plane', action = OpenHangar } } })
end)
