fx_version 'cerulean'
game 'gta5'

name '196rp_fuel'
description '196 RP - Yanacaq sistemi'
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
    'esx_menu_dialog',
    'esx_textui',
    'esx_notify'
}
