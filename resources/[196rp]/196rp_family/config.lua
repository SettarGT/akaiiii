Config = {}

-- Evlilik
Config.Marriage = {
    Price = 2500,        -- ₣
    MinLevel = 2,        -- min level (iş təcrübəsi)
    Cooldown = 3600,     -- boşandıqdan sonra yenidən evlənmə (san)
}

-- CK (karakter ölümü) — yalnız admin + oyunçunun razılığı
Config.CK = {
    RequireAce = 'command',
    ConfirmWord = 'ck',  -- admin /ck <source> ilə təklif göndərir; oyunçu /ckqebul edir
}
