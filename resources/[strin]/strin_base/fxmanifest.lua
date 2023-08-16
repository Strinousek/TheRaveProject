fx_version 'adamant'
lua54 "yes"
game 'gta5'

shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua",
    "shared/*.lua",
    "config.lua"
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/discord.lua',
    'server/sit.lua',
    'server/robbery.lua',
    'server/ammunation.lua',
    'server/network.lua',
    'server/items.lua',
    'server/identifiers.lua',
    'server/doctor.lua',
    'server/carry.lua',
    'server/trunk.lua',
}

files {
    'peds.meta',
	'ambientpedmodelsets.meta',
	'dispatch.meta',
}
    
data_file 'PED_METADATA_FILE' 'peds.meta'
data_file 'AMBIENTPEDMODELSSET_FILE' 'ambientpedmodelsets.meta'
data_file 'DISPATCH_FILE' 'dispatch.meta'
data_file 'PEDS_FILE' 'peds.meta'