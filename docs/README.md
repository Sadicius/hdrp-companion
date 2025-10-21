# 🐾 HDRP-Companion Documentation

**Version:** 4.7.0
**Status:** Production Ready ✅
**Last Updated:** 2025

## 📖 Complete System Documentation

Welcome to the official documentation for the advanced companion/pet system for RedM with RSGCore framework. This documentation suite provides comprehensive guides for players, administrators, and developers.

## 📚 Documentation Index

### 📋 **Player Documentation**

Essential guides for players using the companion system:

- **[User Guide](USER_GUIDE.md)** - Complete player manual
  - Getting your first companion
  - Basic management and care (feeding, grooming, bonding)
  - Training and skill development
  - Activities and mini-games
  - Customization options and accessories
  - Troubleshooting player issues

- **[Hunting Guide](HUNTING_GUIDE.md)** - Hunting with companions
  - Companion hunting abilities by type
  - Hunting strategies (small, medium, large game)
  - Pack coordination and tactics
  - Scent tracking mechanics
  - Training and progression
  - Safety protocols

- **[Games & Activities Guide](GAMES_GUIDE.md)** - Entertainment and activities
  - Interactive play (fetch, retrieval)
  - Treasure discovery mechanics
  - Training sessions (physical, mental, specialty)
  - Environmental exploration
  - Performance and tricks
  - Reward systems

- **[Tracking Guide](TRACKING_GUIDE.md)** - Tracking and scent mechanics
  - How tracking works
  - Trail quality indicators
  - Environmental factors
  - Training progression

### 🛠️ **Administrator Documentation**

Guides for server administrators and developers:

- **[Admin Guide](ADMIN_GUIDE.md)** - Server administrator manual
  - Installation and setup process
  - Complete configuration reference
  - Performance optimization strategies
  - Security and anti-cheat measures
  - Troubleshooting and debugging
  - Admin commands reference
  - Database management

- **[System Overview](SYSTEM_OVERVIEW.md)** - High-level system overview
  - Feature summary
  - System capabilities
  - Integration points
  - Use cases

### 🏗️ **Technical Documentation**

For developers and technical users:

- **[Architecture](ARCHITECTURE.md)** - Technical architecture
  - System architecture diagram (Mermaid)
  - Component responsibilities
  - Data flow diagrams
  - Performance characteristics
  - Integration patterns
  - Code metrics

- **[Multi-Companion Guide](MULTI_COMPANION_GUIDE.md)** - Advanced coordination (v4.7.0)
  - Leadership election mechanics
  - Formation patterns (V-formation, line, circle, scatter, defensive)
  - Pack behaviors and coordination
  - Synchronization protocols
  - Performance optimization

## 🌟 Key Features

### 🤖 **Advanced AI System**
- **Context-Aware Behavior**: Intelligent decision-making based on 6 environmental categories
- **Enhanced Memory System**: Persistent learning with categorized experience storage (v4.7.0)
- **8 Personality Types**: Aggressive, Guardian, Shy, Avoidant, Friendly, Loyal, Playful, Calm
- **Sub-50ms Response Times**: Hardware-monitored performance with real-time optimization
- **Dynamic Context Analysis**: Environmental monitoring (combat, exploration, social contexts)

### 🤝 **Multi-Companion Coordination** (v4.7.0)
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

## 🐕 Available Companion Types

### 🐕 **Dogs**
- **Available Models**: Husky, German Shepherd, Labrador, Retriever
- **Personalities**: Aggressive, Guardian, Shy, Avoidant, Friendly, Loyal, Playful, Calm
- **Abilities**: Attack, tracking, hunting, fetching, guarding

### 🐱 **Cats** 
- **Available Models**: Various domestic cat breeds
- **Specialties**: Stealth, small game hunting, independence
- **Abilities**: Silent movement, rodent detection, climbing

### 🔥 **Special Features**
- **Defensive Mode**: Automatic player protection
- **Hunger/Thirst System**: Realistic needs and care requirements
- **Bonding System**: Relationship building over time
- **Persistent Inventory**: Saddlebags for item storage

## 🛠️ Technology Stack

### **Client-Side**
- **CfxLua**: Primary language optimized for RedM
- **ox_lib**: Modern library for UI and utilities
- **RedM Natives**: Native APIs specific to Red Dead Redemption

### **Server-Side**
- **RSGCore Framework**: Base server framework
- **oxmysql**: Optimized database driver
- **MySQL/MariaDB**: Data persistence system

### **Architecture**
- **Modular Pattern**: Clear separation of concerns
- **Event-Driven**: Event-based communication
- **State Management**: Centralized state control
- **Cache System**: Performance optimization layer

## 📈 Project Metrics

- **4,000+ lines** of optimized code
- **63 customization props** available
- **8 AI personalities** implemented
- **10 progression levels** with XP system
- **6 core modules** fully optimized
- **100% compatible** with RSGCore and ox_lib

## 🚀 Quick Start

### For Players
1. **Read the [User Guide](USER_GUIDE.md)** - Learn how to get and care for companions
2. **Visit a pet stable** in-game (Valentine, Blackwater, or Tumbleweed)
3. **Use `/pet_menu`** to access the companion interface
4. **Purchase your first companion** and start your journey

### For Server Administrators
1. **Read the [Admin Guide](ADMIN_GUIDE.md)** - Complete installation instructions
2. **Install dependencies** (rsg-core, ox_lib, ox_target, oxmysql)
3. **Configure settings** in `shared/config/` files
4. **Adjust performance mode** based on server population
5. **Test and validate** using built-in diagnostics

### For Developers
1. **Review [Architecture](ARCHITECTURE.md)** - Understand system design
2. **Check available exports** in main README
3. **Study modular config** structure in `shared/config/`
4. **Explore API integration** points

## 🎯 System Metrics

- **4,000+ lines** of optimized code
- **63 customization props** available
- **8 AI personalities** implemented
- **10 progression levels** with XP system
- **6 core modules** fully optimized
- **5 formation patterns** for multi-companion coordination
- **100% compatible** with RSGCore and ox_lib

## 📊 Performance Characteristics

### Resource Usage
- **Memory**: ~5-10MB per active companion
- **CPU Impact**: < 1% on modern servers
- **Database Load**: Minimal with optimized queries
- **Network Usage**: Efficient batched updates
- **Response Times**: Sub-50ms AI decisions

### Tested Environments
- ✅ Servers with 32+ concurrent players
- ✅ High-population servers (50+ with performance mode)
- ✅ Multiple companions per player (up to 5)
- ✅ 24/7 production servers with continuous uptime

### Recommended Specifications

| Server Size | RAM | CPU | Performance Mode |
|-------------|-----|-----|------------------|
| Small (< 20 players) | 4GB | 2 cores | Quality |
| Medium (20-50 players) | 8GB | 4 cores | Balanced |
| Large (50+ players) | 16GB | 6+ cores | Performance |

## 🛠️ Installation

### Prerequisites
- **RedM Server**: Compatible RedM server installation
- **RSGCore Framework**: Latest version recommended
- **Database**: MySQL 5.7+ or MariaDB 10.2+
- **Required Dependencies**:
  - `rsg-core` - RSGCore framework
  - `ox_lib` - Overextended library
  - `ox_target` - Targeting system
  - `oxmysql` - MySQL connector

### Quick Installation
```bash
# 1. Clone or download to resources folder
cd resources/
git clone [repository-url] hdrp-companion

# 2. Add to server.cfg (after dependencies)
ensure rsg-core
ensure ox_lib
ensure ox_target
ensure oxmysql
ensure hdrp-companion

# 3. Restart server (database tables auto-create)
restart hdrp-companion
```

**For detailed installation instructions, see [Admin Guide](ADMIN_GUIDE.md)**

## 📞 Support and Troubleshooting

### Documentation Resources
- **[User Guide](USER_GUIDE.md)** - Player questions and basic troubleshooting
- **[Admin Guide](ADMIN_GUIDE.md)** - Server configuration and advanced troubleshooting
- **[Architecture](ARCHITECTURE.md)** - Technical details and system understanding

### Diagnostic Tools
```bash
# Enable debug mode
Config.Debug = true

# Run validation script
# Check scripts/validate_fixes.lua

# Admin commands
/pet_admin stats              # Server statistics
/pet_admin performance        # Performance metrics
/pet_debug ai [id]           # Debug AI behavior
```

### Common Issues
- **Companion Not Spawning**: Check dependencies and console errors
- **Database Errors**: Verify oxmysql configuration
- **Performance Issues**: Adjust AI performance mode
- **Missing Prompts**: Check for keybind conflicts

**For comprehensive troubleshooting, see [Admin Guide - Troubleshooting](ADMIN_GUIDE.md#troubleshooting)**

## 🔄 Version History

### v4.7.0 (Current - Production Ready)
- ✅ Enhanced AI with context awareness
- ✅ Multi-companion coordination system
- ✅ Advanced memory system with learning
- ✅ Performance optimizations
- ✅ Modular configuration architecture
- ✅ Complete documentation suite

## 🌍 Language Support

The system supports multiple languages:
- **English** (`en.json`) - Default
- **Spanish/Español** (`es.json`)

Additional locales can be added in the `locales/` folder.

## 📝 License & Credits

This project is provided as-is for educational and development purposes.

**Credits:**
- **Framework**: RSGCore Team
- **Libraries**: Overextended (ox_lib, ox_target, oxmysql)
- **Community**: RedM development community

---

**Version 4.7.0** | **Production Ready** ✅ | **Enterprise Architecture**

*For detailed setup instructions, see the [Admin Guide](ADMIN_GUIDE.md). For gameplay information, see the [User Guide](USER_GUIDE.md).*