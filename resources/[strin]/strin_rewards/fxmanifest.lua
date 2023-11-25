fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page "web/index.html"

files {
    "web/assets/*.png",
    "web/*.css",
    "web/*.js",
    "web/*.html",
}

shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/*.lua"
}

client_scripts {
    "client/*.lua"
}