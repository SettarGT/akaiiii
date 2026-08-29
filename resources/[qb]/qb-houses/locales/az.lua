local Translations = {
    error = {
        ["no_keys"] = "Evin açarları sizdə yoxdur...",
        ["not_in_house"] = "Siz evdə deyilsiniz!",
        ["out_range"] = "Məsafədən çıxdınız",
        ["no_key_holders"] = "Açar sahibi tapılmadı..",
        ["invalid_tier"] = "Yanlış ev səviyyəsi",
        ["no_house"] = "Yaxınlıqda ev yoxdur",
        ["no_door"] = "Qapıya kifayət qədər yaxın deyilsiniz..",
        ["locked"] = "Ev kilidlidir!",
        ["no_one_near"] = "Yaxınlıqda heç kim yoxdur!",
        ["not_owner"] = "Bu ev sizin deyil.",
        ["no_police"] = "Polis qüvvəsi mövcud deyil..",
        ["already_open"] = "Bu ev artıq açıqdır..",
        ["failed_invasion"] = "Uğursuz oldu, yenidən cəhd edin",
        ["inprogress_invasion"] = "Kimsə artıq qapı üzərində işləyir..",
        ["no_invasion"] = "Bu qapı sındırılmamışdır..",
        ["realestate_only"] = "Bu əmri yalnız daşınmaz əmlak işçisi istifadə edə bilər",
        ["emergency_services"] = "Bu yalnız təcili xidmətlər üçün mümkündür!",
        ["already_owned"] = "Bu ev artıq sahiblidir!",
        ["not_enough_money"] = "Kifayət qədər pulunuz yoxdur..",
        ["remove_key_from"] = "%{firstname} %{lastname} adlı şəxsdən açarlar götürüldü",
        ["already_keys"] = "Bu şəxsin artıq evin açarları var!",
        ["something_wrong"] = "Bir şey səhv getdi, yenidən cəhd edin!",
        ["nobody_at_door"] = 'Qapıda heç kim yoxdur...'
    },
    success = {
        ["unlocked"] = "Ev açıldı!",
        ["home_invasion"] = "Qapı indi açıqdır.",
        ["lock_invasion"] = "Evi yenidən kilidlədiniz..",
        ["recieved_key"] = "%{value} evinin açarlarını aldınız!",
        ["house_purchased"] = "Evi uğurla satın aldınız!"
    },
    info = {
        ["door_ringing"] = "Kimsə qapı zəngini çalır!",
        ["speed"] = "Sürət %{value}-dir",
        ["added_house"] = "Ev əlavə etdiniz: %{value}",
        ["added_garage"] = "Qaraj əlavə etdiniz: %{value}",
        ["exit_camera"] = "Kameradan Çıx",
        ["house_for_sale"] = "Satılıq Ev",
        ["decorate_interior"] = "İnteryeri Bəzə",
        ["create_house"] = "Ev Yarat (Yalnız Daşınmaz Əmlak)",
        ["price_of_house"] = "Evin qiyməti",
        ["tier_number"] = "Ev Səviyyə Nömrəsi",
        ["add_garage"] = "Ev Qarajı Əlavə Et (Yalnız Daşınmaz Əmlak)",
        ["ring_doorbell"] = "Qapı Zəngini Çal"
    },
    menu = {
        ["house_options"] = "Ev Seçimləri",
        ["close_menu"] = "⬅ Menyunu Bağla",
        ["enter_house"] = "Evinizə Girin",
        ["give_house_key"] = "Ev Açarı Ver",
        ["exit_property"] = "Əmlakdan Çıx",
        ["front_camera"] = "Ön Kamera",
        ["back"] = "Geri",
        ["remove_key"] = "Açarı Sil",
        ["open_door"] = "Qapını Aç",
        ["view_house"] = "Evə Bax",
        ["ring_door"] = "Qapı Zəngini Çal",
        ["exit_door"] = "Əmlakdan Çıx",
        ["open_stash"] = "Anbarı Aç",
        ["stash"] = "Anbar",
        ["change_outfit"] = "Geyim Dəyiş",
        ["outfits"] = "Geyimlər",
        ["change_character"] = "Personaj Dəyiş",
        ["characters"] = "Personajlar",
        ["enter_unlocked_house"] = "Açıq Evə Gir",
        ["lock_door_police"] = "Qapını Kilidlə"
    },
    target = {
        ["open_stash"] = "[E] Anbarı Aç",
        ["outfits"] = "[E] Geyim Dəyiş",
        ["change_character"] = "[E] Personaj Dəyiş",
    },
    log = {
        ["house_created"] = "Ev Yaradıldı:",
        ["house_address"] = "**Ünvan**: %{label}\n\n**Qiymət**: %{price}\n\n**Səviyyə**: %{tier}\n\n**Agent**: %{agent}",
        ["house_purchased"] = "Ev Satıldı:",
        ["house_purchased_by"] = "**Ünvan**: %{house}\n\n**Satış Qiyməti**: %{price}\n\n**Alıcı**: %{firstname} %{lastname}"
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
