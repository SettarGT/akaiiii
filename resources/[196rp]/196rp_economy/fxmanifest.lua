fx_version 'cerulean'
game 'gta5'

name '196rp_economy'
description '196 RP — İqtisadiyyat mərkəzi: dinamik qiymət, vergilər, money sink, dupe qorunması'
author '196 RP'
version '1.0.0'

shared_scripts {
    'config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@es_extended/imports.lua',
    'server/main.lua',
}

dependencies {
    'es_extended',
    'oxmysql',
    'esx_notify',
}

lua54 'yes'
