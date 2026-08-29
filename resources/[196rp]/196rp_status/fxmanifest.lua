fx_version 'cerulean'
game 'gta5'
description '196 RP - Həyat statusu (aclıq, susuzluq, enerji) və HUD'
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

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js',
}

dependencies {
    'es_extended',
    'oxmysql',
}
