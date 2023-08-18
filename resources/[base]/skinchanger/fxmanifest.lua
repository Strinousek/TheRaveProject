fx_version 'adamant'

lua54 'yes'
game 'gta5'

description 'Skin Changer'

version '1.0.3'

shared_scripts {
	'config.lua',
	'locale.lua',
	'locales/*.lua',
	'components.lua',
	'@ox_lib/init.lua'
}

client_scripts {
	'client/main.lua'
}

server_script "server/main.lua"
