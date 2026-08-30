Config = {}

-- ═══════════════════════════════════════════════════════════════
-- 196 RP | Whitelist konfiqurasiyası
-- ═══════════════════════════════════════════════════════════════

-- TRUE  = Yalnız whitelist-də olan oyunçular qoşula bilər
-- FALSE = Hamı qoşula bilər (açıq lansman rejimi; /muraciet yenə işləyir)
Config.WhitelistEnabled = false   -- ⚠️ AÇIQ LANSMAN: hamı qoşula bilər (adminlar /wluygula ilə yenə müraciətləri görür)

-- TRUE  = Whitelist yoxlanılmır, hamı daxil olur (açıq lansman)
-- FALSE = Whitelist aktiv, qəbul edilməmiş oyunçular /muraciet edə bilər
Config.OpenRegistration = true    -- ⚠️ Qeydiyyat açıqdır — /muraciet formaları da qəbul olunur

-- Discord Webhook (müraciətlər + qəbul/rədd bildirişləri bura düşür)
-- https://discord.com/developers/applications → Webhooks
Config.Webhook = "BURAYA_DISCORD_WEBHOOK_URL_YAZIN"

-- Gate mesajında göstərilən Discord dəvəti
Config.DiscordInvite = "discord.gg/196rp"

-- Admin qrupları (bu icazələr whitelist-dən yan keçir)
Config.AdminPermissions = { 'qbcore.god', 'qbcore.admin', 'qbcore.mod' }

-- Zenit təhlükəsizliyi: oyunçu qoşulanda yoxlanan identifikatorlar
Config.Identifiers = { 'license', 'steam' }

-- Hesab yoxlanışı serverin yavaşlamaması üçün keşdə saxlanılır (saniyə)
Config.CacheTime = 120

-- Müraciət formunda tələb olunan minimal yaş
Config.MinAge = 16

-- Müraciət mətnləri (oyunçu görür)
Config.Text = {
    apply_title     = '196 RP — Whitelist Müraciəti',
    apply_submit    = 'Göndər',
    applied         = 'Müraciətiniz göndərildi! Adminlər sizə Discord-da cavab verəcək.',
    already_applied = 'Artıq müraciətiniz var. Nəticə üçün Discord-a baxın!',
    accepted        = 'Müraciətiniz QƏBUL EDİLDİ! 196 RP-yə xoş gəldiniz!',
    denied          = 'Müraciətiniz rədd edildi. Səbəb: %{reason}',
    not_open        = 'İndi whitelist müraciətləri qəbul edilmir. Yenidən açıq olduqda müraciət edə bilərsiniz.',
    gate_check      = '196 RP | Whitelist yoxlanılır...',
    gate_denied     = '196 RP | Bu server üçün whitelist tələb olunur.\nMüraciət etmək üçün Discord-a qoşulun: %{discord}',
    gate_open       = '196 RP | Qeydiyyat açıqdır. Xoş gəldiniz!',
}
