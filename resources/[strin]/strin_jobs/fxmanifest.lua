fx_version "cerulean"
game "gta5"

lua54 "yes"

shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua",
    "config.lua"
}

client_scripts {
    "client/main.lua",
    "client/boss_office.lua",
    "client/medical.lua",
    "client/shops.lua",
    "client/blips.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/main.lua",
    "server/boss_office.lua",
    "server/medical.lua",
    "server/billing.lua",
    "server/shops.lua",
    "server/blips.lua"
}