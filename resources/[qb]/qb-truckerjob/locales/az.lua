local Translations = {
    error = {
        no_deposit = "$%{value} depozit tələb olunur",
        cancelled = "Ləğv edildi",
        vehicle_not_correct = "Bu kommersiya avtomobili deyil!",
        no_driver = "Bunu etmək üçün sürücü olmalısınız..",
        no_work_done = "Hələ heç bir iş görməmisiniz..",
        backdoors_not_open = "Avtomobilin arxa qapıları açıq deyil",
        get_out_vehicle = "Bu əməliyyatı yerinə yetirmək üçün avtomobildən düşməlisiniz",
        too_far_from_trunk = "Qutuları avtomobilinizin baqajından götürməlisiniz",
        too_far_from_delivery = "Çatdırılma məntəqəsinə daha yaxın olmalısınız"
    },
    success = {
        paid_with_cash = "$%{value} depozit nəğd ödənildi",
        paid_with_bank = "$%{value} depozit bankdan ödənildi",
        refund_to_cash = "$%{value} depozit nəğd qaytarıldı",
        you_earned = "$%{value} qazandınız",
        payslip_time = "Bütün mağazalara çatdınız .. Maaş vaxtıdır!",
    },
    menu = {
        header = "Mövcud Yük Maşınları",
        close_menu = "⬅ Menyunu bağla",
    },
    mission = {
        store_reached = "Mağazaya çatdınız, [E] ilə baqaja bir qutu qoyun və işarəyə çatdırın",
        take_box = "Bir Qutu Məhsul Götür",
        deliver_box = "Qutu Məhsulu Çatdır",
        another_box = "Başqa bir Qutu Məhsul Götür",
        goto_next_point = "Bütün məhsulları çatdırdınız, növbəti məntəqəyə keçin",
        return_to_station = "Bütün məhsulları çatdırdınız, stansiyaya qayıdın",
        job_completed = "Marşrutu tamamladınız, maaşınızı götürün"
    },
    info = {
        deliver_e = "~g~E~w~ - Məhsulları Çatdır",
        deliver = "Məhsulları Çatdır",
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
