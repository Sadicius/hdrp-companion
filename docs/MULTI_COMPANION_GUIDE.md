# 👥 HDRP-Companion Multi-Companion Management Guide

Complete guide for managing multiple active companions simultaneously in RedM.

## 🎯 Multi-Companion Overview

The HDRP-Companion system supports up to 3-5 active companions simultaneously (server configurable). This advanced feature allows for complex pack dynamics, specialized role assignments, and coordinated group activities that single companions cannot achieve.

## 🐕 Understanding Pack Dynamics

### **🏛️ Pack Hierarchy System**
The system automatically establishes a pack hierarchy based on:
- **Experience Level**: Higher level companions naturally become leaders
- **Bonding Strength**: Stronger player bonds increase leadership potential
- **Personality Types**: Aggressive and Loyal companions tend to lead
- **Activity History**: Companions with more field experience gain authority
- **Training Specialization**: Specialized skills affect pack position

### **👑 Alpha Companion (Pack Leader)**
**Selection Criteria**:
- Highest combination of level + bonding + experience
- Automatically designated when multiple companions are active
- Can be manually assigned through advanced commands

**Leadership Responsibilities**:
- Coordinates group movement and positioning
- Makes tactical decisions during activities
- Mediates conflicts between pack members
- Sets the pace for group activities
- Protects weaker pack members

**Visual Indicators**:
- Subtle golden glow around collar/nameplate
- Confident body language and positioning
- Other companions defer to alpha's decisions
- Takes point position during movement

### **🛡️ Beta Companions (Lieutenants)**
**Role**: Support the alpha and specialize in specific functions
**Typical Assignments**:
- **Scout**: Advanced reconnaissance and tracking
- **Guard**: Protection and security duties
- **Hunter**: Specialized hunting and gathering
- **Support**: Medical and supply assistance

### **🐾 Omega Companions (Pack Members)**
**Role**: Follow pack leadership and contribute specialized skills
**Benefits**: Learn faster from more experienced pack members
**Development**: Gradually increase in hierarchy through experience

## 🎮 Multi-Companion Commands

### **Basic Pack Management**
```
/pet_pack status              - View current pack composition and hierarchy
/pet_pack summon all          - Call all owned companions to your location
/pet_pack dismiss [name]      - Send specific companion back to stable
/pet_pack dismiss all         - Send all companions back to stable
/pet_pack formation [type]    - Set pack movement formation
```

### **Advanced Pack Commands**
```
/pet_pack leader [name]       - Manually assign pack leader
/pet_pack role [name] [role]  - Assign specific role to companion
/pet_pack behavior [mode]     - Set overall pack behavior mode
/pet_pack distance [range]    - Set pack spread distance
/pet_pack follow [target]     - Entire pack follows designated target
```

### **Coordination Commands**
```
/pet_pack coordinate hunt     - Coordinate hunting expedition
/pet_pack coordinate guard    - Set up perimeter defense
/pet_pack coordinate search   - Organize search operation
/pet_pack coordinate combat   - Prepare for combat situation
/pet_pack coordinate rest     - Group rest and recovery
```

## 🏗️ Pack Formations and Tactics

### **🚶 Movement Formations**

#### **Single File Formation**
**Best For**: Narrow paths, stealth operations, urban environments
**Structure**: Alpha leads, others follow in experience order
**Advantages**: Quiet movement, easy to control, good for stealth
**Disadvantages**: Vulnerable to area attacks, slower overall speed

#### **Wedge Formation**
**Best For**: Open terrain, hunting, exploration
**Structure**: Alpha at point, others spread in V-shape behind
**Advantages**: Good visibility, flexible response to threats
**Disadvantages**: Requires more space, harder to maintain in dense terrain

#### **Line Formation**
**Best For**: Search operations, wide area coverage
**Structure**: Companions spread in horizontal line
**Advantages**: Maximum area coverage, parallel searching
**Disadvantages**: Harder to coordinate, vulnerable to flanking

#### **Circle Formation (Defensive)**
**Best For**: Resting, protecting player, dangerous situations
**Structure**: Companions form protective circle around player
**Advantages**: 360-degree protection, mutual support
**Disadvantages**: No forward progress, resource intensive

#### **Scatter Formation**
**Best For**: Complex terrain, evasion, independent operations
**Structure**: Companions spread widely, independent movement
**Advantages**: Hard to attack all at once, covers maximum area
**Disadvantages**: Communication difficulties, potential separation

### **🎯 Specialized Pack Roles**

#### **Scout Role** 🔍
**Primary Function**: Reconnaissance and early warning
**Positioning**: 50-100 meters ahead of main pack
**Abilities**:
- Advanced threat detection
- Route finding and pathfinding
- Terrain assessment
- Enemy position reporting
- Safe area identification

**Best Companions**: Fast breeds, high-level trackers, alert personalities

#### **Hunter Role** 🦌
**Primary Function**: Food procurement and resource gathering
**Positioning**: Flanking positions, mobile
**Abilities**:
- Game animal detection
- Silent stalking
- Coordinated takedowns
- Resource identification
- Tracking specialist

**Best Companions**: Hunting breeds, stealth specialists, patient personalities

#### **Guard Role** 🛡️
**Primary Function**: Protection and security
**Positioning**: Close to player or protected assets
**Abilities**:
- Threat assessment
- Defensive positioning
- Player protection priority
- Intimidation tactics
- Alert systems

**Best Companions**: Large breeds, aggressive personalities, loyal types

#### **Support Role** 🎒
**Primary Function**: Logistics and assistance
**Positioning**: Rear or center of formation
**Abilities**:
- Carry extra supplies
- Medical assistance
- Equipment transport
- Communication relay
- Emergency response

**Best Companions**: Strong breeds, calm personalities, trained carriers

## 🎪 Multi-Companion Activities

### **🦌 Pack Hunting Operations**

#### **Small Game Pack Hunting**
**Pack Size**: 2-3 companions optimal
**Strategy**: Coordinate to drive game toward hunter
**Roles**:
- **Driver**: Pushes game from cover
- **Blocker**: Prevents escape routes
- **Retriever**: Collects downed game

**Execution**:
1. Scout identifies game location
2. Pack positions around target area
3. Coordinated drive begins on command
4. Player takes shot when game is positioned
5. Retriever collects while others continue hunting

#### **Large Game Pack Hunting**
**Pack Size**: 3-5 companions recommended
**Strategy**: Complex coordination for dangerous prey
**Roles**:
- **Alpha Leader**: Tactical coordination
- **Distraction**: Draws attention from dangerous game
- **Flankers**: Attack from sides to confuse prey
- **Safety**: Protects player from charges or attacks

**Safety Protocols**:
- Never send pack directly at large predators
- Use coordinated distraction rather than direct attack
- Have emergency recall commands ready
- Position player for quick escape if needed

### **🔍 Group Search and Rescue**

#### **Missing Person Search**
**Pack Deployment**: Spread formation for maximum coverage
**Coordination**: Regular check-ins and position updates
**Process**:
1. Establish last known position
2. Assign search sectors to each companion
3. Systematic grid search with regular reports
4. Converge on any positive findings
5. Coordinate extraction if person found

#### **Treasure Hunting Expeditions**
**Pack Strategy**: Different companions search different treasure types
**Specialization**:
- **Scent Trackers**: Follow item-handler scent trails
- **Diggers**: Excavate buried items
- **Watchers**: Monitor for threats during digging
- **Carriers**: Transport discovered treasures

### **🏠 Base Defense and Security**

#### **Perimeter Security**
**Pack Deployment**: Strategic positioning around protected area
**Coverage**: 360-degree monitoring with overlapping fields
**Alert System**: Coordinated warning system for threats
**Response**: Graduated response from alert to active defense

#### **Patrol Operations**
**Pack Movement**: Regular patrol routes with companion rotation
**Communication**: Silent signals between pack members
**Documentation**: Mental mapping of regular vs. suspicious activity
**Reporting**: Alert player to any anomalies or threats

## 🧠 Pack Psychology and Behavior

### **🤝 Inter-Companion Relationships**

#### **Friendship Development**
**Factors**: Time spent together, shared activities, complementary personalities
**Signs**: Playing together, grooming each other, coordinated rest
**Benefits**: Improved cooperation, shared learning, emotional support
**Maintenance**: Regular group activities, balanced attention from player

#### **Rivalry and Competition**
**Causes**: Similar roles, personality conflicts, competition for player attention
**Signs**: Resource guarding, positioning disputes, performance competition
**Management**: Clear role assignment, separate resources, individual attention
**Resolution**: Training exercises that require cooperation

#### **Mentorship Dynamics**
**Natural Development**: Experienced companions teach newer ones
**Benefits**: Faster learning for junior companions, leadership development
**Observation**: Watch senior companions demonstrating skills
**Encouragement**: Reward mentoring behavior to reinforce positive dynamics

### **🎭 Pack Personality Combinations**

#### **Balanced Pack (Recommended)**
**Composition**: Mix of personalities and skill levels
**Benefits**: Versatile response to different situations
**Example**: Aggressive leader + Loyal supporter + Playful scout + Calm guard

#### **Specialized Pack**
**Composition**: All companions focused on specific activity
**Benefits**: Exceptional performance in chosen specialty
**Example**: All hunting specialists for dedicated hunting operations

#### **Learning Pack**
**Composition**: One experienced mentor with multiple novices
**Benefits**: Rapid skill development for new companions
**Considerations**: Requires patience and careful management

## ⚙️ Advanced Pack Management

### **🎯 Resource Management**

#### **Food and Water Distribution**
**Challenge**: Multiple companions require more resources
**Strategy**: 
- Establish feeding schedule to prevent competition
- Use multiple food/water sources
- Monitor individual consumption and health
- Carry extra supplies for extended operations

#### **Equipment and Gear**
**Consideration**: Each companion can carry different equipment
**Optimization**:
- Assign gear based on role specialization
- Distribute weight across entire pack
- Have backup equipment on multiple companions
- Specialize load-outs for mission requirements

### **🏥 Health and Medical Management**

#### **Group Health Monitoring**
**System**: Regular health checks for entire pack
**Priority**: Identify and treat issues before they spread
**Quarantine**: Separate sick companions to prevent infection
**Recovery**: Coordinate rest periods for optimal healing

#### **Combat Medicine**
**Preparation**: Designate medical specialist companion
**Training**: Practice emergency response with entire pack
**Equipment**: Distribute medical supplies across pack members
**Coordination**: Establish clear protocols for injury response

### **📈 Performance Optimization**

#### **Skill Development Coordination**
**Strategy**: Train complementary skills across pack
**Efficiency**: Use group training sessions where possible
**Specialization**: Develop each companion's unique strengths
**Cross-Training**: Ensure backup capabilities in case of separation

#### **Experience Distribution**
**Challenge**: Ensure all companions develop appropriately
**Balance**: Rotate leadership and activity participation
**Mentorship**: Use experienced companions to boost others
**Individual Attention**: Spend one-on-one time with each companion

## 🎲 Advanced Multi-Companion Scenarios

### **🏕️ Expedition Management**
**Long-Distance Travel**: Managing pack stamina and resources
**Camp Setup**: Coordinate security and rest arrangements
**Route Planning**: Account for multiple companion needs
**Emergency Protocols**: Procedures for separated or injured companions

### **🎪 Social Interactions**
**Meeting Other Players**: Protocol for multi-companion encounters
**Territorial Behavior**: Managing pack response to outsiders
**Showcase Events**: Coordinated demonstrations of pack abilities
**Community Integration**: Participating in server events with full pack

### **⚔️ Combat Coordination**
**Threat Assessment**: Pack evaluation of danger levels
**Tactical Positioning**: Coordinate defensive and offensive positions
**Priority Protection**: Ensure player safety while managing pack
**Retreat Procedures**: Organized withdrawal under pressure

## 📊 Multi-Companion Statistics and Tracking

### **Pack Performance Metrics**
- Group coordination efficiency
- Individual vs. pack success rates
- Resource consumption tracking
- Experience gain distribution
- Injury and health tracking

### **Relationship Monitoring**
- Inter-companion bond strengths
- Leadership stability metrics
- Conflict resolution success
- Cooperation improvement over time
- Pack harmony indicators

### **Activity Analysis**
- Most successful pack configurations
- Optimal pack sizes for different activities
- Best role assignments for available companions
- Seasonal performance variations
- Long-term pack development trends

---

*Managing multiple companions is both the ultimate challenge and the greatest reward of the companion system. A well-coordinated pack becomes more than the sum of its parts - it becomes a force of nature that can tackle any challenge the frontier throws at you. Remember: great packs aren't born, they're built through patience, understanding, and shared adventure.*