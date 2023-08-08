fx_version 'cerulean'
game 'gta5'

lua54 "yes"

ui_page 'client/nui/index.html'

shared_script {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua"
}

client_scripts {
    'client/*.lua'
}

files {
    'client/nui/*.html',
    'client/nui/*.js',
    'client/nui/*.css',
    'client/nui/fontawesome/*.css',
    'client/nui/webfonts/*.eot',
    'client/nui/webfonts/*.ttf',
    'client/nui/webfonts/*.woff',
    'client/nui/webfonts/*.woff2',
    'client/nui/webfonts/*.svg',
}