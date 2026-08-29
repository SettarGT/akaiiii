local Translations = {
    store = {
        barber = "Bərbərxana",
        surgeon = "Plastik cərrah",
        clothing = "Geyim mağazası",
        outfitchanger = "Forma dəyişmə məntəqəsi"
    },

    outfits = {
        roomOutfits = "Hazır paltarlar",
        myOutfits = "Paltarlarım",
        character = "Geyim",
        accessoires = "Aksesuarlar"
    },

    menu = {
        hair = "Saç",
        character = "Geyim",
        accessoires = "Aksesuarlar",
        features = "Xüsusiyyətlər"
    },

    ui = {
        select = "Seç",
        delete = "Sil",
        select_outfit = "Paltar seç",
        player_model = "Oyunçu modeli",
        model = "Model",
        mother = "Ana",
        father = "Ata",
        texture = "Faktura",
        type = "Tip",
        item = "Əşya",
        skin_color = "Dəri rəngi",
        parent_mixer = "Valideyn qarışığı",
        shape_mix = "Forma qarışığı",
        skin_mix = "Dəri qarışığı",
        arms = "Qollar",
        undershirt = "Alt köynək/Kəmərlər",
        color = "Rəng",
        jacket = "Gödəkçələr/Üstlər",
        vests = "Jiletlər",
        decals = "Etiketlər",
        acessory = "Boyun aksesuarları",
        bags = "Çantalar",
        pants = "Şalvarlar",
        shoes = "Ayaqqabılar",
        eye_color = "Göz rəngi",
        moles = "Xallar/Çillər",
        opacity = "Şəffaflıq",
        nose_width = "Burun eni",
        width = "En",
        nose_peak_height = "Burun zirvəsinin hündürlüyü",
        height = "Hündürlük",
        nose_peak_length = "Burun zirvəsinin uzunluğu",
        length = "Uzunluq",
        nose_bone_height = "Burun sümüyünün hündürlüyü",
        nose_peak_lowering = "Burun zirvəsinin aşağı salınması",
        lowering = "Aşağı salma",
        nose_bone_twist = "Burun sümüyünün əyilməsi",
        twist = "Əyilmə",
        eyebrow_height = "Qaş hündürlüyü",
        eyebrow_depth = "Qaş dərinliyi",
        depth = "Dərinlik",
        cheeks_height = "Yanaq hündürlüyü",
        cheeks_width = "Yanaq eni",
        cheeks_depth = "Yanaq dərinliyi",
        eyes_opening = "Göz açıqlığı",
        opening = "Açıqlıq",
        lips_thickness = "Dodaq qalınlığı",
        thickness = "Qalınlıq",
        jaw_bone_width = "Çənə sümüyü eni",
        jaw_bone_length = "Çənə sümüyü uzunluğu",
        chin_height = "Çənə hündürlüyü",
        chin_width = "Çənə eni",
        butt_chin  ="Yumru çənə",
        size = "Ölçü",
        neck_thickness = "Boyun qalınlığı",
        ageing = "Yaşlanma",
        hair = "Saç",
        eyebrow = "Qaşlar",
        facial_hair = "Üz tükü",
        lipstick = "Pomada",
        blush = "Əngəl",
        makeup = "Makiyaj",
        mask = "Maskalar",
        hat = "Papaqlar",
        glasses = "Eynəklər",
        ear_accessories = "Qulaq aksesuarları",
        watch = "Saatlar",
        bracelet = "Bilərziklər",
        btn_confirm = "Təsdiqlə",
        btn_cancel = "Ləğv et",
        btn_saveOutfit = "Paltarı saxla",
        outfit_name = "Paltar adı"
    },

    notify = {
        error_bracelet = "Ayaq bilərziyini çıxara bilməzsiniz ...",
        info_deleteOutfit = "%{outfit} paltarını silmisiniz!"
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
