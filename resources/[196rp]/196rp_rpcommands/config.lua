Config = {}

-- Yaxınlıqdakı oyunçulara mesajın görünmə məsafəsi (metr)
Config.Distance = 15.0

-- /try şansı (0.0 - 1.0)
Config.TryChance = 0.5

-- Sözlər
Config.Text = {
    me_prefix    = '* %{name} %{text}',
    do_prefix    = '* %{name} %{text}',
    ame_prefix   = '** %{name} %{text}', -- ((anlaşılmayan pərakəndə hərəkət))
    try_success  = '✔ (%{name}) %{text} — UĞURLU',
    try_fail     = '✘ (%{name}) %{text} — UĞURSUZ',
    try_prefix   = '* /try: %{name} %{text}',
    report_prefix = '[REPORT] %{name} (%{id}): %{text}',
    pm_prefix    = '[PM] %{name}: %{text}',
    ooc_prefix   = '[OOC] %{name}: %{text}',
    wrong_usage  = 'Düzgün istifadə: %{cmd} <mətn>',
}

-- Report webhook (boş qalsa, yalnız oyun daxilində adminlərə gedir)
Config.ReportWebhook = ''

