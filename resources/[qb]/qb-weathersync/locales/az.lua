local Translations = {
    weather = {
        now_frozen = 'Hava indi dondurulub.',
        now_unfrozen = 'Hava artıq dondurulmayıb.',
        invalid_syntax = 'Yanlış sintaksis, düzgün istifadə: /weather <hava növü>',
        invalid_syntaxc = 'Yanlış sintaksis, bunun əvəzinə /weather <havaNövü> istifadə edin!',
        updated = 'Hava yeniləndi.',
        invalid = 'Yanlış hava növü, etibarlı növlər: \\nEXTRASUNNY CLEAR NEUTRAL SMOG FOGGY OVERCAST CLOUDS CLEARING RAIN THUNDER SNOW BLIZZARD SNOWLIGHT XMAS HALLOWEEN',
        invalidc = 'Yanlış hava növü, etibarlı növlər: \\nEXTRASUNNY CLEAR NEUTRAL SMOG FOGGY OVERCAST CLOUDS CLEARING RAIN THUNDER SNOW BLIZZARD SNOWLIGHT XMAS HALLOWEEN',
        willchangeto = 'Hava dəyişəcək: %{value}.',
        accessdenied = '/weather əmri üçün icazə rədd edildi.',
    },
    dynamic_weather = {
        disabled = 'Dinamik hava dəyişiklikləri deaktiv edildi.',
        enabled = 'Dinamik hava dəyişiklikləri aktiv edildi.',
    },
    time = {
        frozenc = 'Vaxt indi dondurulub.',
        unfrozenc = 'Vaxt artıq dondurulmayıb.',
        now_frozen = 'Vaxt indi dondurulub.',
        now_unfrozen = 'Vaxt artıq dondurulmayıb.',
        morning = 'Vaxt səhərə təyin edildi.',
        noon = 'Vaxt günortaya təyin edildi.',
        evening = 'Vaxt axşama təyin edildi.',
        night = 'Vaxt gecəyə təyin edildi.',
        change = 'Vaxt %{value}:%{value2}-a dəyişdirildi.',
        changec = 'Vaxt dəyişdirildi: %{value}!',
        invalid = 'Yanlış sintaksis, düzgün istifadə: time <saat> <dəqiqə> !',
        invalidc = 'Yanlış sintaksis. Bunun əvəzinə /time <saat> <dəqiqə> istifadə edin!',
        access = '/time əmri üçün icazə rədd edildi.',
    },
    blackout = {
        enabled = 'Qaranlıq rejimi aktiv edildi.',
        enabledc = 'Qaranlıq rejimi aktiv edildi.',
        disabled = 'Qaranlıq rejimi deaktiv edildi.',
        disabledc = 'Qaranlıq rejimi deaktiv edildi.',
    },
    help = {
        weathercommand = 'Havanı dəyiş.',
        weathertype = 'hava növü',
        availableweather = 'Mövcud növlər: extrasunny, clear, neutral, smog, foggy, overcast, clouds, clearing, rain, thunder, snow, blizzard, snowlight, xmas & halloween',
        timecommand = 'Vaxtı dəyiş.',
        timehname = 'saat',
        timemname = 'dəqiqə',
        timeh = '0 - 23 arası rəqəm',
        timem = '0 - 59 arası rəqəm',
        freezecommand = 'Vaxtı dondur / aç.',
        freezeweathercommand = 'Dinamik hava dəyişikliklərini aç/bağla.',
        morningcommand = 'Vaxtı 09:00-a təyin et',
        nooncommand = 'Vaxtı 12:00-a təyin et',
        eveningcommand = 'Vaxtı 18:00-a təyin et',
        nightcommand = 'Vaxtı 23:00-a təyin et',
        blackoutcommand = 'Qaranlıq rejimini dəyiş.',
    },
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
