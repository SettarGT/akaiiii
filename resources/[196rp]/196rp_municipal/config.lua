Config = {}

-- ═══════════════════════════════════════════════════════════════
-- 196 RP | Bələdiyyə (City Hall) — Pasport & Lisenziyalar
-- ═══════════════════════════════════════════════════════════════

-- Bələdiyyə ofisləri (City Hall + idarə)
Config.Offices = {
    { coords = vector3(-550.8, -191.5, 39.3), label = 'Bələdiyyə | Pasport / Lisenziya', sprite = 419, color = 0, scale = 1.0 },
}

-- Bələdiyyə əməliyyatları
Config.Actions = {
    passport = {
        label = '🪪 Şəxsiyyət Vəsiqəsi (Pasport)',
        price = 500,             -- ₣
        desc = 'FİN kodu + qan qrupu ilə rəsmi pasport',
    },
    driver = {
        label = '🚗 Sürücülük Vəsiqəsi (B kateqoriya)',
        price = 1500,            -- ₣
        desc = 'Nəzəri imtahan (10 sual, 60% keçid) + praktik marşrut',
    },
    weapon = {
        label = '🔫 Silah Lisenziyası',
        price = 5000,            -- ₣
        desc = 'Silah gəzdirmək üçün rəsmi icazə',
    },
    press = {
        label = '📷 Mətbuat Lisenziyası',
        price = 2000,            -- ₣
        desc = 'Reporter işi üçün rəsmi icazə',
    },
    lawyer = {
        label = '⚖️ Vəkillik Lisenziyası',
        price = 10000,           -- ₣
        desc = 'Məhkəmədə vəkilə icazə',
    },
}

-- İmtahan (nəzəri) — 10 sual, 60% keçid
Config.DrivingExam = {
    passPercent = 60,
    questions = {
        { q = 'Yol nişanında "STOP" yazıbsa nə etməlisən?',
          a = { 'Tam dayan, sonra davam et', 'Yavaşla və keç', 'Siqnal ver, keç', 'Dayanmadan keç' }, correct = 1 },
        { q = 'Qırmızı işıqda nə etməlisən?',
          a = { 'Dayan', 'Yavaşla', 'Keç', 'Siqnal ver' }, correct = 1 },
        { q = 'Sürət həddi 60 km/s olan yolda maksimum nə qədər sürə bilərsən?',
          a = { '60 km/s', '70 km/s', '80 km/s', 'İstənilən' }, correct = 1 },
        { q = 'Qəza yerindən qaçmaq necə qiymətləndirilir?',
          a = { 'Cinayət', 'Xırda pozuntu', 'Qayda pozuntusu', 'Heç nə' }, correct = 1 },
        { q = 'Arxa işıqlar (fənərlər) nə vaxt yandırılmalıdır?',
          a = { 'Qaranlıqda / zəif görüntüdə', 'Yalnız gecə', 'Heç vaxt', 'Yalnız yağışda' }, correct = 1 },
        { q = 'Alkoqollu halda maşın sürmək?',
          a = { 'Qadağandır', 'İcazəlidir', 'Kiçik həcmdə icazəlidir', 'Yalnız gecə' }, correct = 1 },
        { q = 'Təhlükəli vəziyyətdə əyləc etmək üçün nə istifadə olunur?',
          a = { 'Əyləc pedalı', 'Qaz pedalı', 'Sükan', 'Siqnal' }, correct = 1 },
        { q = 'Avtomobili park etmək qadağandır:',
          a = { 'Yol nişanı ilə göstərilən yerlərdə', 'Yolun kənarında', 'Ticarət mərkəzində', 'Yaşayış ərazisində' }, correct = 1 },
        { q = 'Sürücü bələdiyyəyə ilk dəfə müraciət edəndə nə lazımdır?',
          a = { 'Pasport (FİN)', 'Yalnız ad', 'Yalnız yaş', 'Heç nə' }, correct = 1 },
        { q = 'Sürücülük vəsiqəsi neçə ballıq sistemlə işləyir?',
          a = { '12 bal', '5 bal', '20 bal', '10 bal' }, correct = 1 },
    },
}

-- Praktik marşrut (3 nəzarət nöqtəsi)
Config.PracticalRoute = {
    { coords = vector3(-640.0, -179.0, 38.2), label = 'Nöqtə 1' },
    { coords = vector3(-700.0, -240.0, 36.0), label = 'Nöqtə 2' },
    { coords = vector3(-620.0, -260.0, 37.5), label = 'Nöqtə 3 (Son)' },
    duration = 120, -- saniyə
}

-- Qan qrupları (təsadüfi)
Config.BloodTypes = { 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-' }

-- FİN kodu (11 rəqəm)
Config.FIN = {
    prefix = '196',            -- ilk 3 rəqəm
    digits = 8,                -- qalan 8 rəqəm (cəmi 11)
}

-- Pasport NUI kart
Config.PassportCard = {
    bg1 = '#0b1a2e',
    bg2 = '#12294a',
    accent = '#f7b733',
}
