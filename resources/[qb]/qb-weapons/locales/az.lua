local Translations = {
    error = {
        canceled = "Ləğv edildi",
        max_ammo = "Maksimum daraq tutumu",
        no_weapon = "Silahınız yoxdur.",
        wrong_ammo = "Daraq növünüz yanlışdır.",
        no_support_attachment = "Bu silah bu qoşmanı dəstəkləmir.",
        no_weapon_in_hand = "Əlinizdə silah yoxdur.",
        weapon_broken = "Bu silah sınıqdır və istifadə oluna bilməz.",
        no_damage_on_weapon = "Bu silah zədələnməyib..",
        weapon_broken_need_repair = "Silahınız sınıqdır, yenidən istifadə etmək üçün təmir etməlisiniz.",
        attachment_already_on_weapon = "Silahınızda artıq %{value} var."
    },
    success = {
        reloaded = "Daraq dolduruldu"
    },
    info = {
        loading_bullets = "Güllələr yüklənir",
        repairshop_not_usable = "Təmir məntəqəsi hazırda ~r~İSTİFADƏLİ~w~ deyil.",
        weapon_will_repair = "Silahınız təmir olunacaq.",
        take_weapon_back = "[E] - Silahı geri götür",
        repair_weapon_price = "[E] Silahı təmir et, ~g~$%{value}~w~",
        removed_attachment = "%{value} silahdan çıxarıldı!",
        hp_of_weapon = "Silahınızın davamlılığı"
    },
    mail = {
        sender = "Tyrone",
        subject = "Təmir",
        message = "%{value} silahınız təmir olunub, məntəqədən götürə bilərsiniz. <br><br> Salam"
    },
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
