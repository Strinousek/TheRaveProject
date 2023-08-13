fx_version "cerulean"
lua54 "yes"
game "gta5"

ui_page "client/nui/index.html"

shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua",
    "config.lua"
}

client_scripts {
    "client/*.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/*.lua",
}

files {
    "client/nui/*.html",
    "client/nui/*.js",
    "client/nui/*.css",
    "client/nui/images/*.png",
}