Config = {}

-- Sürücülük məktəbinin yerləşdiyi yer
Config.DMV = {
    coords = vector3(244.0, -1399.0, 30.5),
    label = 'Sürücülük Məktəbi (DMV)',
    blip = { sprite = 488, color = 46 },
}

-- İmtahan qiyməti
Config.TheoryCost = 200      -- yazılı imtahan
Config.DrivingCost = 500     -- sürmə imtahanı

-- Yazılı imtahan sualları (Azərbaycan dilində)
Config.Questions = {
    {
        q = 'Qırmızı işıqfor nə deməkdir?',
        options = { 'Dayan', 'Sür', 'Yavaşla' },
        answer = 1,
    },
    {
        q = 'İki zolaqlı yolda soldan nəqliyyat vasitəsi yaxınlaşırsa, nə etməlisiniz?',
        options = { 'Sürəti artırmaq', 'Yol vermək', 'Sinyal vermədən dönmək' },
        answer = 2,
    },
    {
        q = 'Təcili yardım maşını siyranı işə salıb yaxınlaşırsa?',
        options = { 'Sürətlə uzaqlaşmaq', 'Yol vermək və dayanmaq', 'Onu izləmək' },
        answer = 2,
    },
    {
        q = 'Piyada keçidində dayanmış piyada gördükdə?',
        options = { 'Sinyal vermək', 'Yol vermək', 'Sürətlə keçmək' },
        answer = 2,
    },
    {
        q = 'Sarı işıqfor nə deməkdir?',
        options = { 'Sürətlənmək', 'Dayanmağa hazırlaşmaq', 'Hərəkətə başlamaq' },
        answer = 2,
    },
    {
        q = 'Sürücülük vəsiqəsi olmadan maşın sürmək?',
        options = { 'Qanunidir', 'Cəriməyə səbəb olur', 'Yalnız gecə qanunidir' },
        answer = 2,
    },
    {
        q = 'Yağışlı havada sürmə zamanı?',
        options = { 'Sürəti artırmaq', 'Sürəti azaltmaq', 'Fənəri söndürmək' },
        answer = 2,
    },
    {
        q = 'Təhlükəli vəziyyətdə nə etməlisiniz?',
        options = { 'Əyləc basmaq', 'Siqnal vermək', 'Hər ikisi' },
        answer = 3,
    },
}

-- Keçmək üçün lazım olan düzgün cavab sayı
Config.PassScore = 6

-- Sürmə imtahanı yolu (yoxlama nöqtələri)
Config.Checkpoints = {
    vector3(244.0, -1399.0, 30.5),
    vector3(180.0, -1390.0, 30.0),
    vector3(130.0, -1390.0, 30.0),
    vector3(100.0, -1390.0, 30.0),
    vector3(100.0, -1340.0, 30.0),
    vector3(150.0, -1340.0, 30.0),
    vector3(200.0, -1340.0, 30.0),
    vector3(244.0, -1360.0, 30.5),
}

-- İmtahan maşını
Config.TestVehicle = 'blista'

-- Vəsiqə tipi (user_licenses cədvəlində)
Config.LicenseType = 'dmv'
