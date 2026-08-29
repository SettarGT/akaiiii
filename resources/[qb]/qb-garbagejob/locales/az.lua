local Translations = {
    error = {
        ["cancled"] = "Ləğv edildi",
        ["no_truck"] = "Maşınınız yoxdur!",
        ["not_enough"] = "Kifayət qədər pul yoxdur (%{value} tələb olunur)",
        ["too_far"] = "Boşaltma məntəqəsindən çox uzaqsınız",
        ["early_finish"] = "Erkən bitirdiyiniz üçün (Tamamlandı: %{completed} Ümumi: %{total}), depozitiniz qaytarılmayacaq.",
        ["never_clocked_on"] = "Heç vaxt işə başlamamısınız!",
        ["all_occupied"] = "Bütün dayanacaq yerləri tutulub",
        ["job"] = "İşi iş mərkəzindən almalısınız",
    },
    success = {
        ["clear_routes"] = "Marşrutlar təmizləndi — %{value} marşrut saxlanılmışdı",
        ["pay_slip"] = "$%{total} qazandınız, %{deposit} depozitiniz bank hesabınıza ödənildi!",
    },
    target = {
        ["talk"] = 'Zibilçi ilə danış',
        ["grab_garbage"] = "Zibil kisəsini götür",
        ["dispose_garbage"] = "Zibil kisəsini boşalt",
    },
    menu = {
        ["header"] = "Zibilçilik Əsas Menyu",
        ["collect"] = "Maaşı götür",
        ["return_collect"] = "Maşını qaytar və maaşını burada götür!",
        ["route"] = "Marşrut tələb et",
        ["request_route"] = "Zibil marşrutu tələb et",
    },
    info = {
        ["payslip_collect"] = "[E] - Maaş",
        ["payslip"] = "Maaş",
        ["not_enough"] = "Depozit üçün kifayət qədər pulunuz yoxdur.. Depozit: $%{value}",
        ["deposit_paid"] = "$%{value} depozit ödədiniz!",
        ["no_deposit"] = "Bu avtomobil üçün depozit ödəməmisiniz..",
        ["truck_returned"] = "Maşın qaytarıldı, maaşınızı və depozitinizi almaq üçün maaş nöqtəsinə gedin!",
        ["bags_left"] = "Hələ %{value} kisə qalıb!",
        ["bags_still"] = "Orada hələ %{value} kisə var!",
        ["all_bags"] = "Bütün zibil kisələri yığıldı, növbəti məntəqəyə keçin!",
        ["depot_issue"] = "Depoda problem yarandı, dərhal qayıdın!",
        ["done_working"] = "İşiniz bitdi! Depoya qayıdın.",
        ["started"] = "İşə başladınız, yer GPS-də işarələndi!",
        ["grab_garbage"] = "[E] Zibil kisəsini götür",
        ["stand_grab_garbage"] = "Zibil kisəsini götürmək üçün burada durun.",
        ["dispose_garbage"] = "[E] Zibil kisəsini boşalt",
        ["progressbar"] = "Kisə maşına qoyulur ..",
        ["garbage_in_truck"] = "Kisəni maşına qoyun..",
        ["stand_here"] = "Burada durun..",
        ["found_crypto"] = "Yerdə kripto USB tapdınız",
        ["payout_deposit"] = "(+ $%{value} depozit)",
        ["store_truck"] =  "[E] - Zibil maşınını saxla",
        ["get_truck"] =  "[E] - Zibil maşını",
        ["picking_bag"] = "Zibil kisəsi götürülür..",
        ["talk"] = "[E] Zibilçi ilə danış",
    },
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
