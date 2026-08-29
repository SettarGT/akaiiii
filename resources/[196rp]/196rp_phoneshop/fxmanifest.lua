fx_version 'cerulean'
game 'gta5'

name '196rp_phoneshop'
description '196 RP — Telefon mağazası: 20 model (10 Aifon + 10 Samsan, parodiya adlar)'
author '196 RP'
version '1.0.0'

shared_scripts {
    'config.lua',
}

client_scripts {
    '@es_extended/imports.lua',
    'client/main.lua',
}

server_scripts {
    '@es_extended/imports.lua',
    'server/main.lua',
}

dependencies {
    'es_extended',
    'esx_menu_default',
    'esx_notify',
    'esx_progressbar',
    'esx_textui',
}

lua54 'yes'
