local Translations = {
    error = {
        not_in_range = 'Bələdiyyədən çox uzaqsınız'
    },
    success = {
        recived_license = '%{value} lisenziyanızı ₣50 qarşılığında aldınız'
    },
    info = {
        new_job_app = 'Müraciətiniz (%{job}) rəisinə göndərildi',
        bilp_text = 'Şəhər xidmətləri',
        city_services_menu = '~g~E~w~ - Şəhər xidmətləri menyusu',
        id_card = 'Şəxsiyyət vəsiqəsi',
        driver_license = 'Sürücülük vəsiqəsi',
        weaponlicense = 'Silah lisenziyası',
        new_job = 'Yeni işiniz mübarək! (%{job})',
    },
    email = {
        jobAppSender = "%{job}",
        jobAppSub = "%(job) müraciətiniz üçün təşəkkür edirik.",
        jobAppMsg = "Salam %{gender} %{lastname}<br /><br />%{job} müraciətinizi qəbul etdi.<br /><br />Rəis sorğunuza baxır və ən qısa zamanda müsahibə üçün sizinlə əlaqə saxlayacaq.<br /><br />Müraciətiniz üçün bir daha təşəkkür edirik.",
        mr = 'Cənab',
        mrs = 'Xanım',
        sender = 'Şəhər rəhbərliyi',
        subject = 'Sürmə dərsi sorğusu',
        message = 'Salam %{gender} %{lastname}<br /><br />Kiminsə sürmə dərsi almaq istədiyi barədə mesaj aldıq<br />Dərs keçməyə hazırsınızsa, bizimlə əlaqə saxlayın:<br />Ad: <strong>%{firstname} %{lastname}</strong><br />Telefon: <strong>%{phone}</strong><br/><br/>Hörmətlə,<br />Los Santos Şəhər rəhbərliyi'
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
