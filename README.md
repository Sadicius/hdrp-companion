# 🐕 HDRP-Companion Pet System for RedM

**Version:** 4.7.2
**Framework:** RSGCore for RedM
**Status:** Production Ready ✅

Advanced companion system for RedM servers featuring sophisticated AI-enhanced behavior, extensive customization options, and engaging interactive gameplay mechanics. Built with enterprise-level architecture and performance optimization.

## ✨ Features

### 🤖 **Advanced AI System**
- **Context-Aware Behavior**: Intelligent decision-making based on 6 environmental categories
- **Enhanced Memory System**: Persistent learning with categorized experience storage
- **8 Personality Types**: Aggressive, Guardian, Shy, Avoidant, Friendly, Loyal, Playful, Calm
- **Sub-50ms Response Times**: Hardware-monitored performance with real-time optimization
- **Dynamic Context Analysis**: Environmental monitoring (combat, exploration, social contexts)

### 🤝 **Multi-Companion Coordination** (v4.7.2)
- **Leadership Election**: Bonding-based automatic leader selection
- **5 Formation Patterns**: V-formation, line, circle, scatter, defensive
- **Pack Hunting**: Coordinated hunting with automatic role assignment
- **Sub-100ms Sync**: Real-time coordination between multiple companions

### 🎨 **Full Customization System**
- **63+ Props & Accessories**: Toys, collars, accessories, utility items
- **Visual Personalization**: Make your companion unique and recognizable
- **Functional Items**: Equipment that provides gameplay benefits
- **Persistent Customization**: All changes saved to database

### 🎮 **Interactive Activities**
- **Treasure Hunting**: Companion-led discovery of buried items
- **Fetch Games**: Classic retrieval mechanics with progressive difficulty
- **Training Exercises**: Physical, mental, and specialty skill development
- **Environmental Exploration**: Guided discovery of interesting locations
- **Performance & Tricks**: Social animations and entertainment

### 🎯 **Combat & Hunting Capabilities**
- **Attack System**: Defend against threats with companion assistance
- **Tracking**: Advanced scent-based trail following
- **Hunting Support**: Coordinated hunting for small, medium, and large game
- **Safety Protocols**: Automatic threat assessment and protective positioning

### ⚡ **Performance Optimized**
- **Real-time Monitoring**: Built-in performance tracking and metrics
- **Intelligent Resource Management**: Efficient threading (100ms-1000ms intervals)
- **Database Optimization**: Connection pooling and prepared statements
- **Automatic Cleanup**: Memory management and garbage collection
- **3 Performance Modes**: Performance, Balanced, Quality

### 🛠️ **RSGCore Integration**
- **Native Framework Compatibility**: Seamless RSGCore integration
- **Player Data Sync**: Citizenid-based companion ownership
- **Event System**: Native event handling and communication
- **Inventory Integration**: Companion item management

### 📊 **Progressive System**
- **10-Level Progression**: XP-based leveling with bonding mechanics
- **Skill Development**: Abilities improve through use and training
- **Attribute Growth**: Stats increase with level and bonding
- **Achievement Tracking**: Monitor milestones and accomplishments

## 🚀 Installation

### Prerequisites
- **RedM Server**: Compatible RedM server installation
- **RSGCore Framework**: Latest version recommended
- **Database**: MySQL/MariaDB with proper configuration
- **Required Dependencies**:
  - `rsg-core` - RSGCore framework
  - `ox_lib` - Overextended library for UI and utilities
  - `ox_target` - Targeting system for interactions
  - `oxmysql` - Optimized MySQL connector

### Installation Steps

1. **Download the Resource**
   ```bash
   cd resources/
   git clone https://github.com/your-repo/hdrp-companion.git
   # Or download and extract the latest release
   ```

2. **Configure Dependencies**

   Ensure your `server.cfg` includes dependencies in the correct order:
   ```bash
   # Core framework
   ensure rsg-core

   # Required libraries
   ensure ox_lib
   ensure ox_target
   ensure oxmysql

   # HDRP Companion (load after dependencies)
   ensure hdrp-companion
   ```

3. **Database Configuration**

   The resource will automatically create required tables on first start:
   - `player_companions` - Main companion data storage
   - `companion_memory` - AI learning and memory system
   - `companion_coordination` - Multi-companion coordination data

   Verify oxmysql configuration in your server config.

4. **First-Time Setup**
   ```bash
   # Start your server
   # Check console for successful initialization:
   [COMPANION] Database tables created successfully
   [COMPANION] Performance monitor initialized
   [COMPANION] Companion system loaded
   ```

5. **Configuration (Optional)**

   Customize settings in modular config files:
   - `shared/config/general.lua` - Core settings and controls
   - `shared/config/performance.lua` - Performance optimization
   - `shared/config/experience.lua` - Leveling and progression
   - `shared/config/shop.lua` - Prices and shop items
   - `shared/config/items.lua` - Food, items, and care
   - `shared/config/attributes.lua` - AI and personality settings

6. **Verify Installation**
   ```bash
   # In-game, use the command:
   /pet_menu
   # Should open the companion interface
   ```

### 🌍 Language Support

The system supports multiple languages with automatic locale loading:
- **English** (`en.json`) - Default
- **Spanish/Español** (`es.json`)

Language is automatically selected based on player settings. Additional locales can be added in the `locales/` folder.

## 🎮 How to Use

### Getting Started

1. **Visit a Pet Stable**
   - Pet stables are located in major towns (Valentine, Blackwater, Tumbleweed)
   - Look for stable NPCs with interaction prompts
   - Or use `/pet_menu` to access the interface from anywhere

2. **Purchase Your First Companion**
   - Browse available companion types (dogs, cats, etc.)
   - Select your preferred breed and personality
   - Choose a unique name for your companion
   - Complete the purchase (prices vary by type)

3. **Spawn and Interact**
   - Your companion will automatically spawn after purchase
   - Follow on-screen prompts for initial bonding
   - Begin building your relationship through care and activities

### 🎮 Controls and Commands

#### **Keyboard Controls** (Proximity-Based Prompts)
When near your active companion, context-sensitive prompts appear:

| Key | Action | Description |
|-----|--------|-------------|
| **G** | Call Companion | Summon companion to your location |
| **H** | Flee Companion | Companion flees/moves away |
| **E** | Actions Menu | Open companion interaction menu |
| **F** | Saddlebag | Access companion's inventory |
| **B** | Brush | Groom your companion |
| **R** | Attack Target | Command attack on aimed target |
| **T** | Track Target | Begin tracking scent trail |
| **U** | Hunt Animals | Activate hunting mode |
| **ENTER** | Drink Water | Allow companion to drink (near water) |
| **SPACE** | Eat Food | Feed companion (with food in inventory) |

*Note: Prompts appear automatically based on context (e.g., attack only shows when aiming at threats)*

#### **Chat Commands**
Commands available from anywhere:

| Command | Function |
|---------|----------|
| `/pet_menu` | Open main companion interface |
| `/pet_stats` | View detailed statistics and status |
| `/pet_games` | Access mini-games and activities |
| `/pet_customize` | Open customization interface |
| `/pet_find` | Locate stored/missing companions |

#### **Admin Commands** (Requires Permissions)
Server administrators have additional commands:

| Command | Function |
|---------|----------|
| `/pet_admin stats` | View server companion statistics |
| `/pet_admin performance` | Check system performance metrics |
| `/pet_admin cleanup` | Force cleanup of inactive companions |

### 🐕 Available Companion Types

#### **Dogs** - Loyal & Versatile
- **Models**: Husky, German Shepherd, Labrador, Retriever
- **Best For**: Hunting, protection, companionship
- **Special Abilities**: Attack, track, hunt, guard, fetch
- **Personalities**: All 8 types available

#### **Cats** - Independent & Stealthy
- **Models**: Various domestic breeds
- **Best For**: Small game hunting, stealth operations
- **Special Abilities**: Silent movement, climbing, rodent detection
- **Personalities**: Shy, Avoidant, Friendly, Calm

#### **Wolves** - Powerful & Wild (Server Configurable)
- **Models**: Wolf variants
- **Best For**: Pack hunting, intimidation, large game
- **Special Abilities**: Pack coordination, territory control
- **Note**: May require admin permission depending on server configuration

## 📋 Companion Care Guide

### 🍖 Feeding & Care
- **Regular Feeding**: Keep your companion's hunger satisfied with appropriate food items
- **Hydration**: Ensure access to clean water, especially after activities
- **Rest**: Allow downtime between intensive activities or training sessions
- **Bonding**: Spend time with your companion to increase bond level

### 🎯 Training Tips
- **Start Small**: Begin with basic commands before advancing to complex behaviors
- **Consistency**: Regular interaction improves AI learning and responsiveness
- **Positive Reinforcement**: Reward good behavior to encourage desired actions
- **Patience**: AI learning takes time - allow your companion to adapt

### 🎮 Activities & Mini-Games
1. **Treasure Hunt**: Guide your companion to find hidden treasures
2. **Fetch Games**: Classic fetch mechanics with various objects
3. **Exploration**: Discover new areas together with enhanced awareness
4. **Training Exercises**: Improve companion skills and abilities
5. **Social Activities**: Interact with other players and their companions

## ⚙️ Configuration

The system uses a **modular configuration architecture** for easy customization and maintenance.

### 📁 Configuration Files

#### **Core Settings** (`shared/config/general.lua`)
```lua
Config.Debug = false                    -- Debug mode
Config.EnableTarget = true              -- ox_target integration
Config.SpawnOnRoadOnly = false         -- Road-only spawning
Config.CompanionDieAge = 45            -- Lifespan in days
Config.priceRevive = 20.0              -- Revive cost
```

#### **Performance Settings** (`shared/config/performance.lua`)
```lua
Config.EnhancedAI = {
    PerformanceMode = 'balanced',      -- 'performance', 'balanced', 'quality'
    MaxMemoryEntries = 20,             -- AI memory limit
    DecisionTimeout = 50,              -- Max AI decision time (ms)
    ContextUpdateRate = 2000,          -- Context analysis frequency (ms)
}
```

**Performance Modes:**
- **Performance** - Optimized for 50+ player servers (reduced AI complexity)
- **Balanced** - Recommended for most servers (20-50 players)
- **Quality** - Full AI features for RP-focused servers (< 32 players)

#### **Economy Settings** (`shared/config/shop.lua`)
```lua
Config.Economy = {
    BasePrices = {
        dog = 150,                     -- Dog purchase price
        cat = 100,                     -- Cat purchase price
        wolf = 500,                    -- Wolf purchase price (if enabled)
    }
}
```

#### **Experience & Progression** (`shared/config/experience.lua`)
- Leveling rates and XP requirements
- Bonding progression mechanics
- Skill unlock levels
- Attribute growth rates

#### **Items & Care** (`shared/config/items.lua`)
- Food types and nutrition values
- Care item definitions
- Feeding mechanics
- Item effects on companion stats

#### **AI & Attributes** (`shared/config/attributes.lua`)
- Personality type definitions
- Behavioral parameters
- AI decision weights
- Companion abilities configuration

### 🔧 Quick Configuration Examples

**For High-Population Servers (50+ players):**
```lua
-- shared/config/performance.lua
Config.EnhancedAI.PerformanceMode = 'performance'
Config.Performance.MaxActiveCompanions = 15
Config.Performance.AIUpdateInterval = 3000
```

**For RP-Focused Servers:**
```lua
-- shared/config/performance.lua
Config.EnhancedAI.PerformanceMode = 'quality'
Config.Performance.MaxActiveCompanions = 30
```

**Adjust Companion Prices:**
```lua
-- shared/config/shop.lua
Config.Economy.BasePrices = {
    dog = 200,    -- Increase prices
    cat = 150,
    wolf = 750,
}
```

### 📚 Full Configuration Guide
For comprehensive configuration instructions, see **[Admin Guide](docs/ADMIN_GUIDE.md)**

## 🔧 Troubleshooting

### Common Issues and Solutions

#### **Companion Not Spawning**
```bash
# Check console for errors
# Verify dependencies are running
ensure rsg-core
ensure ox_lib
ensure ox_target
ensure oxmysql

# Check resource load order in server.cfg
# Ensure hdrp-companion loads AFTER dependencies
```

**Solutions:**
- Verify all dependencies are properly installed
- Check console for specific error messages
- Ensure database connection is active
- Try restarting the resource: `restart hdrp-companion`

#### **Database Errors**
```sql
-- Verify tables exist
SHOW TABLES LIKE 'player_companions';
SHOW TABLES LIKE 'companion_memory';
SHOW TABLES LIKE 'companion_coordination';

-- Check oxmysql configuration
-- Ensure connection string is correct in server.cfg
```

**Solutions:**
- Verify oxmysql is properly configured
- Check database credentials and permissions
- Allow automatic table creation on first start
- Manually create tables if auto-creation fails (see SQL schema in docs)

#### **Performance Issues / Low FPS**
```lua
-- Reduce AI complexity
Config.EnhancedAI.PerformanceMode = 'performance'

-- Limit active companions
Config.Performance.MaxActiveCompanions = 10

-- Increase update intervals
Config.Performance.AIUpdateInterval = 4000
```

**Solutions:**
- Adjust performance mode to 'performance'
- Reduce max active companions on server
- Increase AI update intervals
- Check for other resource conflicts

#### **Missing Commands / Prompts**
**Solutions:**
- Verify RSGCore is running: `status rsg-core`
- Check player permissions for admin commands
- Ensure companion is spawned and active
- Try respawning companion
- Check for conflicting keybind resources

#### **AI Behavior Issues**
**Solutions:**
- Check companion stats (hunger, thirst, happiness)
- Verify companion level and bonding
- Review AI performance mode settings
- Check for context-specific requirements (e.g., hunting requires weapon)

### 🛠️ Debug Tools

```lua
-- Enable debug mode for detailed logging
Config.Debug = true
```

**Admin Debug Commands:**
```bash
/pet_debug ai [companion_id]        # Debug AI behavior
/pet_debug performance               # Show performance metrics
/pet_debug database                  # Check database connectivity
/pet_debug memory [player_id]       # Show memory usage
```

### 📞 Support Resources

- **Documentation**: Check the `docs/` folder for detailed guides
- **Validation Script**: Run `scripts/validate_fixes.lua` for system diagnostics
- **Admin Guide**: See [docs/ADMIN_GUIDE.md](docs/ADMIN_GUIDE.md) for advanced troubleshooting
- **Architecture**: Review [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for system understanding

## 📊 System Requirements

### **Server Requirements**
- **Platform**: RedM compatible server (Windows/Linux)
- **Framework**: RSGCore (latest stable version)
- **Database**: MySQL 5.7+ or MariaDB 10.2+
- **Recommended RAM**: 8GB+ for optimal performance
- **Recommended CPU**: 4+ cores for larger servers

### **Performance Characteristics**
- **Memory Usage**: ~5-10MB per active companion
- **CPU Impact**: < 1% on modern servers
- **Database Load**: Minimal with optimized queries
- **Network Usage**: Efficient batched updates
- **Response Times**: Sub-50ms AI decisions

### **Tested Environments**
- ✅ Servers with 32+ concurrent players
- ✅ High-population servers (50+ with performance mode)
- ✅ Multiple companions per player (up to 5)
- ✅ 24/7 production servers with continuous uptime

### **Recommended Server Specifications**

| Server Size | RAM | CPU | Performance Mode |
|-------------|-----|-----|------------------|
| Small (< 20 players) | 4GB | 2 cores | Quality |
| Medium (20-50 players) | 8GB | 4 cores | Balanced |
| Large (50+ players) | 16GB | 6+ cores | Performance |

## 🏗️ Project Structure

```
hdrp-companion/
├── client/                           # Client-side systems
│   ├── core/                        # Core AI and performance systems
│   │   ├── companion_ai.lua        # Advanced AI decision engine (1,003 lines)
│   │   ├── companion_context.lua   # Context analysis system (542 lines)
│   │   ├── companion_memory.lua    # Memory management (679 lines)
│   │   ├── companion_performance.lua # Performance monitoring
│   │   ├── companion_prompts.lua   # Prompt system
│   │   ├── companion_state.lua     # Centralized state management
│   │   └── companion_optimized.lua # Optimized main client
│   ├── modules/                     # Specialized modules
│   │   ├── companion_activator.lua # Companion spawning/activation
│   │   ├── companion_manager.lua   # Management interface
│   │   ├── companion_coordination.lua # Multi-companion coordination
│   │   └── customization_system.lua # Customization interface
│   ├── action.lua                   # Environmental actions
│   ├── companion.lua                # Shop companion spawns
│   ├── dataview.lua                 # Data view system
│   ├── npcs.lua                     # Stable NPCs
│   └── therapy_target.lua           # Therapy/targeting system
├── server/                          # Server-side logic
│   ├── server.lua                   # Main server (1,693 lines)
│   ├── customization_server.lua     # Customization server
│   └── versionchecker.lua           # Version control
├── shared/                          # Shared configuration (modular)
│   ├── config.lua                   # Main config loader
│   ├── config/
│   │   ├── general.lua              # Core settings
│   │   ├── performance.lua          # Performance tuning
│   │   ├── experience.lua           # XP and progression
│   │   ├── attributes.lua           # AI attributes
│   │   ├── items.lua                # Items and care
│   │   ├── shop.lua                 # Shop and economy
│   │   └── extensions.lua           # Extension settings
│   ├── companion_names.lua          # Name generation
│   ├── companion_props.lua          # 63+ customization props
│   ├── companion_comp.lua           # Component definitions
│   ├── animations_settings.lua      # Animation configurations
│   └── stable_settings.lua          # Stable locations
├── docs/                            # Comprehensive documentation
│   ├── README.md                    # Documentation index
│   ├── USER_GUIDE.md                # Player guide
│   ├── ADMIN_GUIDE.md               # Administrator guide
│   ├── ARCHITECTURE.md              # Technical architecture
│   ├── HUNTING_GUIDE.md             # Hunting activities
│   ├── GAMES_GUIDE.md               # Games and activities
│   ├── TRACKING_GUIDE.md            # Tracking mechanics
│   ├── MULTI_COMPANION_GUIDE.md     # Multi-companion system
│   └── SYSTEM_OVERVIEW.md           # System overview
├── locales/                         # Internationalization
│   ├── en.json                      # English (default)
│   └── es.json                      # Spanish
├── scripts/                         # Utility scripts
│   └── validate_fixes.lua           # System validation
├── stream/                          # Map files
│   └── [stable locations]           # Pet stable locations
├── fxmanifest.lua                   # Resource manifest
└── README.md                        # This file
```

## 🔌 Exports for Integration

The resource provides several exports for integration with other resources:

### Available Exports

```lua
-- Check companion level
local level = exports['hdrp-companion']:CheckCompanionLevel(companionId)

-- Check bonding level
local bonding = exports['hdrp-companion']:CheckCompanionBondingLevel(companionId)

-- Check if player has active companion
local hasActive = exports['hdrp-companion']:CheckActiveCompanion(playerId)

-- Check companion customization status
local customization = exports['hdrp-companion']:CheckCompanionCustomize(companionId)

-- Attack target (for combat integration)
exports['hdrp-companion']:AttackTarget(companionId, targetEntity)

-- Track target (for tracking integration)
exports['hdrp-companion']:TrackTarget(companionId, targetCoords)

-- Hunt animals (for hunting integration)
exports['hdrp-companion']:HuntAnimals(companionId, area)
```

### Usage Example

```lua
-- In another resource, check if player has active companion
local playerId = source
local hasCompanion = exports['hdrp-companion']:CheckActiveCompanion(playerId)

if hasCompanion then
    print("Player has an active companion!")
end
```

## 📚 Documentation

### Complete Documentation Suite

This resource includes extensive documentation:

- **[User Guide](docs/USER_GUIDE.md)** - Complete player manual
  - Getting your first companion
  - Basic management and care
  - Training and bonding
  - Activities and mini-games
  - Customization options

- **[Admin Guide](docs/ADMIN_GUIDE.md)** - Server administrator manual
  - Installation and setup
  - Configuration options
  - Performance optimization
  - Troubleshooting
  - Security and anti-cheat

- **[Hunting Guide](docs/HUNTING_GUIDE.md)** - Hunting mechanics
  - Companion hunting abilities
  - Hunting strategies by game type
  - Pack coordination
  - Training and progression

- **[Games Guide](docs/GAMES_GUIDE.md)** - Activities and entertainment
  - Interactive play mechanics
  - Treasure discovery
  - Training sessions
  - Performance and tricks

- **[Architecture](docs/ARCHITECTURE.md)** - Technical documentation
  - System architecture diagram
  - Component responsibilities
  - Performance characteristics
  - Integration points

- **[Multi-Companion Guide](docs/MULTI_COMPANION_GUIDE.md)** - Advanced coordination
  - Leadership mechanics
  - Formation patterns
  - Pack behaviors
  - Coordination optimization

## 🎯 Key Metrics

- **4,000+ lines** of optimized code
- **63 customization props** available
- **8 AI personalities** implemented
- **10 progression levels** with XP system
- **6 core modules** fully optimized
- **5 formation patterns** for multi-companion coordination
- **100% compatible** with RSGCore and ox_lib

## 📝 License

This project is provided as-is for educational and development purposes. Please respect the original work and contributors.

**Important:** This is a community resource for RedM. Usage should comply with:
- RedM/FiveM Terms of Service
- Server-specific rules and regulations
- Responsible gaming practices

## 🤝 Contributing

Contributions are welcome! Please ensure any modifications:

### Code Standards
- ✅ Maintain compatibility with RSGCore framework
- ✅ Follow existing code structure and naming conventions
- ✅ Include appropriate error handling and validation
- ✅ Test thoroughly before submitting changes
- ✅ Document new features in appropriate docs

### Contribution Process
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes with clear messages
4. Test thoroughly on a development server
5. Update documentation as needed
6. Submit a pull request with detailed description

### Areas for Contribution
- 🌍 Additional language translations (locales)
- 🎨 New customization props and accessories
- 🎮 Additional mini-games and activities
- 🐕 New companion types or breeds
- 📚 Documentation improvements
- 🐛 Bug fixes and optimizations

## 🌟 Credits

- **Framework**: RSGCore Team
- **Libraries**: Overextended (ox_lib, ox_target, oxmysql)
- **Community**: RedM development community
- **Testing**: Server administrators and players who provided feedback

## 📞 Support

- 📖 **Documentation**: Check the `docs/` folder
- 🔍 **Issues**: Report bugs through proper channels
- 💬 **Community**: Engage with RedM community forums
- 🛠️ **Validation**: Use `scripts/validate_fixes.lua` for diagnostics

---

**Version 4.7.2** | **Production Ready** ✅ | **Enterprise Architecture**

*Created for the RedM community - Enhance your roleplay experience with intelligent companion AI*

**Compatible with:** RSGCore • ox_lib • ox_target • oxmysql
