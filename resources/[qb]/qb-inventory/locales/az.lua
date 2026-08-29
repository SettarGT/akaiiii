local Translations = {
    progress = {
        ['snowballs'] = 'Qartopları yığılır...',
    },
    notify = {
        ['failed'] = 'Uğursuz oldu',
        ['canceled'] = 'Ləğv edildi',
        ['vlocked'] = 'Avtomobil kilidli',
        ['notowned'] = 'Bu əşya sizə aid deyil!',
        ['missitem'] = 'Bu əşya sizdə yoxdur!',
        ['nonb'] = 'Yaxınlıqda heç kim yoxdur!',
        ['noaccess'] = 'Giriş yoxdur',
        ['nosell'] = 'Bu əşyanı satmaq olmaz.',
        ['itemexist'] = 'Bu əşya mövcud deyil.',
        ['notencash'] = 'Kifayət qədər pulunuz yoxdur.',
        ['noitem'] = 'Lazımi əşyalar sizdə yoxdur.',
        ['gsitem'] = 'Özünüzə əşya verə bilməzsiniz.',
        ['tftgitem'] = 'Əşya vermək üçün çox uzaqsınız!',
        ['infound'] = 'Vermək istədiyiniz əşya tapılmadı!',
        ['iifound'] = 'Səhv əşya tapıldı, yenidən cəhd edin!',
        ['gitemrec'] = 'Siz aldınız: ',
        ['gitemfrom'] = ' — ',
        ['gitemyg'] = 'Siz verdiniz: ',
        ['gitinvfull'] = 'Digər oyunçunun inventarı doludur!',
        ['giymif'] = 'İnventarınız doludur!',
        ['gitydhei'] = 'Əşyadan kifayət qədər yoxdur',
        ['gitydhitt'] = 'Köçürmək üçün kifayət qədər əşyanız yoxdur',
        ['navt'] = 'Etibarlı tip deyil.',
        ['anfoc'] = 'Arqumentlər düzgün doldurulmayıb.',
        ['yhg'] = 'Siz verdiniz: ',
        ['cgitem'] = 'Əşya verilə bilməz!',
        ['idne'] = 'Əşya mövcud deyil',
        ['pdne'] = 'Oyunçu onlayn deyil',
        ['nogunbag'] = 'Əlində silah və çanta eyni anda ola bilməz!',
        ['hasbag'] = 'Artıq əlində çanta var, yerə qoy!',
        ['invinuse'] = 'Bu inventar hazırda istifadə olunur',
        ['notenoughstock'] = 'Anbarda olan miqdardan artıq ala bilməzsiniz',
        ['canthold'] = 'Bu əşyanı daşıya bilməzsiniz',
    },
    inf_mapping = {
        ['opn_inv'] = 'İnventarı aç',
        ['tog_slots'] = 'Qısayol slotlarını dəyiş',
        ['use_item'] = 'Slotdakı əşyanı istifadə et: ',
    },
    menu = {
        ['vending'] = 'Avtomat',
        ['bin'] = 'Zibil qutusunu aç',
        ['craft'] = 'Düzəlt',
        ['o_bag'] = 'Çantanı aç',
        ['p_bag'] = 'Çantanı götür',
    },
    interaction = {
        ['craft'] = '~g~E~w~ - Düzəlt',
        ['drop_bag'] = 'Çantanı yerə qoymaq üçün [G] basın',
    },
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
