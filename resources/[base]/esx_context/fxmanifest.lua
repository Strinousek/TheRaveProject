fx_version 'bodacious'

game 'gta5'
author 'ESX-Framework & Brayden'
description 'Offical ESX Legacy Context Menu'
lua54 'yes'
version '1.10.1'

shared_scripts {
    '@es_extended/imports.lua',
    "@ox_lib/init.lua"
}

client_scripts {
    'config.lua',
    'main.lua',
}

dependencies {
    'es_extended'
}
