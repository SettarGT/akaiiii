Config = {}

-- İş Mərkəzi məkanları
Config.Locations = {
    { label = 'Mərkəz İş Mərkəzi', coords = vector3(-266.63, -965.76, 31.22), heading = 180.0 },
    { label = 'Sahil İş Mərkəzi', coords = vector3(995.31, -1184.85, 27.09), heading = 180.0 },
}

-- Mülki vətəndaşlar üçün açıq işlər (QBCore.Shared.Jobs daxilində mövcud olanlar)
Config.Jobs = {
    trucker     = 'Yük daşıma — anbarlara yük çatdır',
    taxi        = 'Taksi — sərnişin daşı',
    bus         = 'Avtobus — marşrut sür',
    garbage     = 'Zibilçilik — şəhəri təmizlə',
    hotdog      = 'Hotdog — kürsüdə sat',
    reporter    = 'Reporter — xəbər çək',
    vineyard    = 'Üzümçülük — üzüm yığ və emal et',
    tow         = 'Yedək — avtomobil daşı',
}

Config.Text = {
    header          = 'İş Mərkəzi',
    current_job     = 'Hazırkı iş: %{job}',
    job_info        = '%{label}',
    quit_job        = 'İşdən çıx',
    quit_desc       = 'Mülki vətəndaş ol',
    applied         = '%{job} işinə düzəldiniz!',
    quit_msg        = 'İşdən çıxdınız. Artıq mülki vətəndaşsınız.',
    already         = 'Artıq bu işdəsiniz.',
    wrong_syntax    = 'Düzgün istifadə: /is <iş adı>',
    not_open        = 'Bu iş hazırda qəbul etmir.',
}
