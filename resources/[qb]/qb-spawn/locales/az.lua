local Translations = {
    ui = {
        last_location = "Son mövqe",
        confirm = "Təsdiqlə",
        where_would_you_like_to_start = "Harada başlamaq istəyirsiniz?",
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
