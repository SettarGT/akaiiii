-- 196 RP | Məkanlar (Bələdiyyə, mexanik, balıqçılıq, market və 80-dən çox real məkan)
-- Hər giriş xəritədə bir yer (blip + marker) yaradır.
-- E düyməsi ilə məkan haqqında məlumat açılır.

Config = {}

-- Blip rəngləri (FiveM enumları):
-- 0= Mavi, 1 = Tünd-qırmızı, 2 = Qırmızı, 3 = Yaşıl, 4 = Cəhrayı,
-- 5 = Sarı, 6 = Ağ, 7 = Bənövşəyi, 17 = Narıncı, 38 = Açıq-göy, 49 = Tünd-mavi

Config.Locations = {
    -- ==================== DÖVLƏT VƏ RƏSMİ BİNALAR ====================
    {
        id = 'belediye_bina', name = 'Bələdiyyə binası (Nəriman Nərimanov)',
        desc = 'Şəhər icra hakimiyyətinin binası. İş elanları, qeydiyyat və vətəndaş xidmətləri buradadır.',
        coords = vector3(240.0, -690.0, 30.5), color = { 245, 185, 66 }, marker = 1, size = 1.2,
        blip = { sprite = 475, color = 66, scale = 0.9 }, category = 'Dövlət'
    },
    {
        id = 'vətendaş_qeydiyyəti', name = 'Vətəndaş qeydiyyatı şöbəsi (28 May)',
        desc = 'Yeni vətəndaşların qeydiyyatı və şəxsiyyət vəsiqəsinin verilməsi burada aparılır.',
        coords = vector3(162.0, -965.0, 30.1), color = { 245, 185, 66 }, marker = 1, size = 1.0,
        blip = { sprite = 476, color = 66, scale = 0.8 }, category = 'Dövlət'
    },
    {
        id = 'mehkeme', name = 'Məhkəmə binası (Nəriman Nərimanov)',
        desc = 'Ədliyyə sarayı. Məhkəmə prosesləri və hüquqi məsələlər burada həll olunur.',
        coords = vector3(251.0, -700.0, 30.5), color = { 200, 200, 220 }, marker = 1, size = 1.2,
        blip = { sprite = 472, color = 0, scale = 0.9 }, category = 'Dövlət'
    },
    {
        id = 'polis_merkez', name = 'Polis İdarəsi (Mission Row) (28 May)',
        desc = 'Şəhər polis idarəsi. Cinayət barədə məlumat verin və ya polis işinə müraciət edin.',
        coords = vector3(425.1, -979.5, 30.7), color = { 66, 135, 245 }, marker = 1, size = 1.2,
        blip = { sprite = 60, color = 38, scale = 0.9 }, category = 'Dövlət'
    },
    {
        id = 'polis_sandy', name = 'Sandy Shores Polis Bölməsi (Qara Qarayev)',
        desc = 'Səhra bölgəsinin polis bölməsi.',
        coords = vector3(1853.0, 3686.0, 34.3), color = { 66, 135, 245 }, marker = 1, size = 1.0,
        blip = { sprite = 60, color = 38, scale = 0.8 }, category = 'Dövlət'
    },
    {
        id = 'polis_paleto', name = 'Paleto Bay Polis Bölməsi (Qara Qarayev)',
        desc = 'Şimal sahilinin polis bölməsi.',
        coords = vector3(-447.0, 6014.0, 31.7), color = { 66, 135, 245 }, marker = 1, size = 1.0,
        blip = { sprite = 60, color = 38, scale = 0.8 }, category = 'Dövlət'
    },
    {
        id = 'polis_davis', name = 'Davis Polis Bölməsi (Xətai)',
        desc = 'Cənub məhəlləsinin polis bölməsi.',
        coords = vector3(360.0, -1580.0, 29.3), color = { 66, 135, 245 }, marker = 1, size = 1.0,
        blip = { sprite = 60, color = 38, scale = 0.8 }, category = 'Dövlət'
    },
    {
        id = 'hebsxana', name = 'Bolingbroke Həbsxanası (Qara Qarayev)',
        desc = 'Şəhər həbsxanası. Cəza çəkənlər burada saxlanılır.',
        coords = vector3(1845.0, 2585.0, 45.7), color = { 160, 160, 160 }, marker = 1, size = 1.2,
        blip = { sprite = 237, color = 0, scale = 0.9 }, category = 'Dövlət'
    },
    {
        id = 'yanğın_stansiya', name = 'Yanğınsöndürən stansiyası (Gənclik)',
        desc = 'Şəhər yanğınsöndürmə xidmətinin stansiyası.',
        coords = vector3(-370.0, -130.0, 39.0), color = { 245, 80, 60 }, marker = 1, size = 1.2,
        blip = { sprite = 436, color = 1, scale = 0.9 }, category = 'Dövlət'
    },

    -- ==================== SƏHİYYƏ ====================
    {
        id = 'xeshtexana', name = 'Pillbox Xəstəxanası (Nəriman Nərimanov)',
        desc = 'Şəhərin ən böyük xəstəxanası. Təcili yardım və müalicə burada aparılır.',
        coords = vector3(307.0, -595.0, 43.3), color = { 240, 80, 80 }, marker = 1, size = 1.3,
        blip = { sprite = 61, color = 1, scale = 1.0 }, category = 'Səhiyyə'
    },
    {
        id = 'klinika_sandy', name = 'Sandy Shores Klinikası (Qara Qarayev)',
        desc = 'Səhra bölgəsinin tibb məntəqəsi.',
        coords = vector3(1839.0, 3672.0, 34.3), color = { 240, 80, 80 }, marker = 1, size = 1.0,
        blip = { sprite = 61, color = 1, scale = 0.8 }, category = 'Səhiyyə'
    },
    {
        id = 'klinika_paleto', name = 'Paleto Bay Klinikası (Qara Qarayev)',
        desc = 'Şimal sahilinin tibb məntəqəsi.',
        coords = vector3(-247.0, 6330.0, 32.4), color = { 240, 80, 80 }, marker = 1, size = 1.0,
        blip = { sprite = 61, color = 1, scale = 0.8 }, category = 'Səhiyyə'
    },
    {
        id = 'aptek_merkez', name = 'Mərkəzi Aptek (Xətai)',
        desc = 'Dərman vasitələri və bandajlar burada satılır.',
        coords = vector3(176.0, -1300.0, 29.4), color = { 120, 220, 160 }, marker = 1, size = 0.9,
        blip = { sprite = 403, color = 3, scale = 0.7 }, category = 'Səhiyyə'
    },
    {
        id = 'heyvan_xestexanasi', name = 'Heyvan Klinikası (İçərişəhər)',
        desc = 'Ev heyvanlarının müalicəsi və baxımı üçün klinika.',
        coords = vector3(-1870.0, -1200.0, 19.0), color = { 160, 120, 220 }, marker = 1, size = 0.9,
        blip = { sprite = 406, color = 7, scale = 0.8 }, category = 'Səhiyyə'
    },

    -- ==================== BANKLAR ====================
    {
        id = 'bank_maze', name = 'Maze Bank (28 May)',
        desc = 'Şəhərin ən böyük bankı. Hesab əməliyyatları, kredit və depozitlər.',
        coords = vector3(-75.0, -822.0, 30.0), color = { 120, 200, 250 }, marker = 1, size = 1.2,
        blip = { sprite = 108, color = 49, scale = 0.9 }, category = 'Maliyyə'
    },
    {
        id = 'bank_fleeca_1', name = 'Fleeca Bank — Alta (Nəriman Nərimanov)',
        desc = 'Fleeca Bank filialı.',
        coords = vector3(314.5, -278.5, 54.2), color = { 120, 200, 250 }, marker = 1, size = 1.0,
        blip = { sprite = 108, color = 49, scale = 0.8 }, category = 'Maliyyə'
    },
    {
        id = 'bank_fleeca_2', name = 'Fleeca Bank — Pillbox (Nəriman Nərimanov)',
        desc = 'Fleeca Bank filialı.',
        coords = vector3(351.6, -594.9, 28.8), color = { 120, 200, 250 }, marker = 1, size = 1.0,
        blip = { sprite = 108, color = 49, scale = 0.8 }, category = 'Maliyyə'
    },
    {
        id = 'bank_fleeca_3', name = 'Fleeca Bank — Vespucci (20 Yanvar)',
        desc = 'Fleeca Bank filialı.',
        coords = vector3(-1212.9, -330.6, 37.8), color = { 120, 200, 250 }, marker = 1, size = 1.0,
        blip = { sprite = 108, color = 49, scale = 0.8 }, category = 'Maliyyə'
    },
    {
        id = 'bank_fleeca_4', name = 'Fleeca Bank — Del Perro (Elmlər Akademiyası)',
        desc = 'Fleeca Bank filialı.',
        coords = vector3(-1315.7, -834.7, 16.9), color = { 120, 200, 250 }, marker = 1, size = 1.0,
        blip = { sprite = 108, color = 49, scale = 0.8 }, category = 'Maliyyə'
    },
    {
        id = 'bank_fleeca_5', name = 'Fleeca Bank — Paleto (İçərişəhər)',
        desc = 'Fleeca Bank filialı.',
        coords = vector3(-2961.2, 482.6, 15.7), color = { 120, 200, 250 }, marker = 1, size = 1.0,
        blip = { sprite = 108, color = 49, scale = 0.8 }, category = 'Maliyyə'
    },
    {
        id = 'bank_sandy', name = 'Fleeca Bank — Sandy Shores (Qara Qarayev)',
        desc = 'Fleeca Bank filialı.',
        coords = vector3(1175.1, 2706.4, 38.1), color = { 120, 200, 250 }, marker = 1, size = 1.0,
        blip = { sprite = 108, color = 49, scale = 0.8 }, category = 'Maliyyə'
    },
    {
        id = 'birja', name = 'Şəhər Birjası (28 May)',
        desc = 'Maliyyə bazarlarının ürəyi. Biznes sahibləri burada görüşür.',
        coords = vector3(-140.0, -600.0, 30.0), color = { 120, 200, 250 }, marker = 1, size = 1.0,
        blip = { sprite = 108, color = 49, scale = 0.8 }, category = 'Maliyyə'
    },

    -- ==================== NƏQLİYYAT ====================
    {
        id = 'avtovağzal', name = 'Şəhər Avtovağzalı (Nəriman Nərimanov)',
        desc = 'Şəhərlərarası avtobusların yola düşdüyü mərkəzi avtovağzal.',
        coords = vector3(452.0, -625.0, 28.0), color = { 255, 200, 80 }, marker = 1, size = 1.1,
        blip = { sprite = 513, color = 66, scale = 0.9 }, category = 'Nəqliyyat'
    },
    {
        id = 'dəmiryol_stansiya', name = 'Union Dəmiryol Stansiyası (Koroğlu)',
        desc = 'Şəhərin mərkəzi dəmiryol stansiyası.',
        coords = vector3(703.0, -950.0, 25.0), color = { 255, 200, 80 }, marker = 1, size = 1.1,
        blip = { sprite = 36, color = 66, scale = 0.9 }, category = 'Nəqliyyat'
    },
    {
        id = 'hava_limani', name = 'Los Santos Beynəlxalq Hava Limanı (Ağ şəhər)',
        desc = 'Şəhərin əsas hava limanı. Uçuşlar və aviasiya biznesi.',
        coords = vector3(-1030.0, -2750.0, 20.0), color = { 255, 200, 80 }, marker = 1, size = 1.3,
        blip = { sprite = 90, color = 5, scale = 1.0 }, category = 'Nəqliyyat'
    },
    {
        id = 'heliport', name = 'Los Santos Heliportu (Sahil)',
        desc = 'Vertolyot eniş meydançası.',
        coords = vector3(-745.0, -1445.0, 5.0), color = { 255, 200, 80 }, marker = 1, size = 1.0,
        blip = { sprite = 64, color = 5, scale = 0.8 }, category = 'Nəqliyyat'
    },
    {
        id = 'liman_elysian', name = 'Elysian Limanı (Ağ şəhər)',
        desc = 'Yük gəmilərinin çatdığı ən böyük liman. Liman işləri burada aparılır.',
        coords = vector3(1050.0, -3100.0, 5.9), color = { 255, 200, 80 }, marker = 1, size = 1.3,
        blip = { sprite = 455, color = 66, scale = 0.9 }, category = 'Nəqliyyat'
    },
    {
        id = 'marina', name = 'Vespucci Marina (Elmlər Akademiyası)',
        desc = 'Yaxtaların və qayıqların saxlanıldığı marina.',
        coords = vector3(-1010.0, -640.0, 12.0), color = { 255, 200, 80 }, marker = 1, size = 1.0,
        blip = { sprite = 410, color = 5, scale = 0.8 }, category = 'Nəqliyyat'
    },
    {
        id = 'taksi_dayanacaq', name = 'Taksi Dayanacağı (Dərnəgül)',
        desc = 'Taksi xidmətinin mərkəzi. Taksi işinə buradan başlaya bilərsiniz.',
        coords = vector3(895.0, -179.0, 74.7), color = { 250, 220, 90 }, marker = 1, size = 1.0,
        blip = { sprite = 56, color = 5, scale = 0.9 }, category = 'Nəqliyyat'
    },

    -- ==================== TİCARƏT VƏ MAĞAZALAR ====================
    {
        id = 'market_legion', name = '24/7 Market — Legion (Xətai)',
        desc = 'Gündəlik ərzaq və məişət malları mağazası.',
        coords = vector3(25.7, -1345.5, 29.5), color = { 120, 220, 160 }, marker = 1, size = 1.0,
        blip = { sprite = 52, color = 3, scale = 0.8 }, category = 'Ticarət'
    },
    {
        id = 'market_vinewood', name = '24/7 Market — Vinewood (Nəriman Nərimanov)',
        desc = 'Gündəlik ərzaq və məişət malları mağazası.',
        coords = vector3(373.9, 325.8, 103.6), color = { 120, 220, 160 }, marker = 1, size = 1.0,
        blip = { sprite = 52, color = 3, scale = 0.8 }, category = 'Ticarət'
    },
    {
        id = 'market_ocaen', name = '24/7 Market — Great Ocean (İçərişəhər)',
        desc = 'Gündəlik ərzaq və məişət malları mağazası.',
        coords = vector3(-3241.9, 1001.2, 12.8), color = { 120, 220, 160 }, marker = 1, size = 1.0,
        blip = { sprite = 52, color = 3, scale = 0.8 }, category = 'Ticarət'
    },
    {
        id = 'market_strawberry', name = '24/7 Market — Strawberry (Elmlər Akademiyası)',
        desc = 'Gündəlik ərzaq və məişət malları mağazası.',
        coords = vector3(-1222.9, -908.3, 12.3), color = { 120, 220, 160 }, marker = 1, size = 1.0,
        blip = { sprite = 52, color = 3, scale = 0.8 }, category = 'Ticarət'
    },
    {
        id = 'market_sandy', name = '24/7 Market — Sandy Shores (Qara Qarayev)',
        desc = 'Gündəlik ərzaq və məişət malları mağazası.',
        coords = vector3(549.2, 2669.2, 42.2), color = { 120, 220, 160 }, marker = 1, size = 1.0,
        blip = { sprite = 52, color = 3, scale = 0.8 }, category = 'Ticarət'
    },
    {
        id = 'market_paleto', name = '24/7 Market — Paleto Bay (İçərişəhər)',
        desc = 'Gündəlik ərzaq və məişət malları mağazası.',
        coords = vector3(-3038.9, 585.9, 7.9), color = { 120, 220, 160 }, marker = 1, size = 1.0,
        blip = { sprite = 52, color = 3, scale = 0.8 }, category = 'Ticarət'
    },
    {
        id = 'supermarket', name = 'Rob\'s Supermarket (Elmlər Akademiyası)',
        desc = 'Böyük ərzaq supermarketi. Hər şey bir yerdə!',
        coords = vector3(-706.0, -905.0, 19.2), color = { 120, 220, 160 }, marker = 1, size = 1.1,
        blip = { sprite = 52, color = 3, scale = 0.9 }, category = 'Ticarət'
    },
    {
        id = 'elektronika_mağaza', name = 'Elektronika Mağazası (Elmlər Akademiyası)',
        desc = 'Telefonlar, kompüterlər və elektron cihazlar.',
        coords = vector3(-1222.9, -907.0, 12.3), color = { 140, 180, 255 }, marker = 1, size = 0.9,
        blip = { sprite = 500, color = 49, scale = 0.8 }, category = 'Ticarət'
    },
    {
        id = 'mebel_mağaza', name = 'Mebel Mağazası (Dərnəgül)',
        desc = 'Ev üçün mebel və daxili bəzək əşyaları.',
        coords = vector3(1130.0, -400.0, 66.0), color = { 220, 170, 110 }, marker = 1, size = 0.9,
        blip = { sprite = 524, color = 17, scale = 0.8 }, category = 'Ticarət'
    },
    {
        id = 'zerger_dukani', name = 'Zərgər Dükanı (Vangelico) (Gənclik)',
        desc = 'Qızıl, brilyant və qiymətli zinət əşyaları.',
        coords = vector3(-630.0, -240.0, 38.1), color = { 250, 210, 100 }, marker = 1, size = 0.9,
        blip = { sprite = 617, color = 66, scale = 0.8 }, category = 'Ticarət'
    },
    {
        id = 'kitab_mağaza', name = 'Kitab Mağazası (Elmlər Akademiyası)',
        desc = 'Kitablar və dəftərxana ləvazimatları.',
        coords = vector3(-1222.0, -908.0, 12.3), color = { 200, 170, 130 }, marker = 1, size = 0.8,
        blip = { sprite = 499, color = 2, scale = 0.7 }, category = 'Ticarət'
    },
    {
        id = 'çiçək_dukani', name = 'Çiçək Dükanı (28 May)',
        desc = 'Təzə çiçəklər və buketlər.',
        coords = vector3(-420.0, -1120.0, 15.0), color = { 240, 140, 200 }, marker = 1, size = 0.8,
        blip = { sprite = 522, color = 2, scale = 0.7 }, category = 'Ticarət'
    },
    {
        id = 'heyvan_mağaza', name = 'Heyvan Mağazası (Qara Qarayev)',
        desc = 'Ev heyvanları və onlar üçün ləvazimatlar.',
        coords = vector3(560.0, 2700.0, 42.2), color = { 200, 160, 240 }, marker = 1, size = 0.8,
        blip = { sprite = 406, color = 7, scale = 0.7 }, category = 'Ticarət'
    },
    {
        id = 'oyuncaq_mağaza', name = 'Oyuncaq Mağazası (Sahil)',
        desc = 'Uşaqlar üçün oyuncaqlar.',
        coords = vector3(-1150.0, -1600.0, 5.0), color = { 255, 150, 150 }, marker = 1, size = 0.8,
        blip = { sprite = 522, color = 2, scale = 0.7 }, category = 'Ticarət'
    },
    {
        id = 'internet_kafe', name = 'İnternet Kafe (20 Yanvar)',
        desc = 'Kompüter xidmətləri və internet.',
        coords = vector3(-1075.0, -260.0, 37.0), color = { 130, 170, 255 }, marker = 1, size = 0.8,
        blip = { sprite = 500, color = 49, scale = 0.7 }, category = 'Ticarət'
    },
    {
        id = 'açıq_bazar', name = 'Açıq Kənd Bazarı (Qara Qarayev)',
        desc = 'Yerli məhsulların satıldığı açıq bazar.',
        coords = vector3(1392.6, 3604.6, 35.0), color = { 120, 220, 160 }, marker = 1, size = 1.0,
        blip = { sprite = 476, color = 3, scale = 0.8 }, category = 'Ticarət'
    },

    -- ==================== YEMƏK VƏ İÇKİ ====================
    {
        id = 'restoran_1', name = 'Restoran — Legion Meydanı (Xətai)',
        desc = 'Şəhərin mərkəzində ləziz yeməklər.',
        coords = vector3(240.0, -1380.0, 30.0), color = { 255, 200, 120 }, marker = 1, size = 0.9,
        blip = { sprite = 498, color = 66, scale = 0.8 }, category = 'Yemək'
    },
    {
        id = 'restoran_pier', name = 'Del Perro Pier Restoranı (İçərişəhər)',
        desc = 'Dəniz məhsulları və gözəl mənzərə.',
        coords = vector3(-1631.0, -1010.0, 6.0), color = { 255, 200, 120 }, marker = 1, size = 0.9,
        blip = { sprite = 498, color = 66, scale = 0.8 }, category = 'Yemək'
    },
    {
        id = 'kafe_bean', name = 'Bean Machine Kafesi (Gənclik)',
        desc = 'Ən yaxşı qəhvə şəhərin tam mərkəzində.',
        coords = vector3(-630.0, -236.0, 38.1), color = { 200, 150, 100 }, marker = 1, size = 0.8,
        blip = { sprite = 526, color = 2, scale = 0.7 }, category = 'Yemək'
    },
    {
        id = 'fastfood', name = 'Fast Food — Burger Shot (Xətai)',
        desc = 'Tez və dadlı yeməklər.',
        coords = vector3(72.0, -1399.0, 29.4), color = { 255, 220, 100 }, marker = 1, size = 0.9,
        blip = { sprite = 505, color = 66, scale = 0.8 }, category = 'Yemək'
    },
    {
        id = 'gecə_klubu', name = 'Vanilla Unicorn Gecə Klubu (Xətai)',
        desc = 'Şəhərin ən məşhur gecə klubu.',
        coords = vector3(127.4, -1304.0, 29.3), color = { 240, 100, 200 }, marker = 1, size = 1.0,
        blip = { sprite = 121, color = 2, scale = 0.9 }, category = 'Yemək'
    },
    {
        id = 'bar_tequila', name = 'Tequi-la-la Bar (Gənclik)',
        desc = 'Vespucci bulvarında məşhur bar.',
        coords = vector3(-560.0, -288.0, 45.0), color = { 240, 100, 200 }, marker = 1, size = 0.9,
        blip = { sprite = 93, color = 2, scale = 0.8 }, category = 'Yemək'
    },
    {
        id = 'bar_bahama', name = 'Bahama Mamas Klubu (20 Yanvar)',
        desc = 'Şəhərin ən parlaq əyləncə məkanı.',
        coords = vector3(-1388.8, -586.0, 30.2), color = { 240, 100, 200 }, marker = 1, size = 0.9,
        blip = { sprite = 121, color = 2, scale = 0.8 }, category = 'Yemək'
    },
    {
        id = 'cay_evi', name = 'Çay Evi (Elmlər Akademiyası)',
        desc = 'Ətirli çay, qənd və gözəl söhbətlər.',
        coords = vector3(-1220.0, -910.0, 12.3), color = { 200, 130, 80 }, marker = 1, size = 0.8,
        blip = { sprite = 526, color = 2, scale = 0.7 }, category = 'Yemək'
    },
    {
        id = 'dondurma', name = 'Dondurma Mağazası (Xətai)',
        desc = 'Şəhərin ən dadlı dondurmaları.',
        coords = vector3(455.0, -1280.0, 29.5), color = { 255, 180, 220 }, marker = 1, size = 0.8,
        blip = { sprite = 93, color = 2, scale = 0.7 }, category = 'Yemək'
    },

    -- ==================== XİDMƏT VƏ İSTİRAHƏT ====================
    {
        id = 'idman_zali', name = 'İdman Zalı (Sahil)',
        desc = 'Fitnes və idman üçün ən yaxşı yer.',
        coords = vector3(-710.0, -1510.0, 10.5), color = { 150, 220, 255 }, marker = 1, size = 0.9,
        blip = { sprite = 311, color = 49, scale = 0.8 }, category = 'İstirahət'
    },
    {
        id = 'hovuz', name = 'Şəhər Hovuzu (20 Yanvar)',
        desc = 'Üzgüçülük və istirahət üçün hovuz.',
        coords = vector3(-1210.0, -520.0, 15.0), color = { 120, 200, 255 }, marker = 1, size = 0.9,
        blip = { sprite = 68, color = 38, scale = 0.8 }, category = 'İstirahət'
    },
    {
        id = 'golf_klub', name = 'Los Santos Golf Klubu (Koroğlu)',
        desc = 'Şəhərin ən dəbli idman və istirahət klubu.',
        coords = vector3(1116.0, -1294.0, 43.2), color = { 120, 220, 120 }, marker = 1, size = 1.0,
        blip = { sprite = 109, color = 3, scale = 0.9 }, category = 'İstirahət'
    },
    {
        id = 'kazino', name = 'Diamond Kazinosu (Dərnəgül)',
        desc = 'Böyük kazino — amma unutmayın, qumar riskdir!',
        coords = vector3(925.0, 46.0, 81.0), color = { 250, 210, 100 }, marker = 1, size = 1.1,
        blip = { sprite = 617, color = 66, scale = 0.9 }, category = 'İstirahət'
    },
    {
        id = 'kinoteatr', name = 'Kinoteatr (Nəriman Nərimanov)',
        desc = 'Yeni filmlər və popkorn.',
        coords = vector3(330.0, 205.0, 110.0), color = { 255, 150, 150 }, marker = 1, size = 0.9,
        blip = { sprite = 502, color = 2, scale = 0.8 }, category = 'İstirahət'
    },
    {
        id = 'teatr', name = 'Teatr binası (28 May)',
        desc = 'Şəhər teatrı — mədəni həyatın mərkəzi.',
        coords = vector3(-250.0, -900.0, 30.0), color = { 220, 170, 220 }, marker = 1, size = 0.9,
        blip = { sprite = 502, color = 7, scale = 0.8 }, category = 'İstirahət'
    },
    {
        id = 'muzey', name = 'Şəhər Muzeyi (Elmlər Akademiyası)',
        desc = 'Tarix və mədəniyyət muzeyi.',
        coords = vector3(-1070.0, -720.0, 32.0), color = { 200, 190, 170 }, marker = 1, size = 0.9,
        blip = { sprite = 499, color = 0, scale = 0.8 }, category = 'İstirahət'
    },
    {
        id = 'legion_meydan', name = 'Legion Meydanı (28 May)',
        desc = 'Şəhərin ürəyi — görüşlər və hadisələr burada baş verir.',
        coords = vector3(215.0, -810.0, 30.7), color = { 255, 240, 200 }, marker = 1, size = 1.2,
        blip = { sprite = 475, color = 5, scale = 0.9 }, category = 'İstirahət'
    },
    {
        id = 'çimərlik_del_perro', name = 'Del Perro Çimərliyi (İçərişəhər)',
        desc = 'Şəhərin ən məşhur çimərliyi. Günəş, qum və dəniz!',
        coords = vector3(-1580.0, -1050.0, 13.0), color = { 120, 220, 255 }, marker = 1, size = 1.1,
        blip = { sprite = 72, color = 38, scale = 0.9 }, category = 'İstirahət'
    },
    {
        id = 'çimərlik_vespucci', name = 'Vespucci Çimərliyi (Sahil)',
        desc = 'Skaterlər və gənclərin sevimli yeri.',
        coords = vector3(-1200.0, -1600.0, 5.0), color = { 120, 220, 255 }, marker = 1, size = 1.0,
        blip = { sprite = 72, color = 38, scale = 0.8 }, category = 'İstirahət'
    },
    {
        id = 'park', name = 'Şəhər Parkı (28 May)',
        desc = 'Ailə və dostlarla gəzinti üçün yaşıl park.',
        coords = vector3(-450.0, -1150.0, 12.0), color = { 120, 220, 120 }, marker = 1, size = 1.0,
        blip = { sprite = 72, color = 3, scale = 0.8 }, category = 'İstirahət'
    },
    {
        id = 'vinwood_təpə', name = 'Vinewood Təpəsi — Mənzərə Nöqtəsi (Nəriman Nərimanov)',
        desc = 'Şəhərin ən gözəl mənzərəsi. Foto üçün ideal yer!',
        coords = vector3(640.0, 120.0, 200.0), color = { 255, 240, 200 }, marker = 1, size = 1.0,
        blip = { sprite = 483, color = 5, scale = 0.8 }, category = 'İstirahət'
    },

    -- ==================== İŞ YERLƏRİ ====================
    {
        id = 'balıqçılıq_sahil', name = 'Balıqçılıq Sahili',
        desc = 'Balıq tutmaq üçün ən yaxşı yer. Balıqçılıq işi üçün buraya gəlin!',
        coords = vector3(-1650.0, -1060.0, 13.0), color = { 120, 200, 255 }, marker = 1, size = 1.0,
        blip = { sprite = 68, color = 38, scale = 0.8 }, category = 'İş'
    },
    {
        id = 'balıqçılıq_göl', name = 'Alamo Gölü — Balıqçılıq (Qara Qarayev)',
        desc = 'Göl balıqçılığı — sakit və gəlirli iş.',
        coords = vector3(1330.0, 4240.0, 33.0), color = { 120, 200, 255 }, marker = 1, size = 1.0,
        blip = { sprite = 68, color = 38, scale = 0.8 }, category = 'İş'
    },
    {
        id = 'mədən', name = 'Mədən Sahəsi (Gənclik)',
        desc = 'Fil və qiymətli daşların çıxarıldığı mədən.',
        coords = vector3(-590.0, 2090.0, 130.0), color = { 200, 180, 150 }, marker = 1, size = 1.0,
        blip = { sprite = 478, color = 0, scale = 0.8 }, category = 'İş'
    },
    {
        id = 'meşə', name = 'Meşə Təsərrüfatı (Qara Qarayev)',
        desc = 'Ağac kəsmə və odun hazırlama işi.',
        coords = vector3(-530.0, 5380.0, 70.0), color = { 150, 190, 120 }, marker = 1, size = 1.0,
        blip = { sprite = 476, color = 3, scale = 0.8 }, category = 'İş'
    },
    {
        id = 'ferma', name = 'Grapeseed Ferması (Qara Qarayev)',
        desc = 'Əkinçilik və heyvandarlıq — kənd həyatının ürəyi.',
        coords = vector3(2450.0, 4970.0, 46.0), color = { 220, 200, 120 }, marker = 1, size = 1.0,
        blip = { sprite = 476, color = 66, scale = 0.8 }, category = 'İş'
    },
    {
        id = 'üzüm_bağı', name = 'Üzüm Bağı (20 Yanvar)',
        desc = 'Üzüm yığımı və şərab istehsalı.',
        coords = vector3(-1870.0, 2945.0, 42.0), color = { 200, 120, 160 }, marker = 1, size = 1.0,
        blip = { sprite = 478, color = 2, scale = 0.8 }, category = 'İş'
    },
    {
        id = 'zibilxana', name = 'Zibil İdarəsi (28 May)',
        desc = 'Şəhər təmizliyi işi. Zibil yığın və şəhəri təmiz saxlayın!',
        coords = vector3(-320.0, -1540.0, 31.0), color = { 170, 170, 170 }, marker = 1, size = 1.0,
        blip = { sprite = 318, color = 0, scale = 0.8 }, category = 'İş'
    },
    {
        id = 'poçt', name = 'Poçt İdarəsi (28 May)',
        desc = 'Məktub və bağlama çatdırılması işi.',
        coords = vector3(-260.0, -720.0, 32.0), color = { 200, 220, 160 }, marker = 1, size = 1.0,
        blip = { sprite = 468, color = 66, scale = 0.8 }, category = 'İş'
    },
    {
        id = 'yük_şirkəti', name = 'Yük Daşıma Şirkəti (Xətai)',
        desc = 'Şəhərlərarası yük daşıma işi. Böyük maşınlar və böyük qazanclar!',
        coords = vector3(900.0, -2100.0, 30.0), color = { 255, 200, 120 }, marker = 1, size = 1.0,
        blip = { sprite = 478, color = 66, scale = 0.8 }, category = 'İş'
    },
    {
        id = 'kuryer', name = 'Kuryer Xidməti (Sahil)',
        desc = 'Sürətli çatdırılma — motosikletlə şəhər boyu bağlama daşıyın.',
        coords = vector3(-1100.0, -1200.0, 15.0), color = { 255, 200, 120 }, marker = 1, size = 1.0,
        blip = { sprite = 478, color = 66, scale = 0.8 }, category = 'İş'
    },
    {
        id = 'avtobus_depo', name = 'Avtobus Deposu (Nəriman Nərimanov)',
        desc = 'Şəhər avtobuslarının dayanacağı. Avtobus sürücüsü işi.',
        coords = vector3(450.0, -650.0, 28.0), color = { 255, 220, 90 }, marker = 1, size = 1.0,
        blip = { sprite = 513, color = 66, scale = 0.8 }, category = 'İş'
    },
    {
        id = 'çörək_zavodu', name = 'Çörək Zavodu (Xətai)',
        desc = 'Təzə çörək və şirniyyat istehsalı.',
        coords = vector3(1000.0, -2000.0, 30.0), color = { 230, 190, 120 }, marker = 1, size = 1.0,
        blip = { sprite = 476, color = 17, scale = 0.8 }, category = 'İş'
    },
    {
        id = 'ət_kombinatı', name = 'Ət Kombinatı (Xətai)',
        desc = 'Ət emalı və qəssablıq işi.',
        coords = vector3(1010.0, -2120.0, 30.0), color = { 220, 140, 120 }, marker = 1, size = 1.0,
        blip = { sprite = 476, color = 1, scale = 0.8 }, category = 'İş'
    },
    {
        id = 'tikiş_emalatxana', name = 'Tikiş Emalatxanası (Xətai)',
        desc = 'Paltar istehsalı və dərzilik işi.',
        coords = vector3(700.0, -1500.0, 25.0), color = { 220, 160, 220 }, marker = 1, size = 0.9,
        blip = { sprite = 476, color = 7, scale = 0.8 }, category = 'İş'
    },
    {
        id = 'dəmirçi', name = 'Dəmirçi Emalatxanası (Nəriman Nərimanov)',
        desc = 'Metal emalı və alət istehsalı.',
        coords = vector3(1300.0, 1100.0, 100.0), color = { 200, 150, 100 }, marker = 1, size = 0.9,
        blip = { sprite = 478, color = 17, scale = 0.8 }, category = 'İş'
    },
    {
        id = 'elektrik', name = 'Elektrik Stansiyası (Koroğlu)',
        desc = 'Şəhər enerjisi — elektrik xətlərinin təmiri işi.',
        coords = vector3(880.0, -1300.0, 26.0), color = { 250, 240, 120 }, marker = 1, size = 1.0,
        blip = { sprite = 467, color = 66, scale = 0.8 }, category = 'İş'
    },
    {
        id = 'su_anbarı', name = 'Su Anbarı / Bənd (Qara Qarayev)',
        desc = 'Şəhərin su təchizatı obyekti.',
        coords = vector3(915.0, 2310.0, 48.0), color = { 120, 200, 255 }, marker = 1, size = 0.9,
        blip = { sprite = 68, color = 38, scale = 0.8 }, category = 'İş'
    },
    {
        id = 'bərə', name = 'Bərə / Gəmi Limanı (Sahil)',
        desc = 'Gəmiçilik və bərə xidməti.',
        coords = vector3(-820.0, -1400.0, 5.0), color = { 120, 200, 255 }, marker = 1, size = 0.9,
        blip = { sprite = 410, color = 38, scale = 0.8 }, category = 'İş'
    },
    {
        id = 'taksopark', name = 'Taksopark (Ağ şəhər)',
        desc = 'Taksi sürücüləri burada gözləyir. Taksi işinə başlamaq üçün gəlin!',
        coords = vector3(-1040.0, -2650.0, 13.0), color = { 250, 220, 90 }, marker = 1, size = 1.0,
        blip = { sprite = 56, color = 5, scale = 0.8 }, category = 'İş'
    },
    {
        id = 'peşə_məktəbi', name = 'Peşə Məktəbi (28 May)',
        desc = 'Yeni peşə öyrənmək istəyənlər üçün məktəb.',
        coords = vector3(-120.0, -1100.0, 26.0), color = { 200, 190, 170 }, marker = 1, size = 0.9,
        blip = { sprite = 476, color = 0, scale = 0.8 }, category = 'İş'
    },

    -- ==================== XİDMƏT SECTORU ====================
    {
        id = 'mexanik_1', name = 'Mexanik Emalatxanası — La Mesa (Xətai)',
        desc = 'Avtomobil təmiri və modifikasiya. Mexanik işi üçün buraya gəlin!',
        coords = vector3(488.4, -1318.7, 29.2), color = { 255, 180, 80 }, marker = 1, size = 1.1,
        blip = { sprite = 72, color = 66, scale = 0.9 }, category = 'Xidmət'
    },
    {
        id = 'mexanik_2', name = 'Mexanik Emalatxanası — La Puerta (Koroğlu)',
        desc = 'Avtomobil təmiri və modifikasiya.',
        coords = vector3(723.1, -1088.9, 22.2), color = { 255, 180, 80 }, marker = 1, size = 1.0,
        blip = { sprite = 72, color = 66, scale = 0.8 }, category = 'Xidmət'
    },
    {
        id = 'mexanik_3', name = 'Mexanik Emalatxanası — Strawberry (28 May)',
        desc = 'Avtomobil təmiri və modifikasiya.',
        coords = vector3(-211.5, -1324.9, 30.9), color = { 255, 180, 80 }, marker = 1, size = 1.0,
        blip = { sprite = 72, color = 66, scale = 0.8 }, category = 'Xidmət'
    },
    {
        id = 'mexanik_4', name = 'Mexanik Emalatxanası — Elysian (Sahil)',
        desc = 'Avtomobil təmiri və modifikasiya.',
        coords = vector3(-1154.9, -2006.1, 13.2), color = { 255, 180, 80 }, marker = 1, size = 1.0,
        blip = { sprite = 72, color = 66, scale = 0.8 }, category = 'Xidmət'
    },
    {
        id = 'avtoyuma_1', name = 'Avtoyuma — Legion (Xətai)',
        desc = 'Avtomobilinizi təmizləyin.',
        coords = vector3(20.5, -1393.7, 29.3), color = { 120, 200, 255 }, marker = 1, size = 0.9,
        blip = { sprite = 100, color = 38, scale = 0.7 }, category = 'Xidmət'
    },
    {
        id = 'avtoyuma_2', name = 'Avtoyuma — Vespucci (Elmlər Akademiyası)',
        desc = 'Avtomobilinizi təmizləyin.',
        coords = vector3(-698.6, -933.3, 19.0), color = { 120, 200, 255 }, marker = 1, size = 0.9,
        blip = { sprite = 100, color = 38, scale = 0.7 }, category = 'Xidmət'
    },
    {
        id = 'avtosalon', name = 'Premium Deluxe Avtosalon (28 May)',
        desc = 'Lüks avtomobillər satış salonu. Yeni maşın almaq üçün buraya gəlin!',
        coords = vector3(-42.5, -1100.6, 26.4), color = { 140, 220, 255 }, marker = 1, size = 1.2,
        blip = { sprite = 225, color = 49, scale = 0.9 }, category = 'Xidmət'
    },
    {
        id = 'motosalon', name = 'Motosiklet Salonu (Koroğlu)',
        desc = 'Motosikletlər və skuterlər satışı.',
        coords = vector3(1050.0, -900.0, 30.0), color = { 140, 220, 255 }, marker = 1, size = 1.0,
        blip = { sprite = 226, color = 49, scale = 0.8 }, category = 'Xidmət'
    },
    {
        id = 'bərbərxana_1', name = 'Bərbərxana — Legion (Xətai)',
        desc = 'Saç düzümü və baxım.',
        coords = vector3(81.3, -1287.6, 29.3), color = { 240, 180, 200 }, marker = 1, size = 0.8,
        blip = { sprite = 71, color = 2, scale = 0.7 }, category = 'Xidmət'
    },
    {
        id = 'bərbərxana_2', name = 'Bərbərxana — Paleto (Qara Qarayev)',
        desc = 'Saç düzümü və baxım.',
        coords = vector3(-278.1, 6228.5, 31.7), color = { 240, 180, 200 }, marker = 1, size = 0.8,
        blip = { sprite = 71, color = 2, scale = 0.7 }, category = 'Xidmət'
    },
    {
        id = 'gözəllik_salonu', name = 'Gözəllik Salonu (20 Yanvar)',
        desc = 'Manikür, makiyaj və gözəllik xidmətləri.',
        coords = vector3(-1090.0, -250.0, 37.0), color = { 240, 150, 200 }, marker = 1, size = 0.8,
        blip = { sprite = 71, color = 2, scale = 0.7 }, category = 'Xidmət'
    },
    {
        id = 'paltar_1', name = 'Binco Geyim Mağazası (Xətai)',
        desc = 'Gündəlik geyim və aksesuarlar.',
        coords = vector3(72.3, -1399.1, 29.4), color = { 220, 170, 220 }, marker = 1, size = 1.0,
        blip = { sprite = 73, color = 7, scale = 0.8 }, category = 'Xidmət'
    },
    {
        id = 'paltar_2', name = 'Ponsonbys Geyim Mağazası (20 Yanvar)',
        desc = 'Dəbli və bahalı geyimlər.',
        coords = vector3(-1450.7, -236.5, 49.8), color = { 220, 170, 220 }, marker = 1, size = 1.0,
        blip = { sprite = 73, color = 7, scale = 0.8 }, category = 'Xidmət'
    },
    {
        id = 'paltar_3', name = 'Geyim Mağazası — Sandy Shores (Qara Qarayev)',
        desc = 'Gündəlik geyim və aksesuarlar.',
        coords = vector3(615.2, 2759.6, 42.1), color = { 220, 170, 220 }, marker = 1, size = 1.0,
        blip = { sprite = 73, color = 7, scale = 0.8 }, category = 'Xidmət'
    },
    {
        id = 'paltar_4', name = 'Geyim Mağazası — Paleto Bay (20 Yanvar)',
        desc = 'Gündəlik geyim və aksesuarlar.',
        coords = vector3(-1096.5, 2708.8, 19.1), color = { 220, 170, 220 }, marker = 1, size = 1.0,
        blip = { sprite = 73, color = 7, scale = 0.8 }, category = 'Xidmət'
    },
    {
        id = 'ayaqqabı_emalatxana', name = 'Ayaqqabı Emalatxanası (Koroğlu)',
        desc = 'Əl işi ayaqqabılar və təmir.',
        coords = vector3(770.0, -1400.0, 26.0), color = { 200, 160, 120 }, marker = 1, size = 0.8,
        blip = { sprite = 476, color = 17, scale = 0.7 }, category = 'Xidmət'
    },
    {
        id = 'saat_ustası', name = 'Saat Emalatxanası (Elmlər Akademiyası)',
        desc = 'Qiymətli saatların təmiri və satışı.',
        coords = vector3(-1170.0, -880.0, 14.0), color = { 220, 190, 120 }, marker = 1, size = 0.8,
        blip = { sprite = 617, color = 66, scale = 0.7 }, category = 'Xidmət'
    },
    {
        id = 'şüşəbənd', name = 'Şüşəbənd Emalatxanası (Xətai)',
        desc = 'Vitraj və şüşə işləri.',
        coords = vector3(810.0, -2000.0, 30.0), color = { 180, 220, 240 }, marker = 1, size = 0.8,
        blip = { sprite = 476, color = 38, scale = 0.7 }, category = 'Xidmət'
    },

    -- ==================== YANACAQ ====================
    {
        id = 'yanacaq_1', name = 'Yanacaqdoldurma Məntəqəsi — Legion (28 May)',
        desc = 'Avtomobilinizi yanacaqla doldurun.',
        coords = vector3(49.4, -866.5, 30.5), color = { 250, 120, 80 }, marker = 1, size = 1.0,
        blip = { sprite = 361, color = 1, scale = 0.8 }, category = 'Yanacaq'
    },
    {
        id = 'yanacaq_2', name = 'Yanacaqdoldurma Məntəqəsi — La Mesa (Koroğlu)',
        desc = 'Avtomobilinizi yanacaqla doldurun.',
        coords = vector3(819.6, -1028.8, 26.4), color = { 250, 120, 80 }, marker = 1, size = 1.0,
        blip = { sprite = 361, color = 1, scale = 0.8 }, category = 'Yanacaq'
    },
    {
        id = 'yanacaq_3', name = 'Yanacaqdoldurma Məntəqəsi — Vinewood (Nəriman Nərimanov)',
        desc = 'Avtomobilinizi yanacaqla doldurun.',
        coords = vector3(620.8, 269.1, 103.1), color = { 250, 120, 80 }, marker = 1, size = 1.0,
        blip = { sprite = 361, color = 1, scale = 0.8 }, category = 'Yanacaq'
    },
    {
        id = 'yanacaq_4', name = 'Yanacaqdoldurma Məntəqəsi — Great Ocean (20 Yanvar)',
        desc = 'Avtomobilinizi yanacaqla doldurun.',
        coords = vector3(-1437.5, -275.7, 46.2), color = { 250, 120, 80 }, marker = 1, size = 1.0,
        blip = { sprite = 361, color = 1, scale = 0.8 }, category = 'Yanacaq'
    },
    {
        id = 'yanacaq_5', name = 'Yanacaqdoldurma Məntəqəsi — Paleto (İçərişəhər)',
        desc = 'Avtomobilinizi yanacaqla doldurun.',
        coords = vector3(-2096.9, -320.4, 13.2), color = { 250, 120, 80 }, marker = 1, size = 1.0,
        blip = { sprite = 361, color = 1, scale = 0.8 }, category = 'Yanacaq'
    },
    {
        id = 'yanacaq_6', name = 'Yanacaqdoldurma Məntəqəsi — Sandy Shores (Dərnəgül)',
        desc = 'Avtomobilinizi yanacaqla doldurun.',
        coords = vector3(2580.5, 362.1, 108.5), color = { 250, 120, 80 }, marker = 1, size = 1.0,
        blip = { sprite = 361, color = 1, scale = 0.8 }, category = 'Yanacaq'
    },
    {
        id = 'yanacaq_7', name = 'Yanacaqdoldurma Məntəqəsi — Alamo (Xətai)',
        desc = 'Avtomobilinizi yanacaqla doldurun.',
        coords = vector3(-70.2, -1761.7, 29.6), color = { 250, 120, 80 }, marker = 1, size = 1.0,
        blip = { sprite = 361, color = 1, scale = 0.8 }, category = 'Yanacaq'
    },
    {
        id = 'yanacaq_8', name = 'Yanacaqdoldurma Məntəqəsi — Route 68 (20 Yanvar)',
        desc = 'Avtomobilinizi yanacaqla doldurun.',
        coords = vector3(-2555.3, 2334.4, 33.1), color = { 250, 120, 80 }, marker = 1, size = 1.0,
        blip = { sprite = 361, color = 1, scale = 0.8 }, category = 'Yanacaq'
    },

    -- ==================== DAŞINMAZ ƏMLAK ====================
    {
        id = 'əmlak_agentliyi', name = 'Daşınmaz Əmlak Agentliyi (20 Yanvar)',
        desc = 'Ev almaq və ya satmaq istəyirsiniz? Agentliyə gəlin!',
        coords = vector3(-1350.0, -700.0, 25.0), color = { 180, 220, 160 }, marker = 1, size = 1.0,
        blip = { sprite = 475, color = 3, scale = 0.8 }, category = 'Əmlak'
    },
    {
        id = 'villa_bölgəsi', name = 'Villa Bölgəsi — Rockford Hills (20 Yanvar)',
        desc = 'Şəhərin ən bahalı evlərinin yerləşdiyi rayon.',
        coords = vector3(-750.0, 300.0, 100.0), color = { 220, 200, 150 }, marker = 1, size = 1.0,
        blip = { sprite = 40, color = 66, scale = 0.8 }, category = 'Əmlak'
    },
    {
        id = 'yaşayış_zona', name = 'Yaşayış Zonası — Grove Street (Xətai)',
        desc = 'Cənub məhəlləsinin məşhur küçəsi.',
        coords = vector3(120.0, -1950.0, 20.8), color = { 220, 200, 150 }, marker = 1, size = 1.0,
        blip = { sprite = 40, color = 17, scale = 0.8 }, category = 'Əmlak'
    },

    -- ==================== TƏBİƏT VƏ GÖRMƏLİ YERLƏR ====================
    {
        id = 'dağ', name = 'Cilead Dağı (Qara Qarayev)',
        desc = 'Şəhərin ən hündür nöqtəsi. Mənzərə nəfəs kəsəndir!',
        coords = vector3(500.0, 5600.0, 800.0), color = { 200, 210, 220 }, marker = 1, size = 1.1,
        blip = { sprite = 318, color = 0, scale = 0.9 }, category = 'Təbiət'
    },
    {
        id = 'alaamo_gölü', name = 'Alamo Gölü (Qara Qarayev)',
        desc = 'Böyük göl — balıqçılıq və istirahət üçün ideal.',
        coords = vector3(1030.0, 2450.0, 40.0), color = { 120, 200, 255 }, marker = 1, size = 1.1,
        blip = { sprite = 68, color = 38, scale = 0.9 }, category = 'Təbiət'
    },
    {
        id = 'kanyon', name = 'Raton Kanyonu (20 Yanvar)',
        desc = 'Nəfəs kəsən təbiət mənzərəsi.',
        coords = vector3(-700.0, 2300.0, 150.0), color = { 200, 160, 120 }, marker = 1, size = 1.0,
        blip = { sprite = 318, color = 17, scale = 0.8 }, category = 'Təbiət'
    },
    {
        id = 'şəlalə', name = 'Şəlalə (Qara Qarayev)',
        desc = 'Təbiətin səsi — istirahət üçün gözəl yer.',
        coords = vector3(-450.0, 4500.0, 300.0), color = { 120, 200, 255 }, marker = 1, size = 1.0,
        blip = { sprite = 68, color = 38, scale = 0.8 }, category = 'Təbiət'
    },
    {
        id = 'palıd_meşə', name = 'Palmer-Taylor Meşəsi (Qara Qarayev)',
        desc = 'Şəhərin ən böyük meşəsi.',
        coords = vector3(-800.0, 5200.0, 250.0), color = { 120, 180, 100 }, marker = 1, size = 1.0,
        blip = { sprite = 318, color = 3, scale = 0.8 }, category = 'Təbiət'
    },

    -- ==================== SƏNAYE ====================
    {
        id = 'sənaye_zona', name = 'La Mesa Sənaye Zonası (Xətai)',
        desc = 'Fabriklər və anbarların yerləşdiyi sənaye rayonu.',
        coords = vector3(1000.0, -2300.0, 30.0), color = { 200, 190, 170 }, marker = 1, size = 1.0,
        blip = { sprite = 478, color = 0, scale = 0.8 }, category = 'Sənaye'
    },
    {
        id = 'anbar', name = 'Böyük Anbar Kompleksi (Ağ şəhər)',
        desc = 'Malların saxlanıldığı anbar kompleksi.',
        coords = vector3(-750.0, -2200.0, 20.0), color = { 200, 190, 170 }, marker = 1, size = 1.0,
        blip = { sprite = 478, color = 0, scale = 0.8 }, category = 'Sənaye'
    },
    {
        id = 'neft_platforması', name = 'Neft Platforması (Ağ şəhər)',
        desc = 'Sahildən görünən neft platforması.',
        coords = vector3(-1990.0, -3370.0, 5.0), color = { 180, 160, 140 }, marker = 1, size = 0.9,
        blip = { sprite = 436, color = 0, scale = 0.7 }, category = 'Sənaye'
    },
    {
        id = 'tikinti', name = 'Tikinti Sahəsi (Ağ şəhər)',
        desc = 'Yeni binaların inşa olunduğu sahə.',
        coords = vector3(-400.0, -2200.0, 20.0), color = { 240, 220, 120 }, marker = 1, size = 1.0,
        blip = { sprite = 476, color = 66, scale = 0.8 }, category = 'Sənaye'
    }
}
