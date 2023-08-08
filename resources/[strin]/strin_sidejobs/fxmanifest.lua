fx_version "cerulean"
lua54 "yes"
game "gta5"

shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua",
    "configs/*.lua",
}

client_scripts {
    "client/main.lua",
    "client/taxi.lua",
    "client/lumberjack.lua",
}

server_scripts {
    "server/main.lua",
    "server/taxi.lua",
    "server/lumberjack.lua",
}