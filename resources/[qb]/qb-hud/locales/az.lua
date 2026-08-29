local Translations = {
    notify = {
        ["hud_settings_loaded"] = "HUD Ayarları Yükləndi!",
        ["hud_restart"] = "HUD Yenidən Başladılır!",
        ["hud_start"] = "HUD İşə Salındı!",
        ["hud_command_info"] = "Bu əmr cari HUD ayarlarınızı sıfırlayır!",
        ["load_square_map"] = "Kvadrat xəritə yüklənir...",
        ["loaded_square_map"] = "Kvadrat xəritə yükləndi!",
        ["load_circle_map"] = "Dairəvi xəritə yüklənir...",
        ["loaded_circle_map"] = "Dairəvi xəritə yükləndi!",
        ["cinematic_on"] = "Kino rejimi aktivdir!",
        ["cinematic_off"] = "Kino rejimi deaktivdir!",
        ["engine_on"] = "Mühərrik işə salındı!",
        ["engine_off"] = "Mühərrik söndürüldü!",
        ["low_fuel"] = "Yanacaq səviyyəsi aşağıdır!",
        ["access_denied"] = "İcazəniz yoxdur!",
        ["stress_gain"] = "Stress artır!",
        ["stress_removed"] = "Stress azalır!"
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
