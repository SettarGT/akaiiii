local QBCore = exports['qb-core']:GetCoreObject()

local function OpenUnits(mode)
    local menu = {
        { header = mode == 'rent' and '📦 Anbar İcarəsi' or '📂 Anbarı Aç', isMenuHeader = true, icon = 'fas fa-warehouse' },
    }
    for u = 1, Config.Units do
        menu[#menu + 1] = {
            header = ('Anbar №%d'):format(u),
            txt = mode == 'rent' and ('₣%d / 7 gün · %d slot'):format(Config.RentPrice, Config.Slots) or 'Məzmunu aç',
            icon = mode == 'rent' and 'fas fa-key' or 'fas fa-box-open',
            params = { unit = u, mode = mode },
        }
    end
    exports['qb-menu']:openMenu(menu, function(selected)
        if not selected or not selected.params then return end
        if selected.params.mode == 'rent' then
            TriggerServerEvent('196rp_storage:server:rent', selected.params.unit)
        else
            TriggerServerEvent('196rp_storage:server:open', selected.params.unit)
        end
    end)
end

local function OpenTerminalMenu()
    local menu = {
        { header = '📦 196 Self-Storage', isMenuHeader = true, icon = 'fas fa-warehouse' },
        { header = '🔑 Anbar icarə et', txt = ('₣%d / 7 gün'):format(Config.RentPrice), icon = 'fas fa-key', params = { action = 'rent' } },
        { header = '📂 Anbara bax', txt = 'İcarədə olan anbarınızı açın', icon = 'fas fa-box-open', params = { action = 'open' } },
        { header = '🔨 Storage Wars', txt = 'Kor hərrac — /auk', icon = 'fas fa-gavel', params = { action = 'auction' } },
    }
    exports['qb-menu']:openMenu(menu, function(selected)
        if not selected or not selected.params then return end
        if selected.params.action == 'rent' then
            OpenUnits('rent')
        elseif selected.params.action == 'open' then
            OpenUnits('open')
        else
            TriggerServerEvent('196rp_storage:server:auctionRequest')
        end
    end)
end

-- ── Kiosk obyekti + blip ──
CreateThread(function()
    local kiosk = Config.Kiosk
    local blip = AddBlipForCoord(kiosk.coords)
    SetBlipSprite(blip, 478)
    SetBlipColour(blip, 47)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('196 Self-Storage')
    EndTextCommandSetBlipName(blip)

    local kioskEntity = CreateObject(GetHashKey(kiosk.prop), kiosk.coords.x, kiosk.coords.y, kiosk.coords.z, true, true, false)
    SetEntityHeading(kioskEntity, kiosk.heading)
    FreezeEntityPosition(kioskEntity, true)

    exports['qb-target']:AddTargetEntity(kioskEntity, {
        options = {
            { label = '[E] ' .. kiosk.label, icon = 'fas fa-warehouse', action = OpenTerminalMenu },
        },
        distance = 2.5,
    })
end)

-- ── Hərrac NUI ──
local auctionOpen = false

RegisterNetEvent('196rp_storage:client:auction', function(data)
    auctionOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', data = data })
end)

RegisterNetEvent('196rp_storage:client:update', function(data)
    SendNUIMessage({ action = 'update', data = data })
end)

RegisterNetEvent('196rp_storage:client:auctionEnd', function()
    auctionOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end)

RegisterNUICallback('bid', function(data, cb)
    TriggerServerEvent('196rp_storage:server:bid', tonumber(data.amount))
    cb({})
    return true
end)

RegisterNUICallback('close', function(_, cb)
    auctionOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    cb({})
    return true
end)
