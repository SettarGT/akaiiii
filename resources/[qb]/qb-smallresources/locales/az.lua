local Translations = {
    afk = {
        will_kick = 'Siz AFK-dasınız və atılacaqsınız: ',
        time_seconds = ' saniyə!',
        time_minutes = ' dəqiqə!',
        kick_message = 'AFK olduğunuz üçün atıldınız'
    },
    wash = {
        in_progress = "Avtomobil yuyulur...",
        wash_vehicle = "[E] Avtomobili yuyun",
        wash_vehicle_target = "Avtomobili Yuyun",
        dirty = "Avtomobil çirkli deyil",
        cancel = "Yuma ləğv edildi..."
    },
    consumables = {
        eat_progress = "Yemək yeyilir...",
        drink_progress = "İçki içilir...",
        liqour_progress = "Alkoqol içilir...",
        coke_progress = "Sürətli qəbul...",
        crack_progress = "Krek çəkilir...",
        ecstasy_progress = "Həblər qəbul edilir",
        healing_progress = "Sağalma",
        meth_progress = "Met çəkilir...",
        joint_progress = "Joint yandırılır...",
        use_parachute_progress = "Paraşüt geyinilir...",
        pack_parachute_progress = "Paraşüt yığılır...",
        no_parachute = "Paraşütünüz yoxdur!",
        armor_full = "Artıq kifayət qədər zirehiniz var!",
        armor_empty = "Jilet geyinməmisiniz...",
        armor_progress = "Bədən zirehi geyinilir...",
        heavy_armor_progress = "Ağır zireh geyinilir...",
        remove_armor_progress = "Bədən zirehi çıxarılır...",
        canceled = "Ləğv edildi..."
    },
    cruise = {
        unavailable = "Kruiz-kontrol mövcud deyil",
        activated = "Kruiz-kontrol aktivdir",
        deactivated = "Kruiz-kontrol deaktivdir",
        not_Enough_Fuel = "Kifayət qədər yanacaq yoxdur"
    },
    editor = {
        started = "Yazmağa başlandı!",
        save = "Yazı saxlanıldı!",
        delete = "Yazı silindi!",
        editor = "Sonra görüşərik!"
    },
    firework = {
        place_progress = "Fişəng qoyulur...",
        canceled = "Ləğv edildi...",
        time_left = "Fişəng buraxılış: "
    },
    seatbelt = {
        use_harness_progress = "Yarış kəməri bağlanır",
        remove_harness_progress = "Yarış kəməri çıxarılır",
        no_car = "Siz avtomobildə deyilsiniz."
    },
    teleport = {
        teleport_default = 'Lifti istifadə et'
    },
    pushcar = {
        stop_push = "[E] İtələməyi dayandır",
        notDamaged = "Avtomobil itələmək üçün kifayət qədər zədəli deyil!",
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
