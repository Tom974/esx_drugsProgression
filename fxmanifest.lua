resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

fx_version 'adamant'
game 'gta5'

description 'Drugs progressie plugin'
version '0.1'

client_scripts {
	'@es_extended/locale.lua',
    'locales/nl.lua',
	'config/config.lua',
	'client/client.lua',
}

server_scripts {
	'@es_extended/locale.lua',
    'locales/nl.lua',
    '@oxmysql/lib/MySQL.lua',
	'config/config.lua',
	'server/server.lua',
}

dependency 'es_extended'