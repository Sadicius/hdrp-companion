# 🐾 HDRP-Companion - Sistema de Mascotas RedM

## 📖 Documentación Completa del Sistema

Bienvenido a la documentación oficial del sistema de compañeros/mascotas para RedM con RSGCore. Este sistema ha sido completamente refactorizado siguiendo las mejores prácticas de desarrollo.

## 📚 Índice de Documentación

### 🏗️ Arquitectura del Sistema
- [Arquitectura General](architecture.md) - Diseño modular y patrones implementados
- [Estado del Sistema](companion-state.md) - Gestión centralizada del estado
- [Sistema de IA](companion-ai.md) - Inteligencia artificial avanzada

### 🔧 Módulos Principales  
- [Cliente Optimizado](client-optimized.md) - Cliente principal refactorizado
- [Gestión de Prompts](prompt-system.md) - Sistema de prompts optimizado
- [Sistema de Customización](customization-system.md) - Personalización completa

### ⚙️ Configuración y Uso
- [Instalación](installation.md) - Guía de instalación paso a paso
- [Configuración](configuration.md) - Opciones de configuración detalladas
- [Comandos y Eventos](commands-events.md) - Lista completa de comandos

### 🚀 Características Técnicas
- [Optimizaciones](optimizations.md) - Mejoras de rendimiento implementadas
- [Integración RSGCore](rsgcore-integration.md) - Integración con el framework
- [Base de Datos](database.md) - Estructura de la base de datos

### 🎯 Funcionalidades
- [Funciones de Compañeros](companion-functions.md) - Todas las funciones disponibles
- [Sistema de Niveles](leveling-system.md) - Progresión y experiencia
- [Personalización](customization-features.md) - 63 props y opciones

## 🌟 Características Principales

### ✅ **Sistema Modular Optimizado**
- **Arquitectura limpia** separando responsabilidades
- **Gestión de estado centralizada** con CompanionState
- **Sistema de IA avanzado** usando natives RedM específicos
- **Gestión de prompts optimizada** con threading eficiente

### ✅ **Integración Completa**
- **RSGCore Framework** - Integración nativa completa
- **ox_lib** - UI moderna y utilidades avanzadas
- **oxmysql** - Base de datos optimizada
- **lib.onCache** - Sistema de cache de alto rendimiento

### ✅ **Funcionalidades Avanzadas**
- **63 Props de Customización** - Juguetes, cuernos, collares, medallas, máscaras, cigarros
- **Sistema de Niveles** - Progresión basada en XP con 10 niveles
- **IA Inteligente** - 8 tipos de personalidad diferentes
- **Combate Avanzado** - Ataque, rastreo, caza de animales
- **Persistencia Completa** - Todo se guarda automáticamente

### ✅ **Optimizaciones de Rendimiento**
- **lib.onCache** - Elimina llamadas nativas repetitivas
- **Threading Optimizado** - Intervalos apropiados (100ms-1000ms)
- **Cleanup Automático** - Gestión de memoria eficiente
- **Variables Globales** - Patrón RSGCore correcto (sin require)

## 🎮 Tipos de Compañeros

### 🐕 **Perros**
- **Modelos Disponibles**: Husky, Pastor Alemán, Labrador, Retriever
- **Personalidades**: Agresivo, Guardián, Tímido, Evitativo
- **Habilidades**: Ataque, rastreo, caza, recuperación

### 🔥 **Características Especiales**
- **Modo Defensivo** - Protege automáticamente al jugador
- **Sistema de Hambre/Sed** - Necesidades realistas
- **Bonding System** - Relación que mejora con el tiempo
- **Inventario Persistente** - Alforjas para almacenamiento

## 🛠️ Tecnologías Utilizadas

### **Frontend (Cliente)**
- **CfxLua** - Lenguaje principal optimizado para RedM
- **ox_lib** - Librería moderna para UI y utilities
- **RedM Natives** - APIs nativas específicas de Red Dead Redemption

### **Backend (Servidor)**  
- **RSGCore Framework** - Framework base del servidor
- **oxmysql** - Driver de base de datos optimizado
- **MySQL/MariaDB** - Sistema de persistencia

### **Arquitectura**
- **Patrón Modular** - Separación clara de responsabilidades
- **Event-Driven** - Comunicación basada en eventos
- **State Management** - Gestión centralizada del estado
- **Cache System** - Optimización de rendimiento

## 📈 Métricas del Proyecto

- **+4,000 líneas** de código refactorizado
- **63 props** de customización activados
- **8 personalidades** de IA implementadas
- **10 niveles** de progresión
- **6 módulos** principales optimizados
- **100% compatible** con RSGCore y ox_lib

## 🔧 Estado del Desarrollo

### ✅ **Completado**
- [x] Refactorización completa de arquitectura
- [x] Sistema modular implementado
- [x] Integración RSGCore/ox_lib completa
- [x] Sistema de customización activado
- [x] Optimizaciones de rendimiento
- [x] Sistema de cache lib.onCache
- [x] Documentación completa

### 🚀 **Listo para Producción**
El sistema está completamente optimizado y listo para ser usado en servidores de producción RedM con RSGCore.

---

## 📞 Soporte

Para más información, consulta los archivos de documentación específicos en esta carpeta o revisa el código fuente comentado.

**Versión:** 4.6.0 Optimizada  
**Framework:** RSGCore para RedM  
**Compatibilidad:** ox_lib, oxmysql  
**Estado:** Producción Ready ✅