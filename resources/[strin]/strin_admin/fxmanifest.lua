fx_version "cerulean"
game "gta5"
lua54 "yes"

shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua",
}

client_scripts {
    "client/noclip.lua",
    "client/main.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/admins.lua",
    "server/main.lua",
    "server/bans.lua",
    "server/honeypot.lua",
}