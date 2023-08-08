fx_version 'adamant'
lua54 "yes"
game 'gta5'

shared_scripts {
  "@es_extended/imports.lua",
  "@ox_lib/init.lua"
}

client_script 'client.lua'

server_script {
  '@oxmysql/lib/MySQL.lua',
  'server.lua'
}

-- {
-- 	"display": "Police",
-- 	"subMenu": [
-- 		{
-- 		  "title": "Envoyer un message",
-- 		  "eventName": "esx_addons_gcphone:call",
-- 		  "type": {
-- 		  "number": "police"
-- 		}}
-- 	]
-- }
