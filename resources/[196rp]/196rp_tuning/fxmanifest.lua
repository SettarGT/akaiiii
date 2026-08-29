fx_version 'cerulean'
game 'gta5'

name '196rp_tuning'
description '196 RP - Tuninq emalatxanası (mühərrik, əyləc, ötürücü, asqı, zireh, turbo, ksenon, rəng)'
author '196 RP'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

dependencies {
    'es_extended',
    'esx_context',
    'esx_textui',
}
