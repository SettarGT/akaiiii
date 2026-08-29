local Translations = {
    error = {
        no_vehicles = 'Bu məkanda avtomobil yoxdur!',
        not_depot = 'Avtomobiliniz depoda deyil',
        not_owned = 'Bu avtomobil saxlanıla bilməz',
        not_correct_type = 'Bu tip avtomobili burada saxlay bilməzsiniz',
        not_enough = 'Kifayət qədər pul yoxdur',
        no_garage = 'Yoxdur',
        vehicle_occupied = 'Avtomobil boş olmadığı üçün saxlanıla bilməz',
        vehicle_not_tracked = 'Avtomobil izlənə bilmədi',
        no_spawn = 'Ərazi çox izdihamlıdır'
    },
    success = {
        vehicle_parked = 'Avtomobil saxlanıldı',
        vehicle_tracked = 'Avtomobil izləndi',
    },
    status = {
        out = 'Çöldə',
        garaged = 'Qarajda',
        impound = 'Polis tərəfindən müsadirə edilib',
        house = 'Ev',
    },
    info = {
        car_e = 'E - Qaraj',
        sea_e = 'E - Qayıqxana',
        air_e = 'E - Hava limanı',
        rig_e = 'E - Ağır maşın meydanı',
        depot_e = 'E - Depo',
        house_garage = 'E - Ev qarajı',
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
