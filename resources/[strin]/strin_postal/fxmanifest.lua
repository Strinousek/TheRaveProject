fx_version "cerulean"
game "gta5"

lua54 "yes"

shared_scripts {
	"@es_extended/imports.lua",
	"@ox_lib/init.lua",
}

client_scripts {
	"config.lua",
	--"@blips/blips.lua",
	"client/main.lua"
}

server_scripts {
	"config.lua",
	"server/main.lua"
}

server_export "GetNearestPostal"
