-- 196 RP | İş sistemi
-- Hər iş: Başla (HQ) → İşlə (workPoints) → Sat/Çatdır (sellPoints)
-- və ya nəqliyyat işləri: Başla → Çatdır → Təhvil ver

Config = {}

Config.Jobs = {
    ---------------------------------------------------------
    -- TOPLAMA İŞLƏRİ (collect)
    ---------------------------------------------------------
    {
        name = 'baliqci',
        label = 'Balıqçı',
        icon = '🎣',
        type = 'collect',
        description = 'Dənizdə balıq tutun və balıq bazarında satın. Sakit və gəlirli iş!',
        hq = vector3(-1650.0, -1060.0, 13.0),
        workPoints = {
            vector3(-1650.0, -1060.0, 13.0), vector3(-1610.0, -1020.0, 13.0),
            vector3(-1570.0, -1060.0, 13.0), vector3(-1630.0, -980.0, 13.0),
            vector3(1330.0, 4240.0, 33.0)
        },
        sellPoints = { vector3(48.0, -1100.0, 29.5) },
        item = 'baliq',
        price = 25,
        workTime = 4500,
        cooldown = 2500,
        anim = { dict = 'amb@world_human_stand_fishing@base', lib = 'base' },
        messages = {
            'Balıq tutdunuz!',
            'Yaxşı balıq! Çantasına at!',
            'Daha bir balıq!'
        }
    },
    {
        name = 'medenci',
        label = 'Mədənçi',
        icon = '⛏️',
        type = 'collect',
        description = 'Dağda filiz çıxarın və filiz alıcısına satın.',
        hq = vector3(-590.0, 2090.0, 130.0),
        workPoints = {
            vector3(-590.0, 2090.0, 130.0), vector3(-610.0, 2060.0, 129.0),
            vector3(-560.0, 2120.0, 132.0), vector3(-540.0, 2070.0, 128.0),
            vector3(-620.0, 2130.0, 130.0)
        },
        sellPoints = { vector3(900.0, -2150.0, 29.0) },
        item = 'filiz',
        price = 30,
        workTime = 5000,
        cooldown = 3000,
        anim = { dict = 'amb@world_human_hammering@male@base', lib = 'base' },
        messages = {
            'Filiz çıxardınız!',
            'Ağır filiz parçası!',
            'Qiymətli filiz tapdınız!'
        }
    },
    {
        name = 'mescci',
        label = 'Meşəçi',
        icon = '🪓',
        type = 'collect',
        description = 'Meşədə odun hazırlayın və odun anbarına satın.',
        hq = vector3(-530.0, 5380.0, 70.0),
        workPoints = {
            vector3(-530.0, 5380.0, 70.0), vector3(-500.0, 5420.0, 72.0),
            vector3(-560.0, 5350.0, 68.0), vector3(-480.0, 5450.0, 75.0),
            vector3(-600.0, 5400.0, 70.0)
        },
        sellPoints = { vector3(800.0, -1550.0, 25.0) },
        item = 'odun',
        price = 20,
        workTime = 4500,
        cooldown = 2500,
        anim = { dict = 'amb@world_human_hammering@male@base', lib = 'base' },
        messages = {
            'Odun hazırladınız!',
            'Gözəl odun parçası!',
            'Meşədən odun gətirdiniz!'
        }
    },
    {
        name = 'fermer',
        label = 'Fermer',
        icon = '🌾',
        type = 'collect',
        description = 'Tarlada məhsul toplayın və kənd bazarında satın.',
        hq = vector3(2450.0, 4970.0, 46.0),
        workPoints = {
            vector3(2450.0, 4970.0, 46.0), vector3(2420.0, 4930.0, 44.0),
            vector3(2480.0, 4960.0, 46.0), vector3(2440.0, 5010.0, 48.0),
            vector3(2500.0, 4990.0, 45.0)
        },
        sellPoints = { vector3(1392.6, 3604.6, 35.0) },
        item = 'meyve',
        price = 15,
        workTime = 4000,
        cooldown = 2500,
        anim = { dict = 'amb@world_human_gardener_plant@male@base', lib = 'base' },
        messages = {
            'Təzə meyvə topladınız!',
            'Məhsul yığdınız!',
            'Səbət doldu!'
        }
    },
    {
        name = 'uzumci',
        label = 'Üzüm Yığan',
        icon = '🍇',
        type = 'collect',
        description = 'Üzüm bağında üzüm yığın və şərab zavoduna satın.',
        hq = vector3(-1870.0, 2945.0, 42.0),
        workPoints = {
            vector3(-1870.0, 2945.0, 42.0), vector3(-1840.0, 2960.0, 44.0),
            vector3(-1900.0, 2920.0, 41.0), vector3(-1830.0, 2900.0, 42.0),
            vector3(-1920.0, 2960.0, 43.0)
        },
        sellPoints = { vector3(-1930.0, 2880.0, 41.0) },
        item = 'uzum',
        price = 18,
        workTime = 4000,
        cooldown = 2500,
        anim = { dict = 'amb@world_human_gardener_plant@male@base', lib = 'base' },
        messages = {
            'Şirəli üzüm yığdınız!',
            'Salxım üzüm!',
            'Üzüm bağında məhsul!'
        }
    },
    {
        name = 'zibilci',
        label = 'Zibilçi',
        icon = '🗑️',
        type = 'collect',
        description = 'Şəhər küçələrindən zibil toplayın və resayklinq zavoduna aparın.',
        hq = vector3(-320.0, -1540.0, 31.0),
        workPoints = {
            vector3(-320.0, -1540.0, 31.0), vector3(-150.0, -1300.0, 31.0),
            vector3(50.0, -1250.0, 30.0), vector3(250.0, -900.0, 30.0),
            vector3(450.0, -1050.0, 29.0), vector3(-450.0, -900.0, 30.0)
        },
        sellPoints = { vector3(2050.0, 2830.0, 45.0) },
        item = 'zibil',
        price = 10,
        workTime = 3500,
        cooldown = 2000,
        anim = { dict = 'amb@prop_human_bum_bin', lib = 'base' },
        messages = {
            'Zibil topladınız!',
            'Küçə təmizləndi!',
            'Daha bir torba zibil!'
        }
    },
    {
        name = 'belediye',
        label = 'Bələdiyyə İşçisi',
        icon = '🏛️',
        type = 'collect',
        description = 'Şəhər meydanlarını təmizləyin və bələdiyyəyə təhvil verin. Şəhərin üzü sizdən asılıdır!',
        hq = vector3(240.0, -690.0, 30.5),
        workPoints = {
            vector3(215.0, -810.0, 30.7), vector3(100.0, -1100.0, 29.0),
            vector3(350.0, -950.0, 29.0), vector3(-150.0, -800.0, 30.0),
            vector3(450.0, -700.0, 28.0), vector3(600.0, -850.0, 25.0)
        },
        sellPoints = { vector3(240.0, -690.0, 30.5) },
        item = 'zibil',
        price = 8,
        workTime = 3500,
        cooldown = 2000,
        anim = { dict = 'amb@world_human_janitor@male@base', lib = 'base' },
        messages = {
            'Meydan təmizləndi!',
            'Şəhər daha təmizdir!',
            'Bələdiyyə işi görüldü!'
        }
    },
    {
        name = 'corekci',
        label = 'Çörəkçi',
        icon = '🥖',
        type = 'collect',
        description = 'Buğda sahəsindən buğda toplayın və çörək zavoduna çatdırın.',
        hq = vector3(1000.0, -2000.0, 30.0),
        workPoints = {
            vector3(2450.0, 4970.0, 46.0), vector3(2500.0, 4990.0, 45.0),
            vector3(2420.0, 4930.0, 44.0), vector3(2480.0, 5010.0, 46.0)
        },
        sellPoints = { vector3(1000.0, -2000.0, 30.0) },
        item = 'bugda',
        price = 12,
        workTime = 4000,
        cooldown = 2500,
        anim = { dict = 'amb@world_human_gardener_plant@male@base', lib = 'base' },
        messages = {
            'Buğda topladınız!',
            'Qızıl buğda dənləri!',
            'Tarla məhsulu!'
        }
    },
    {
        name = 'qessab',
        label = 'Qəssab',
        icon = '🥩',
        type = 'collect',
        description = 'Fermadan ət gətirin və əmtəə kombinatında emal edin.',
        hq = vector3(1010.0, -2120.0, 30.0),
        workPoints = {
            vector3(2500.0, 4900.0, 44.0), vector3(2530.0, 4920.0, 45.0),
            vector3(2480.0, 4940.0, 45.0)
        },
        sellPoints = { vector3(1010.0, -2120.0, 30.0) },
        item = 'mal_eti',
        price = 22,
        workTime = 4000,
        cooldown = 2500,
        anim = { dict = 'amb@world_human_hammering@male@base', lib = 'base' },
        messages = {
            'Təzə ət gətirdiniz!',
            'Ət emal edildi!',
            'Kombinata ət çatdı!'
        }
    },
    {
        name = 'elektrikci',
        label = 'Elektrikçi',
        icon = '⚡',
        type = 'collect',
        description = 'Enerji xətlərindən kabel yığın və stansiyaya çatdırın.',
        hq = vector3(880.0, -1300.0, 26.0),
        workPoints = {
            vector3(880.0, -1300.0, 26.0), vector3(850.0, -1350.0, 27.0),
            vector3(920.0, -1250.0, 26.0), vector3(800.0, -1200.0, 27.0),
            vector3(950.0, -1400.0, 28.0)
        },
        sellPoints = { vector3(880.0, -1300.0, 26.0) },
        item = 'kabel',
        price = 20,
        workTime = 4000,
        cooldown = 2500,
        anim = { dict = 'mini@repair', lib = 'fixing_a_ped' },
        messages = {
            'Kabel yığdınız!',
            'Enerji xətti təmir edildi!',
            'Stansiyaya kabel çatdı!'
        }
    },
    {
        name = 'limanici',
        label = 'Liman İşçisi',
        icon = '⚓',
        type = 'collect',
        description = 'Liman konteynerlərini boşaldın və anbara daşıyın.',
        hq = vector3(1050.0, -3100.0, 5.9),
        workPoints = {
            vector3(1050.0, -3100.0, 5.9), vector3(1000.0, -3050.0, 5.9),
            vector3(1100.0, -3080.0, 6.0), vector3(980.0, -3120.0, 5.9),
            vector3(1120.0, -3150.0, 6.0)
        },
        sellPoints = { vector3(900.0, -3300.0, 6.0) },
        item = 'konteyner',
        price = 35,
        workTime = 4500,
        cooldown = 2500,
        anim = { dict = 'amb@world_human_hammering@male@base', lib = 'base' },
        messages = {
            'Konteyner yükü boşaldıldı!',
            'Anbara yük çatdırıldı!',
            'Liman işi görüldü!'
        }
    },
    {
        name = 'demirci',
        label = 'Dəmirçi',
        icon = '🔨',
        type = 'collect',
        description = 'Qırıntı metal toplayın və dəmirçi emalatxanasında emal edin.',
        hq = vector3(1300.0, 1100.0, 100.0),
        workPoints = {
            vector3(1300.0, 1100.0, 100.0), vector3(1250.0, 1150.0, 98.0),
            vector3(1350.0, 1050.0, 102.0), vector3(1280.0, 1080.0, 99.0),
            vector3(1330.0, 1130.0, 101.0)
        },
        sellPoints = { vector3(1300.0, 1100.0, 100.0) },
        item = 'metal',
        price = 25,
        workTime = 4000,
        cooldown = 2500,
        anim = { dict = 'amb@world_human_hammering@male@base', lib = 'base' },
        messages = {
            'Metal topladınız!',
            'Dəmir parçası!',
            'Emalatxanaya metal çatdı!'
        }
    },
    {
        name = 'bagban',
        label = 'Bağban',
        icon = '🌿',
        type = 'collect',
        description = 'Parkları təmiz saxlayın — yarpaq yığın və bələdiyyəyə təhvil verin.',
        hq = vector3(-450.0, -1150.0, 12.0),
        workPoints = {
            vector3(-450.0, -1150.0, 12.0), vector3(-420.0, -1100.0, 12.0),
            vector3(-480.0, -1200.0, 12.0), vector3(-400.0, -1050.0, 11.0),
            vector3(-500.0, -1180.0, 12.0)
        },
        sellPoints = { vector3(240.0, -690.0, 30.5) },
        item = 'yarpaq',
        price = 6,
        workTime = 3000,
        cooldown = 2000,
        anim = { dict = 'amb@world_human_gardener_plant@male@base', lib = 'base' },
        messages = {
            'Yarpaq yığdınız!',
            'Park təmizləndi!',
            'Bağban işi görüldü!'
        }
    },

    ---------------------------------------------------------
    -- NƏQLİYYAT İŞLƏRİ (vehicle)
    ---------------------------------------------------------
    {
        name = 'taksi',
        label = 'Taksi Sürücüsü',
        icon = '🚕',
        type = 'vehicle',
        description = 'Sərnişinləri şəhərin istədiyi yerə aparın. Hər səfər pul qazandırır!',
        hq = vector3(895.0, -179.0, 74.7),
        vehicleSpawn = vector3(898.0, -176.0, 74.7),
        vehicleHeading = 240.0,
        vehicle = 'taxi',
        vehicleColor = { 252, 212, 40 },
        rounds = 5,
        pay = 140,
        destinations = {
            { label = 'Legion Meydanı', coords = vector3(215.0, -810.0, 30.7) },
            { label = 'Pillbox Xəstəxanası', coords = vector3(307.0, -595.0, 43.3) },
            { label = 'Maze Bank', coords = vector3(-75.0, -822.0, 30.0) },
            { label = 'Binco Geyim', coords = vector3(72.3, -1399.1, 29.4) },
            { label = '24/7 Market', coords = vector3(25.7, -1345.5, 29.5) },
            { label = 'Vanilla Unicorn', coords = vector3(127.4, -1304.0, 29.3) },
            { label = 'Del Perro Çimərliyi', coords = vector3(-1580.0, -1050.0, 13.0) },
            { label = 'Vangelico Zərgər', coords = vector3(-630.0, -240.0, 38.1) },
            { label = 'Polis İdarəsi', coords = vector3(425.1, -979.5, 30.7) },
            { label = 'Fleeca Bank', coords = vector3(351.6, -594.9, 28.8) }
        }
    },
    {
        name = 'avtobus',
        label = 'Avtobus Sürücüsü',
        icon = '🚌',
        type = 'vehicle',
        description = 'Şəhər marşrutu ilə avtobus sürün — dayanacaqlarda sərnişinlər sizi gözləyir!',
        hq = vector3(450.0, -650.0, 28.0),
        vehicleSpawn = vector3(455.0, -640.0, 28.0),
        vehicleHeading = 90.0,
        vehicle = 'bus',
        vehicleColor = { 60, 90, 160 },
        rounds = 7,
        pay = 100,
        destinations = {
            { label = 'Avtovağzal', coords = vector3(452.0, -625.0, 28.0) },
            { label = 'Legion Meydanı', coords = vector3(215.0, -810.0, 30.7) },
            { label = 'Binco Geyim', coords = vector3(72.3, -1399.1, 29.4) },
            { label = '24/7 Market', coords = vector3(25.7, -1345.5, 29.5) },
            { label = 'Maze Bank', coords = vector3(-75.0, -822.0, 30.0) },
            { label = 'Pillbox Xəstəxanası', coords = vector3(307.0, -595.0, 43.3) },
            { label = 'Avtovağzal', coords = vector3(452.0, -625.0, 28.0) }
        }
    },
    {
        name = 'yuk',
        label = 'Yük Maşını Sürücüsü',
        icon = '🚛',
        type = 'vehicle',
        description = 'Yük maşını ilə şəhərlərarası yük daşıyın — ən gəlirli işlərdən biri!',
        hq = vector3(900.0, -2100.0, 30.0),
        vehicleSpawn = vector3(905.0, -2130.0, 30.0),
        vehicleHeading = 20.0,
        vehicle = 'packer',
        vehicleColor = { 200, 40, 40 },
        rounds = 4,
        pay = 350,
        destinations = {
            { label = 'Elysian Limanı', coords = vector3(1050.0, -3100.0, 5.9) },
            { label = 'Böyük Anbar', coords = vector3(-750.0, -2200.0, 20.0) },
            { label = 'Resayklinq Zavodu', coords = vector3(2050.0, 2830.0, 45.0) },
            { label = 'Ət Kombinatı', coords = vector3(1010.0, -2120.0, 30.0) },
            { label = 'La Mesa Sənaye', coords = vector3(1000.0, -2300.0, 30.0) }
        }
    },
    {
        name = 'kuryer',
        label = 'Kuryer',
        icon = '📦',
        type = 'vehicle',
        description = 'Poçt idarəsindən bağlamaları götürün və motosikletlə ünvanlara çatdırın.',
        hq = vector3(-260.0, -720.0, 32.0),
        vehicleSpawn = vector3(-255.0, -715.0, 32.0),
        vehicleHeading = 160.0,
        vehicle = 'ruffian',
        vehicleColor = { 220, 220, 220 },
        rounds = 6,
        pay = 120,
        destinations = {
            { label = 'Legion Meydanı', coords = vector3(215.0, -810.0, 30.7) },
            { label = 'Maze Bank', coords = vector3(-75.0, -822.0, 30.0) },
            { label = '24/7 Market', coords = vector3(25.7, -1345.5, 29.5) },
            { label = 'Polis İdarəsi', coords = vector3(425.1, -979.5, 30.7) },
            { label = 'Avtosalon', coords = vector3(-42.5, -1100.6, 26.4) },
            { label = 'Vangelico Zərgər', coords = vector3(-630.0, -240.0, 38.1) },
            { label = 'Restoran Pier', coords = vector3(-1631.0, -1010.0, 6.0) },
            { label = 'Binco Geyim', coords = vector3(72.3, -1399.1, 29.4) }
        }
    }
}

-- İş məlumatlarını tapmaq üçün köməkçi
Config.GetJob = function(name)
    for i = 1, #Config.Jobs do
        if Config.Jobs[i].name == name then
            return Config.Jobs[i]
        end
    end
    return nil
end
