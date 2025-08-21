# 🐕 HDRP-Companion Pet System for RedM

Advanced companion system for RedM servers with AI-enhanced behavior, customization options, and interactive gameplay mechanics.

## ✨ Features

- **🤖 Advanced AI System**: Context-aware companion behavior with dynamic decision making
- **🎨 Full Customization**: 63+ props and accessories for companion personalization
- **🎮 Interactive Mini-Games**: 5 engaging activities to play with your companions
- **⚡ Performance Optimized**: Sub-50ms response times with memory management
- **🛠️ RSGCore Integration**: Native compatibility with RSGCore framework
- **📊 Progressive System**: Leveling, bonding, and experience mechanics

## 🚀 Installation

### Prerequisites
- RedM Server with RSGCore framework
- Required dependencies:
  - `rsg-core`
  - `ox_lib`
  - `ox_target`
  - `oxmysql`

### Installation Steps
1. Download the latest release
2. Extract to your server's `resources` folder
3. Add `ensure hdrp-companion` to your `server.cfg`
4. Restart your server (database tables will auto-create)
5. Configure settings in `shared/config.lua` if needed

## 🎮 How to Use

### Getting Started
1. Visit any pet stable in-game
2. Use `/pet_menu` to access the main companion interface
3. Purchase your first companion from the available selection
4. Follow the on-screen prompts to complete your purchase

### Basic Commands
- `/pet_menu` - Open main companion menu
- `/pet_stats` - View companion statistics and status
- `/pet_games` - Access mini-games and activities
- `/pet_customize` - Open customization interface
- `/pet_find` - Locate your stored companions

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

### Basic Settings
Edit `shared/config.lua` to customize:
- Companion purchase prices
- Experience gain rates
- Food and water consumption
- Available customization options
- Performance optimization settings

### Advanced Configuration
- **AI Performance Mode**: Choose between 'performance', 'balanced', or 'quality'
- **Max Companions**: Set maximum companions per player (default: 3-5)
- **Respawn Settings**: Configure companion behavior after disconnection
- **Database Options**: Customize table names and cleanup intervals

## 🔧 Troubleshooting

### Common Issues
- **Companion Not Spawning**: Check server console for dependency errors
- **Database Errors**: Ensure oxmysql is properly configured
- **Performance Issues**: Adjust AI performance mode in config
- **Missing Commands**: Verify RSGCore is running and up to date

### Support
- Check the `docs/` folder for detailed documentation
- Review `scripts/validate_fixes.lua` for system validation
- Ensure all dependencies are properly installed and updated

## 📊 System Requirements

- **Server**: RedM compatible server
- **Framework**: RSGCore (latest version recommended)
- **Database**: MySQL/MariaDB with oxmysql
- **Memory**: Minimal impact with intelligent resource management
- **Performance**: Optimized for servers with 32+ concurrent players

## 🏗️ File Structure

```
hdrp-companion/
├── client/          # Client-side scripts and AI system
├── server/          # Server-side logic and database management
├── shared/          # Shared configuration and data
├── docs/            # Documentation and guides
├── locales/         # Multi-language support
├── stream/          # Map files for pet stables
└── scripts/         # Validation and utility scripts
```

## 📝 License

This project is provided as-is for educational and development purposes. Please respect the original work and contributors.

## 🤝 Contributing

Contributions are welcome! Please ensure any modifications:
- Maintain compatibility with RSGCore framework
- Follow existing code structure and naming conventions
- Include appropriate error handling and validation
- Test thoroughly before submitting changes

---

*Created for the RedM community - Enhance your roleplay experience with intelligent companion AI*