Config = {}

-- Mebel mağazası (harada mebel almaq olar)
Config.Store = {
    coords = vector3(275.0, -1010.0, 30.0),
    label = 'Mebel Mağazası',
    blip = { sprite = 401, color = 5 },
}

-- Ev interyer nöqtəsi (bütün evlər üçün ortaq)
Config.Interior = vector3(266.0, -1007.0, -38.0)

-- Satışda olan mebellər
Config.Furniture = {
    { model = 'v_med_cor_sofa',       label = 'Divan',            price = 2500 },
    { model = 'v_med_cor_sofa2',      label = 'Böyük divan',      price = 3500 },
    { model = 'v_res_tre_sofa_s',     label = 'Şık divan',        price = 5000 },
    { model = 'v_med_bed_single',     label = 'Tək çarpayı',      price = 2000 },
    { model = 'v_med_bed_double',     label = 'İkili çarpayı',    price = 3500 },
    { model = 'v_res_tre_bed2',       label = 'Lüks çarpayı',     price = 6000 },
    { model = 'v_res_tre_table',      model2 = 'v_res_tre_stool', label = 'Yemək masası',   price = 3000 },
    { model = 'v_med_sideboard',      label = 'Komedin',          price = 1200 },
    { model = 'v_med_cor_sideboard',  label = 'Yan şkaf',         price = 1500 },
    { model = 'v_med_cor_tv',         label = 'Televizor',        price = 4000 },
    { model = 'v_med_cor_lampa',      label = 'Döşəmə lampası',   price = 800 },
    { model = 'v_med_cor_lamptable',  label = 'Masa lampası',     price = 500 },
    { model = 'v_med_cor_table',      label = 'Kofe masası',      price = 1800 },
    { model = 'v_res_fa_chair02',     label = 'Kreslo',           price = 2200 },
    { model = 'v_med_cor_plant',      label = 'Bitki (çiçək)',    price = 700 },
    { model = 'v_res_tre_bedrug',     label = 'Xalça',            price = 900 },
    { model = 'v_med_p_kitchen_units',label = 'Mətbəx dəsti',     price = 8000 },
    { model = 'v_med_fridgem',        label = 'Soyuducu',         price = 4500 },
    { model = 'v_med_cor_washmashin', label = 'Paltaryuyan',      price = 3000 },
    { model = 'v_med_micro',          label = 'Mikrodalğalı soba',price = 1200 },
}

-- Mebeli qoyarkən fırlatma düyməsi (R)
Config.RotateKey = 45   -- R
-- Təsdiq (E)
Config.ConfirmKey = 38  -- E
-- Ləğv (BACKSPACE)
Config.CancelKey = 177

-- Yer yerləşdirmə məsafəsi
Config.PlaceDistance = 3.0
