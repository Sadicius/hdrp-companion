fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

description 'hdrp-companion'
version '4.6.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

client_scripts {
    'client/client.lua',
    'client/npcs.lua',
    'client/companion.lua',
    'client/action.lua',
    'client/dataview.lua',
    'client/therapy_target.lua',
    'client/components/customize.lua'
}

files {
    'client/components/companion_props.lua',
    'client/components/companion_comp.lua',
    'shared/animations_settings.lua',
    'shared/stable_settings.lua',
    'locales/*.json'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
    'server/versionchecker.lua'
}

dependencies {
    'rsg-core',
    'ox_lib'
}

lua54 'yes'

export 'CheckCompanionLevel'
export 'CheckCompanionBondingLevel'
export 'CheckActiveCompanion'
export 'CheckCompanionCustomize'
export 'AttackTarget'
export 'TrackTarget'
export 'HuntAnimals'
