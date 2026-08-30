local QBCore = exports['qb-core']:GetCoreObject()
local dog = nil
local dogFollowing = false

local function DespawnDog()
    if dog and DoesEntityExist(dog) then
        DeleteEntity(dog)
    end
    dog = nil
    dogFollowing = false
    QBCore.Functions.Notify('🐕 İt qaytarıldı.', 'primary')
end

-- ── İt çağır / qaytar ──
RegisterNetEvent('196rp_k9:client:toggle', function()
    if dogFollowing then
        DespawnDog()
        return
    end

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    RequestModel(Config.DogModel)
    local t = 0
    while not HasModelLoaded(Config.DogModel) and t < 100 do
        Wait(20)
        t = t + 1
    end
    if not HasModelLoaded(Config.DogModel) then
        QBCore.Functions.Notify('İt modeli yüklənə bilmədi!', 'error')
        return
    end

    dog = CreatePed(4, Config.DogModel, pos.x + 1.5, pos.y + 1.5, pos.z, 0.0, true, false)
    SetPedRelationshipGroupHash(dog, GetHashKey('COP'))
    SetPedCanRagdoll(dog, false)
    TaskWanderStandard(dog, 5.0, 10.0)
    dogFollowing = true
    QBCore.Functions.Notify('🐕 K9 iti çağırıldı — sizi izləyir. (/k9axtar ilə iyləyin)', 'success')
end)

-- İtin davranışı
CreateThread(function()
    while true do
        Wait(500)
        if dog and DoesEntityExist(dog) and dogFollowing then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local dpos = GetEntityCoords(dog)
            local dist = #(pos - dpos)

            if IsPedInAnyVehicle(ped, false) then
                -- Oyunçu maşındadırsa, maşının yanında qal
                local veh = GetVehiclePedIsIn(ped, false)
                local vx, vy, vz = table.unpack(GetEntityCoords(veh))
                if dist > 12.0 then
                    SetPedCoordsKeepVehicle(dog, vx + 2.0, vy + 2.0, vz)
                end
            else
                if dist > 4.0 then
                    -- Yavaş yaxınlaş
                    local heading = GetHeadingFromVector_2d(pos.x - dpos.x, pos.y - dpos.y)
                    SetPedDesiredHeading(dog, heading)
                    TaskGoToCoordAnyMeans(dog, pos.x, pos.y, pos.z, 6.0, 0, 0, 1, 0)
                else
                    TaskWanderStandard(dog, 2.0, 5.0)
                end
            end
        end
    end
end)

-- Növbətçilikdən çıxanda iti qaytar
RegisterNetEvent('QBCore:Client:OnJobUpdate', function()
    if dogFollowing then
        local pData = QBCore.Functions.GetPlayerData()
        if pData.job.type ~= 'leo' then
            DespawnDog()
        end
    end
end)
