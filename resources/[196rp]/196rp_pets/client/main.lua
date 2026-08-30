local QBCore = exports['qb-core']:GetCoreObject()
local pet = nil
local petName = ''

local function OpenShop()
    local menu = {
        { header = '🐾 196 Heyvan Mağazası', isMenuHeader = true, icon = 'fas fa-paw' },
    }
    for _, p in ipairs(Config.Pets) do
        menu[#menu + 1] = {
            header = p.label,
            txt = ('Qiymət: ₣%d'):format(p.price),
            icon = 'fas fa-dog',
            params = { model = p.model },
        }
    end
    exports['qb-menu']:openMenu(menu, function(selected)
        if selected and selected.params and selected.params.model then
            TriggerServerEvent('196rp_pets:server:buy', selected.params.model)
        end
    end)
end

CreateThread(function()
    for _, s in ipairs(Config.Shops) do
        exports['qb-target']:AddBoxZone('196pets_' .. s.label, s.coords, 2.5, 2.5, {
            name = '196pets_' .. s.label, heading = s.heading, debugPoly = false,
            minZ = s.coords.z - 1, maxZ = s.coords.z + 3,
        }, {
            options = { { label = '[E] ' .. s.label, icon = 'fas fa-paw', action = OpenShop } },
            distance = 2.5,
        })
        local blip = AddBlipForCoord(s.coords)
        SetBlipSprite(blip, 442)
        SetBlipColour(blip, 5)
        SetBlipScale(blip, 0.7)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(s.label)
        EndTextCommandSetBlipName(blip)
    end
end)

-- ── Spawn / izlə ──
RegisterNetEvent('196rp_pets:client:spawn', function(model, name)
    if pet and DoesEntityExist(pet) then
        DeleteEntity(pet)
    end
    petName = name or 'Heyvan'
    RequestModel(model)
    local t = 0
    while not HasModelLoaded(model) and t < 100 do
        Wait(20)
        t = t + 1
    end
    if HasModelLoaded(model) then
        local pos = GetEntityCoords(PlayerPedId()) + GetEntityForwardVector(PlayerPedId()) * 2.0
        pet = CreatePed(28, model, pos.x, pos.y, pos.z, GetEntityHeading(PlayerPedId()), true, false)
        SetPedCanRagdoll(pet, false)
        SetEntityInvincible(pet, true)
        QBCore.Functions.Notify(('🐾 %s yanınızda!'):format(petName), 'success')
    end
end)

RegisterNetEvent('196rp_pets:client:despawn', function()
    if pet and DoesEntityExist(pet) then
        DeleteEntity(pet)
    end
    pet = nil
end)

RegisterCommand('heyvan', function()
    TriggerServerEvent('196rp_pets:server:call')
end, false)

RegisterCommand('heyvanqaytar', function()
    TriggerServerEvent('196rp_pets:server:return')
end, false)

RegisterCommand('heyvanbesle', function()
    TriggerServerEvent('196rp_pets:server:feed')
end, false)

RegisterCommand('heyvanad', function(_, args)
    local name = table.concat(args, ' ')
    if name ~= '' then
        TriggerServerEvent('196rp_pets:server:rename', name)
    else
        QBCore.Functions.Notify('İstifadə: /heyvanad <ad>', 'primary')
    end
end, false)

-- İzləmə
CreateThread(function()
    while true do
        Wait(1500)
        if pet and DoesEntityExist(pet) then
            local ped = PlayerPedId()
            local ppos = GetEntityCoords(ped)
            local vpos = GetEntityCoords(pet)
            local dist = #(ppos - vpos)
            if dist > 30 then
                SetEntityCoords(pet, ppos.x + 1.5, ppos.y + 1.5, ppos.z)
            elseif dist > 5 and not IsPedInAnyVehicle(ped, false) then
                local hp = GetEntityHeading(ped)
                local fx, fy = ppos.x - math.sin(math.rad(hp)) * 2.5, ppos.y + math.cos(math.rad(hp)) * 2.5
                TaskGoToCoordAnyMeans(pet, fx, fy, ppos.z, 2.0, 0, 0, 786603, 1.5)
            end
        end
    end
end)
