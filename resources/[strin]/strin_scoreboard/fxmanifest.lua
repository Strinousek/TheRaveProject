fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page 'client/nui/index.html'

shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua",
}

client_scripts {
    "client/*.lua"
}

server_scripts {
    "server/*.lua"
}

files {
    "client/nui/*.html",
    "client/nui/*.png",
    "client/nui/*.css",
    "client/nui/*.js",
    "client/nui/fontawesome/*.css",
    "client/nui/webfonts/*.eot",
    "client/nui/webfonts/*.ttf",
    "client/nui/webfonts/*.woff",
    "client/nui/webfonts/*.woff2",
    "client/nui/webfonts/*.svg",
}