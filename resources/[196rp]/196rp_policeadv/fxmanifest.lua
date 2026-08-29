fx_version 'cerulean'
game 'gta5'

name '196rp_policeadv'
description '196 RP - Dövlət qüvvələri: qərargah, polis radarı, yol polisi, K9 iti, SWAT, staj əlavəsi, TİB helikopteri, yanğın dərəcələri, mülki müdafiə'
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
    'esx_menu_dialog',
    'esx_notify',
    'esx_textui',
    'oxmysql'
}
