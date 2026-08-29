local Translations = {
    error = {
        lockpick_fail = "Uğursuz oldu",
        door_not_found = "Model hash alınmadı, qapı şəffafdırsa qapı çərçivəsinə nişan alın",
        same_entity = "Hər iki qapı eyni obyekt ola bilməz",
        door_registered = "Bu qapı artıq qeydiyyatdadır",
        door_identifier_exists = "Bu identifikatorlu qapı konfiqurasiyada artıq mövcuddur. (%s)",
    },
    success = {
        lockpick_success = "Uğurlu"
    },
    general = {
        locked = "Kilidli",
        unlocked = "Açıq",
        locked_button = "[E] - Kilidli",
        unlocked_button = "[E] - Açıq",
        keymapping_description = "Qapı kilidləri ilə əlaqə yarat",
        keymapping_remotetriggerdoor = "Qapını uzaqdan aç",
        locked_menu = "Kilidli",
        pickable_menu = "Qıfılla açılan",
        cantunlock_menu = 'Açıla bilməz',
        hidelabel_menu = 'Qapı etiketini gizlət',
        distance_menu = "Maksimum məsafə",
        item_authorisation_menu = "Əşya icazəsi",
        citizenid_authorisation_menu = "CitizenID icazəsi",
        gang_authorisation_menu = "Qrup icazəsi",
        job_authorisation_menu = "İş icazəsi",
        jobGrade_authorisation_menu = "İş rütbəsi (istəyə bağlı)",
        gangGrade_authorisation_menu = "Qrup rütbəsi (istəyə bağlı)",
        doortype_title = "Qapı növü",
        doortype_door = "Tək qapı",
        doortype_double = "İkili qapı",
        doortype_sliding = "Tək sürüşmə qapı",
        doortype_doublesliding = "İkili sürüşmə qapı",
        doortype_garage = "Qaraj",
        dooridentifier_title = "Unikal identifikator",
        doorlabel_title = "Qapı etiketi",
        configfile_title = "Konfiqurasiya faylı adı",
        submit_text = "Göndər",
        newdoor_menu_title = "Yeni qapı əlavə et",
        newdoor_command_description = "Qapı kilid sisteminə yeni qapı əlavə et",
        doordebug_command_description = "Debug rejimini dəyiş",
        warning = "Xəbərdarlıq",
        created_by = "yaradan:",
        warn_no_permission_newdoor = "%{player} (%{license}) icazəsiz yeni qapı əlavə etməyə cəhd etdi (mənbə: %{source})",
        warn_no_authorisation = "%{player} (%{license}) icazəsiz qapı açmağa cəhd etdi (Göndərilən: %{doorID})",
        warn_wrong_doorid = "%{player} (%{license}) yanlış qapını yeniləməyə cəhd etdi (Göndərilən: %{doorID})",
        warn_wrong_state = "%{player} (%{license}) yanlış vəziyyətə yeniləməyə cəhd etdi (Göndərilən: %{state})",
        warn_wrong_doorid_type = "%{player} (%{license}) düzgün doorID göndərmədi (Göndərilən: %{doorID})",
        warn_admin_privilege_used = "%{player} (%{license}) admin imtiyazı ilə qapı açdı"
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
