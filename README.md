# rsg-companions
This script is part of the pet/companion system in RedM, allowing players to summon, control, train, and customize pets with artificial intelligence and multiple interactive features.
Summoning Companions
Use a command or a whistle to summon the companion. Requires being out of jail and not being dead. The companion can only be summoned near roads if Config.SpawnOnRoadOnly is enabled. Companions gain XP by performing actions.
XP determines:
- Companion level (1 to 10)
- Health, stamina, agility, speed, acceleration
- Inventory capacity (weight and slots)
- XP also determines the level of bonding.
Orders the companion to flee and then deletes itself. Allows you to follow NPCs or animals. Allows you to attack a valid target. The companion hunts animals and delivers meat.
Saves companion status: Dirt, Physical attributes, Unique inventory per pet
Sell, trade, or store pets. Companion can rest in rural environments if they are far from the player.
Configures buttons for actions. Levels required to unlock skills. Defines the companion's levels, attributes, scaling, and behavior.


Customization through components (accessories) and visual attributes (WIP custom).

# Controls Set and Info
-------------------
- [A] move left
- [D] move right
-------------------
- [U] call companion
- [F] flee companion
- [ENTER] saddlebag companion
- [R] Hunt Mode companion
- [J] Actions Menu companion
-------------------
- [V] Attack target companion
- [C] Track target companion
-------------------
- [C] drink companion
- [C] graze companion
-------------------

# Commands Set
- /pet_find      to check stable your pet
- /pet_menu       to check menu your pet
- /pet_stats  to check status menu your pet
- /pet_games  to check game menu your pet

- /pet_name   to rename your active companion
- /pet_call     to spawn your pet
- /pet_flee      to make your pet flee
- /pet_sleep      to make your pet flee in stable and unactive
- /pet_revive    to revive pet

- /pet_hunt      to toggle hunt mode pet
- /pet_bone      to play your pet bone 
- /pet_buried    to play your pet hide bone
- /pet_findburied     to play your pet search hide bone or random locations
- /pet_treasure  to play your pet follow treasure clue
- /pet_clean + {bone, buried, treasure, all} to play your pet follow treasure clue

- /loadpet     to load customice attach props pet (WIP)

# info configurable resource
- Folder shared have all config

- Details:
- config: for all basic config pets
- stable_settings: for add or change coords, prices, models for spawn
- companion_animations: for add or change animations for menu animation pet

- companion_comp: WIP dont use
- companion_prop: WIP dont use

# Exports
- If you're in another script and want to use any of these exported functions, you can do the following:
exports['rsg-companion']:CheckCompanionLevel - current level of the active partner
exports['rsg-companion']:CheckCompanionBondingLevel - link level
exports['rsg-companion']:CheckActiveCompanion - current partner's ped (entity)
exports['rsg-companion']:AttackTarget({ entity }) - Calls partner to attack a given target
exports['rsg-companion']:TrackTarget({ entity }) - Calls partner to track a given target
exports['rsg-companion']:HuntAnimals({ entity }) - Calls partner to hunt animal a given target

- Exportable mission treasure random location with clues and follow entity
exports['rsg-companion']:TreasureHunt({ entity }) - Calls partner to entity a given games treasure clues (WIP)


```lua
-- config
Config.Companions = true

-- example target in entity
if Config.EnableTarget and Config.Companions then
    exports.ox_target:addLocalEntity(entity, {
        {
            name = 'npc_hunt_animal',
            icon = 'far fa-eye',
            label = locale('cl_promp_menu'),
            onSelect = function()
                -- local companionLevel = exports['rsg-companion']:CheckCompanionLevel()
                -- local bondingLevel = exports['rsg-companion']:CheckCompanionBondingLevel()
                local companionPed = exports['rsg-companion']:CheckActiveCompanion()
                if companionPed ~= 0 then
                  -- exports['rsg-companion']:AttackTarget({ entity })
                  -- exports['rsg-companion']:TrackTarget({ entity })
                  exports['rsg-companion']:HuntAnimals({ entity })
                end
            end,
            distance = 15.0
        }
    })
end
```

# Credit
- Humanity Is Insanity#3505 & Zee#2115 from The Crossroads RP for code inspiration and system
- RedEM-RP for the menu : https://github.com/RedEM-RP/redemrp_menu_base
- Goghor#9453 for coding assistance / companion bonding work
- RexShack / RexShack#3041 (for the original RSG Horses)
- Szileni / Szileni#7038 (for the original tbrp_companions)
- for the original rdn_companions
- for the original bwrp_animalshelter
- for the original mm_snowball

## EXTRAS
# Sound Add
- Add the `CALLING_WHISTLE_01.oog` into `installation` folder in `\resources\[standalone]\interact-sound\client\html\sounds`

# Items V2
```lua
    companion_feed 		= {name = 'companion_feed', 		label = 'Comida de Mascota', weight = 500, type = 'item', image = 'resource_dog_feed.png',  unique = false, useable = true, shouldClose = true, description = 'Recurso para mascotas'},
    companion_drink 	= {name = 'companion_drink', 		label = 'Bebida de Mascota', weight = 500, type = 'item', image = 'resource_dog_drink.png', unique = false, useable = true, shouldClose = true, description = 'Recurso para mascotas'},
    companion_sugar 	= {name = 'companion_sugar', 		label = 'Dulce de Mascota', weight = 500, type = 'item', image = 'resource_dog_sugar.png', unique = false, useable = true, shouldClose = true, description = 'Recurso para mascotas'},
    companion_bone 	= {name = 'companion_bone', 		label = 'Hueso de Mascota', weight = 500, type = 'item', image = 'resource_dog_bone.png', unique = false, useable = true, shouldClose = true, description = 'Recurso para mascotas'},
    companion_stimulant	= {name = 'companion_stimulant', 	label = 'Estimulante de Mascota', weight = 500, type = 'item', image = 'resource_dog_stimulant.png', unique = false, useable = true, shouldClose = true, description = 'Recurso para mascotas'},
    companion_reviver 	= {name = 'companion_reviver', 		label = 'Revivir Mascota', weight = 500, type = 'item', image = 'resource_dog_revive.png', unique = false, useable = true, shouldClose = true, description = 'Recurso para mascotas'},
```

# log essentials
```lua
['petinfo'] = ''
```
