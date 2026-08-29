fx_version 'cerulean'
game 'gta5'

name '196rp_bakumap'
description '196 RP — Bakı xəritəsi qatı: 12 metro stansiyası, rayonlar, xətlər'
author '196 RP'
version '1.0.0'

shared_scripts {
    'config.lua',
    'objects.lua',
}

client_scripts {
    '@es_extended/imports.lua',
    'client/main.lua',
    'client/objects.lua',
}

server_scripts {
    '@es_extended/imports.lua',
    'server/main.lua',
}

dependencies {
    'es_extended',
    'esx_menu_default',
    'esx_notify',
    'esx_textui',
}

lua54 'yes'
