fx_version 'cerulean'
game 'gta5'

name '196rp_civicjobs'
description '196 RP - Şəhər işləri: pizza/kuryer/yük çatdırma, jurnalist, elektrik, santexnik, bağban, yanacaqçı, rəqqasə, arıçı, heyvandar, əczaçı, həkim, stomatoloq, veterinar, gözəllik, masaj, detallinq, əmlak agenti, bilet satıcısı'
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
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'es_extended',
    'esx_notify',
    'esx_progressbar',
    'esx_textui',
    'oxmysql'
}
