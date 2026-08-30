local QBCore = exports['qb-core']:GetCoreObject()
local boomBox = nil
local tvProp = nil
local radioIdx = 1

local function SpawnProp(model, offset, heading)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped) + offset
    RequestModel(model)
    local t = 0
    while not HasModelLoaded(model) and t < 60 do
        Wait(20)
        t = t + 1
    end
    if HasModelLoaded(model) then
        local prop = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
        SetEntityHeading(prop, heading or GetEntityHeading(ped))
        return prop
    end
    return nil
end

-- ── Boombox ──
RegisterCommand('boombox', function()
    if boomBox and DoesEntityExist(boomBox) then
        DeleteEntity(boomBox)
        boomBox = nil
        QBCore.Functions.Notify('🔊 Boombox götürüldü.', 'primary')
        return
    end
    boomBox = SpawnProp(Config.Props.Boombox, vector3(0, 1.2, 0.3))
    if boomBox then
        QBCore.Functions.Notify('🔊 Boombox qoyuldu — /radio ilə musiqi seçin!', 'success')
    end
end, false)

-- ── Boombox URL yayımı (birbaşa mp3/ogg axın) ──
RegisterCommand('boomboxurl', function(_, args)
    if not boomBox or not DoesEntityExist(boomBox) then
        QBCore.Functions.Notify('Əvvəlcə /boombox ilə boombox qoyun.', 'error')
        return
    end
    local url = table.concat(args, ' ')
    if url == '' then
        QBCore.Functions.Notify('İstifadə: /boomboxurl https://.../musiqi.mp3', 'error')
        return
    end
    local ok = pcall(PlayStreamFromObject, boomBox, '', url)
    QBCore.Functions.Notify(ok and '▶️ Yayım başladı (URL).' or '⚠️ URL yayımı bu build-də dəstəklənmir.', ok and 'success' or 'error')
end, false)

RegisterCommand('boomboxstop', function()
    pcall(StopStreamedObject)
    QBCore.Functions.Notify('⏹ Yayım dayandırıldı.', 'primary')
end, false)

RegisterCommand('boomboxendir', function()
    if boomBox and DoesEntityExist(boomBox) then
        DeleteEntity(boomBox)
    end
    boomBox = nil
    QBCore.Functions.Notify('🔇 Boombox söndürüldü.', 'primary')
end, false)

-- ── TV ──
RegisterCommand('tv', function()
    if tvProp and DoesEntityExist(tvProp) then
        DeleteEntity(tvProp)
        tvProp = nil
        QBCore.Functions.Notify('📺 TV götürüldü.', 'primary')
        return
    end
    tvProp = SpawnProp(Config.Props.TV, vector3(1.2, 0, 0.8), 270.0)
    if tvProp then
        QBCore.Functions.Notify('📺 TV qoyuldu.', 'success')
    end
end, false)


-- ── TV NUI (YouTube / Twitch) ──
local function OpenTvNui(url)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', url = url })
end

RegisterNetEvent('196rp_media:client:tv', function(url)
    OpenTvNui(url)
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    QBCore.Functions.Notify('📺 TV bağlandı.', 'primary')
    cb({})
    return true
end)

-- ── Radio: stansiya seçimi (RP göstəricisi — audio GTA daxili radio ilə) ──
RegisterCommand('radio', function()
    radioIdx = radioIdx + 1
    if radioIdx > #Config.Radio then radioIdx = 1 end
    local st = Config.Radio[radioIdx]
    QBCore.Functions.Notify(('📻 Stansiya: %s'):format(st.label), 'success')
end, false)

-- ── /tvlink <url>: NUI vasitəsilə YouTube/Twitch açmaq ──
RegisterCommand('tvlink', function(_, args)
    local url = table.concat(args, ' ')
    OpenTvNui(url ~= '' and url or nil)
end, false)
