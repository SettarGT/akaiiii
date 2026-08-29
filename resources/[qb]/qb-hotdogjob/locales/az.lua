local Translations = {
    error = {
        no_money = 'Kifayət qədər pul yoxdur',
        too_far = 'Hotdog kürsünüzdən çox uzaqsınız',
        no_stand = 'Hotdog kürsünüz yoxdur',
        cust_refused = 'Müştəri imtina etdi!',
        no_stand_found = 'Hotdog kürsünüz heç yerdə tapılmadı, depozitiniz qaytarılmayacaq!',
        no_more = 'Bu barədə bələdiyyə qarşısında daha %{value} hüququnuz yoxdur',
        deposit_notreturned = 'Hotdog kürsünüz yox idi',
        no_dogs = 'Hotdoglarınız yoxdur',
    },
    success = {
        deposit = '$%{deposit} depozit ödədiniz!',
        deposit_returned = '$%{deposit} depozitiniz qaytarıldı!',
        sold_hotdogs = '%{value} ədəd Hotdog $%{value2}-a satıldı',
        made_hotdog = '%{value} Hotdog hazırladınız',
        made_luck_hotdog = '%{value} x %{value2} Hotdog hazırladınız',
    },
    info = {
        command = "Kürsünü sil (yalnız admin)",
        blip_name = 'Hotdog kürsüsü',
        start_working = '[E] İşə Başla',
        start_work = 'İşə Başla',
        stop_working = '[E] İşi Dayandır',
        stop_work = 'İşi Dayandır',
        grab_stall = '[~g~G~s~] Kürsünü Götür',
        drop_stall = '[~g~G~s~] Kürsünü Qoy',
        grab = 'Kürsünü Götür',
        prepare = 'Hotdog Hazırla',
        toggle_sell = 'Satışı Aç/Bağla',
        selling_prep = '[~g~E~s~] Hotdog hazırla [Satış: ~g~Satılır~w~]',
        not_selling = '[~g~E~s~] Hotdog hazırla [Satış: ~r~Satılmır~w~]',
        sell_dogs = '[~g~7~s~] %{value} ədəd Hotdogu $%{value2}-a sat / [~g~8~s~] İmtina et',
        sell_dogs_target = '%{value} ədəd Hotdogu $%{value2}-a sat',
        admin_removed = "Hotdog kürsüsü silindi",
        label_a = "Mükəmməl (A)",
        label_b = "Nadir (B)",
        label_c = "Adi (C)"
    },
    keymapping = {
        gkey = 'Hotdog kürsüsünü burax',
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
