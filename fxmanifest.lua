fx_version 'adamant'
game 'gta5'
description 'Banking system which allows players to add, remove or transfer money from personal and common accounts.'
author 'Sinyx'
version '1.0.1'

ui_page "html/index.html"

files {
    "html/icons/*.svg",
    "html/index.html",
    "html/js/jquery.js",
    "html/js/bank.js",
    "html/css/app.css",
}


server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "src/config.lua",
    "src/server/utils.lua",
    "src/server/cache.lua",
    "src/server/globals.lua",
    "src/server/core.lua"
}

client_scripts {
    "src/config.lua",
    "src/client/core.lua",
    "src/client/nui.lua"
}

server_exports {
    "AddMoney",
    "RemoveMoney",
    "GetBankMoney",
    "RemoveFromCache"
}