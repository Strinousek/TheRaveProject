fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page "client/nui/index.html"

files {
    "client/nui/*.html",
    "client/nui/*.js",
    "client/nui/*.css",
    "client/nui/*.json",
    "client/nui/images/*.jpg",
    "client/nui/images/*.png",
    'client/nui/fontawesome/*.css',
    'client/nui/webfonts/*.eot',
    'client/nui/webfonts/*.ttf',
    'client/nui/webfonts/*.woff',
    'client/nui/webfonts/*.woff2',
    'client/nui/webfonts/*.svg',
}

shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua",
    "config.lua",
}

client_scripts {
    "client/main.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/main.lua",
    "server/convert.lua",
}