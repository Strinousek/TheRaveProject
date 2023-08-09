fx_version "cerulean"
lua54 "yes"
game "gta5"

client_scripts {
    "@ox_lib/init.lua",
    "client/*.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/*.lua"
}