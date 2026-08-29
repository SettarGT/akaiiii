fx_version 'cerulean'
game 'gta5'

name '196rp_police'
description '196 RP - Polis işi (növbə, qandallar, cərimə, həbsxana)'
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
    'esx_textui',
    'esx_notify',
    'esx_progressbar',
    '196rp_garage'
}
