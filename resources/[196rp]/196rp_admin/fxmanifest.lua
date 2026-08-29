fx_version 'cerulean'
game 'gta5'

name '196rp_admin'
description '196 RP - Admin əmrləri'
author '196 RP'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@es_extended/locale.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'es_extended'
}
