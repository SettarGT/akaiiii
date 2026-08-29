fx_version 'cerulean'
game 'gta5'
description '196 RP - Ev interyeri (mebel)'
lua54 'yes'
version '1.0.0'

shared_scripts {
    '/config.lua',
    '@es_extended/imports.lua',
}

server_scripts {
    '/server/main.lua',
}

client_scripts {
    '/client/main.lua',
}

dependencies {
    'es_extended',
    'esx_context',
    'oxmysql',
}
