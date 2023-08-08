fx_version 'adamant'
lua54 "yes"
game 'gta5'

------
-- InteractSound by Scott
-- Verstion: v0.0.1
------

-- Manifest Version

-- Client Scripts
client_script 'client/main.lua'

-- Server Scripts
server_script 'server/main.lua'

-- NUI Default Page
ui_page('client/html/index.html')

-- Files needed for NUI
-- DON'T FORGET TO ADD THE SOUND FILES TO THIS!
files({
    'client/html/index.html',
    -- Begin Sound Files Here...
    -- client/html/sounds/ ... .ogg
    'client/html/sounds/busted.ogg',
    'client/html/sounds/ziptie.ogg',
    'client/html/sounds/vitrina.ogg',
    'client/html/sounds/demo.ogg',

    "client/html/sounds/coin_machine.ogg",
    "client/html/sounds/hang_up.ogg",
})
