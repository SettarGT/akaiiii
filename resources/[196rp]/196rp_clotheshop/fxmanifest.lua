fx_version 'cerulean'
game 'gta5'

name '196rp_clotheshop'
description '196 RP - Paltar mağazaları və soyunma kabinələri'
author '196 RP'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@es_extended/locale.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

dependencies {
    'es_extended',
    'esx_skin',
    'esx_textui',
    'esx_notify'
}
