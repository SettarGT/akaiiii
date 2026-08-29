fx_version 'cerulean'
game 'gta5'

name '196rp_spawn'
description '196 RP - Spawn seçim ekranı (Azərbaycan dili)'
author '196 RP'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@es_extended/locale.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/css/style.css',
    'web/js/app.js'
}
