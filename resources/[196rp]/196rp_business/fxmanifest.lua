fx_version 'cerulean'
game 'gta5'

name '196rp_business'
description '196 RP - Məkanlar, bliplər və markerlər'
author '196 RP'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

dependencies {
    'es_extended',
    'esx_textui'
}
