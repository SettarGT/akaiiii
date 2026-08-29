fx_version 'cerulean'
game 'gta5'

name '196rp_social'
description '196 RP - Sosial sistemlər: hədiyyə, evlilik (nişan + toy), dostluq, missiya sistemi'
author '196 RP'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'es_extended',
    'esx_menu_default',
    'esx_menu_dialog',
    'esx_notify',
    'esx_progressbar',
    'esx_textui',
    'oxmysql'
}
