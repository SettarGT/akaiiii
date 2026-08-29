local Translations = {
    error = {
        smash_own = "Sahibi olduğunuz avtomobili sındıra bilməzsiniz.",
        cannot_scrap = "Bu avtomobil sökülə bilməz.",
        not_driver = "Siz sürücü deyilsiniz",
        demolish_vehicle = "İndi avtomobilləri sökməyə icazəniz yoxdur",
        canceled = "Ləğv edildi",
    },
    text = {
        scrapyard = 'Metal qırıntısı meydanı',
        disassemble_vehicle = '[E] - Avtomobili Sök',
        disassemble_vehicle_target = 'Avtomobili Sök',
        email_list = "[E] - Avtomobil siyahısını e-poçtla göndər",
        email_list_target = "Avtomobil siyahısını e-poçtla göndər",
        demolish_vehicle = "Avtomobili Sök",
    },
    email = {
        sender = "Turner Avto Sökümü",
        subject = "Avtomobil Siyahısı",
        message = "Yalnız müəyyən sayda avtomobili sökə bilərsiniz.<br />Sökdüyünüz hər şeyi özünüz üçün saxlaya bilərsiniz, yalnız məni narahat etməyin.<br /><br /><strong>Avtomobil siyahısı:</strong><br />",
    },
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
