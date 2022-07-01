fx_version 'cerulean'

game 'gta5'

dependencies {
    'progressBars',
    'mythic_notify'
}

client_script 'client.lua'

server_script 'server.lua'

ui_page('html/index.html')

files {
    'html/index.html',
    'html/script.js',
    'html/style.css',
    'html/img/logo.png',
    'html/img/logo-red.png',
    'html/img/logo-blue.png',
}