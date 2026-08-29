local Translations = {
    error = {
        process_canceled = "Emal ləğv edildi",
        plant_has_died = "Bitki qurudu. Bitkini çıxarmaq üçün ~r~ E ~w~ basın.",
        cant_place_here = "Buraya qoymaq olmaz",
        not_safe_here = "Burada təhlükəli, evinizdə cəhd edin",
        not_need_nutrition = "Bitki gübrəyə ehtiyac duymur",
        this_plant_no_longer_exists = "Bu bitki artıq mövcud deyil?",
        house_not_found = "Ev tapılmadı",
        you_dont_have_enough_resealable_bags = "Kifayət qədər bağlanan kisəniz yoxdur",
    },
    text = {
        sort = 'Növ:',
        harvest_plant = 'Bitkini yığmaq üçün ~g~ E ~w~ basın.',
        nutrition = "Gübrə:",
        health = "Sağlamlıq:",
        progress = "İrəliləyiş:",
        harvesting_plant = "Bitki yığılır",
        planting = "Əkilir",
        feeding_plant = "Bitki bəslənir",
        the_plant_has_been_harvested = "Bitki yığıldı",
        removing_the_plant = "Bitki çıxarılır",
        stage = "Hazırkı mərhələ:",
        highestStage = "Yığım mərhələsi:",
    },
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
