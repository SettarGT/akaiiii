local Translations = {
    error = {
        to_far_from_door = 'Zəng lövhəsindən çox uzaqsınız',
        nobody_home = 'Evdə heç kim yoxdur..',
        nobody_at_door = 'Qapıda heç kim yoxdur...'
    },
    success = {
        receive_apart = 'Mənzil aldınız',
        changed_apart = 'Mənzili dəyişdiniz',
    },
    info = {
        at_the_door = 'Kimsə qapıdadır!',
    },
    text = {
        options = '[E] Mənzil Seçimləri',
        enter = 'Mənzilə Gir',
        ring_doorbell = 'Qapı Zəngini Çal',
        logout = 'Personajdan Çıx',
        change_outfit = 'Geyim Dəyiş',
        open_stash = 'Anbarı Aç',
        move_here = 'Buraya Köç Et',
        open_door = 'Qapını Aç',
        leave = 'Mənzildən Çıx',
        close_menu = '⬅ Menyunu Bağla',
        tennants = 'Sakinlər',
    },
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
