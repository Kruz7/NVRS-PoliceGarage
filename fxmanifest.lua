fx_version 'adamant'
game 'gta5'
lua54 'yes'
author "Neverours"
description "Police garage system by nvrs"
client_scripts {
    'client/client.lua',
    'config.lua',
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
    'config.lua',
}
server_scripts { '@mysql-async/lib/MySQL.lua' }
