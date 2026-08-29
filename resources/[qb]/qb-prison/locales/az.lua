local Translations = {
    error = {
        ["missing_something"] = "Görünür sizdə nəsə çatışmır...",
        ["not_enough_police"] = "Kifayət qədər polis yoxdur..",
        ["door_open"] = "Qapı artıq açıqdır..",
        ["cancelled"] = "Əməliyyat ləğv edildi..",
        ["didnt_work"] = "Alınmadı..",
        ["emty_box"] = "Qutu boşdur..",
        ["injail"] = "%{Time} ay həbsxanadasınız..",
        ["item_missing"] = "Sizdə əşya yoxdur..",
        ["escaped"] = "Qaçdınız... Tezliklə buradan uzaqlaşın.!",
        ["do_some_work"] = "Cəzanı azaltmaq üçün işləyin, hazırkı iş: %{currentjob}",
        ["security_activated"] = "Ən yüksək təhlükəsizlik səviyyəsi aktivdir, kamerada qalın!"
    },
    success = {
        ["found_phone"] = "Telefon tapdınız..",
        ["time_cut"] = "İşləyərək cəzanızdan vaxt qazandınız.",
        ["free_"] = "Azadsınız! Zövq alın! :)",
        ["timesup"] = "Vaxtınız bitdi! Ziyarətçi mərkəzindən çıxış edin",
    },
    info = {
        ["timeleft"] = "Hələ %{JAILTIME} ay qalıb",
        ["lost_job"] = "İşsiz qaldınız",
        ["job_interaction"] = "[E] Elektrik işi",
        ["job_interaction_target"] = "%{job} işini gör",
        ["received_property"] = "Əmlakınızı geri aldınız..",
        ["seized_property"] = "Əmlakınız müsadirə edildi, vaxtınız bitəndə hər şeyi geri alacaqsınız..",
        ["cells_blip"] = "Kamerlər",
        ["freedom_blip"] = "Həbsxana qəbul masası",
        ["canteen_blip"] = "Yeməkxana",
        ["work_blip"] = "Həbsxana işi",
        ["target_freedom_option"] = "Vaxtı yoxla",
        ["target_canteen_option"] = "Yemək götür",
        ["police_alert_title"] = "Yeni çağırış",
        ["police_alert_description"] = "Həbsxana qiyamı",
        ["connecting_device"] = "Cihaz qoşulur",
        ["working_electricity"] = "Kabellər qoşulur"
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
