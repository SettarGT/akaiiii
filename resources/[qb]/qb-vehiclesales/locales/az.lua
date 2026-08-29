local Translations = {
    error = {
        not_your_vehicle = 'Bu avtomobil sizə aid deyil..',
        vehicle_does_not_exist = 'Avtomobil mövcud deyil',
        not_enough_money = 'Kifayət qədər pulunuz yoxdur',
        finish_payments = 'Satmadan əvvəl bu avtomobilin borcunu tam ödəməlisiniz..',
        no_space_on_lot = 'Meydançada maşınınız üçün yer yoxdur!',
        not_in_veh = 'Siz avtomobildə deyilsiniz!',
        not_for_sale = 'Bu avtomobil SATIŞDA DEYİL!',
    },
    menu = {
        view_contract = 'Müqaviləyə bax',
        view_contract_int = '[E] Müqaviləyə bax',
        sell_vehicle = 'Avtomobil Sat',
        sell_vehicle_help = 'Avtomobili digər vətəndaşlara sat!',
        sell_back = 'Avtomobili geri sat!',
        sell_back_help = 'Avtomobilinizi endirimli qiymətə geri satın!',
        interaction = '[E] Avtomobil Sat',
    },
    success = {
        sold_car_for_price = 'Avtomobilinizi $%{value}-a satdınız',
        car_up_for_sale = 'Avtomobiliniz satışa çıxarıldı! Qiymət - $%{value}',
        vehicle_bought = 'Avtomobil alındı',
    },
    info = {
        confirm_cancel = '~g~Y~w~ - Təsdiqlə / ~r~N~w~ - Ləğv et',
        vehicle_returned = 'Avtomobiliniz qaytarıldı',
        used_vehicle_lot = 'İstifadə olunmuş Avtomobil Meydanı',
        sell_vehicle_to_dealer = '[~g~E~w~] - Avtomobili satıcıya sat: ~g~$%{value}',
        view_contract = '[~g~E~w~] - Avtomobil müqaviləsinə bax',
        cancel_sale = '[~r~G~w~] - Satışı ləğv et',
        model_price = '%{value}, Qiymət: ~g~$%{value2}',
        are_you_sure = 'Avtomobilinizi artıq satmaq istəmədiyinizə əminsiniz?',
        yes_no = '[~g~7~w~] - Bəli | [~r~8~w~] - Xeyr',
        place_vehicle_for_sale = '[~g~E~w~] - Avtomobili sahibi kimi satışa qoy',
    },
    charinfo = {
        firstname = 'naməlum',
        lastname = 'naməlum',
        account = 'Hesab naməlum..',
        phone = 'telefon nömrəsi naməlum..',
    },
    mail = {
        sender = 'Larrys RV Satışı',
        subject = 'Avtomobilinizi satdınız!',
        message = '%{value2} satışından $%{value} qazandınız.',
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
