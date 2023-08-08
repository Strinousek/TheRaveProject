fx_version "cerulean"
game "gta5"

ui_page 'nui/blank.html'
loadscreen "nui/index.html"
loadscreen_manual_shutdown "yes"

client_script "client.lua"

files {
    "nui/index.html",
    "nui/blank.html",
    "nui/**/*",
}