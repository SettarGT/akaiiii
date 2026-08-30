Config = {}

-- Yarış trekləri
Config.Tracks = {
    {
        id = 'city',
        label = 'Şəhər Dairəsi',
        desc = 'Şəhər mərkəzi üzrə dairə — 9 nəzarət nöqtəsi',
        entryFee = 500,
        checkpoints = {
            vector3(430.2, -1020.2, 28.3),
            vector3(130.7, -1026.6, 29.4),
            vector3(40.7, -1045.6, 29.1),
            vector3(-45.5, -1017.8, 27.4),
            vector3(-61.6, -964.2, 26.6),
            vector3(-16.8, -916.6, 26.8),
            vector3(110.6, -939.8, 29.9),
            vector3(267.6, -962.8, 29.5),
            vector3(396.3, -984.5, 28.2),
        },
    },
    {
        id = 'vine',
        label = 'Vinewood Təpələri',
        desc = 'Dağ yolları — 6 nəzarət nöqtəsi',
        entryFee = 750,
        checkpoints = {
            vector3(283.2, 391.1, 105.9),
            vector3(446.3, 456.3, 110.1),
            vector3(654.2, 424.8, 113.9),
            vector3(664.5, 270.5, 104.5),
            vector3(469.9, 227.4, 111.0),
            vector3(346.5, 322.8, 105.7),
        },
    },
    {
        id = 'highway',
        label = 'Magistral Sprint',
        desc = 'Şəhər ətrafı magistral — 6 nəzarət nöqtəsi',
        entryFee = 1000,
        checkpoints = {
            vector3(-1013.2, -797.5, 17.2),
            vector3(-1186.8, -762.2, 17.6),
            vector3(-1343.9, -669.7, 15.3),
            vector3(-1325.3, -512.2, 20.4),
            vector3(-1148.2, -421.5, 19.8),
            vector3(-1020.3, -512.2, 17.9),
        },
    },
}

-- Mövsüm bal sistemi (trek üzrə ən yaxşı vaxt sıralaması)
Config.Points = { 10, 8, 6, 5, 4, 3, 2, 1 }

-- Nəzarət nöqtəsi radiusu (metr)
Config.CheckpointRadius = 6.0
