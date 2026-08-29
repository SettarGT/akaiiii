local Translations = {
    success = {
        you_have_been_clocked_in = "İşə başladınız",
        sold = '%{amount} ədəd %{item} üçün $%{price} qazandınız',
    },
    text = {
        point_enter_warehouse = "[E] Anbara gir",
        enter_warehouse= "Anbara gir",
        exit_warehouse= "Anbardan çıx",
        point_exit_warehouse = "[E] Anbardan çıx",
        toggle_duty = "Növbəni dəyiş",
        point_toggle_duty = "[E] Növbəni dəyiş",
        hand_in_package = "Paketi təhvil ver",
        point_hand_in_package = "[E] Paketi təhvil ver",
        get_package = "Paketi götür",
        point_get_package = "[E] Paketi götür",
        picking_up_the_package = "Paket götürülür",
        unpacking_the_package = "Paket açılır",
        clock_in = "İşə başladınız",
        clock_out = "İşdən çıxdınız",
        sell_materials = "Materialları sat",
        point_sell_materials = "[E] Materialları sat",
        price = "Qiymət: $%{price}",
        amount = "Miqdar",
        sell = "Sat",
    },
    error = {
        you_have_clocked_out = "İşdən çıxdınız",
        nothing_to_sell = "Satmağa heç nəyiniz yoxdur",
        out_of_stock = "%{item} anbarda bitib",
        too_far_to_sell = "Satmaq üçün çox uzaqsınız",
    },
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
