fx_version 'adamant'
lua54 "yes"
game 'gta5'

ui_page "ui/index.html"

files {
    "ui/index.html",
    "ui/vue.min.js",
    "ui/script.js",
    "ui/main.css",
    "ui/styles/police.css",
    "ui/badges/police.png",
    "ui/footer.png",
    "ui/mugshot.png"
}

shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua",
}

server_scripts {
    '@async/async.lua',
    '@oxmysql/lib/MySQL.lua',
    "sv_mdt.lua",
    "sv_vehcolors.lua"
}

client_script "cl_mdt.lua"
