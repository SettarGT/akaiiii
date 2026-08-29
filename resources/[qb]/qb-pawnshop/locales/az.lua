local Translations = {
    error = {
        negative = 'Mənfi məbləğ satmağa çalışırsınız?',
        no_melt = 'Mənə əritmək üçün heç nə vermədiniz...',
        no_items = 'Kifayət qədər əşya yoxdur',
        inventory_full = 'Bütün mümkün əşyaları almaq üçün inventar çox doludur. Növbəti dəfə inventarın dolu olmadığına əmin olun. İtirilən əşyalar: %{value}'
    },
    success = {
        sold = '%{value} x %{value2} üçün $%{value3} satdınız',
        items_received = '%{value} x %{value2} aldınız',
    },
    info = {
        title = 'Lombard',
        subject = 'Əşyaların əridilməsi',
        message = 'Əşyalarınızı əritməyi bitirdik. İstədiyiniz vaxt gəlib götürə bilərsiniz.',
        open_pawn = 'Lombardı aç',
        sell = 'Əşyaları Sat',
        sell_pawn = 'Əşyaları Lombarda Sat',
        melt = 'Əşyaları Ərit',
        melt_pawn = 'Əritmə dükanını aç',
        melt_pickup = 'Əridilmiş əşyaları götür',
        pawn_closed = 'Lombard bağlıdır. %{value}:00 AM - %{value2}:00 PM arası gəlin',
        sell_items = 'Satış qiyməti $%{value}',
        back = '⬅ Geri',
        melt_item = '%{value} ərit',
        max = 'Maksimum miqdar %{value}',
        submit = 'Ərit',
        melt_wait = 'Mənə %{value} dəqiqə verin, əşyalarınız əridiləcək',
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
