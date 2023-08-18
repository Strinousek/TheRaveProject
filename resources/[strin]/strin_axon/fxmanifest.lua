fx_version 'cerulean'
lua54 "yes"
game 'gta5'

files {
  'html/vhs.ttf',
  'html/main.js',
  'html/main.css',
  'html/index.html',
  'html/axon.png',
}

ui_page 'html/index.html'

shared_scripts {
  "@es_extended/imports.lua",
  "@ox_lib/init.lua"
}

client_scripts {
  'client/*.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/*.lua',
}