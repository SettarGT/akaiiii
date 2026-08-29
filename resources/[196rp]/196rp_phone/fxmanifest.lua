fx_version 'cerulean'
game 'gta5'

name '196rp_phone'
description '196 RP - Telefon sistemi: premium NUI (zəng, SMS, kontaktlar, bank)'
author '196 RP'
version '1.1.0'

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

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/css/style.css',
    'web/js/app.js',
}

dependencies {
    'es_extended',
    'esx_notify',
    'oxmysql',
}

lua54 'yes'
