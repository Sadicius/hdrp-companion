-- ================================
-- COMPANION ACTIVATOR MODULE
-- Enables all the commented customization system
-- ================================

-- Activate companion props by uncommenting them
local function ActivateComponentsProps()
    local filePath = 'client/components/companion_props.lua'

    -- Read the file content
    local file = io.open(GetResourcePath(GetCurrentResourceName()) .. '/' .. filePath, 'r')
    if not file then
        print('[ACTIVATOR] Could not open companion_props.lua')
        return false
    end

    local content = file:read('*all')
    file:close()

    -- Uncomment all the props
    content = content:gsub('%-%-%s*(%s*{[^}]-hashid[^}]-},%s*)', '%1')

    -- Write back to file
    local writeFile = io.open(GetResourcePath(GetCurrentResourceName()) .. '/' .. filePath, 'w')
    if not writeFile then
        print('[ACTIVATOR] Could not write to companion_props.lua')
        return false
    end

    writeFile:write(content)
    writeFile:close()

    print('[ACTIVATOR] Companion props activated successfully')
    return true
end

-- Enable customization config
local function EnableCustomizationConfig()
    -- Enable customization features in config
    Config.CustomCompanion = true
    Config.Camera = {
        Dog = true,
        DistY = 2.0,
        DistZ = 0.5
    }

    Config.ComponentHash = {
        Toys = "toys",
        Horns = "horns",
        Neck = "neck",
        Medal = "medal",
        Masks = "masks",
        Cigar = "cigar"
    }

    Config.PriceComponent = {
        Toys = 5,
        Horns = 10,
        Neck = 8,
        Medal = 15,
        Masks = 12,
        Cigar = 6
    }

    print('[ACTIVATOR] Customization config enabled')
end

-- Initialize activation
CreateThread(function()
    if Config.Debug then
        print('[ACTIVATOR] Starting companion customization activation')
    end

    EnableCustomizationConfig()

    if Config.Debug then
        print('[ACTIVATOR] Companion customization system is now active')
    end
end)