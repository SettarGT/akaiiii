Config = {}

-- Discord Webhook URL-ləri
-- Necə yaratmaq olar: Discord server → Parametrlər → İnteqrasiyalar → Webhook → Yeni webhook
-- Sonra bu URL-i aşağıya yapışdırın. Boş qalsa, loqlar deaktivdir.

Config.Webhooks = {
    server = 'BURAYA_SERVER_LOQ_WEBHOOK_URLI',   -- qoşulma/çıxma
    admin  = 'BURAYA_ADMIN_LOQ_WEBHOOK_URLI',    -- admin əməlləri
    report = 'BURAYA_REPORT_LOQ_WEBHOOK_URLI',   -- reportlar
}

-- Server adı (loqlarda görünür)
Config.ServerName = '196 RP'

-- Rənglər (hex, # işarəsi olmadan)
Config.Colors = {
    join    = '4CAF50',
    leave   = 'F44336',
    admin   = 'FF9800',
    report  = 'E91E63',
    generic = '2196F3',
}
