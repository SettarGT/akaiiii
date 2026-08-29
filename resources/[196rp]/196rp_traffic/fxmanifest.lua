fx_version 'cerulean'
game 'gta5'

name '196rp_traffic'
description '196 RP - Şəhər boş qalmasın: piyada və avtomobil trafiki həmişə aktiv'
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
    'es_extended'
}
