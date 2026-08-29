local Translations = {
    menus = {
        header = 'Düzəltmə Menyusu',
        pickupworkBench = 'İş stolunu götür',
        entercraftAmount = 'Düzəltmə sayını daxil et:',
    },
    notifications = {
        pickupBench = 'İş stolunu götürdünüz.',
        invalidAmount = 'Yanlış miqdar daxil edildi',
        invalidInput = 'Yanlış daxiletmə',
        notenoughMaterials = "Kifayət qədər materialınız yoxdur!",
        craftingCancelled = 'Düzəltməni ləğv etdiniz',
        tablePlace = 'İş stolunuz yerləşdirildi',
        craftMessage = '%s düzəltdiniz',
        xpGain = '%s sahəsində %d XP qazandınız',
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
