fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author '196 RP'
description '196 RP - İş sistemi (balıqçılıq, mədən, meşə, inşaat, mexanik, avtosalon — hibrid self-service)'
version '1.2.0'

shared_scripts {
    'config.lua',
    '@qb-core/shared/locale.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

dependencies {
    'qb-core',
    'qb-menu',
    'qb-target',
    'qb-vehiclekeys',
    'progressbar',
    'oxmysql',
}
