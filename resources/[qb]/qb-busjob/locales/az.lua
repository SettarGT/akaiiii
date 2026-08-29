local Translations = {
    error = {
        already_driving_bus = 'Artıq avtobus sürürsünüz',
        not_in_bus = 'Siz avtobusda deyilsiniz',
        one_bus_active = 'Eyni anda yalnız bir aktiv avtobusunuz ola bilər',
        drop_off_passengers = 'İşi dayandırmazdan əvvəl sərnişinləri endirin',
        exploit = "İstismar cəhdi"
    },
    success = {
        dropped_off = 'Sərnişin endirildi',
    },
    info = {
        bus = 'Standart Avtobus',
        goto_busstop = 'Avtobus dayanacağına gedin',
        busstop_text = '[E] Avtobus Dayanacağı',
        bus_plate = 'AVT', -- Can be 3 or 4 characters long (uses random 4 digits)
        bus_depot = 'Avtobus deposu',
        bus_stop_work = '[E] İşi Dayandır',
        bus_job_vehicles = '[E] İş Avtomobilləri'
    },
    menu = {
        bus_header = 'Avtobus Avtomobilləri',
        bus_close = '⬅ Menyunu bağla'
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
