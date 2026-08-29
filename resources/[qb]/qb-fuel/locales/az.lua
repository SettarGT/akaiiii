local Translations = {
    progress = {
        refueling = 'Yanacaq doldurulur...',
    },
    success = {
        refueled = 'Avtomobil yanacaqla dolduruldu',
    },
    error = {
        no_money = 'Kifayət qədər pulunuz yoxdur',
        no_vehicle = 'Yaxınlıqda avtomobil tapılmadı',
        no_vehicles = 'Yaxınlıqda avtomobillər yoxdur',
        no_jerrycan = 'Yanınızda benzin qabı yoxdur',
        vehicle_full = 'Avtomobilin yanacaq çəni artıq doludur',
        no_fuel_can = 'Benzin qabında yanacaq yoxdur',
        no_nozzle = 'Yaxınlıqda şlanq bağlanmış avtomobil yoxdur',
        too_far = 'Nasosdan çox uzaqsınız, şlanq qaytarıldı',
        wrong_side = 'Avtomobilin çəni digər tərəfdədir',
    },
    target = {
        put_fuel = 'Yanacaq qoy',
        get_nozzle = 'Şlanqı götür',
        buy_jerrycan = 'Benzin qabı al $%{price}',
        refill_jerrycan = 'Benzin qabını doldur $%{price}',
        refill_fuel = 'Yanacaqla doldur',
        nozzle_put = 'Şlanqı tax',
        nozzle_remove = 'Şlanqı çıxar',
        return_nozzle = 'Şlanqı qaytar',
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
