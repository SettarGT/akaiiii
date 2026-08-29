local Translations = {
    error = {
        minimum_store_robbery_police = "Kifayət qədər polis yoxdur (%{MinimumStoreRobberyPolice} tələb olunur)",
        not_driver = "Siz sürücü deyilsiniz",
        demolish_vehicle = "İndi avtomobilləri sökməyə icazəniz yoxdur",
        process_canceled = "Əməliyyat ləğv edildi..",
        you_broke_the_lock_pick = "Qıfıl açarını sındırdınız",
    },
    text = {
        the_cash_register_is_empty = "Kassa boşdur",
        try_combination = "~g~E~w~ - Kombinasiyanı sına",
        safe_opened = "Seyf açıldı",
        emptying_the_register= "Kassa boşaldılır..",
        safe_code = "Seyf kodu: "
    },
    email = {
        shop_robbery = "10-31 | Mağaza soyğunu",
        someone_is_trying_to_rob_a_store = "%{street} ünvanında kimsə mağazanı soymağa çalışır (KAMERA ID: %{cameraId1})",
        storerobbery_progress = "Mağaza soyğunu davam edir"
    },
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
