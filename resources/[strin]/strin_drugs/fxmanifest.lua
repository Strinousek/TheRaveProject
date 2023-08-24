fx_version "cerulean"
lua54 "yes"
game "gta5"

shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua",
    "config.lua"
}

client_scripts {
    "client/main.lua",
    "client/weed.lua",
    "client/lsd.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/main.lua",
    "server/weed.lua",
    "server/lsd.lua",
}