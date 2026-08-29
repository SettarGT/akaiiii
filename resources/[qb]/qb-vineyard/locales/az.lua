local Translations = {
    error = {
        ["invalid_job"] = "Düşünmürəm ki, burada işləyirəm...",
        ["invalid_items"] = "Düzgün əşyalar sizdə yoxdur!",
        ["no_items"] = "Heç bir əşyanız yoxdur!",
    },
    progress = {
        ["pick_grapes"] = "Üzüm yığılır ..",
        ["process_grapes"] = "Üzüm emal olunur ..",
    },
    task = {
        ["start_task"] = "[E] Başlamaq üçün",
        ["load_ingrediants"] = "[E] İnqrediyentləri Yüklə",
        ["wine_process"] = "[E] Şərab istehsalına başla",
        ["get_wine"] = "[E] Şərabı Götür",
        ["make_grape_juice"] = "[E] Üzüm Şirəsi Hazırla",
        ["sell_items"] = "[E] Şərab / Üzüm Şirəsi Sat",
        ["countdown"] = "Qalan vaxt %{time}s",
        ['cancel_task'] = "Tapşırığı ləğv etdiniz"
    },
    text = {
        ["start_shift"] = "Üzümçülükdə növbəniz başladı!",
        ["end_shift"] = "Üzümçülükdə növbəniz bitdi!",
        ["valid_zone"] = "Etibarlı zona!",
        ["invalid_zone"] = "Etibarsız zona!",
        ["zone_entered"] = "%{zone} zonasına daxil oldunuz",
        ["zone_exited"] = "%{zone} zonasından çıxdınız",
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
