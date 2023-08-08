fx_version 'adamant'

lua54 'yes'
game 'gta5'

description 'Skin Changer'

version '1.0.3'

shared_scripts {
	'config.lua',
	'@ox_lib/init.lua'
}

client_scripts {
	'locale.lua',
	'locales/*.lua',
	'client/main.lua'
}

server_script "server/main.lua"
