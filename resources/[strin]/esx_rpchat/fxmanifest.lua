fx_version "cerulean"
lua54 "yes"
game "gta5"

shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua"
}

client_script "client/main.lua"

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/main.lua"
}
