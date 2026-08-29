local Translations = {
    error = {
        ['missing_something'] = 'Görünür sizdə nəsə çatışmır...',
        ['not_enough_police'] = 'Kifayət qədər polis yoxdur..',
        ['door_open'] = 'Qapı artıq açıqdır..',
        ['process_cancelled'] = 'Əməliyyat ləğv edildi..',
        ['didnt_work'] = 'Alınmadı..',
        ['emty_box'] = 'Qutu boşdur..',
        ['not_allowed_time'] = "Günün bu vaxtında bunu edə bilməzsiniz."
    },
    success = {
        ['worked'] = 'Alındı!',
    },
    info = {
        ['palert'] = 'Ev soyğunu cəhdi',
        ['henter'] = '~g~E~w~ - Girmək üçün',
        ['hleave'] = '~g~E~w~ - Evdən çıxmaq üçün',
        ['aint'] = '~g~E~w~ - ',
        ['hsearch'] = 'Axtarılır..',
        ['hsempty'] = 'Boşdur..',
    },
    searching = {
        ['search_bcabinet'] = 'Yataq dəstini axtar',
        ['search_closet'] = 'Şkafı axtar',
        ['search_chest'] = 'Sandığı axtar',
        ['search_drawer'] = 'Çekmeceləri axtar',
        ['search_cabinet'] = 'Gecə dəsti',
        ['search_kcabinet'] = 'Mətbəx şkaflarını axtar',
        ['search_shelves'] = 'Rəfləri axtar',
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
