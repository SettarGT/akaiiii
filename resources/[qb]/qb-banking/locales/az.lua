local Translations = {
    success = {
        withdraw = 'Pul çıxarışı uğurla tamamlandı',
        deposit = 'Əmanət uğurla tamamlandı',
        transfer = 'Köçürmə uğurla tamamlandı',
        account = 'Hesab yaradıldı',
        rename = 'Hesab adı dəyişdirildi',
        delete = 'Hesab silindi',
        userAdd = 'İstifadəçi əlavə edildi',
        userRemove = 'İstifadəçi silindi',
        card = 'Kart yaradıldı',
        give = '₣%s nəğd pul verildi',
        receive = '₣%s nəğd pul alındı',
    },
    error = {
        error = 'Xəta baş verdi',
        access = 'İcazə yoxdur',
        account = 'Hesab tapılmadı',
        accounts = 'Maksimum hesab sayına çatıldı',
        user = 'İstifadəçi artıq əlavə edilib',
        noUser = 'İstifadəçi tapılmadı',
        money = 'Kifayət qədər pul yoxdur',
        pin = 'Yanlış PIN',
        card = 'Bank kartı tapılmadı',
        amount = 'Yanlış məbləğ',
        toofar = 'Çox uzaqsınız',
    },
    progress = {
        atm = 'ATM-ə giriş edilir',
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
