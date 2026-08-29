-- Avtomobil xüsusiyyətlərinin saxlanması/geri yüklənməsi
-- (client tərəfində işləyir, serverə JSON kimi göndərilir)

function GetVehicleProperties(vehicle)
    if not DoesEntityExist(vehicle) then
        return {}
    end

    local color1, color2 = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)

    return {
        model = GetEntityModel(vehicle),
        modelName = string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))),
        plate = GetVehicleNumberPlateText(vehicle),
        color1 = color1,
        color2 = color2,
        pearlescentColor = pearlescentColor,
        wheelColor = wheelColor,
        modEngine = GetVehicleMod(vehicle, 11),
        modBrakes = GetVehicleMod(vehicle, 12),
        modTransmission = GetVehicleMod(vehicle, 13),
        modSuspension = GetVehicleMod(vehicle, 15),
        modArmor = GetVehicleMod(vehicle, 16),
        modTurbo = GetVehicleMod(vehicle, 18),
        windowTint = GetVehicleWindowTint(vehicle),
        plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
    }
end

function SetVehicleProperties(vehicle, props)
    if not DoesEntityExist(vehicle) then
        return
    end

    if props.color1 then
        SetVehicleColours(vehicle, props.color1, props.color2 or 0)
    end
    if props.pearlescentColor then
        SetVehicleExtraColours(vehicle, props.pearlescentColor, props.wheelColor or 0)
    end
    if props.modEngine then
        SetVehicleMod(vehicle, 11, props.modEngine, false)
    end
    if props.modBrakes then
        SetVehicleMod(vehicle, 12, props.modBrakes, false)
    end
    if props.modTransmission then
        SetVehicleMod(vehicle, 13, props.modTransmission, false)
    end
    if props.modSuspension then
        SetVehicleMod(vehicle, 15, props.modSuspension, false)
    end
    if props.modArmor then
        SetVehicleMod(vehicle, 16, props.modArmor, false)
    end
    if props.modTurbo then
        SetVehicleMod(vehicle, 18, props.modTurbo, false)
    end
    if props.windowTint then
        SetVehicleWindowTint(vehicle, props.windowTint)
    end
    if props.plateIndex then
        SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
    end
end
