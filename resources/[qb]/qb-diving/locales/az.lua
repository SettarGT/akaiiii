local Translations = {
    error = {
        ["canceled"] = "Ləğv edildi",
        ["911_chatmessage"] = "911 MESAJI",
        ["take_off"] = "Dalğıc kostyumunu çıxarmaq üçün /divingsuit",
        ["not_wearing"] = "Dalğıc dəsti geyinməmisiniz ..",
        ["no_coral"] = "Satmaq üçün mərcanınız yoxdur..",
        ["not_standing_up"] = "Dalğıc dəstini geyinmək üçün ayaq üstə durmalısınız",
        ["need_otube"] = "Boş dalğıc dəstini doldurmaq üçün oksigen balonu lazımdır",
        ["oxygenlevel"] = 'dəstin səviyyəsi %{oxygenlevel}, 0% olmalıdır'
    },
    success = {
        ["took_out"] = "Dalğıc kostyumunu çıxardınız",
        ["tube_filled"] = "Balon uğurla dolduruldu"
    },
    info = {
        ["collecting_coral"] = "Mərcan yığılır",
        ["diving_area"] = "Dalğıc ərazisi",
        ["collect_coral"] = "Mərcan yığ",
        ["collect_coral_dt"] = "[E] - Mərcan Yığ",
        ["checking_pockets"] = "Mərcan satmaq üçün ciblər yoxlanılır",
        ["sell_coral"] = "Mərcan Sat",
        ["sell_coral_dt"] = "[E] - Mərcan Sat",
        ["blip_text"] = "911 - Dalğıc sahəsi",
        ["put_suit"] = "Dalğıc kostyumu geyin",
        ["pullout_suit"] = "Dalğıc kostyumu çıxarılır ..",
        ["cop_msg"] = "Bu mərcan oğurlanmış ola bilər",
        ["cop_title"] = "Qanunsuz dalğıc",
        ["command_diving"] = "Dalğıc kostyumunu çıxar",
    },
    warning = {
        ["oxygen_one_minute"] = "Havanız 1 dəqiqədən az qalıb",
        ["oxygen_running_out"] = "Dalğıc dəstinin havası tükənir",
    },
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
