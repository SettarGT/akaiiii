local Translations = {
    text = {
        weazle_overlay = "Weazle Overlay ~INPUT_PICKUP~ \nFilm Overlay: ~INPUT_INTERACTION_MENU~",
        vehicle = "Weazel News Avtomobilləri",
        close_menu = "⬅ Menyunu bağla",
        heli = "Weazel News Helikopterləri",
        store_vehicle = "~g~E~w~ - Avtomobili saxla",
        vehicles = "~g~E~w~ - Avtomobillər",
        store_helicopters = "~g~E~w~ - Helikopterləri saxla",
        helicopters = "~g~E~w~ - Helikopterlər",
        enter = "~g~E~w~ - Gir",
        go_outside = "~g~E~w~ - Çölə çıx",
        breaking_news = "TƏCİLİ XƏBƏR",
        title_breaking_news = "Saat 7:00 / Bu gün Weazel News Eksklüziv",
        bottom_breaking_news = "Ən SON XƏBƏRLƏRİ canlı olaraq sizə çatdırırıq"
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
