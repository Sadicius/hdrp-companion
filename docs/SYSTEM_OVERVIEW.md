# 🎮 HDRP-Companion System Overview

Complete guide to how the companion system works and how to interact with your companions.

## 🏗️ System Architecture

### **Core Components**
```
┌─────────────────────────────────────────────────────────────────┐
│                    HDRP-COMPANION SYSTEM                       │
├─────────────────┬─────────────────┬─────────────────────────────┤
│   CLIENT SIDE   │   SERVER SIDE   │        DATABASE             │
├─────────────────┼─────────────────┼─────────────────────────────┤
│ • PromptManager │ • RSGCore       │ • player_companions         │
│ • CompanionAI   │ • Oxmysql       │ • companion_memory          │
│ • Coordination  │ • Events        │ • companion_coordination    │
│ • ContextAnalz  │ • Callbacks     │                             │
│ • MemorySystem  │ • Commands      │                             │
│ • StateManager  │                 │                             │
└─────────────────┴─────────────────┴─────────────────────────────┘
```

## 🎯 User Interaction Methods

### **1. Prompt System (Primary Interface)**
The system uses **RedM Prompts** - interactive buttons that appear near your companion.

#### **Main Prompts:**
- **Call Companion**: Spawn your companion near you
- **Flee Companion**: Store companion safely 
- **Actions Menu**: Open context menu for companion activities
- **Saddlebags**: Access companion inventory
- **Brush**: Groom companion (hold button)

#### **Combat/Activity Prompts:**
- **Attack Target**: Command companion to attack aimed target
- **Track Target**: Have companion track a player or entity
- **Hunt Target**: Coordinate hunting with companion

#### **Environmental Prompts:**
- **Drink**: Allow companion to drink from water sources
- **Eat**: Let companion eat from food sources

### **2. Targeting System (ox_target)**
Used for:
- **Purchasing companions** at stables
- **Customization interactions** at stable areas
- **Advanced interactions** with NPCs

### **3. Context Menus (ox_lib)**
- **Animation menu** - Select companion animations/tricks
- **Advanced actions** - Complex companion behaviors
- **Settings** - Companion preferences and configurations

## 🤖 Automated Systems

### **AI Context Analysis**
The companion automatically analyzes:
- **Player Activity**: Combat, walking, running, sneaking, armed status
- **Environment**: City, town, wilderness, forest, mountains, water
- **Time of Day**: Morning, afternoon, evening, night
- **Weather**: Clear, rainy, drizzle, windy
- **Social Context**: Alone, with players, with NPCs, crowded areas

### **Multi-Companion Coordination** 
**Completely Automatic** - No manual commands needed:

```
🐕 PACK BEHAVIOR SYSTEM 🐕
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   DETECTION     │───▶│   ANALYSIS      │───▶│   EXECUTION     │
│                 │    │                 │    │                 │
│ • Scan for      │    │ • Determine     │    │ • Apply         │
│   nearby        │    │   optimal       │    │   formation     │
│   companions    │    │   behavior      │    │ • Coordinate    │
│ • Identify      │    │ • Select        │    │   movement      │
│   owners        │    │   formation     │    │ • Manage        │
│ • Calculate     │    │ • Assign        │    │   hierarchy     │
│   distances     │    │   roles         │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

#### **Automatic Formations:**
- **Independent**: Each companion acts individually
- **Follow Formation**: Line formation behind player
- **Defensive Circle**: Protective circle around player
- **Exploration Spread**: Spread out for area coverage
- **Pack Hunting**: Coordinated hunting behavior

#### **Context-Based Behavior:**
- **Combat** → Defensive Circle or Follow Formation
- **Hunting** → Pack Hunting coordination
- **Walking/Running** → Exploration Spread or Follow Formation
- **Idle** → Formation based on companion count

### **Memory System**
Companions automatically remember:
- **Interaction history** with player
- **Context changes** and significant events
- **Bonding experiences** and training
- **Environmental preferences** and behaviors

## 🎮 Actual Player Experience

### **Getting Your First Companion:**
1. **Visit a Stable** (Valentine, Blackwater, Tumbleweed)
2. **Use ox_target** on companion NPCs to see purchase options
3. **Select companion type** and set name/gender
4. **Purchase** with in-game money

### **Daily Interaction:**
1. **Call Companion**: Prompt appears when no companion active
2. **Basic Care**: Prompts appear near companion for feeding, watering, brushing
3. **Activities**: Context menu for games, training, advanced actions
4. **Environmental**: Automatic drinking/eating when near appropriate sources

### **Combat/Activities:**
1. **Target an Entity**: Aim at enemy, animal, or player
2. **Combat Prompts Appear**: Attack, Track, Hunt options
3. **Companion Responds**: Automatically executes command
4. **Context Awareness**: Behavior adapts to situation

### **Multi-Companion Management:**
- **Completely Automatic**: No manual pack management needed
- **Smart Coordination**: System detects and coordinates multiple companions
- **Adaptive Behavior**: Pack behavior changes based on activity and context
- **Hierarchy Management**: Leadership determined by bonding level and experience

## 🔧 Technical Features

### **Performance Optimized:**
- **Performance Monitoring**: Context analysis <25ms target with warning alerts
- **Efficient Memory Usage**: Lightweight caching system
- **Smart Updates**: 500ms quick updates, 2000ms full analysis
- **Performance Monitoring**: Built-in performance tracking

### **Advanced AI Features:**
- **Context-Aware Behavior**: Responds to environment and activity
- **Learning System**: Improves behavior through interaction
- **Emotional Intelligence**: Tracks happiness, bonding, and mood
- **Environmental Adaptation**: Adjusts to weather, terrain, and social situations

### **Integration Features:**
- **RSGCore Compatible**: Full framework integration
- **ox_lib Menus**: Modern UI components
- **ox_target System**: Seamless targeting integration
- **Database Persistent**: All data saved automatically

## 📊 System Capabilities

### **What Works Automatically:**
✅ **Multi-companion coordination** (automatic formations)  
✅ **Context-aware behavior** (adapts to player activity)  
✅ **Environmental interactions** (automatic drinking/eating)  
✅ **Performance optimization** (efficient resource usage)  
✅ **Memory and learning** (companion remembers experiences)  
✅ **Pack leadership** (automatic hierarchy based on bonding)  

### **What Requires Player Input:**
🎮 **Calling/storing companion** (prompts)  
🎮 **Feeding and care** (prompts)  
🎮 **Combat commands** (target + prompt)  
🎮 **Animation/tricks** (context menu)  
🎮 **Customization** (ox_target at stables)  

## 🚀 Advanced Features

### **Companion Intelligence:**
- **Predictive Behavior**: Anticipates player needs
- **Adaptive Learning**: Improves through experience
- **Social Awareness**: Responds to other players and companions
- **Environmental Mastery**: Understands terrain and weather effects

### **Coordination Excellence:**
- **Pack Dynamics**: Natural hierarchy and cooperation
- **Tactical Positioning**: Smart formation selection
- **Communication**: Silent coordination between companions
- **Conflict Resolution**: Automatic mediation of companion disputes

