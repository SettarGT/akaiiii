fx_version 'cerulean'
game 'gta5'

name '196rp_municipal'
description '196 RP - Bələdiyyə işləri: günün müxtəlif vaxtlarında müxtəlif yerlərdə yol təmiri, təmizlik, işıq dirəkləri'
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
    'esx_notify',
    'esx_progressbar',
    'esx_textui'
}
