local QBCore = exports['qb-core']:GetCoreObject()

local function OpenHospitalMenu()
    local pData = QBCore.Functions.GetPlayerData()
    local dead = pData.metadata.isdead or false
    local insured = tonumber(pData.metadata.insurance or 0) and tonumber(pData.metadata.insurance) > os.time()

    local menu = {
        { header = '🏥 Xəstəxana Qəbulu', isMenuHeader = true, icon = 'fas fa-hospital' },
        { header = '🩺 Sığorta al', txt = string.format('₣%d — 30 gün müalicə pulsuz', Config.Prices.Insurance), icon = 'fas fa-shield-heart', params = { act = 'insurance' } },
        { header = '💊 Müalicə', txt = insured and 'Sığortanız aktiv — pulsuz' or string.format('₣%d', Config.Prices.Heal), icon = 'fas fa-notes-medical', params = { act = 'heal' } },
    }
    if dead then
        menu[#menu + 1] = {
            header = '⚡ AED ilə canlandır',
            txt = string.format('₣%d — yalnız EMS növbətçidə olmayanda', Config.Prices.Revive),
            icon = 'fas fa-bolt',
            params = { act = 'revive' },
        }
    end

    exports['qb-menu']:openMenu(menu, function(selected)
        if not selected or not selected.params then return end
        if selected.params.act == 'insurance' then TriggerServerEvent('196rp_hospital:server:buyInsurance')
        elseif selected.params.act == 'heal' then TriggerServerEvent('196rp_hospital:server:heal')
        elseif selected.params.act == 'revive' then TriggerServerEvent('196rp_hospital:server:revive')
        end
    end)
end

RegisterNetEvent('196rp_hospital:client:heal', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ResetPedVisibleDamage(ped)
    ClearPedBloodDamage(ped)
end)

RegisterNetEvent('196rp_hospital:client:revive', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ResetPedVisibleDamage(ped)
    ClearPedBloodDamage(ped)
    SetPlayerControl(PlayerId(), true, 0)
    ClearPedTasksImmediately(ped)
end)

CreateThread(function()
    for i, loc in ipairs(Config.Locations) do
        local blip = AddBlipForCoord(loc.coords)
        SetBlipSprite(blip, 61)
        SetBlipColour(blip, 2)
        SetBlipScale(blip, 0.9)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(loc.label)
        EndTextCommandSetBlipName(blip)

        exports['qb-target']:AddBoxZone('196hospital_' .. i, loc.coords, 3.0, 3.0, {
            name = '196hospital_' .. i,
            heading = loc.heading,
            debugPoly = false,
            minZ = loc.coords.z - 1,
            maxZ = loc.coords.z + 3,
        }, { options = { { label = '[E] ' .. loc.label .. ' — Qəbul', icon = 'fas fa-hospital-user', action = OpenHospitalMenu } } })
    end
end)
