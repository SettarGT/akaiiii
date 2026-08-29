local Translations = {
    error = {
        finish_work = "Əvvəlcə bütün işlərinizi bitirin",
        vehicle_not_correct = "Bu düzgün avtomobil deyil",
        failed = "Uğursuz oldunuz",
        not_towing_vehicle = "Yedək avtomobilində olmalısınız",
        too_far_away = "Çox uzaqsınız",
        no_work_done = "Hələ heç bir iş görməmisiniz",
        no_deposit = "$%{value} depozit tələb olunur",
    },
    success = {
        paid_with_cash = "$%{value} depozit nəğd ödənildi",
        paid_with_bank = "$%{value} depozit bankdan ödənildi",
        refund_to_cash = "$%{value} depozit nəğd qaytarıldı",
        you_earned = "$%{value} qazandınız",
    },
    menu = {
        header = "Mövcud Yedək Maşınları",
        close_menu = "⬅ Menyunu bağla",
    },
    mission = {
        delivered_vehicle = "Avtomobili çatdırdınız",
        get_new_vehicle = "Yeni avtomobil götürülə bilər",
        towing_vehicle = "Avtomobil qaldırılır...",
        goto_depot = "Avtomobili Hayes deposuna aparın",
        vehicle_towed = "Avtomobil yedəkləndi",
        untowing_vehicle = "Avtomobili götürün",
        vehicle_takenoff = "Avtomobil götürüldü",
    },
    info = {
        tow = "Avtomobili yedək platformasına qoyun",
        toggle_npc = "NPC işini dəyiş",
        skick = "İstismar cəhdi",
    },
    label = {
        payslip = "Maaş",
        vehicle = "Avtomobil",
        npcz = "NPC zonası",
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
