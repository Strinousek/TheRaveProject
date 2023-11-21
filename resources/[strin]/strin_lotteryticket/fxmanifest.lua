fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page "web/index.html"

shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua",
    "config.lua",
}

server_scripts {
    "server/*.lua",
}

client_scripts {
    "client/*.lua",
}

files {
    "web/*.html",
    "web/*.js",
    "web/*.css",
}