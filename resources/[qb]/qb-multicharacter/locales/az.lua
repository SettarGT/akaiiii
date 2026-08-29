local Translations = {
    notifications = {
        ["char_deleted"] = "Personaj silindi!",
        ["deleted_other_char"] = "%{citizenid} citizen ID-li personajı uğurla sildiniz.",
        ["forgot_citizenid"] = "Citizen ID daxil etməyi unutdunuz!",
    },

    commands = {
        ["deletechar_description"] = "Başqa oyunçunun personajını silir",
        ["citizenid"] = "Citizen ID",
        ["citizenid_help"] = "Silmək istədiyiniz personajın Citizen ID-si",

        ["logout_description"] = "Personajdan çıx (Admin)",

        ["closeNUI_description"] = "Multi NUI bağla"
    },

    misc = {
        ["droppedplayer"] = "QBCore-dan ayrıldınız"
    },

    ui = {
        characters_header = "Personajlarım",
        emptyslot = "Boş slot",
        play_button = "Oyna",
        create_button = "Personaj Yarat",
        delete_button = "Personajı Sil",

        charinfo_header = "Personaj Məlumatı",
        charinfo_description = "Personajınız haqqında bütün məlumatı görmək üçün slot seçin.",
        name = "Ad",
        male = "Kişi",
        female = "Qadın",
        firstname = "Ad",
        lastname = "Soyad",
        nationality = "Milliyyət",
        gender = "Cins",
        birthdate = "Doğum tarixi",
        job = "İş",
        jobgrade = "İş rütbəsi",
        cash = "Nəğd pul",
        bank = "Bank",
        phonenumber = "Telefon nömrəsi",
        accountnumber = "Hesab nömrəsi",

        chardel_header = "Personaj Qeydiyyatı",

        deletechar_header = "Personajı Sil",
        deletechar_description = "Personajınızı silmək istədiyinizə əminsiniz?",

        cancel = "Ləğv et",
        confirm = "Təsdiqlə",

        retrieving_playerdata = "Oyunçu məlumatları yüklənir",
        validating_playerdata = "Oyunçu məlumatları yoxlanılır",
        retrieving_characters = "Personajlar yüklənir",
        validating_characters = "Personajlar yoxlanılır",

        ran_into_issue = "Bir problemlə qarşılaşdıq",
        profanity = "Görünür adınızda və ya milliyyətinizdə nalayiq sözlər istifadə etməyə çalışırsınız!",
        forgotten_field = "Görünür bir və ya bir neçə xananı doldurmağı unutdunuz!"
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
