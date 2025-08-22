-- ================================
-- COMPANION NAMES & TEXTS
-- Nombres y textos predefinidos para companions
-- ================================

CompanionTexts = {
    -- Nombres predefinidos por tipo
    names = {
        dog = {
            'Rex', 'Max', 'Buddy', 'Charlie', 'Jack', 'Rocky', 'Duke', 'Bear',
            'Scout', 'Hunter', 'Shadow', 'Storm', 'Thunder', 'Lightning', 'Ranger',
            'Wolf', 'Bandit', 'Outlaw', 'Maverick', 'Rebel', 'Spirit', 'Phoenix'
        },
        cat = {
            'Whiskers', 'Shadow', 'Luna', 'Smokey', 'Tiger', 'Felix', 'Milo',
            'Oscar', 'Simba', 'Leo', 'Chester', 'Oliver', 'Jasper', 'Midnight'
        },
        horse = {
            'Thunder', 'Lightning', 'Storm', 'Spirit', 'Maverick', 'Rebel',
            'Champion', 'Noble', 'Majesty', 'Glory', 'Victory', 'Triumph'
        }
    },
    
    -- Descripciones por temperamento
    descriptions = {
        loyal = "Un compañero leal que nunca te abandonará",
        brave = "Valiente y dispuesto a enfrentar cualquier peligro",
        playful = "Juguetón y lleno de energía",
        calm = "Tranquilo y sereno, perfecto para largas travesías",
        protective = "Protector nato, siempre vigilante",
        intelligent = "Inteligente y fácil de entrenar"
    },
    
    -- Comandos de voz
    voice_commands = {
        come = {"ven", "come", "aquí", "here"},
        stay = {"quieto", "stay", "espera", "wait"},
        follow = {"sígueme", "follow", "vamos", "let's go"},
        sit = {"siéntate", "sit", "down"},
        good = {"bien", "good", "bravo", "excelente"}
    },
    
    -- Textos de interacción
    interaction_texts = {
        feed = "Alimentar a %s",
        pet = "Acariciar a %s", 
        play = "Jugar con %s",
        train = "Entrenar a %s",
        heal = "Curar a %s",
        customize = "Personalizar a %s"
    },
    
    -- Estados de ánimo
    moods = {
        happy = {
            text = "Feliz",
            description = "Tu compañero está contento y lleno de energía"
        },
        sad = {
            text = "Triste", 
            description = "Tu compañero necesita atención y cuidados"
        },
        hungry = {
            text = "Hambriento",
            description = "Tu compañero necesita comida"
        },
        tired = {
            text = "Cansado",
            description = "Tu compañero necesita descansar"
        },
        excited = {
            text = "Emocionado",
            description = "Tu compañero está listo para la aventura"
        }
    }
}

-- ================================
-- FUNCIONES DE UTILIDAD
-- ================================

function GetRandomCompanionName(animalType)
    local names = CompanionTexts.names[animalType or 'dog']
    if names and #names > 0 then
        return names[math.random(#names)]
    end
    return "Compañero"
end

function GetCompanionDescription(temperament)
    return CompanionTexts.descriptions[temperament] or "Un compañero fiel"
end

function GetInteractionText(action, companionName)
    local template = CompanionTexts.interaction_texts[action]
    if template then
        return string.format(template, companionName)
    end
    return action
end

function GetMoodInfo(mood)
    return CompanionTexts.moods[mood] or CompanionTexts.moods.happy
end

-- Exportar para uso global
exports('GetRandomCompanionName', GetRandomCompanionName)
exports('GetCompanionDescription', GetCompanionDescription)
exports('GetInteractionText', GetInteractionText)
exports('GetMoodInfo', GetMoodInfo)