fx_version "cerulean"
game "gta5"

lua54 "yes"

author "Strin"
description "Society system for ESX, made with love."

shared_script {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/main.lua",
    "server/paycheck.lua",
}

dependency "es_extended"