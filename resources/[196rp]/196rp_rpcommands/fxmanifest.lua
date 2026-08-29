fx_version 'cerulean'
game 'common'

name '196rp_rpcommands'
description '196 RP - Rol-pley əmrləri (/me, /do, /try, /ooc, /report)'
author '196 RP'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@es_extended/locale.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'es_extended'
}
