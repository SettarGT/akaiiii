-- 196 RP | Dövlət formaları — müştəri tərəfi
-- 196 loqosu YALNIZ dövlət formalarında görünür (mülki geyimlərdə yoxdur)

local wearingUniform = nil   -- { label = ..., job = ... }
local savedCivilSkin = nil
local hudEnabled = false

-- ==================== KÖMƏKÇİLƏR ====================

local function ApplyUniform(uniform)
    local ped = PlayerPedId()

    -- Əvvəlcə bütün komponentləri sıfırla ki, köhnə geyim qalmasın
    for componentId = 0, 11 do
        SetPedComponentVariation(ped, componentId, 0, 0, 0)
    end

    for componentId, data in pairs(uniform.component or {}) do
        SetPedComponentVariation(ped, componentId, data.d, data.t or 0, 0)
    end

    -- Prop-ları təmizlə
    for propId = 0, 10 do
        ClearPedProp(ped, propId)
    end

    for propId, data in pairs(uniform.prop or {}) do
        SetPedPropIndex(ped, propId, data.d, data.t or 0, true)
    end

    if uniform.armor then
        SetPedArmour(ped, uniform.armor)
    end

    SetPedArmour(ped, uniform.armor or 0)
end

local function RestoreCivilian()
    if savedCivilSkin then
        TriggerEvent('skinchanger:loadSkin', savedCivilSkin)
        savedCivilSkin = nil
    end
end

-- Mülki geyimi yadda saxla (bir dəfə)
local function SaveCivilSkin()
    if savedCivilSkin then
        return
    end
    TriggerEvent('skinchanger:getSkin', function(skin)
        savedCivilSkin = skin
    end)
end

-- ==================== MENYU ====================

local function OpenWardrobe(wardrobe)
    local jobName = ESX.GetPlayerData().job and ESX.GetPlayerData().job.name
    local grade = ESX.GetPlayerData().job and ESX.GetPlayerData().job.grade or 0

    if jobName ~= wardrobe.job then
        ESX.ShowNotification((Config.Messages.noJob):format(wardrobe.job:upper()), 'error')
        return
    end

    local uniforms = Config.Uniforms[jobName] or {}
    local menu = {
        { icon = 'fas fa-shield-alt', title = ('%s — Geyim Otağı'):format(Config.BrandFull), unselectable = true },
    }

    for i = 1, #uniforms do
        local u = uniforms[i]
        local locked = (u.grade or 0) > grade
        menu[#menu + 1] = {
            icon = locked and 'fas fa-lock' or 'fas fa-tshirt',
            title = locked and ('%s ~r~(rütbə %s lazımdır)~s~'):format(u.label, u.grade) or u.label,
            disabled = locked,
            name = 'uniform_' .. i,
        }
    end

    menu[#menu + 1] = { icon = 'fas fa-user', title = 'Mülki geyimə keç', name = 'civil' }

    exports['esx_context']:Open('right', menu, function(selected)
        if selected.name == 'civil' then
            SaveCivilSkin()
            RestoreCivilian()
            wearingUniform = nil
            ESX.ShowNotification(Config.Messages.civilian, 'info')
            ESX.TriggerServerCallback('196rp_dutyuniform:setWorn', function() end, nil)
            return
        end

        local idx = tonumber(selected.name:match('^uniform_(%d+)$'))
        if not idx or not uniforms[idx] then
            return
        end

        local u = uniforms[idx]
        if (u.grade or 0) > grade then
            ESX.ShowNotification(Config.Messages.noGrade, 'error')
            return
        end

        SaveCivilSkin()

        -- Mülki geyim yadda saxlanılana qədər gözlə
        local tries = 0
        while not savedCivilSkin and tries < 40 do
            Wait(25)
            tries = tries + 1
        end

        ApplyUniform(u)
        wearingUniform = { label = u.label, job = jobName }
        ESX.ShowNotification((Config.Messages.dressed):format(u.label), 'success')

        ESX.TriggerServerCallback('196rp_dutyuniform:setWorn', function() end, idx)
    end)
end

-- ==================== ƏSAS DÖVRƏ ====================

CreateThread(function()
    while true do
        local wait = 750
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for i = 1, #Config.Wardrobes do
            local w = Config.Wardrobes[i]
            local dist = #(coords - w.coords)

            if dist < 30.0 then
                wait = 0
                DrawMarker(21, w.coords.x, w.coords.y, w.coords.z - 0.6, 0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0, 0.6, 0.6, 0.4, 30, 90, 200, 160, false, true, 2, nil, nil, false)
            end

            if dist < 1.8 then
                ESX.TextUI(('[E] — %s'):format(w.label), 'info')
                if IsControlJustPressed(0, 38) then
                    ESX.HideUI()
                    OpenWardrobe(w)
                end
            end
        end

        if wait == 750 then
            ESX.HideUI()
        end

        Wait(wait)
    end
end)

-- ==================== 196 NÖVBƏ NİŞANI (HUD) ====================
-- Yalnız 196 dövlət forması geyiniləndə görünür

CreateThread(function()
    while true do
        if wearingUniform and not IsPauseMenuActive() then
            local x, y = 0.013, 0.905

            -- Fon
            DrawRect(x + 0.045, y + 0.018, 0.092, 0.052, 12, 18, 30, 190)
            -- Sol zolaq (dövlət rəngi)
            DrawRect(x + 0.0025, y + 0.018, 0.005, 0.052, 40, 130, 220, 230)

            -- "196"
            SetTextFont(4)
            SetTextScale(0.0, 0.42)
            SetTextColour(255, 255, 255, 235)
            SetTextOutline()
            SetTextEntry('STRING')
            AddTextComponentString(Config.Brand)
            DrawText(x + 0.008, y + 0.002)

            -- Orqan adı
            SetTextFont(0)
            SetTextScale(0.0, 0.26)
            SetTextColour(190, 210, 240, 220)
            SetTextEntry('STRING')
            AddTextComponentString(wearingUniform.label:gsub('^196 ', ''))
            DrawText(x + 0.040, y + 0.010)
        end

        Wait(0)
    end
end)

-- ==================== SERVERDƏN GƏLƏN ====================

-- Giriş zamanı geyilmiş formanı bərpa et
RegisterNetEvent('196rp_dutyuniform:restore', function(uniformIndex)
    if not uniformIndex then
        wearingUniform = nil
        return
    end

    local jobName = ESX.GetPlayerData().job and ESX.GetPlayerData().job.name
    local uniforms = Config.Uniforms[jName or '']
    local u = uniforms and uniforms[uniformIndex]

    if not u then
        wearingUniform = nil
        return
    end

    -- Personaj tam yüklənənə qədər gözlə
    local tries = 0
    while not DoesEntityExist(PlayerPedId()) and tries < 100 do
        Wait(100)
        tries = tries + 1
    end

    SaveCivilSkin()
    tries = 0
    while not savedCivilSkin and tries < 40 do
        Wait(25)
        tries = tries + 1
    end

    ApplyUniform(u)
    wearingUniform = { label = u.label, job = jobName }
end)

-- Növbədən çıxarkən (digər resurslar çağıra bilər)
RegisterNetEvent('196rp_dutyuniform:forceUndress', function()
    RestoreCivilian()
    wearingUniform = nil
end)

exports('IsWearingUniform', function()
    return wearingUniform ~= nil
end)

exports('GetUniformLabel', function()
    return wearingUniform and wearingUniform.label or nil
end)
