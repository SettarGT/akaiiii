local Translations ={
    ["not_on_radio"] = "Heç bir tezliyə qoşulmamısınız",
    ["joined_to_radio"] = "Qoşuldunuz: %{channel}",
    ["restricted_channel_error"] = "Bu tezliyə qoşula bilməzsiniz!",
    ["invalid_radio"] = "Bu tezlik mövcud deyil.",
    ["you_on_radio"] = "Artıq bu kanala qoşulmusunuz",
    ["you_leave"] = "Kanalı tərk etdiniz.",
    ['volume_radio'] = 'Yeni səs səviyyəsi %{value}',
    ['decrease_radio_volume'] = 'Radio artıq maksimum səs səviyyəsindədir',
    ['increase_radio_volume'] = 'Radio artıq minimum səs səviyyəsindədir',
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
