-- 196 RP | Şəhər canlılığı — müştəri tərəfi
-- Piyada və avtomobil populyasiyasını həmişə aktiv saxlayır

CreateThread(function()
    -- Populyasiya büdcəsini maksimuma qaldır (bir dəfə)
    SetPedPopulationBudget(Config.PedBudget)
    SetVehiclePopulationBudget(Config.VehicleBudget)
end)

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        -- Şəhər mərkəzindən uzaqlaşdıqca trafiki azalt
        local distFromCenter = #(coords - vector3(0.0, -900.0, 30.0))
        local m = 1.0
        if distFromCenter > Config.RemoteDistance then
            m = Config.RemoteMultiplier
        end

        SetVehicleDensityMultiplierThisFrame(Config.VehicleDensity * m)
        SetRandomVehicleDensityMultiplierThisFrame(Config.RandomVehicleDensity * m)
        SetParkedVehicleDensityMultiplierThisFrame(Config.ParkedDensity * m)
        SetPedDensityMultiplierThisFrame(Config.PedDensity * m)
        SetScenarioPedDensityMultiplierThisFrame(Config.ScenarioPedDensity * m, false)
        SetGarbageTrucks(false)
        SetCreateRandomCops(false)
        SetCreateRandomCopsNotOnScenarios(true)
        SetCreateRandomCopsOnScenarios(true)

        -- Nəqliyyat vasitələrinin yox olmasının qarşısını al
        SetNumberOfParkedVehicles(math.floor(20 * m))

        Wait(0)
    end
end)

-- Oyunçu maşınından düşəndə ətrafdakı NPC-lərin silinməməsi üçün
CreateThread(function()
    while true do
        Wait(5000)
        -- Boş qalan NPC maşınlarının yığışmasına icazə ver (performans üçün)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        local handle, vehicle = FindFirstVehicle()
        local ok = handle ~= -1
        repeat
            if DoesEntityExist(vehicle) and not IsVehiclePreviouslyOwnedByPlayer(vehicle) then
                local dist = #(GetEntityCoords(vehicle) - coords)
                if dist > 400.0 and GetPedInVehicleSeat(vehicle, -1) == 0 then
                    SetEntityAsMissionEntity(vehicle, true, true)
                    DeleteVehicle(vehicle)
                end
            end
            ok, vehicle = FindNextVehicle(handle)
        until not ok
        EndFindVehicle(handle)
    end
end)
