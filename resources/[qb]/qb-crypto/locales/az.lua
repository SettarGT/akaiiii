local Translations = {
    error = {
        you_dont_have_a_cryptostick = 'Kripto USB-niz yoxdur',
        cryptostick_malfunctioned = 'Kripto USB nasazlığı'
    },
    success = {
        you_have_exchanged_your_cryptostick_for = 'Kripto USB-nizi dəyişdiniz: %{amount} QBit'
    },
    credit = {
        there_are_amount_credited = '%{amount} QBit hesabınıza köçürüldü!',
        you_have_qbit_purchased = '%{dataCoins} QBit aldınız!'
    },
    debit = {
        you_have_sold = '%{dataCoins} QBit satdınız!'
    },
    text = {
        enter_usb = '[E] - USB-ni qoş',
        system_is_rebooting = 'Sistem yenidən başladılır - %{rebootInfoPercentage} %',
        you_have_not_given_a_new_value = 'Yeni dəyər daxil etmədiniz ... Cari dəyər: %{crypto}',
        this_crypto_does_not_exist = 'Bu kripto mövcud deyil, mövcud kripto(lar): Qbit',
        you_have_not_provided_crypto_available_qbit = 'Kripto daxil etmədiniz, mövcud: Qbit',
        the_qbit_has_a_value_of = 'QBit-in dəyəri: %{crypto}',
        you_have_with_a_value_of = 'Sizdə %{playerPlayerDataMoneyCrypto} QBit var, dəyəri: %{mypocket},-'
    }
}

if GetConvar('qb_locale', 'en') == 'az' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
