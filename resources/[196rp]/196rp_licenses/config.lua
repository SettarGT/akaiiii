-- 196 RP | Əlavə vəsiqələr konfiqurasiyası (bənd 1)
-- Motosiklet, yük maşını, təyyarə və qayıq vəsiqələri — hər biri ayrı imtahanla

Config = {}

Config.DMV = {
    coords = vector3(244.0, -1399.0, 30.5),
    label = '196 Sürücülük Məktəbi — Əlavə vəsiqələr',
    blip = { sprite = 488, colour = 46, scale = 0.9 },
    markerDist = 2.5,
}

-- Hər vəsiqə növü üçün ayrıca imtahan
Config.Licenses = {
    {
        type = 'drive_bike',
        label = 'Motosiklet vəsiqəsi',
        icon = 'fas fa-motorcycle',
        price = 500,
        requires = nil,                 -- ön şərt yoxdur
        vehicle = 'bati',
        spawn = vector3(238.0, -1405.0, 30.4),
        heading = 250.0,
        target = vector3(-1150.0, -1650.0, 4.3),
        targetLabel = 'Vespucci sahili',
        targetRadius = 30.0,
        timeLimit = 240,
    },
    {
        type = 'drive_truck',
        label = 'Yük maşını vəsiqəsi',
        icon = 'fas fa-truck',
        price = 1200,
        requires = 'dmv',               -- əvvəlcə avtomobil vəsiqəsi lazımdır
        vehicle = 'mule',
        spawn = vector3(240.0, -1390.0, 30.4),
        heading = 250.0,
        target = vector3(145.0, 6360.0, 31.3),
        targetLabel = 'Sandy Shores anbarı',
        targetRadius = 40.0,
        timeLimit = 420,
    },
    {
        type = 'pilot',
        label = 'Təyyarə vəsiqəsi',
        icon = 'fas fa-plane',
        price = 2500,
        requires = 'dmv',
        vehicle = 'duster',
        spawn = vector3(-1260.0, -3005.0, 13.9),
        heading = 60.0,
        target = vector3(-1850.0, -2800.0, 14.0),
        targetLabel = 'Uçuş zolağının sonu',
        targetRadius = 120.0,
        timeLimit = 300,
    },
    {
        type = 'boat',
        label = 'Qayıq vəsiqəsi',
        icon = 'fas fa-ship',
        price = 900,
        requires = nil,
        vehicle = 'seashark',
        spawn = vector3(-800.0, -1510.0, 0.5),
        heading = 190.0,
        target = vector3(-900.0, -1700.0, 0.5),
        targetLabel = 'Açıq dəniz nöqtəsi',
        targetRadius = 80.0,
        timeLimit = 240,
    },
}

Config.GetLicense = function(typeName)
    for i = 1, #Config.Licenses do
        if Config.Licenses[i].type == typeName then
            return Config.Licenses[i]
        end
    end
    return nil
end
