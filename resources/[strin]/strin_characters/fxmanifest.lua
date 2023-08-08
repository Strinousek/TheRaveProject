fx_version 'cerulean'

game 'gta5'
lua54 "yes"

shared_scripts {
	'@es_extended/imports.lua',
	"@ox_lib/init.lua"
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua',
	'server/characters.lua',
}

client_scripts {
	'client/main.lua',
	'client/register.lua'
}

ui_page 'nui/index.html'

files {
	'nui/index.html',
	'nui/*.css',
	'nui/images/*.png',
	'nui/*.js',
}

dependency {
	"es_extended",
	"ox_lib",
	"ox_inventory",
	"skinchanger",
	"strin_skin"
}
