local Translations = {
    success = {
        success_message = "Uğurlu",
        fuses_are_blown = "Sığortalar yandırıldı",
        door_has_opened = "Qapı açıldı"
    },
    error = {
        cancel_message = "Ləğv edildi",
        safe_too_strong = "Görünür seyf qıfılı çox möhkəmdir...",
        missing_item = "Sizdə əşya yoxdur...",
        bank_already_open = "Bank artıq açıqdır...",
        minimum_police_required = "Minimum %{police} polis tələb olunur",
        security_lock_active = "Təhlükəsizlik kilidi aktivdir, qapını açmaq hazırda mümkün deyil",
        wrong_type = "%{receiver} %{argument} arqumenti üçün düzgün tip almadı\\nqəbul edilən tip: %{receivedType}\\nqəbul edilən dəyər: %{receivedValue}\\n gözlənilən tip: %{expected}",
        fuses_already_blown = "Sığortalar artıq yandırılıb...",
        event_trigger_wrong = "%{event}%{extraInfo} şərtlər ödənilmədən çağırıldı, mənbə: %{source}",
        missing_ignition_source = "Yandırma mənbəyi yoxdur"
    },
    general = {
        breaking_open_safe = "Seyf sındırılır...",
        connecting_hacking_device = "Hacking cihazı qoşulur...",
        fleeca_robbery_alert = "Fleeca bank soyğunu cəhdi",
        paleto_robbery_alert = "Blain County Savings bank soyğunu cəhdi",
        pacific_robbery_alert = "Pacific Standard Bank soyğunu cəhdi",
        break_safe_open_option_target = "Seyfi Sındır",
        break_safe_open_option_drawtext = "[E] Seyfi sındır",
        validating_bankcard = "Kart yoxlanılır...",
        thermite_detonating_in_seconds = "Termit %{time} saniyə ərzində partlayacaq",
        bank_robbery_police_call = "10-90: Bank Soyğunu"
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
