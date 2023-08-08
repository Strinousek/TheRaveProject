fx_version "cerulean"
lua54 "yes"
game "gta5"

shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua",
    "config.lua",
}

client_scripts {
    "client/main.lua",
    "client/cash_registers.lua",
    "client/jewelery.lua",
    "client/banks.lua",
}

server_scripts {
    "server/main.lua",
    "server/cash_registers.lua",
    "server/jewelery.lua",
    "server/banks.lua",
}