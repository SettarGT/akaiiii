local Translations = {
    error = {
        no_people_nearby = "Yaxınlıqda oyunçu yoxdur",
        no_vehicle_found = "Avtomobil tapılmadı",
        extra_deactivated = "%{extra} əlavəsi deaktiv edildi",
        extra_not_present = "%{extra} əlavəsi bu avtomobildə yoxdur",
        not_driver = "Siz avtomobilin sürücüsü deyilsiniz",
        vehicle_driving_fast = "Bu avtomobil çox sürətlə hərəkət edir",
        seat_occupied = "Bu oturacaq tutulub",
        race_harness_on = "Yarış kəməri taxılıdır, oturacaq dəyişə bilməzsiniz",
        obj_not_found = "İstənilən obyekt yaradıla bilmədi",
        not_near_ambulance = "Təcili yardım maşınının yaxınlığında deyilsiniz",
        far_away = "Çox uzaqsınız",
        stretcher_in_use = "Bu xərək artıq istifadə olunur",
        not_kidnapped = "Bu şəxsi siz qaçırmamısınız",
        trunk_closed = "Baqaj bağlıdır",
        cant_enter_trunk = "Bu baqaja girə bilməzsiniz",
        already_in_trunk = "Artıq baqajdasınız",
        someone_in_trunk = "Kimsə artıq baqajdadır"
    },
    progress = {
        flipping_car = "Avtomobil çevrilir.."
    },
    success = {
        extra_activated = "%{extra} əlavəsi aktiv edildi",
        entered_trunk = "Baqajdasınız"
    },
    info = {
        no_variants = "Bunun üçün variantlar yox kimi görünür",
        wrong_ped = "Bu ped modeli bu seçimə icazə vermir",
        nothing_to_remove = "Çıxaracaq heç nəyiniz yox kimi görünür",
        already_wearing = "Artıq bunu geyinmisiniz",
        switched_seats = "İndi %{seat} oturacağındasınız"
    },
    general = {
        command_description = "Radial menyunu aç",
        push_stretcher_button = "[E] - Xərəyi itələ",
        stop_pushing_stretcher_button = "~g~E~w~ - İtələməyi dayandır",
        lay_stretcher_button = "[G] - Xərəyə uzan",
        push_position_drawtext = "Buradan itələ",
        get_off_stretcher_button = "[G] - Xərəkdən düş",
        get_out_trunk_button = "[E] Baqajdan çıx",
        close_trunk_button = "[G] Baqajı bağla",
        open_trunk_button = "[G] Baqajı aç",
        getintrunk_command_desc = "Baqaja gir",
        putintrunk_command_desc = "Oyunçunu baqaja qoy"
    },
    options = {
        emergency_button = "Təcili yardım düyməsi",
        driver_seat = "Sürücü oturacağı",
        passenger_seat = "Sərnişin oturacağı",
        other_seats = "Digər oturacaq",
        rear_left_seat = "Arxa sol oturacaq",
        rear_right_seat = "Arxa sağ oturacaq"
    },
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
