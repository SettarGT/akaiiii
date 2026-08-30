fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author '196 RP'
description '196 RP - VIP (kosmetik ulduz, queue priority, xüsusi plitə)'
version '1.0.0'

shared_scripts {
    'config.lua',
    '@qb-core/shared/locale.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@connectqueue/connectqueue.lua',
    'server/main.lua',
}

dependencies {
    'qb-core',
    'connectqueue',
    'oxmysql',
}
