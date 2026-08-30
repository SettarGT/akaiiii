fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Azerbaijan Role Play (196 RP)'
description 'F5 Radial maşın idarəetmə menyusu (glassmorphism)'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
}

dependencies {
    'qb-core',
}
