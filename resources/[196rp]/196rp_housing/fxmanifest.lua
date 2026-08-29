fx_version 'cerulean'
game 'gta5'

name '196rp_housing'
description '196 RP - Daşınmaz əmlak sistemi (ev almaq/satmaq)'
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

server_scripts {
    'server/main.lua'
}

dependencies {
    'es_extended',
    'esx_menu_default',
    'esx_menu_dialog',
    'esx_textui',
    'esx_notify'
}
