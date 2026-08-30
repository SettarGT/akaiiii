Config = {}

-- ═══════════════════════════════════════════════════════════════
-- 196 RP | Faktura (Invoice) sistemi
-- ═══════════════════════════════════════════════════════════════

-- Maksimum məbləğ (server-side yoxlama)
Config.MaxAmount = 500000

-- Faktura müddəti (saniyə) — bitdikdə avtomatik ləğv
Config.Expiry = 300

-- Discord Webhook (faktura logları)
Config.Webhook = "BURAYA_DISCORD_WEBHOOK_URL_YAZIN"

-- Ödəmə yolu: 'bank' (banka köçürülür) / 'cash' (nağd) / 'both' (əvvəl bank, sonra cash)
Config.PaymentMethod = 'both'
