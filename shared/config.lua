-- ================================
-- HDRP-COMPANION MAIN CONFIGURATION
-- Modular configuration system
-- ================================

lib.locale()

-- Initialize config table
Config = {}

-- Load configuration modules in order
require 'shared.config.general'     -- Core settings
require 'shared.config.shop'        -- Shop items and prices
require 'shared.config.experience'  -- XP and progression
require 'shared.config.attributes'  -- Pet attributes and AI
require 'shared.config.items'       -- Items and feeding
require 'shared.config.performance' -- Performance monitoring and optimization

-- Add any remaining legacy configurations below this line for compatibility
-- (To be gradually migrated to appropriate modules)