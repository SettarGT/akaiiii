local Translations = {
    error = {
        fingerprints = 'Şüşədə barmaq iziniz qaldı',
        minimum_police = 'Minimum %{value} polis tələb olunur',
        wrong_weapon = 'Silahınız kifayət qədər güclü deyil..',
        to_much = 'Cibinizdə çox şey var'
    },
    success = {},
    info = {
        progressbar = 'Vitrin sındırılır',
    },
    general = {
        target_label = 'Vitrini sındır',
        drawtextui_grab = '[E] Vitrini sındır',
        drawtextui_broken = 'Vitrin sınıqdır'
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
