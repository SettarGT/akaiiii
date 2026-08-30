local QBCore = exports['qb-core']:GetCoreObject()

local menuOpen = false
local currentVehicle = nil
local actionId = 1

-- ═══════════════════════════════════════════════════════════════
-- Menyu aç/bağla
-- ═══════════════════════════════════════════════════════════════

local function GetCurrentVehicle()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        return GetVehiclePedIsIn(ped, false)
    end
    return nil
end

local function RefreshMenu()
    if not currentVehicle then return end
    local plate = QBCore.Functions.GetPlate(currentVehicle)
    local engine = GetIsVehicleEngineRunning(currentVehicle)
    local locked = GetVehicleDoorLockStatus(currentVehicle) >= 1
    SendNUIMessage({
        action = 'refresh',
        data = {
            plate = plate,
            engine = engine,
            locked = locked,
            inVehicle = IsPedInAnyVehicle(PlayerPedId(), false),
        },
    })
end

local function OpenMenu()
    currentVehicle = GetCurrentVehicle()
    if not currentVehicle then
        QBCore.Functions.Notify('Maşın içində deyilsiniz.', 'error')
        return
    end
    menuOpen = true
    SetNuiFocus(true, true)
    RefreshMenu()
    SendNUIMessage({ action = 'open', data = {} })
end

local function CloseMenu()
    menuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close', data = {} })
end

-- ═══════════════════════════════════════════════════════════════
-- Düymə bağlaması
-- ═══════════════════════════════════════════════════════════════

RegisterCommand('vehicleui', function()
    if menuOpen then CloseMenu() else OpenMenu() end
end, false)

RegisterKeyMapping('vehicleui', 'Avtomobil Radiyal Menyu (F5)', 'keyboard', Config.Keybind)

-- ═══════════════════════════════════════════════════════════════
-- Fəaliyyətlər
-- ═══════════════════════════════════════════════════════════════

local function GetVehicleDriver(veh)
    if GetPedInVehicleSeat(veh, -1) == PlayerPedId() then return true end
    return false
end

local Actions = {
    -- Mühərrik
    engine = function(veh)
        if not GetVehicleDriver(veh) then QBCore.Functions.Notify('Yalnız sürücü!', 'error') return end
        local on = GetIsVehicleEngineRunning(veh)
        SetVehicleEngineOn(veh, not on, false, true)
        RefreshMenu()
    end,
    -- Kilid
    lock = function(veh)
        if not GetVehicleDriver(veh) then QBCore.Functions.Notify('Yalnız sürücü!', 'error') return end
        local locked = GetVehicleDoorLockStatus(veh) >= 1
        if locked then
            SetVehicleDoorsLocked(veh, 1)
            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 1)
            QBCore.Functions.Notify('🚪 Qapılar kilidləndi.', 'success')
        else
            SetVehicleDoorsLocked(veh, 2)
            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 2)
            QBCore.Functions.Notify('🔓 Qapılar açıldı.', 'success')
        end
        RefreshMenu()
    end,
    -- Bütün qapılar
    doors = function(veh)
        local open = false
        for i = 0, 3 do
            if GetVehicleDoorAngleRatio(veh, i) > 0.05 then open = true break end
        end
        for _, door in ipairs({0, 1, 2, 3}) do
            if open then
                SetVehicleDoorShut(veh, door, false)
            else
                SetVehicleDoorOpen(veh, door, false, false)
            end
        end
        RefreshMenu()
    end,
    -- Sərnişin qapıları
    passenger = function(veh)
        local open = GetVehicleDoorAngleRatio(veh, 1) > 0.05
        for _, door in ipairs({1, 2}) do
            if open then SetVehicleDoorShut(veh, door, false) else SetVehicleDoorOpen(veh, door, false, false) end
        end
        RefreshMenu()
    end,
    -- Baqaj
    trunk = function(veh)
        local open = GetVehicleDoorAngleRatio(veh, 5) > 0.05
        if open then SetVehicleDoorShut(veh, 5, false) else SetVehicleDoorOpen(veh, 5, false, false) end
        RefreshMenu()
    end,
    -- Kapot
    hood = function(veh)
        local open = GetVehicleDoorAngleRatio(veh, 4) > 0.05
        if open then SetVehicleDoorShut(veh, 4, false) else SetVehicleDoorOpen(veh, 4, false, false) end
        RefreshMenu()
    end,
    -- Pəncərələr (hamısı)
    windows = function(veh)
        local closed = GetVehicleWindowTint(veh)
        if closed > 0 then
            for i = 0, 5 do RollDownWindow(veh, i) end
        else
            for i = 0, 5 do RollUpWindow(veh, i) end
        end
        RefreshMenu()
    end,
    -- Farlar
    lights = function(veh)
        local mode = GetVehicleLightsState(veh) ~= 0 and 1 or 4
        SetVehicleLights(veh, mode)
        SetVehicleLightsMode(veh, mode)
        RefreshMenu()
    end,
    -- Əlavə işıqlar
    extra = function(veh)
        local on = GetVehicleExtraLights(veh) > 0
        SetVehicleExtraLights(veh, on and 0 or 1)
        RefreshMenu()
    end,
}

-- ═══════════════════════════════════════════════════════════════
-- NUI çağırışları
-- ═══════════════════════════════════════════════════════════════

RegisterNUICallback('close', function(_, cb)
    CloseMenu()
    cb({})
end)

RegisterNUICallback('action', function(data, cb)
    if not menuOpen or not currentVehicle then cb({ ok = false }) return end
    local fn = Actions[data.action]
    if fn then
        fn(currentVehicle)
    end
    cb({ ok = true })
end)

-- Menyu bağlananda yenilə
CreateThread(function()
    while true do
        if menuOpen then
            RefreshMenu()
        end
        Wait(1000)
    end
end)

-- Piyada ikən F5 sıxılırsa → bildiriş
CreateThread(function()
    while true do
        if not menuOpen and not IsPedInAnyVehicle(PlayerPedId(), false) then
            -- heç nə
        end
        Wait(2000)
    end
end)
