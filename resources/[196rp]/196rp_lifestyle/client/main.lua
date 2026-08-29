-- 196 RP | Həyat tərzi — müştəri tərəfi
-- Gigiyena, siqaret, alkoqol, stress, üzgüçülük, hava, bişirmə, qeydlər

local state = {
    hygiene = Config.Hygiene.start,
    stress = Config.Stress.start,
    drunk = 0,
    sick = false,
    season = 'spring',
}

local lastHygieneWarn = 0
local lastHygieneDrain = 0
local lastStressWarn = 0
local lastSmoke = 0
local lastHealthDrain = 0
local lastColdDrain = 0
local loaded = false

-- ==================== SERVERDƏN GƏLƏN VƏZİYYƏT ====================

RegisterNetEvent('196rp_lifestyle:setState', function(serverState)
    if type(serverState) == 'table' then
        state.hygiene = serverState.hygiene or state.hygiene
        state.stress = serverState.stress or state.stress
        state.drunk = serverState.drunk or 0
        state.sick = serverState.sick or false
        state.season = serverState.season or state.season
    end
    loaded = true
end)

RegisterNetEvent('196rp_lifestyle:updateValue', function(key, value)
    if key == 'hygiene' or key == 'stress' or key == 'drunk' then
        state[key] = value or 0
    elseif key == 'sick' then
        state.sick = value and true or false
        if value then
            ESX.ShowNotification('~r~🤒 Xəstələndiniz!~s~ Xəstəxanada həkim qəbuluna gedin.', 'error', 8000)
        else
            ESX.ShowNotification('~g~Sağaldınız!~s~', 'success')
        end
    elseif key == 'season' then
        state.season = value or state.season
    end
end)

local function SyncToServer()
    TriggerServerEvent('196rp_lifestyle:sync', {
        hygiene = state.hygiene,
        stress = state.stress,
        drunk = state.drunk,
    })
end

-- ==================== KÖMƏKÇİLƏR ====================

local function Clamp(n, min, max)
    if n < min then return min end
    if n > max then return max end
    return n
end

local function GetSeasonByMonth()
    local month = tonumber(os.date('%m'))
    return Config.Seasons.months[month] or 'spring'
end

local function IsRaining()
    local h = GetPrevWeatherTypeHashName()
    for i = 1, #Config.Weather.rain do
        if h == GetHashKey(Config.Weather.rain[i]) then
            return true
        end
    end
    return false
end

local function IsSnowing()
    local h = GetPrevWeatherTypeHashName()
    for i = 1, #Config.Weather.snow do
        if h == GetHashKey(Config.Weather.snow[i]) then
            return true
        end
    end
    return false
end

local function HasWarmClothes()
    local ped = PlayerPedId()
    for i = 1, #Config.Weather.jacketComponents do
        local comp = Config.Weather.jacketComponents[i]
        if GetPedDrawableVariation(ped, comp) and GetPedDrawableVariation(ped, comp) > 0 then
            return true
        end
    end
    return false
end

-- ==================== ALKOQOL EFFEKTİ ====================

local activeClipset = nil
local function ApplyDrunkEffects()
    local ped = PlayerPedId()
    local level = state.drunk
    local wanted = nil

    if level >= Config.Alcohol.staggerLevel then
        wanted = 'move_m@drunk@verydrunk'
    elseif level >= Config.Alcohol.dizzyLevel then
        wanted = 'move_m@drunk@slightlydrunk'
    end

    if wanted ~= activeClipset then
        if activeClipset then
            ResetPedMovementClipset(ped, 0)
        end
        if wanted then
            RequestAnimSet(wanted)
            local t = 0
            while not HasAnimSetLoaded(wanted) and t < 40 do
                Wait(50)
                t = t + 1
            end
            SetPedMovementClipset(ped, wanted, 0.5, true)
        end
        activeClipset = wanted
    end

    if level >= Config.Alcohol.dizzyLevel then
        SetTimecycleModifier('drunk')
        SetTimecycleModifierStrength(math.min(1.0, level / 100))
    else
        ClearTimecycleModifier()
    end
end

-- ==================== SİQARET ====================

RegisterNetEvent('196rp_lifestyle:smoke', function()
    local now = GetGameTimer()
    if now - lastSmoke < Config.Smoking.cooldown then
        ESX.ShowNotification('Bir az gözləyin, yenidən siqaret çəkmək tezdir.', 'info')
        return
    end
    lastSmoke = now

    ESX.Progressbar('Siqaret çəkirsiniz...', Config.Smoking.duration, {
        FreezePlayer = false,
        animation = {
            type = 'anim',
            dict = 'amb@world_human_smoking@male@male_a@base',
            lib = 'base'
        },
        onFinish = function()
            state.stress = Clamp(state.stress - Config.Smoking.stressRelief, 0, Config.Stress.max)
            SyncToServer()
            ESX.ShowNotification(('~g~Stress azaldı~s~ (-%s), amma sağlamlığınıza zərərlidir.'):format(
                Config.Smoking.stressRelief), 'info')
        end
    })
end)

-- ==================== HƏYAT DÖVRƏSİ ====================

CreateThread(function()
    while true do
        Wait(1000)

        if loaded and not IsPauseMenuActive() then
            local ped = PlayerPedId()

            -- GİGİYENA azalır
            state.hygiene = Clamp(state.hygiene - (Config.Hygiene.decayPerMinute / 60), 0, 100)

            -- STRESS sakit olanda azalır
            local resting = GetEntitySpeed(ped) < 0.3 and not IsPedInAnyVehicle(ped, false)
            local stressDecay = Config.Stress.decreasePerMinute / 60
            if resting then
                stressDecay = stressDecay * Config.Stress.restMultiplier
            end
            state.stress = Clamp(state.stress - stressDecay, 0, Config.Stress.max)

            -- ALKOQOL azalır
            if state.drunk > 0 then
                state.drunk = Clamp(state.drunk - (Config.Alcohol.decayPerMinute / 60), 0, 100)
            end
            ApplyDrunkEffects()

            -- Aşağı gigiyena xəbərdarlığı + can itkisi
            if state.hygiene < Config.Hygiene.lowThreshold then
                local t = GetGameTimer()
                if t - lastHygieneWarn > 60000 then
                    lastHygieneWarn = t
                    ESX.ShowNotification('~r~Gigiyenanız aşağıdır!~s~ Duş qəbul edin (çimərlik, hovuz və ya ev).', 'warning', 7000)
                end
                if t - lastHygieneDrain > 30000 then
                    lastHygieneDrain = t
                    local h = GetEntityHealth(ped)
                    if h > 110 then
                        SetEntityHealth(ped, h - Config.Hygiene.healthDrain)
                    end
                end
            end

            -- Yüksək stress xəbərdarlığı
            if state.stress > Config.Stress.warnThreshold then
                local t = GetGameTimer()
                if t - lastStressWarn > 90000 then
                    lastStressWarn = t
                    ESX.ShowNotification(('~r~Stress səviyyəniz yüksəkdir: %s%%~s~\nİstirahət edin və ya siqaret çəkin.'):format(math.floor(state.stress)), 'warning', 7000)
                end
            end

            -- Çox yüksək stress — ekran titrəməsi
            if state.stress >= Config.Stress.panicThreshold and math.random(1, 10) == 1 then
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.15)
            end

            -- Xəstəlik — canı aparır
            if state.sick then
                local t = GetGameTimer()
                if t - lastHealthDrain > 30000 then
                    lastHealthDrain = t
                    local h = GetEntityHealth(ped)
                    if h > 110 then
                        SetEntityHealth(ped, h - 2)
                    end
                end
            end

            -- ÜZGÜÇÜLÜK (8)
            if IsPedSwimming(ped) then
                local stamina = GetPlayerSprintStaminaRemaining(PlayerId()) * 100
                if stamina < Config.Swimming.dangerThreshold then
                    local h = GetEntityHealth(ped)
                    if h > 110 then
                        SetEntityHealth(ped, h - Config.Swimming.healthDrain)
                        if math.random(1, 8) == 1 then
                            ESX.ShowNotification('~r~Üzümlülüyünüz bitir!~s~ Sahilə çıxın.', 'error', 4000)
                        end
                    end
                end
            end

            -- QIŞDA SOYUQ GEYİM (9/10)
            if (state.season == 'winter' or IsSnowing()) and not HasWarmClothes() then
                local t = GetGameTimer()
                if t - lastColdDrain > 30000 then
                    lastColdDrain = t
                    local h = GetEntityHealth(ped)
                    if h > 110 then
                        SetEntityHealth(ped, h - Config.Weather.coldDamage)
                        ESX.ShowNotification('~b~Üşüyürsünüz!~s~ İsti geyim (gödəkçə) geyinin.', 'info', 5000)
                    end
                end
            end

            -- Yağış stressi bir az artırır (9)
            if IsRaining() then
                state.stress = Clamp(state.stress + (Config.Weather.rainStress / 60), 0, Config.Stress.max)
            end
        end
    end
end)

-- Serverə hər 30 saniyədə sinxronizasiya
CreateThread(function()
    while true do
        Wait(30000)
        if loaded then
            SyncToServer()
        end
    end
end)

-- Zərbə alanda stress artır (7)
CreateThread(function()
    local lastHealth = nil
    while true do
        Wait(1000)
        if loaded then
            local ped = PlayerPedId()
            local health = GetEntityHealth(ped)

            if lastHealth and health < lastHealth - 5 then
                state.stress = Clamp(state.stress + Config.Stress.increaseOnDamage, 0, Config.Stress.max)
                -- Huşunu itirmə (2)
                if health <= 110 and Config.Swimming.sickAfterDrown then
                    TriggerServerEvent('196rp_lifestyle:onKnockedOut')
                end
            end

            lastHealth = health
        end
    end
end)

-- Dava zamanı stress (7)
CreateThread(function()
    while true do
        Wait(2000)
        if loaded then
            local ped = PlayerPedId()
            if IsPedInMeleeCombat(ped) or IsPedShooting(ped) then
                state.stress = Clamp(state.stress + Config.Stress.increaseOnFight, 0, Config.Stress.max)
            end
        end
    end
end)

-- ==================== DUŞ (4) ====================

CreateThread(function()
    while true do
        local wait = 750
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for i = 1, #Config.Showers do
            local s = Config.Showers[i]
            local dist = #(coords - s.coords)

            if dist < 25.0 then
                wait = 0
                DrawMarker(1, s.coords.x, s.coords.y, s.coords.z - 1.0, 0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0, 1.2, 1.2, 0.5, 60, 160, 255, 120, false, true, 2, nil, nil, false)
            end

            if dist < 1.8 then
                ESX.TextUI('[E] — Duş qəbul et', 'info')
                if IsControlJustPressed(0, 38) then
                    ESX.HideUI()
                    ESX.Progressbar('Duş qəbul edirsiniz...', Config.Hygiene.showerTime, {
                        FreezePlayer = true,
                        animation = { type = 'Scenario', Scenario = 'WORLD_HUMAN_STAND_IMPATIENT' },
                        onFinish = function()
                            state.hygiene = Config.Hygiene.showerRestore
                            SyncToServer()
                            ESX.ShowNotification('~g~Tərtəmiz oldunuz!~s~ Gigiyena: 100%', 'success')
                        end
                    })
                end
            end
        end

        if wait == 750 then
            ESX.HideUI()
        end

        Wait(wait)
    end
end)

-- ==================== XƏSTƏXANA (2) ====================

local function OpenHospitalMenu(loc)
    local menu = {
        { icon = 'fas fa-hospital', title = ('🏥 %s'):format(loc.label), unselectable = true },
        { icon = 'fas fa-briefcase-medical', title = ('Tam müalicə — ~g~%s$~s~'):format(Config.Hospital.healPrice), name = 'heal' },
        { icon = 'fas fa-pills', title = ('Həkim qəbulu (xəstəlik) — ~g~%s$~s~'):format(Config.Hospital.cureSickPrice), name = 'cure' },
        { icon = 'fas fa-info-circle', title = state.sick and '~r~Xəstəsiniz~s~' or '~g~Sağsınız~s~', unselectable = true },
    }

    exports['esx_context']:Open('right', menu, function(selected)
        ESX.Progressbar('Həkim sizi müayinə edir...', Config.Hospital.healTime, {
            FreezePlayer = true,
            animation = { type = 'Scenario', Scenario = 'WORLD_HUMAN_CLIPBOARD' },
            onFinish = function()
                ESX.TriggerServerCallback('196rp_lifestyle:hospital', function(ok, msg)
                    ESX.ShowNotification(msg, ok and 'success' or 'error', 6000)
                    if ok and selected.name == 'heal' then
                        local ped = PlayerPedId()
                        SetEntityHealth(ped, GetEntityMaxHealth(ped))
                        SetPedArmour(ped, 100)
                    end
                end, selected.name)
            end
        })
    end)
end

CreateThread(function()
    while true do
        local wait = 750
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for i = 1, #Config.Hospital.locations do
            local loc = Config.Hospital.locations[i]
            local dist = #(coords - loc.coords)

            if dist < 25.0 then
                wait = 0
                DrawMarker(21, loc.coords.x, loc.coords.y, loc.coords.z - 0.5, 0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0, 0.7, 0.7, 0.5, 220, 60, 60, 130, false, true, 2, nil, nil, false)
            end

            if dist < 1.8 then
                ESX.TextUI('[E] — Həkim qəbulu', 'info')
                if IsControlJustPressed(0, 38) then
                    ESX.HideUI()
                    OpenHospitalMenu(loc)
                end
            end
        end

        if wait == 750 then
            ESX.HideUI()
        end

        Wait(wait)
    end
end)

-- ==================== BİŞİRMƏ (11) ====================

CreateThread(function()
    while true do
        local wait = 750
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local dist = #(coords - Config.Cooking.kitchen)

        if dist < 25.0 then
            wait = 0
            DrawMarker(1, Config.Cooking.kitchen.x, Config.Cooking.kitchen.y, Config.Cooking.kitchen.z - 1.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 0.5, 255, 160, 40, 120, false, true, 2, nil, nil, false)
        end

        if dist < 2.0 then
            ESX.TextUI('[E] — Yemək bişir', 'info')
            if IsControlJustPressed(0, 38) then
                ESX.HideUI()

                local menu = {
                    { icon = 'fas fa-utensils', title = '🍳 Mətbəx — nə bişirək?', unselectable = true },
                }
                for i = 1, #Config.Cooking.recipes do
                    local r = Config.Cooking.recipes[i]
                    local needs = {}
                    for j = 1, #r.ingredients do
                        needs[#needs + 1] = ('%sx%s'):format(r.ingredients[j].item, r.ingredients[j].count)
                    end
                    menu[#menu + 1] = {
                        icon = 'fas fa-fire',
                        title = r.label,
                        description = ('Lazımdır: %s'):format(table.concat(needs, ', ')),
                        name = 'cook_' .. i,
                    }
                end

                exports['esx_context']:Open('right', menu, function(selected)
                    local idx = tonumber(selected.name:match('^cook_(%d+)$'))
                    if not idx then
                        return
                    end

                    ESX.Progressbar('Yemək bişirirsiniz...', Config.Cooking.cookTime, {
                        FreezePlayer = true,
                        animation = { type = 'Scenario', Scenario = 'PROP_HUMAN_BBQ' },
                        onFinish = function()
                            ESX.TriggerServerCallback('196rp_lifestyle:cook', function(ok, msg)
                                ESX.ShowNotification(msg, ok and 'success' or 'error', 6000)
                            end, idx)
                        end
                    })
                end)
            end
        end

        if wait == 750 then
            ESX.HideUI()
        end

        Wait(wait)
    end
end)

-- ==================== QEYDLƏR (12) ====================

RegisterCommand('qeyd', function(_, args)
    local text = table.concat(args, ' ')
    if text == '' then
        ESX.ShowNotification('İstifadə: /qeyd [mətn]', 'info')
        return
    end

    ESX.TriggerServerCallback('196rp_lifestyle:addNote', function(ok, msg)
        ESX.ShowNotification(msg, ok and 'success' or 'error')
    end, text)
end, false)

RegisterCommand('qeydler', function()
    ESX.TriggerServerCallback('196rp_lifestyle:getNotes', function(notes)
        local menu = {
            { icon = 'fas fa-book', title = ('📔 Qeydlər dəftəri (%s)'):format(#notes), unselectable = true },
        }

        if #notes == 0 then
            menu[#menu + 1] = { icon = 'fas fa-info', title = 'Qeyd yoxdur. /qeyd [mətn] ilə əlavə edin.', unselectable = true }
        else
            for i = 1, #notes do
                menu[#menu + 1] = {
                    icon = 'fas fa-sticky-note',
                    title = notes[i].note,
                    description = tostring(notes[i].created_at or ''),
                    name = 'note_' .. notes[i].id,
                }
            end
        end

        exports['esx_context']:Open('right', menu, function(selected)
            local id = tonumber(selected.name:match('^note_(%d+)$'))
            if not id then
                return
            end

            ESX.TriggerServerCallback('196rp_lifestyle:deleteNote', function(ok)
                if ok then
                    ESX.ShowNotification('Qeyd silindi.', 'info')
                end
            end, id)
        end)
    end)
end, false)

-- ==================== VƏZİYYƏT ƏMRİ ====================

RegisterCommand('vaziyyet', function()
    ESX.ShowNotification(
        ('🧍 GIGIYENA: ~w~%s%%~s~ | 😰 STRESS: ~w~%s%%~s~ | 🍺 SƏRXOŞLUQ: ~w~%s%%~s~ | %s %s'):format(
            math.floor(state.hygiene), math.floor(state.stress), math.floor(state.drunk),
            state.sick and '~r~XƏSTƏ~s~' or '~g~SAĞ~s~',
            Config.Seasons.labels[state.season] or ''), 'info', 8000)
end, false)

-- Mövsüm (girişdə bir dəfə)
CreateThread(function()
    state.season = GetSeasonByMonth()
    Wait(6000)
    ESX.ShowNotification(('📅 Mövsüm: ~y~%s~s~ | /vaziyyet ilə vəziyyətinizə baxın'):format(
        Config.Seasons.labels[state.season] or state.season), 'info', 8000)
end)

exports('GetLifestyleState', function()
    return state
end)
