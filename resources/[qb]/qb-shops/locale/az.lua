local Translations = {
    info = {
        open_shop = '[E] Mağaza',
        deliver_e = '~g~E~w~ - Məhsulları çatdır',
        deliver = 'Məhsulları çatdır',
    },
    error = {
        missing_license = 'Bəzi məhsullar üçün %s lisenziyası çatışmır',
        no_deposit = 'Depozit tələb olunur: $%{value}',
        cancelled = 'Ləğv edildi',
        vehicle_not_correct = 'Bu kommersiya vasitəsi deyil!',
        no_driver = 'Bunu etmək üçün sürücü olmalısınız..',
        no_work_done = "Hələ heç bir iş görməmisiniz..",
        backdoors_not_open = "Vasitənin arxa qapıları açıq deyil",
        get_out_vehicle = 'Bu əməliyyatı yerinə yetirmək üçün vasitədən çıxmalısınız',
        too_far_from_trunk = 'Qutuları vasitənizin baqajından götürməlisiniz',
        too_far_from_delivery = 'Çatdırılma məntəqəsinə daha yaxın olmalısınız'
    },
    success = {
        dealer_verify = 'Diler lisenziyanızı yoxlayır',
        paid_with_cash = '$%{value} depozit nağd ödənildi',
        paid_with_bank = '$%{value} depozit bankdan ödənildi',
        refund_to_cash = '$%{value} depozit nağd ödənildi',
        you_earned = '$%{value} qazandınız',
        payslip_time = 'Bütün mağazaları gəzdiniz.. Maaşınızı almaq vaxtıdır!',
    },
    mission = {
        store_reached = 'Mağazaya çatdınız, baqajdan [E] ilə qutu götürün və markerə çatdırın',
        take_box = 'Məhsul qutusu götür',
        deliver_box = 'Məhsul qutusunu çatdır',
        another_box = 'Başqa məhsul qutusu götür',
        goto_next_point = 'Bütün məhsulları çatdırdınız, növbəti məntəqəyə keçin',
        return_to_station = 'Bütün məhsulları çatdırdınız, məntəqəyə qayıdın',
        job_completed = 'Marşrutu tamamladınız'
    },
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
