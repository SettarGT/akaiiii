fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author '196 RP'
description '196 RP - Streamer rejimi (RP mesajlarında adı gizlət)'
version '1.0.0'

shared_scripts {
    'config.lua',
    '@qb-core/shared/locale.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

dependencies {
    'qb-core',
}
