fx_version 'cerulean'
game 'gta5'
lua54 "yes"

ui_page 'client/nui/index.html'

shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua"
}

client_scripts {
    'client/camera.lua',
    'client/main.lua',
    'client/commands.lua'
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    'server/*.lua'
}

files {
    'client/nui/*.html',
    'client/nui/css/*.css',
    'client/nui/*.js',
    'client/nui/webfonts/*.ttf',
    'client/nui/webfonts/*.eot',
    'client/nui/webfonts/*.svg',
    'client/nui/webfonts/*.woff',
    'client/nui/webfonts/*.woff2',
}

dependencies {
    "skinchanger",
    "ox_lib",
    "es_extended"
}