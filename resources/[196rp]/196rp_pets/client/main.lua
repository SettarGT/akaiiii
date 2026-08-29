-- 196 RP | Ev heyvanları — müştəri tərəfi
-- Mağaza, heyvanı çağırma, gəzdirmə, yemləmə, əmrlər

local activePet = nil      -- { id, name, model, species, ped }

-- ==================== KÖMƏKÇİLƏR ====================

local function GetCommandsFor(species)
    return species == 'cat' and Config.CatCommands or Config.DogCommands
end

local function SpawnPet(pet)
    if activePet and DoesEntityExist(activePet.ped) then
        DeleteEntity(activePet.ped)
    end

    local model = GetHashKey(pet.model)
    RequestModel(model)
    local t = 0
    while not HasModelLoaded(model) and t < 100 do
        Wait(50)
        t = t + 1
    end
    if not HasModelLoaded(model) then
        ESX.ShowNotification('Heyvan çağırıla bilmədi!', 'error')
        return
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped) + GetEntityForwardVector(ped) * 1.5

    local animal = CreatePed(28, model, coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
    SetModelAsNoLongerNeeded(model)

    if not animal or animal == 0 then
        return
    end

    SetEntityAsMissionEntity(animal, true, true)
    SetPedCanBeTargetted(animal, false)
    SetPedCanRagdoll(animal, false)
    SetBlockingOfNonTemporaryEvents(animal, false)
    SetPedKeepTask(animal, true)
    SetPedFleeAttributes(animal, 0, false)
    SetEntityInvincible(animal, true)

    activePet = {
        id = pet.id,
        name = pet.name,
        model = pet.model,
        species = pet.species,
        ped = animal
    }

    ESX.ShowNotification(('~g~🐾 %s~s~ yanınızdadır! ~w~/heyvan~s~ ilə əmr verin.'):format(pet.name), 'success')
end

local function FollowPet()
    if not activePet or not DoesEntityExist(activePet.ped) then
        return
    end

    TaskFollowToOffsetOfEntity(activePet.ped, PlayerPedId(), 0.0, -1.2, 0.0, 2.2, -1, 2.0, true)
    ESX.ShowNotification(('~g~%s~s~ dalınızca gəlir.'):format(activePet.name), 'info')
end

local function PlayPetAnim(dict, anim)
    if not activePet or not DoesEntityExist(activePet.ped) then
        return
    end

    ClearPedTasks(activePet.ped)

    if not dict then
        FollowPet()
        return
    end

    RequestAnimDict(dict)
    local t = 0
    while not HasAnimDictLoaded(dict) and t < 60 do
        Wait(50)
        t = t + 1
    end

    TaskPlayAnim(activePet.ped, dict, anim, 3.0, -1, -1, 1, 0, false, false, false)
end

-- ==================== ƏMR MENYUSU ====================

local function OpenPetCommands()
    if not activePet then
        ESX.ShowNotification('Yanınızda heyvan yoxdur! Əvvəlcə çağırın.', 'error')
        return
    end

    local commands = GetCommandsFor(activePet.species)
    local menu = {
        { icon = 'fas fa-paw', title = ('🐾 %s'):format(activePet.name), unselectable = true },
    }

    for i = 1, #commands do
        menu[#menu + 1] = {
            icon = 'fas fa-hand-paper',
            title = commands[i].label,
            name = 'cmd_' .. commands[i].id,
        }
    end

    menu[#menu + 1] = { icon = 'fas fa-utensils', title = 'Yemlə', name = 'feed' }
    menu[#menu + 1] = { icon = 'fas fa-home', title = 'Heyvanı göndər', name = 'dismiss' }

    exports['esx_context']:Open('right', menu, function(selected)
        if selected.name == 'feed' then
            ESX.TriggerServerCallback('196rp_pets:feed', function(ok, msg)
                ESX.ShowNotification(msg, ok and 'success' or 'error')
                if ok and activePet then
                    TaskPlayAnim(activePet.ped, 'creatures@rottweiler@amb@world_dog_barking@base', 'base',
                        3.0, -1, 2500, 1, 0, false, false, false)
                end
            end, activePet.id)
            return
        end

        if selected.name == 'dismiss' then
            if DoesEntityExist(activePet.ped) then
                DeleteEntity(activePet.ped)
            end
            ESX.ShowNotification(('~y~%s~s~ evə göndərildi.'):format(activePet.name), 'info')
            activePet = nil
            return
        end

        local cmdId = selected.name:match('^cmd_(.+)$')
        for i = 1, #commands do
            if commands[i].id == cmdId then
                PlayPetAnim(commands[i].dict, commands[i].anim)
                break
            end
        end
    end)
end

-- ==================== /heyvan MENYUSU ====================

local function OpenPetMenu()
    ESX.TriggerServerCallback('196rp_pets:getMyPets', function(pets)
        local menu = {
            { icon = 'fas fa-paw', title = '🐾 Ev Heyvanlarım', unselectable = true },
        }

        if #pets == 0 then
            menu[#menu + 1] = {
                icon = 'fas fa-store',
                title = 'Heyvanınız yoxdur — mağazadan alın',
                unselectable = true
            }
        else
            for i = 1, #pets do
                local p = pets[i]
                local icon = p.species == 'cat' and '🐱' or '🐶'
                menu[#menu + 1] = {
                    icon = 'fas fa-paw',
                    title = ('%s %s — aclıq ~y~%s%%~s~, sevinc ~y~%s%%~s~')
                        :format(icon, p.name, p.hunger or 0, p.happy or 0),
                    name = 'pet_' .. p.id,
                }
            end
        end

        exports['esx_context']:Open('right', menu, function(selected)
            local petId = tonumber(selected.name:match('^pet_(%d+)$'))
            if not petId then
                return
            end

            local pet = nil
            for i = 1, #pets do
                if pets[i].id == petId then
                    pet = pets[i]
                    break
                end
            end
            if not pet then
                return
            end

            local actions = {
                { icon = 'fas fa-paw', title = pet.name, unselectable = true },
                { icon = 'fas fa-walking', title = 'Çağır və gəzdir', name = 'call' },
                { icon = 'fas fa-utensils', title = 'Yemlə', name = 'feed' },
                { icon = 'fas fa-dollar-sign', title = 'Mağazaya qaytar (sat)', name = 'sell' },
            }

            exports['esx_context']:Open('right', actions, function(sel)
                if sel.name == 'call' then
                    SpawnPet(pet)
                    Wait(800)
                    FollowPet()
                elseif sel.name == 'feed' then
                    ESX.TriggerServerCallback('196rp_pets:feed', function(ok, msg)
                        ESX.ShowNotification(msg, ok and 'success' or 'error')
                    end, petId)
                elseif sel.name == 'sell' then
                    ESX.TriggerServerCallback('196rp_pets:sell', function(ok, msg)
                        ESX.ShowNotification(msg, ok and 'success' or 'error')
                        if ok and activePet and activePet.id == petId then
                            if DoesEntityExist(activePet.ped) then
                                DeleteEntity(activePet.ped)
                            end
                            activePet = nil
                        end
                    end, petId)
                end
            end)
        end)
    end)
end

RegisterCommand('heyvan', function()
    OpenPetMenu()
end, false)

RegisterKeyMapping('heyvan', 'Ev heyvanları menyusu', 'keyboard', '')

-- ==================== MAĞAZA ====================

local function OpenShop()
    ESX.TriggerServerCallback('196rp_pets:getShop', function(animals)
        local menu = {
            { icon = 'fas fa-store', title = '🐾 196 Ev Heyvanları Mağazası', unselectable = true },
        }

        for i = 1, #animals do
            local a = animals[i]
            local icon = a.species == 'cat' and '🐱' or '🐶'
            menu[#menu + 1] = {
                icon = 'fas fa-paw',
                title = ('%s %s — ~g~%s$~s~'):format(icon, a.label, a.price),
                name = 'buy_' .. i,
            }
        end

        exports['esx_context']:Open('right', menu, function(selected)
            local idx = tonumber(selected.name:match('^buy_(%d+)$'))
            if not idx or not animals[idx] then
                return
            end

            local animal = animals[idx]

            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'pet_name', {
                title = ('%s üçün ad yazın:'):format(animal.label)
            }, function(data, dialogMenu)
                dialogMenu.close()
                local name = tostring(data.value or '')

                ESX.TriggerServerCallback('196rp_pets:buy', function(ok, msg)
                    ESX.ShowNotification(msg, ok and 'success' or 'error', 7000)
                end, animal.model, name)
            end, function(data, dialogMenu)
                dialogMenu.close()
            end)
        end)
    end)
end

-- ==================== ƏSAS DÖVRƏ ====================

CreateThread(function()
    -- Mağaza blipi
    local blip = AddBlipForCoord(Config.Shop.coords.x, Config.Shop.coords.y, Config.Shop.coords.z)
    SetBlipSprite(blip, Config.Shop.blip.sprite)
    SetBlipColour(blip, Config.Shop.blip.color)
    SetBlipScale(blip, 0.8)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.Shop.name)
    EndTextCommandSetBlipName(blip)

    while true do
        local wait = 750
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local dist = #(coords - Config.Shop.coords)

        if dist < 30.0 then
            wait = 0
            DrawMarker(1, Config.Shop.coords.x, Config.Shop.coords.y, Config.Shop.coords.z - 1.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.6, 1.6, 0.6, 40, 200, 90, 120, false, true, 2, nil, nil, false)
        end

        if dist < 2.0 then
            ESX.TextUI('[E] — 196 Ev Heyvanları Mağazası', 'info')
            if IsControlJustPressed(0, 38) then
                ESX.HideUI()
                OpenShop()
            end
        end

        if wait == 750 then
            ESX.HideUI()
        end

        Wait(wait)
    end
end)

-- Heyvan dalınızca gəlirsə hər 2 saniyədən bir tapşırığı təzələ
CreateThread(function()
    while true do
        Wait(2000)
        if activePet and DoesEntityExist(activePet.ped) then
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
                -- Maşına mindikdə heyvanı yanınıza teleport et
                local veh = GetVehiclePedIsIn(ped, false)
                local vehCoords = GetEntityCoords(veh)
                if #(GetEntityCoords(activePet.ped) - vehCoords) > 12.0 then
                    SetEntityCoords(activePet.ped, vehCoords.x + 2.0, vehCoords.y, vehCoords.z, false, false, false, false)
                end
            else
                local dist = #(GetEntityCoords(activePet.ped) - GetEntityCoords(ped))
                if dist > 25.0 then
                    local c = GetEntityCoords(ped) + GetEntityForwardVector(ped) * 1.5
                    SetEntityCoords(activePet.ped, c.x, c.y, c.z, false, false, false, false)
                elseif dist > 6.0 then
                    FollowPet()
                end
            end
        end
    end
end)

-- Oyunçu çıxanda heyvanı sil
AddEventHandler('esx:onPlayerLogout', function()
    if activePet and DoesEntityExist(activePet.ped) then
        DeleteEntity(activePet.ped)
    end
    activePet = nil
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then
        return
    end
    if activePet and DoesEntityExist(activePet.ped) then
        DeleteEntity(activePet.ped)
    end
end)

exports('GetActivePet', function()
    return activePet
end)
