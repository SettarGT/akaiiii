local Translations = {
    error = {
        not_online                  = 'Oyunçu onlayn deyil',
        wrong_format                = 'Səhv format',
        missing_args                = 'Bütün arqumentlər daxil edilməyib (x, y, z)',
        missing_args2               = 'Bütün arqumentlər doldurulmalıdır!',
        no_access                   = 'Bu əmrə icazəniz yoxdur',
        company_too_poor            = 'İşəgötürəninizin hesabı kasadır',
        item_not_exist              = 'Əşya mövcud deyil',
        too_heavy                   = 'İnventar çox doludur',
        location_not_exist          = 'Məkan mövcud deyil',
        duplicate_license           = '[QBCORE] - Təkrarlanan Rockstar Lisensiyası tapıldı',
        no_valid_license            = '[QBCORE] - Etibarlı Rockstar Lisensiyası tapılmadı',
        not_whitelisted             = '[QBCORE] - Bu server üçün whitelist-ə daxil deyilsiniz',
        server_already_open         = 'Server artıq açıqdır',
        server_already_closed       = 'Server artıq bağlıdır',
        no_permission               = 'Bunun üçün icazəniz yoxdur..',
        no_waypoint                 = 'Xəritədə işarə qoyulmayıb.',
        tp_error                    = 'Teleportasiya zamanı xəta baş verdi.',
        ban_table_not_found         = '[QBCORE] - Bazada ban cədvəli tapılmadı. SQL faylını düzgün idxal etdiyinizə əmin olun.',
        connecting_database_error   = '[QBCORE] - Bazaya qoşularkən xəta baş verdi. SQL serverin işlədiyini və server.cfg-dəki məlumatların düzgün olduğunu yoxlayın.',
        connecting_database_timeout = '[QBCORE] - Baza bağlantısı vaxt aşımına düşdü. SQL serverin işlədiyini və server.cfg-dəki məlumatların düzgün olduğunu yoxlayın.',
    },
    success = {
        server_opened = 'Server hamı üçün açıldı',
        server_closed = 'Server bağlandı',
        teleported_waypoint = 'Xəritədəki işarəyə teleport oldunuz.',
    },
    info = {
        received_paycheck = '$%{value} məbləğində maaş aldınız',
        job_info = 'İş: %{value} | Rütbə: %{value2} | Növbə: %{value3}',
        gang_info = 'Qrup: %{value} | Rütbə: %{value2}',
        on_duty = 'İndi növbədəsiniz!',
        off_duty = 'Növbədən çıxdınız!',
        checking_ban = 'Salam %s. Ban olub-olmadığınız yoxlanılır.',
        join_server = '%s, {Server Name} serverinə xoş gəldiniz.',
        checking_whitelisted = 'Salam %s. Whitelist icazəniz yoxlanılır.',
        exploit_banned = 'Xidmət şərtlərini pozduğunuz üçün banlandınız. Ətraflı məlumat üçün Discord-a baxın: %{discord}',
        exploit_dropped = 'Qayda pozuntusuna görə serverdən atıldınız',
    },
    command = {
        tp = {
            help = 'Oyunçuya və ya koordinata teleport (Admin)',
            params = {
                x = { name = 'id/x', help = 'Oyunçunun ID-si və ya X mövqeyi' },
                y = { name = 'y', help = 'Y mövqeyi' },
                z = { name = 'z', help = 'Z mövqeyi' },
            },
        },
        tpm = { help = 'Xəritədəki işarəyə teleport (Admin)' },
        togglepvp = { help = 'Serverdə PVP-ni aç/bağla (Admin)' },
        addpermission = {
            help = 'Oyunçuya icazə ver (God Only)',
            params = {
                id = { name = 'id', help = 'Oyunçunun ID-si' },
                permission = { name = 'permission', help = 'İcazə səviyyəsi' },
            },
        },
        removepermission = {
            help = 'Oyunçudan icazəni götür (God Only)',
            params = {
                id = { name = 'id', help = 'Oyunçunun ID-si' },
                permission = { name = 'permission', help = 'İcazə səviyyəsi' },
            },
        },
        openserver = { help = 'Serveri hər kəs üçün aç (Admin)' },
        closeserver = {
            help = 'Serveri icazəsizlər üçün bağla (Admin)',
            params = {
                reason = { name = 'reason', help = 'Bağlanma səbəbi (istəyə bağlı)' },
            },
        },
        car = {
            help = 'Avtomobil yarat (Admin)',
            params = {
                model = { name = 'model', help = 'Avtomobilin model adı' },
            },
        },
        dv = { help = 'Avtomobili sil (Admin)' },
        dvall = { help = 'Bütün avtomobilləri sil (Admin)' },
        dvp = { help = 'Bütün piyadaları sil (Admin)' },
        dvo = { help = 'Bütün obyektləri sil (Admin)' },
        givemoney = {
            help = 'Oyunçuya pul ver (Admin)',
            params = {
                id = { name = 'id', help = 'Oyunçunun ID-si' },
                moneytype = { name = 'moneytype', help = 'Pul növü (cash, bank, crypto)' },
                amount = { name = 'amount', help = 'Pul miqdarı' },
            },
        },
        setmoney = {
            help = 'Oyunçunun pulunu təyin et (Admin)',
            params = {
                id = { name = 'id', help = 'Oyunçunun ID-si' },
                moneytype = { name = 'moneytype', help = 'Pul növü (cash, bank, crypto)' },
                amount = { name = 'amount', help = 'Pul miqdarı' },
            },
        },
        job = { help = 'İşinizi yoxlayın' },
        setjob = {
            help = 'Oyunçunun işini təyin et (Admin)',
            params = {
                id = { name = 'id', help = 'Oyunçunun ID-si' },
                job = { name = 'job', help = 'İş adı' },
                grade = { name = 'grade', help = 'İş rütbəsi' },
            },
        },
        gang = { help = 'Qrupunuzu yoxlayın' },
        setgang = {
            help = 'Oyunçunun qrupunu təyin et (Admin)',
            params = {
                id = { name = 'id', help = 'Oyunçunun ID-si' },
                gang = { name = 'gang', help = 'Qrup adı' },
                grade = { name = 'grade', help = 'Qrup rütbəsi' },
            },
        },
        ooc = { help = 'OOC Chat Mesajı' },
        me = {
            help = 'Yerli mesaj göstər',
            params = {
                message = { name = 'message', help = 'Göndəriləcək mesaj' }
            },
        },
    },
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
