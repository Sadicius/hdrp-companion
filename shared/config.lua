-- ================================
-- HDRP-COMPANION MAIN CONFIGURATION
-- Modular configuration system
-- ================================

lib.locale()

-- Initialize config table (CRITICAL: Must be first, no fallbacks in RSG Framework)
Config = {}

-- Load configuration modules in order
require 'shared.config.general'     -- Core settings
require 'shared.config.shop'        -- Shop items and prices
require 'shared.config.experience'  -- XP and progression
require 'shared.config.attributes'  -- Pet attributes and AI
require 'shared.config.items'       -- Items and feeding
require 'shared.config.performance' -- Performance monitoring and optimization

-- Load stable settings using safe pattern (avoid require() in RSG)
-- Instead, stable_settings.lua will be included in shared_scripts in fxmanifest.lua
-- This ensures proper loading order without require() dependencies

-- Add any remaining legacy configurations below this line for compatibility
-- (To be gradually migrated to appropriate modules)