local Translations = {
    error = {
        ['already_mission'] = 'Artıq NPC missiyası edirsiniz',
        ['not_in_taxi'] = 'Siz taksidə deyilsiniz',
        ['missing_meter'] = 'Bu avtomobildə taksi sayğacı yoxdur',
        ['no_vehicle'] = "Siz avtomobildə deyilsiniz",
        ['not_active_meter'] = 'Taksi sayğacı aktiv deyil',
        ['ride_canceled'] = 'Çox dəfə qəza etdiniz, səfər ləğv edildi!',
        ['broken_taxi'] = 'İşə davam etmədən əvvəl taksiniz təmir olunmalıdır!',
        ['crash_warning'] = 'Daha %d dəfə %s qəza etsəniz, müştəri səfəri dayandıracaq və maaş almayacaqsınız!',
        ['time'] = 'dəfə',
        ['times'] = 'dəfə',
    },
    success = {
        ['mission_cancelled'] = 'Missiya uğurla ləğv edildi',
    },
    info = {
        ['person_was_dropped_off'] = 'Sərnişin çatdırıldı!',
        ['npc_on_gps'] = 'NPC GPS-də işarələnib',
        ['go_to_location'] = 'NPC-ni göstərilən məkana çatdırın',
        ['vehicle_parking'] = '[E] Avtomobil dayanacağı',
        ['job_vehicles'] = '[E] İş avtomobilləri',
        ['drop_off_npc'] = '[E] NPC-ni endir',
        ['call_npc'] = '[E] NPC çağır',
        ['blip_name'] = 'Mərkəz Taksi',
        ['taxi_label_1'] = 'Standart Taksi',
        ['no_spawn_point'] = 'Taksi üçün yer tapıla bilmədi',
        ['taxi_returned'] = 'Taksi dayanacağa qaytarıldı',
        ['on_duty'] = '[E] - Növbəyə çıx',
        ['off_duty'] = '[E] - Növbədən çıx',
        ['tip_received'] = 'Təhlükəsiz sürücülük üçün ₣%[sd] bahşiş aldınız',
        ['tip_not_received'] = 'Gələcəkdə bahşiş almaq istəyirsinizsə, taksini qəzaya salmamağa çalışın',
    },
    menu = {
        ['taxi_menu_header'] = 'Taksi Avtomobilləri',
        ['close_menu'] = '⬅ Menyunu bağla',
        ['boss_menu'] = 'Rəis menyusu'
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
