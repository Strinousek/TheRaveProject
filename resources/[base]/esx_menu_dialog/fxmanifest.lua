fx_version 'adamant'
game 'gta5'


description 'ESX Menu Dialog'

version '1.0.0'

shared_script "@es_extended/imports.lua"

client_scripts {
	'client/main.lua'
}

ui_page {
	'html/ui.html'
}

files {
	'html/ui.html',
	'html/css/app.css',
	'html/js/mustache.min.js',
	'html/js/app.js',
	'html/fonts/pdown.ttf',
	'html/fonts/bankgothic.ttf',
	'html/fonts/ignis.ttf',	
	'html/img/cursor.png',
	'html/img/keys/enter.png',
	'html/img/keys/return.png',
}