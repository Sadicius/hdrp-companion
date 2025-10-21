fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

description 'hdrp-companion'
version '4.7.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/config/general.lua',
    'shared/config/shop.lua',
    'shared/config/experience.lua',
    'shared/config/attributes.lua',
    'shared/config/items.lua',
    'shared/config/performance.lua',
    'shared/config/extensions.lua',
    'shared/companion_names.lua'
}

client_scripts {
-- Core system (load order critical)
'client/core/companion_state.lua', -- Centralized state (must load first)
'client/core/companion_performance.lua', -- Performance monitoring system
'client/core/companion_context.lua', -- AI context analysis system (v4.7.0)
'client/core/companion_memory.lua', -- Enhanced memory system (v4.7.0)
'client/core/companion_ai.lua', -- Optimized advanced AI system
'client/core/companion_prompts.lua', -- Optimized prompt system
'client/core/companion_optimized.lua', -- Optimized main client

-- Specific systems
'client/npcs.lua', -- Stable NPCs
'client/companion.lua', -- Shop companion spawns
'client/action.lua', -- Environmental actions (drinking/eating)
'client/dataview.lua', -- Data view
'client/therapy_target.lua', -- Therapy system

-- Specialized modules
'client/modules/companion_activator.lua', -- Companion activation
'client/modules/companion_manager.lua', -- Companion management
'client/modules/companion_coordination.lua', -- Multi-companion coordination (v4.7.0)
'client/modules/customization_system.lua' -- Customization system
}

files {
    'shared/companion_props.lua',
    'shared/companion_comp.lua',
    'shared/animations_settings.lua',
    'shared/stable_settings.lua',
    'locales/*.json'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
    'server/customization_server.lua',
    'server/versionchecker.lua'
}

dependencies {
    'rsg-core',
    'ox_lib',
    'ox_target'
}

lua54 'yes'

export 'CheckCompanionLevel'
export 'CheckCompanionBondingLevel'
export 'CheckActiveCompanion'
export 'CheckCompanionCustomize'
export 'AttackTarget'
export 'TrackTarget'
export 'HuntAnimals'
