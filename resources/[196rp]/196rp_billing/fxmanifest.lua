fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Azerbaijan Role Play (196 RP)'
description 'Faktura sistemi: /faktura <id> <məbləğ> <səbəb> → NUI qəbul/imitina, webhook log'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
}

dependencies {
    'qb-core',
    'oxmysql',
}
