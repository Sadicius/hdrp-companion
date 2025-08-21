# 🎯 Funciones del Sistema de Compañeros

## 📋 Índice de Funciones

- [Gestión Básica](#gestión-básica)
- [Sistema de IA](#sistema-de-ia)
- [Customización](#customización)
- [Sistema de Niveles](#sistema-de-niveles)
- [Combate y Habilidades](#combate-y-habilidades)
- [Gestión de Estado](#gestión-de-estado)
- [Prompts y UI](#prompts-y-ui)

---

## 🏠 Gestión Básica

### **CompanionClient:SpawnCompanion(companionData)**
Spawns un compañero en el mundo usando datos de la base de datos.

**Parámetros:**
- `companionData` (table) - Datos del compañero de la BD

**Características:**
- ✅ Validación de posición de spawn
- ✅ Restricciones de carretera (configurable)
- ✅ Aplicación automática de customización
- ✅ Configuración de estadísticas por nivel
- ✅ Inicio automático de comportamiento de seguimiento

```lua
-- Ejemplo de uso
local companionData = {
    companionid = "DOG001",
    model = "a_c_dogHusky_01",
    companiondata = json.encode({
        xp = 150,
        bonding = 75,
        health = 100
    })
}

local success = CompanionClient:SpawnCompanion(companionData)
```

### **CompanionClient:DespawnCompanion(saveData)**
Despawnea el compañero actual del mundo.

**Parámetros:**
- `saveData` (boolean) - Si guardar datos antes de despawn

**Características:**
- ✅ Guardado automático de progreso
- ✅ Cleanup de customización
- ✅ Fade out visual (configurable)
- ✅ Reset completo del estado

---

## 🧠 Sistema de IA

### **CompanionAI:SetPersonality(companionPed, personalityType)**
Establece la personalidad del compañero afectando su comportamiento.

**Personalidades Disponibles:**
- `AGGRESSIVE` - Más agresivo en combate
- `GUARD_DOG` - Defensivo, protege al jugador
- `TIMIDGUARDDOG` - Guardián tímido
- `ATTACK_DOG` - Especializado en ataques
- `AVOID_DOG` - Evita conflictos (por defecto)

```lua
-- Configurar personalidad agresiva
CompanionAI:SetPersonality(companionPed, 'AGGRESSIVE')
```

### **CompanionAI:StartFollowing(companionPed, targetEntity)**
Inicia el comportamiento de seguimiento usando natives RedM optimizados.

**Características:**
- ✅ Distancia de seguimiento configurable
- ✅ Velocidad adaptativa
- ✅ Persistencia automática
- ✅ Evitación de obstáculos

### **CompanionAI:AttackTarget(companionPed, targetEntity)**
Ordena al compañero atacar un objetivo específico.

**Validaciones:**
- ✅ Nivel de XP mínimo requerido
- ✅ Estado de hambre/sed/felicidad
- ✅ Distancia al objetivo
- ✅ Adición automática de XP

### **CompanionAI:TrackTarget(companionPed, targetEntity)**
Hace que el compañero rastree un objetivo y cree un blip en el mapa.

**Características:**
- ✅ Blip temporal en el objetivo
- ✅ Movimiento inteligente al objetivo
- ✅ Auto-eliminación del blip después de tiempo configurado

### **CompanionAI:HuntAnimal(companionPed, animalEntity)**
Sistema completo de caza de animales con recuperación automática.

**Proceso:**
1. Validación de habilidades de caza
2. Ataque al animal objetivo
3. Espera a que el animal muera
4. Recuperación automática del cadáver
5. Entrega de carne al jugador
6. Retorno automático al jugador

---

## 🎨 Customización

### **CustomizationSystem:OpenCustomizationMenu(companionPed)**
Abre el menú de customización con todas las opciones disponibles.

**63 Props Disponibles:**

#### 🧸 **Juguetes (Toys)**
- Pelotas, huesos, juguetes de cuerda
- **Precio:** $5 cada uno

#### 📯 **Cuernos (Horns)**  
- Cuernos decorativos de diferentes estilos
- **Precio:** $10 cada uno

#### 🏺 **Collares (Neck)**
- Collares elegantes y funcionales
- **Precio:** $15 cada uno

#### 🏅 **Medallas (Medal)**
- Medallas de honor y reconocimiento
- **Precio:** $20 cada uno

#### 🎭 **Máscaras (Masks)**
- Máscaras protectoras y decorativas  
- **Precio:** $25 cada uno

#### 🚬 **Cigarros (Cigar)**
- Accesorios únicos de estilo
- **Precio:** $30 cada uno

### **CustomizationSystem:LoadCustomization(companionPed, customizationData)**
Carga la customización guardada desde la base de datos.

### **CustomizationSystem:SaveCustomization(companionId, customizationData)**
Guarda la customización actual en la base de datos con validación de propietario.

---

## 📈 Sistema de Niveles

### **CompanionState:AddXP(amount)**
Añade experiencia al compañero con detección automática de subida de nivel.

**Características:**
- ✅ Detección automática de level up
- ✅ Eventos de notificación
- ✅ Actualización de estadísticas

### **CompanionState:GetLevel()**
Calcula el nivel actual basado en la XP total.

**Sistema de Niveles:**
- **Nivel 1:** 0-100 XP
- **Nivel 2:** 101-250 XP  
- **Nivel 3:** 251-500 XP
- **...hasta Nivel 10**

### **CompanionState:CanPerformAction(requiredXP, checkStats)**
Valida si el compañero puede realizar una acción específica.

**Validaciones:**
- ✅ XP mínima requerida
- ✅ Estados de hambre (>25)
- ✅ Estados de sed (>25)
- ✅ Estados de felicidad (>25)

---

## ⚔️ Combate y Habilidades

### **Comando: Atacar**
- **XP Requerida:** Configurable en `Config.TrickXp.Attack`
- **Efecto:** El compañero ataca al objetivo seleccionado
- **Recompensa:** +2 XP por ataque

### **Comando: Rastrear**  
- **XP Requerida:** Configurable en `Config.TrickXp.Track`
- **Efecto:** Crea blip y rastrea al objetivo
- **Duración:** 60 segundos (configurable)
- **Recompensa:** +2 XP por rastreo

### **Comando: Cazar**
- **XP Requerida:** Configurable en `Config.TrickXp.HuntAnimals`
- **Efecto:** Caza animales y los trae al jugador
- **Recompensa:** Carne + XP

### **Modo Defensivo Automático**
Si está habilitado en configuración:
- Detecta automáticamente amenazas al jugador
- Responde a combate del jugador
- Protege al jugador sin comandos manuales

---

## 🗂️ Gestión de Estado

### **CompanionState:Initialize()**
Inicializa el sistema de estado centralizado.

### **CompanionState:GetData() / SetData(data)**
Gestiona los datos completos del compañero.

### **CompanionState:UpdateStat(stat, value)**
Actualiza estadísticas individuales con validación de rangos.

**Estadísticas Disponibles:**
- `health` - Salud (0-100)
- `hunger` - Hambre (0-100)  
- `thirst` - Sed (0-100)
- `happiness` - Felicidad (0-100)
- `stamina` - Resistencia (0-100)
- `bonding` - Vínculo (0-100)

### **CompanionState:Reset()**
Resetea completamente el estado y limpia entidades.

---

## 🖱️ Prompts y UI

### **PromptManager:InitializeCompanionPrompts()**
Inicializa todos los prompts del sistema organizados por grupos.

**Grupos de Prompts:**
- `companion_main` - Llamar, huir, acciones
- `companion_interaction` - Alforjas, cepillar
- `companion_combat` - Atacar, rastrear, cazar
- `companion_environment` - Beber, comer

### **PromptManager:HandleMainPrompts()**
Maneja los prompts principales basados en el estado del compañero.

### **PromptManager:HandleCombatPrompts(targetEntity)**
Gestiona prompts de combate cuando hay un objetivo seleccionado.

**Validaciones:**
- ✅ Distancia máxima (15 metros)
- ✅ Compañero activo
- ✅ Configuración habilitada

---

## 🔧 Funciones de Utilidad

### **GetOptimalSpawnPosition(playerCoords)**
Encuentra la mejor posición para spawnear el compañero.

**Algoritmo:**
1. Genera posiciones aleatorias alrededor del jugador (3-8m)
2. Verifica altura del suelo
3. Valida ausencia de obstáculos
4. Retorna posición óptima o fallback

### **ApplyLevelStats(companionPed, level)**
Aplica estadísticas escaladas basadas en el nivel.

**Escalado:**
- Salud base × (1 + level × 0.1)
- Otros stats según configuración de nivel

### **CreateCompanionBlip(companionPed)**
Crea un blip en el mapa para el compañero activo.

---

## 📊 Eventos del Sistema

### **Eventos Cliente**
- `rsg-companions:client:callCompanion` - Llamar compañero
- `rsg-companions:client:fleeCompanion` - Huir compañero  
- `rsg-companions:client:openActionsMenu` - Menú de acciones
- `rsg-companions:client:brushCompanion` - Cepillar compañero
- `rsg-companions:client:openCustomizationMenu` - Menú customización

### **Eventos Servidor**
- `rsg-companions:server:SaveCustomization` - Guardar customización
- `rsg-companions:server:LoadCustomization` - Cargar customización
- `rsg-companions:server:PurchaseComponent` - Comprar componente
- `rsg-companions:server:UpdateCompanionData` - Actualizar datos

---

## 🎮 Exports Disponibles

### **Exports de Compatibilidad**
```lua
-- Verificar nivel del compañero
local level = exports['hdrp-companion']:CheckCompanionLevel()

-- Verificar bonding
local bonding = exports['hdrp-companion']:CheckCompanionBondingLevel()

-- Obtener compañero activo
local companionPed = exports['hdrp-companion']:CheckActiveCompanion()

-- Funciones de combate
exports['hdrp-companion']:AttackTarget(data)
exports['hdrp-companion']:TrackTarget(data)
exports['hdrp-companion']:HuntAnimals(data)
```

### **Exports Nuevos**
```lua
-- Acceso al cliente optimizado
local CompanionClient = exports['hdrp-companion']:GetCompanionClient()

-- Acceso al sistema de IA
local CompanionAI = exports['hdrp-companion']:GetCompanionAI()

-- Acceso al gestor de prompts
local PromptManager = exports['hdrp-companion']:GetPromptManager()

-- Acceso al estado
local CompanionState = exports['hdrp-companion']:GetCompanionState()
```

---

## 🔄 Flujo de Funcionamiento

### **1. Inicialización**
```
lib.onCache → CompanionState:Initialize() → PromptManager:InitializeCompanionPrompts()
```

### **2. Spawn de Compañero**
```
Validación → Spawn → Configuración → Customización → IA → Prompts
```

### **3. Ciclo de Vida**
```
Seguimiento → Acciones → Validaciones → XP → Guardado → Cleanup
```

### **4. Customización**
```
Menú → Selección → Compra → Aplicar → Guardar → Sincronizar
```

Esta documentación cubre todas las funciones principales del sistema. Para detalles específicos de implementación, revisa el código fuente correspondiente en cada módulo.