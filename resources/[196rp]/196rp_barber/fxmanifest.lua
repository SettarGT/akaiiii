fx_version 'cerulean'
game 'gta5'
description '196 RP - Bərbər və Döymə salonu'
lua54 'yes'
version '1.0.0'

shared_scripts {
    '/config.lua',
    '@es_extended/imports.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '/server/main.lua',
}

client_scripts {
    '/client/main.lua',
}

dependencies {
    'es_extended',
    'esx_skin',
    'skinchanger',
    'esx_context',
}
