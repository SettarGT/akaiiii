local Translations = {
    notify = {
        ydhk = 'Bu avtomobilin açarları sizdə yoxdur.',
        nonear = 'Açarları vermək üçün yaxınlıqda heç kim yoxdur',
        vlock = 'Avtomobil kilitləndi!',
        vunlock = 'Avtomobil açıldı!',
        vlockpick = 'Qapının qıfılını açmağı bacardınız!',
        fvlockpick = 'Açarları tapa bilmədiniz və əsəbiləşdiniz.',
        vgkeys = 'Açarları təhvil verirsiniz.',
        vgetkeys = 'Avtomobilin açarlarını aldınız!',
        fpid = 'Oyunçu ID-si və nömrə nişanını doldurun',
        cjackfail = 'Maşın oğurluğu uğursuz oldu!',
        vehclose = 'Yaxınlıqda avtomobil yoxdur!',
    },
    progress = {
        takekeys = 'Cibdən açarlar götürülür...',
        hskeys = 'Avtomobil açarları axtarılır...',
        acjack = 'Maşın oğurluğuna cəhd edilir...',
    },
    info = {
        skeys = '~g~[H]~w~ - Açarları axtar',
        tlock = 'Avtomobil qıfılını dəyiş',
        palert = 'Avtomobil oğurluğu davam edir. Tip: ',
        engine = 'Mühərriki aç/bağla',
    },
    addcom = {
        givekeys = 'Açarları kiməsə ver. ID yoxdursa, ən yaxın şəxsə və ya avtomobildəki hamıya verir.',
        givekeys_id = 'id',
        givekeys_id_help = 'Oyunçu ID-si',
        addkeys = 'Kiməsə avtomobilə açarlar əlavə edir.',
        addkeys_id = 'id',
        addkeys_id_help = 'Oyunçu ID-si',
        addkeys_plate = 'plate',
        addkeys_plate_help = 'Nömrə nişanı',
        rkeys = 'Kiməsə avtomobilin açarlarını götürür.',
        rkeys_id = 'id',
        rkeys_id_help = 'Oyunçu ID-si',
        rkeys_plate = 'plate',
        rkeys_plate_help = 'Nömrə nişanı',
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
