fx_version 'cerulean'
game 'gta5'

name '196rp_speedcam'
description '196 RP - Sürət kameraları (100 m qalmış xəritədə göstərir) və sürət həddi zonaları'
author '196 RP'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'es_extended',
    'esx_notify'
}
