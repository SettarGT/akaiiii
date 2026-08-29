-- 196 RP | Bakı xəritəsi — 3D obyekt spawner
-- Yalnız yaxınlıqdakı obyektlər yaradılır, uzaqlaşanlar silinir (kasma yoxdur)

local specs = {}          -- bütün obyektlərin təsviri
local spawned = {}        -- key → entity handle
local modelCache = {}     -- model adı → hash (bir dəfə yüklənir)
local layerEnabled = Config.Objects.Enabled
local testProp = nil

-- ==================== MODEL YÜKLƏMƏ (keşli) ====================

local function LoadModel(name)
    if modelCache[name] then
        return modelCache[name]
    end

    local hash = GetHashKey(name)
    RequestModel(hash)

    local tries = 0

    while not HasModelLoaded(hash) and tries < 100 do
        Wait(20)
        tries = tries + 1
    end

    if not HasModelLoaded(hash) then
        return nil
    end

    modelCache[name] = hash

    return hash
end

-- ==================== SPESİFİKASİYA LİSTİ ====================

local function BuildSpecs()
    specs = {}

    -- Hər stansiyanın giriş komplekti
    for i = 1, #Config.Stations do
        local st = Config.Stations[i]
        local base = Baku.Coords(st.id)

        for j = 1, #Config.Objects.StationLayout do
            local t = Config.Objects.StationLayout[j]

            specs[#specs + 1] = {
                key = st.id .. '_' .. t.id,
                model = t.model,
                x = base.x + t.dx,
                y = base.y + t.dy,
                z = base.z + t.z,
                heading = t.heading,
            }
        end
    end

    -- Rayonlara görə xüsusi tikililər
    for i = 1, #Config.Objects.Extras do
        local ex = Config.Objects.Extras[i]
        local st = Baku.GetStation(ex.station)

        if st then
            local base = Baku.Coords(st.id)

            specs[#specs + 1] = {
                key = 'ex_' .. ex.id,
                model = ex.model,
                x = base.x + ex.dx,
                y = base.y + ex.dy,
                z = base.z + ex.z,
                heading = ex.heading,
            }
        end
    end
end

-- ==================== SPAWN / DESPAWN ====================

local function Despawn(key)
    local handle = spawned[key]

    if handle and DoesEntityExist(handle) then
        SetEntityAsMissionEntity(handle, true, true)
        DeleteEntity(handle)
    end

    spawned[key] = nil
end

local function Spawn(spec)
    local hash = LoadModel(spec.model)

    if not hash then
        return false
    end

    local x, y, z = spec.x, spec.y, spec.z

    -- YERƏ OTURTMQ — DİQQƏT: bu native-ə vector3 ötürmək oyunu ÇÖKDÜRÜR,
    -- ona görə x, y, z ayrı-ayrı float kimi verilir.
    if Config.Objects.GroundSnap then
        local found, groundZ = GetGroundZFor_3dCoord(x, y, z + 3.0, false)

        if found then
            z = groundZ
        end
    end

    -- Lokal obyekt (isNetwork = false): şəbəkə trafiki yaratmır
    local obj = CreateObject(hash, x, y, z, false, false, false)

    if not obj or obj == 0 then
        return false
    end

    SetEntityHeading(obj, spec.heading or 0.0)
    FreezeEntityPosition(obj, true)
    SetEntityInvincible(obj, true)
    SetEntityCollision(obj, true, false)
    SetModelAsNoLongerNeeded(hash)

    spawned[spec.key] = obj

    return true
end

-- ==================== ANA DÖNGÜ ====================

CreateThread(function()
    BuildSpecs()

    while true do
        if layerEnabled then
            local pedCoords = GetEntityCoords(PlayerPedId())
            local active = 0

            for i = 1, #specs do
                local spec = specs[i]
                local dx = pedCoords.x - spec.x
                local dy = pedCoords.y - spec.y
                local dist = math.sqrt(dx * dx + dy * dy)
                local exists = spawned[spec.key] ~= nil

                if dist < Config.Objects.SpawnDistance then
                    if not exists and active < Config.Objects.MaxObjects then
                        if Spawn(spec) then
                            active = active + 1
                        end
                    elseif exists then
                        active = active + 1
                    end
                elseif dist > Config.Objects.DespawnDistance and exists then
                    Despawn(spec.key)
                end
            end
        end

        Wait(Config.Objects.TickMs)
    end
end)

-- ==================== RESURS DAYANANDA TƏMİZLƏMƏ ====================

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    for key in pairs(spawned) do
        Despawn(key)
    end

    if testProp and DoesEntityExist(testProp) then
        SetEntityAsMissionEntity(testProp, true, true)
        DeleteEntity(testProp)
    end

    testProp = nil
end)

-- ==================== ƏMRLƏR ====================

-- 3D qatı aç/bağla (FPS problemi olarsa bağlamaq üçün)
RegisterCommand('xerite3d', function()
    layerEnabled = not layerEnabled

    if not layerEnabled then
        for key in pairs(spawned) do
            Despawn(key)
        end
        ESX.ShowNotification('🏗️ 3D obyekt qatı ~r~SÖNDÜRÜLDÜ~s~.', 'info', 5000)
    else
        ESX.ShowNotification('🏗️ 3D obyekt qatı ~g~YANDIRILDI~s~.', 'info', 5000)
    end
end, false)

-- Model adını oyunda yoxlamaq üçün: /obyekt prop_bench_01a
RegisterCommand('obyekt', function(source, args)
    local name = args[1]

    if not name then
        ESX.ShowNotification('İstifadə: ~y~/obyekt <model adı>~s~', 'error', 6000)
        return
    end

    if testProp and DoesEntityExist(testProp) then
        SetEntityAsMissionEntity(testProp, true, true)
        DeleteEntity(testProp)
        testProp = nil
    end

    local hash = LoadModel(name)

    if not hash then
        ESX.ShowNotification(('❌ ~y~%s~s~ modeli tapılmadı (ad səhvdir).'):format(name), 'error', 8000)
        return
    end

    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local px = pedCoords.x + forward.x * 3.0
    local py = pedCoords.y + forward.y * 3.0
    local pz = pedCoords.z

    local found, groundZ = GetGroundZFor_3dCoord(px, py, pz + 3.0, false)

    if found then
        pz = groundZ
    end

    testProp = CreateObject(hash, px, py, pz, false, false, false)

    if testProp and testProp ~= 0 then
        FreezeEntityPosition(testProp, true)
        ESX.ShowNotification(('✅ ~g~%s~s~ yaradıldı.'):format(name), 'success', 6000)
    else
        ESX.ShowNotification(('⚠️ ~y~%s~s~ yaradıla bilmədi.'):format(name), 'error', 6000)
    end
end, false)

-- Test obyektini sil
RegisterCommand('obyektsil', function()
    if testProp and DoesEntityExist(testProp) then
        SetEntityAsMissionEntity(testProp, true, true)
        DeleteEntity(testProp)
        testProp = nil
        ESX.ShowNotification('Test obyekti silindi.', 'info')
    else
        ESX.ShowNotification('Aktiv test obyekti yoxdur.', 'info')
    end
end, false)

-- Diaqnostika: neçə obyekt aktivdir
RegisterCommand('obyektsay', function()
    local n = 0

    for _ in pairs(spawned) do
        n = n + 1
    end

    ESX.ShowNotification(('🏗️ Aktiv obyekt: ~b~%s~s~ / %s (cəmi spesifikasiya: %s)'):format(
        n, Config.Objects.MaxObjects, #specs), 'info', 8000)
end, false)

-- ==================== İXRAC ====================

exports('GetActiveObjectCount', function()
    local n = 0

    for _ in pairs(spawned) do
        n = n + 1
    end

    return n
end)
