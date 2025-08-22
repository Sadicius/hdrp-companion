# 🛠️ HDRP-Companion Guía de Administración

Guía completa de configuración y gestión para administradores de servidor.

## 🚀 Configuración Inicial

### Verificación de Prerequisitos
Antes de la instalación, asegúrate que tu servidor tenga:
```bash
# Recursos requeridos
ensure rsg-core      # Framework RSGCore
ensure ox_lib        # Librería Overextended
ensure ox_target     # Sistema de targeting
ensure oxmysql       # Conector de base de datos
```

### Proceso de Instalación
1. **Descargar y Extraer**: Coloca en tu carpeta `resources`
2. **Configuración de Base de Datos**: Las tablas se auto-crean en primer inicio
3. **Configuración del Servidor**: Añadir a `server.cfg`
4. **Reiniciar Servidor**: Reinicio completo requerido para inicialización

### Verificar Instalación
```bash
# Revisa la consola para estos mensajes:
[COMPANION] Tablas de base de datos creadas exitosamente
[COMPANION] Monitor de rendimiento inicializado
[COMPANION] Sistema de compañeros cargado
```

## ⚙️ Configuración Principal

### Archivo de Configuración Principal: `shared/config.lua`

```lua
Config = {
    Debug = false,                    -- Habilitar modo debug para troubleshooting
    MaxCompanions = 3,               -- Máx compañeros por jugador
    AutoSave = true,                 -- Guardado automático de datos de compañeros
    SaveInterval = 300000,           -- Intervalo de auto-guardado (5 minutos)
    
    -- Configuraciones de Rendimiento
    Performance = {
        Mode = 'balanced',           -- 'performance', 'balanced', 'quality'
        MaxActiveCompanions = 20,    -- Máx compañeros activos en servidor
        AIUpdateInterval = 2000,     -- Frecuencia de actualización IA (ms)
        CleanupInterval = 600000,    -- Limpiar compañeros inactivos (10 min)
    },
    
    -- Configuraciones Económicas
    Economy = {
        EnablePurchasing = true,     -- Permitir compra de compañeros
        BasePrices = {
            dog = 150,               -- Precio base para perros
            cat = 100,               -- Precio base para gatos
            wolf = 500,              -- Precio base para lobos (si está habilitado)
        },
        FeedingCosts = {
            raw_meat = 5,            -- Costo por alimentación
            cooked_meat = 8,
            dog_biscuit = 3,
        }
    }
}
```

### Configuración Avanzada de Rendimiento: `shared/config/performance.lua`

```lua
Config.EnhancedAI = {
    -- Modos de Rendimiento IA
    PerformanceMode = 'balanced',    -- 'performance', 'balanced', 'quality'
    
    -- Gestión de Memoria
    MaxMemoryEntries = 20,           -- Límite de memoria IA por compañero
    MemoryCleanupInterval = 300,     -- Limpiar memorias viejas (segundos)
    
    -- Toma de Decisiones
    DecisionTimeout = 50,            -- Tiempo máx de decisión IA (ms)
    ContextUpdateRate = 2000,        -- Frecuencia de análisis de contexto (ms)
    
    -- Límites de Recursos del Servidor
    MaxConcurrentAI = 25,            -- Máx compañeros IA procesando simultáneamente
    ThreadPriority = 'normal',       -- 'low', 'normal', 'high'
}
```

## 🎯 Optimización de Rendimiento

### Modos de Rendimiento Explicados

**🚀 Modo Performance** (Recomendado para servidores de alta población):
```lua
Config.EnhancedAI.PerformanceMode = 'performance'
```
- Complejidad IA reducida para mejor FPS
- Tiempos de respuesta más rápidos
- Menor uso de memoria
- Mejor para servidores de 50+ jugadores

**⚖️ Modo Balanced** (Por defecto - Recomendado para la mayoría de servidores):
```lua
Config.EnhancedAI.PerformanceMode = 'balanced'
```
- Balance óptimo de características y rendimiento
- Buen comportamiento IA sin uso pesado de recursos
- Adecuado para servidores de 20-50 jugadores

**✨ Modo Quality** (Recomendado para servidores enfocados en RP):
```lua
Config.EnhancedAI.PerformanceMode = 'quality'
```
- Características IA completas y comportamientos avanzados
- Mejor inteligencia e inmersión de compañeros
- Mejor para servidores pequeños (menos de 32 jugadores)

### Monitoreo de Recursos del Servidor

Revisar impacto del sistema de compañeros:
```bash
# Monitorear uso de recursos
monitor resource_name

# Revisar compañeros activos
/pet_admin stats

# Ver métricas de rendimiento
/pet_admin performance
```

### Consejos de Optimización

**Para Servidores de Alta Población**:
```lua
Config.Performance.MaxActiveCompanions = 15    -- Reducir de default 20
Config.Performance.AIUpdateInterval = 3000     -- Aumentar de 2000ms
Config.MaxCompanions = 2                       -- Reducir de 3 por jugador
```

**Para Servidores de Baja Población**:
```lua
Config.Performance.MaxActiveCompanions = 30    -- Aumentar para más compañeros
Config.Performance.AIUpdateInterval = 1500     -- Actualizaciones IA más rápidas
Config.MaxCompanions = 5                       -- Permitir más por jugador
```

## 🏪 Configuración Económica

### Estrategia de Precios
```lua
Config.Economy.BasePrices = {
    dog = 150,              -- Compañero inicial, asequible
    cat = 100,              -- Opción más barata para nuevos jugadores
    wolf = 500,             -- Compañero premium, raro
    bear = 1000,            -- Compañero élite (si está habilitado)
}
```

### Integración de Tienda
```lua
Config.Shops = {
    EnableNPCShops = true,           -- Habilitar vendedores NPC de compañeros
    EnablePlayerShops = false,       -- Permitir ventas jugador-a-jugador
    
    ShopLocations = {
        valentine = {
            coords = vector3(-378.89, 786.52, 116.18),
            npc = 'a_m_m_farmer_01',
            blip = true
        },
        blackwater = {
            coords = vector3(-875.42, -1230.52, 53.84),
            npc = 'a_m_m_farmer_01',
            blip = true
        }
    }
}
```

### Configuración de Moneda
```lua
Config.Currency = {
    Type = 'cash',                   -- 'cash', 'bank', 'custom'
    CustomCurrency = 'companion_tokens', -- Si usas moneda personalizada
    EnableMultipleCurrencies = false -- Permitir diferentes métodos de pago
}
```

## 🔒 Seguridad y Anti-Trampas

### Limitaciones de Jugadores
```lua
Config.Security = {
    MaxCompanionsPerPlayer = 3,      -- Límite duro por jugador
    CooldownBetweenPurchases = 3600, -- 1 hora de cooldown (segundos)
    RequireMinLevel = 5,             -- Nivel mín de jugador para comprar compañeros
    
    -- Restricciones de Invocación
    AntiSpamDelay = 5000,            -- 5 segundos de delay entre invocaciones
    MaxSpawnDistance = 50.0,         -- Distancia máx del jugador para invocar
    SafeZoneOnly = false,            -- Solo permitir invocación en zonas seguras
}
```

### Comandos de Admin
```bash
# Gestión de compañeros para admin
/pet_admin give [player_id] [type]     # Dar compañero a jugador
/pet_admin remove [player_id] [comp_id] # Remover compañero específico
/pet_admin reset [player_id]           # Resetear todos los compañeros del jugador
/pet_admin stats                       # Ver estadísticas de compañeros del servidor
/pet_admin cleanup                     # Forzar limpieza de compañeros inactivos
```

### Gestión de Base de Datos
```lua
Config.Database = {
    AutoCleanup = true,              -- Habilitar limpieza automática
    CleanupInterval = 86400,         -- Limpieza diaria (segundos)
    KeepInactiveFor = 2592000,       -- Mantener compañeros inactivos por 30 días
    BackupBeforeCleanup = true,      -- Crear backup antes de limpieza
}
```

## 🐕 Configuración de Tipos de Compañeros

### Tipos de Compañeros Disponibles
```lua
Config.CompanionTypes = {
    dog = {
        enabled = true,
        models = {'a_c_dog_shepherd', 'a_c_dog_husky', 'a_c_dog_retriever'},
        basePrice = 150,
        maxLevel = 10,
        specialAbilities = {'hunt', 'guard', 'fetch'}
    },
    cat = {
        enabled = true,
        models = {'a_c_cat_01'},
        basePrice = 100,
        maxLevel = 8,
        specialAbilities = {'stealth', 'small_game_hunt'}
    },
    wolf = {
        enabled = false,             -- Deshabilitado por defecto
        models = {'a_c_wolf', 'a_c_wolf_medium'},
        basePrice = 500,
        maxLevel = 12,
        specialAbilities = {'pack_hunt', 'intimidate', 'track'},
        requiresPermission = true    -- Permiso de admin requerido
    }
}
```

### Configuración de Habilidades de Compañeros
```lua
Config.Abilities = {
    hunt = {
        enabled = true,
        cooldown = 300,              -- 5 minutos de cooldown
        successRate = 0.7,           -- 70% de tasa de éxito base
        experienceGain = 25
    },
    guard = {
        enabled = true,
        alertRadius = 15.0,          -- Alertar jugador dentro de 15 unidades
        threatDetection = true,
        alertSound = true
    },
    fetch = {
        enabled = true,
        maxDistance = 100.0,         -- Distancia máx de traer
        itemTypes = {'all'},         -- Elementos que pueden ser traídos
        cooldown = 10
    }
}
```

## 🎮 Configuración de Mini-Juegos

### Habilitar/Deshabilitar Mini-Juegos
```lua
Config.MiniGames = {
    treasureHunt = {
        enabled = true,
        cooldown = 1800,             -- 30 minutos de cooldown
        maxRewards = 3,              -- Máx recompensas por búsqueda
        difficultyLevels = {'easy', 'medium', 'hard'}
    },
    fetchGame = {
        enabled = true,
        cooldown = 60,               -- 1 minuto de cooldown
        maxDistance = 50.0,
        experienceGain = 10
    },
    agility = {
        enabled = true,
        requiresSetup = true,        -- Admin debe colocar cursos de agilidad
        timeLimit = 120,             -- 2 minutos límite de tiempo
        experienceGain = 15
    }
}
```

### Configuración de Recompensas
```lua
Config.Rewards = {
    treasureHunt = {
        common = {'cash', 5, 25},    -- Tipo, mín, máx
        uncommon = {'item', 'gold_nugget', 1},
        rare = {'item', 'jewelry_emerald_ring', 1}
    },
    training = {
        experienceMultiplier = 1.5,  -- 1.5x XP para entrenamiento
        bondingBonus = 0.1,          -- 10% bonificación de vínculo
        cooldownReduction = 0.9      -- 10% reducción de cooldown
    }
}
```

## 🔧 Guía de Troubleshooting

### Problemas Comunes y Soluciones

**Problema: Los compañeros no aparecen**
```bash
# Revisar dependencias
ensure ox_lib
ensure ox_target
ensure rsg-core

# Verificar conexión de base de datos
/check mysql

# Revisar consola para errores
[ERROR] [oxmysql] Conexión falló
```

**Problema: Rendimiento pobre con muchos compañeros**
```lua
-- Reducir complejidad IA
Config.EnhancedAI.PerformanceMode = 'performance'
Config.Performance.MaxActiveCompanions = 10
Config.Performance.AIUpdateInterval = 4000
```

**Problema: Errores de base de datos**
```sql
-- Revisar estructura de tabla
DESCRIBE player_companions;
DESCRIBE companion_memory;
DESCRIBE companion_coordination;

-- Arreglar datos corruptos
DELETE FROM player_companions WHERE companiondata = '{}';
```

### Modo Debug
Habilitar modo debug para logging detallado:
```lua
Config.Debug = true
```

Comandos de debug:
```bash
/pet_debug ai [companion_id]      # Debug comportamiento IA
/pet_debug performance             # Mostrar métricas de rendimiento
/pet_debug database               # Revisar conectividad de base de datos
/pet_debug memory [player_id]     # Mostrar uso de memoria
```

### Monitoreo de Rendimiento
```lua
Config.Monitoring = {
    EnableMetrics = true,           -- Habilitar rastreo de rendimiento
    LogPerformance = false,         -- Log a archivo
    AlertThreshold = 100,           -- Alertar si tiempo de respuesta > 100ms
    AutoOptimize = true             -- Ajustes automáticos de rendimiento
}
```

## 📊 Estadísticas del Servidor y Analíticas

### Analíticas Integradas
```bash
# Ver estadísticas de compañeros del servidor
/pet_admin analytics

# Exportar datos para análisis
/pet_admin export [timeframe]

# Reportes de rendimiento
/pet_admin performance report
```

### Eventos Personalizados para Integración
```lua
-- Eventos de servidor que puedes conectar
RegisterServerEvent('hdrp-companions:server:companionSpawned')
RegisterServerEvent('hdrp-companions:server:companionDismissed')
RegisterServerEvent('hdrp-companions:server:companionLevelUp')
RegisterServerEvent('hdrp-companions:server:companionDied')

-- Eventos de cliente
RegisterNetEvent('hdrp-companions:client:updateCompanionData')
RegisterNetEvent('hdrp-companions:client:playAnimation')
RegisterNetEvent('hdrp-companions:client:showNotification')
```

## 🔄 Backup y Mantenimiento

### Backups Automatizados
```lua
Config.Backup = {
    AutoBackup = true,              -- Habilitar backups automáticos
    BackupInterval = 3600,          -- Backups cada hora (segundos)
    BackupLocation = 'backups/',    -- Directorio de backup
    KeepBackups = 7,                -- Mantener últimos 7 backups
    CompressBackups = true          -- Comprimir archivos de backup
}
```

### Programa de Mantenimiento
```bash
# Comandos de mantenimiento semanal
/pet_admin cleanup                 # Remover compañeros inactivos
/pet_admin optimize               # Optimizar tablas de base de datos
/pet_admin backup                 # Backup manual
/pet_admin validate               # Validar integridad de datos
```

### Procedimientos de Actualización
1. **Antes de actualizar**: Siempre respalda tu base de datos
2. **Durante actualización**: Reinicio de servidor usualmente requerido
3. **Después de actualización**: Ejecutar script de validación
4. **Monitorear**: Revisar logs para cualquier problema de migración

## 💡 Mejores Prácticas

### Consejos de Configuración de Servidor
1. **Empezar Conservador**: Comenzar con modo performance, actualizar según necesidad
2. **Monitorear Uso de Recursos**: Vigilar memory leaks o uso alto de CPU
3. **Backups Regulares**: Backups automáticos diarios previenen pérdida de datos
4. **Rollouts Graduales**: Probar nuevas características con cuentas de admin primero
5. **Feedback de Jugadores**: Escuchar reportes de jugadores sobre comportamiento de compañeros

### Recomendaciones de Seguridad
1. **Actualizaciones Regulares**: Mantener el recurso actualizado a la última versión
2. **Control de Acceso**: Limitar comandos de admin a staff confiable
3. **Seguridad de Base de Datos**: Usar contraseñas fuertes y conexiones seguras
4. **Monitoreo**: Configurar alertas para actividad inusual de compañeros
5. **Logs de Auditoría**: Mantener logs de acciones de admin y actividades de jugadores

---

*Para soporte adicional, revisa el script de validación en `scripts/validate_fixes.lua` o consulta la sección de troubleshooting.*