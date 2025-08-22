-- ================================
-- COMPANION PERFORMANCE MONITOR
-- Advanced metrics system for companion AI optimization
-- ================================

local RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

-- ================================
-- PERFORMANCE METRICS SYSTEM
-- ================================

local PerformanceMonitor = {
    -- Real-time metrics
    metrics = {
        fps = {
            current = 0,
            baseline = 0,
            impact = 0,
            samples = {},
            sampleSize = 30
        },
        memory = {
            current = 0,
            peak = 0,
            baseline = 0,
            companion = 0
        },
        events = {
            total = 0,
            perMinute = 0,
            lastMinute = {},
            errors = 0
        },
        ai = {
            stateChanges = 0,
            tasksQueued = 0,
            tasksCompleted = 0,
            averageTaskTime = 0
        }
    },
    
    -- Configuration
    config = {
        enabled = Config.Debug or false,
        alertThreshold = {
            fpsImpact = 0.5, -- % FPS impact before alert
            memoryUsage = 5.0, -- MB before alert
            errorRate = 0.01 -- % error rate before alert
        },
        sampleInterval = 1000, -- ms between samples
        reportInterval = 60000 -- ms between reports
    },
    
    -- Internal state
    running = false,
    startTime = 0,
    lastReport = 0
}

-- ================================
-- INITIALIZATION
-- ================================

function PerformanceMonitor:Initialize()
    if self.running then return end
    
    self.running = true
    self.startTime = GetGameTimer()
    self.lastReport = self.startTime
    
    -- Establecer baseline
    self:EstablishBaseline()
    
    -- Iniciar monitoring threads
    self:StartMonitoringThreads()
    
    if Config.Debug then
        print('[COMPANION-PERF] Performance monitoring initialized')
    end
end

function PerformanceMonitor:EstablishBaseline()
    -- Medir FPS baseline (sin companion activo)
    local samples = {}
    for i = 1, 10 do
        table.insert(samples, GetFrameTime())
        Wait(100)
    end
    
    local total = 0
    for _, sample in ipairs(samples) do
        total = total + sample
    end
    
    local averageFrameTime = total / #samples
    self.metrics.fps.baseline = 1.0 / averageFrameTime
    
    -- Baseline de memoria
    self.metrics.memory.baseline = collectgarbage('count')
    
    if Config.Debug then
        print(string.format('[COMPANION-PERF] Baseline established - FPS: %.1f, Memory: %.2f MB', 
            self.metrics.fps.baseline, self.metrics.memory.baseline / 1024))
    end
end

-- ================================
-- MONITORING THREADS
-- ================================

function PerformanceMonitor:StartMonitoringThreads()
    -- Thread principal de métricas
    CreateThread(function()
        while self.running do
            self:CollectMetrics()
            self:CheckThresholds()
            Wait(self.config.sampleInterval)
        end
    end)
    
    -- Thread de reportes periódicos
    CreateThread(function()
        while self.running do
            Wait(self.config.reportInterval)
            if self.config.enabled then
                self:GenerateReport()
            end
        end
    end)
end

function PerformanceMonitor:CollectMetrics()
    local currentTime = GetGameTimer()
    
    -- Métricas FPS
    local frameTime = GetFrameTime()
    local currentFPS = 1.0 / frameTime
    
    self.metrics.fps.current = currentFPS
    self.metrics.fps.impact = ((self.metrics.fps.baseline - currentFPS) / self.metrics.fps.baseline) * 100
    
    -- Agregar sample y mantener tamaño
    table.insert(self.metrics.fps.samples, currentFPS)
    if #self.metrics.fps.samples > self.metrics.fps.sampleSize then
        table.remove(self.metrics.fps.samples, 1)
    end
    
    -- Métricas de memoria
    local currentMemory = collectgarbage('count') / 1024 -- Convert to MB
    self.metrics.memory.current = currentMemory
    if currentMemory > self.metrics.memory.peak then
        self.metrics.memory.peak = currentMemory
    end
    
    -- Calcular memoria usada por companion
    self.metrics.memory.companion = currentMemory - self.metrics.memory.baseline / 1024
end

function PerformanceMonitor:CheckThresholds()
    local alerts = {}
    
    -- Check FPS impact
    if self.metrics.fps.impact > self.config.alertThreshold.fpsImpact then
        table.insert(alerts, {
            type = 'fps',
            message = string.format('FPS impact: %.2f%%', self.metrics.fps.impact),
            severity = 'warning'
        })
    end
    
    -- Check memory usage
    if self.metrics.memory.companion > self.config.alertThreshold.memoryUsage then
        table.insert(alerts, {
            type = 'memory',
            message = string.format('Memory usage: %.2f MB', self.metrics.memory.companion),
            severity = 'warning'
        })
    end
    
    -- Check error rate
    local errorRate = self.metrics.events.errors / math.max(self.metrics.events.total, 1)
    if errorRate > self.config.alertThreshold.errorRate then
        table.insert(alerts, {
            type = 'errors',
            message = string.format('Error rate: %.2f%%', errorRate * 100),
            severity = 'error'
        })
    end
    
    -- Procesar alertas
    for _, alert in ipairs(alerts) do
        self:HandleAlert(alert)
    end
end

function PerformanceMonitor:HandleAlert(alert)
    if Config.Debug then
        print(string.format('[COMPANION-PERF] ALERT [%s]: %s', alert.severity:upper(), alert.message))
    end
    
    -- Notificar al jugador si es crítico
    if alert.severity == 'error' then
        lib.notify({
            title = 'Companion Performance Alert',
            description = alert.message,
            type = 'error',
            duration = 5000
        })
    end
    
    -- Log para debugging
    TriggerEvent('rsg-companions:performance:alert', alert)
end

-- ================================
-- EVENT TRACKING
-- ================================

function PerformanceMonitor:TrackEvent(eventType, success, executionTime)
    if not self.running then return end
    
    self.metrics.events.total = self.metrics.events.total + 1
    
    if not success then
        self.metrics.events.errors = self.metrics.events.errors + 1
    end
    
    -- Track por tipo de evento
    if eventType == 'stateChange' then
        self.metrics.ai.stateChanges = self.metrics.ai.stateChanges + 1
    elseif eventType == 'taskQueued' then
        self.metrics.ai.tasksQueued = self.metrics.ai.tasksQueued + 1
    elseif eventType == 'taskCompleted' then
        self.metrics.ai.tasksCompleted = self.metrics.ai.tasksCompleted + 1
        if executionTime then
            -- Calcular average task time (simple moving average)
            self.metrics.ai.averageTaskTime = 
                (self.metrics.ai.averageTaskTime + executionTime) / 2
        end
    end
end

-- ================================
-- REPORTING SYSTEM
-- ================================

function PerformanceMonitor:GenerateReport()
    local currentTime = GetGameTimer()
    local runtime = (currentTime - self.startTime) / 1000 / 60 -- minutes
    
    local report = {
        timestamp = os.date('%Y-%m-%d %H:%M:%S'),
        runtime = string.format('%.1f minutes', runtime),
        fps = {
            current = string.format('%.1f', self.metrics.fps.current),
            baseline = string.format('%.1f', self.metrics.fps.baseline),
            impact = string.format('%.2f%%', self.metrics.fps.impact)
        },
        memory = {
            current = string.format('%.2f MB', self.metrics.memory.current),
            companion = string.format('%.2f MB', self.metrics.memory.companion),
            peak = string.format('%.2f MB', self.metrics.memory.peak)
        },
        events = {
            total = self.metrics.events.total,
            errors = self.metrics.events.errors,
            errorRate = string.format('%.3f%%', 
                (self.metrics.events.errors / math.max(self.metrics.events.total, 1)) * 100)
        },
        ai = {
            stateChanges = self.metrics.ai.stateChanges,
            tasksQueued = self.metrics.ai.tasksQueued,
            tasksCompleted = self.metrics.ai.tasksCompleted,
            averageTaskTime = string.format('%.2f ms', self.metrics.ai.averageTaskTime)
        }
    }
    
    if Config.Debug then
        print('[COMPANION-PERF] === PERFORMANCE REPORT ===')
        print(string.format('Runtime: %s | FPS: %s (-%s) | Memory: %s | Error Rate: %s',
            report.runtime, report.fps.current, report.fps.impact, 
            report.memory.companion, report.events.errorRate))
        print(string.format('AI Events: %d state changes, %d/%d tasks (avg: %s)',
            report.ai.stateChanges, report.ai.tasksCompleted, 
            report.ai.tasksQueued, report.ai.averageTaskTime))
    end
    
    -- Trigger event para otros sistemas
    TriggerEvent('rsg-companions:performance:report', report)
    
    return report
end

-- ================================
-- API PÚBLICA
-- ================================

function PerformanceMonitor:GetCurrentMetrics()
    return {
        fps = {
            current = self.metrics.fps.current,
            impact = self.metrics.fps.impact
        },
        memory = {
            companion = self.metrics.memory.companion
        },
        events = {
            total = self.metrics.events.total,
            errors = self.metrics.events.errors
        }
    }
end

function PerformanceMonitor:IsPerformanceGood()
    return self.metrics.fps.impact < self.config.alertThreshold.fpsImpact and
           self.metrics.memory.companion < self.config.alertThreshold.memoryUsage
end

function PerformanceMonitor:Shutdown()
    self.running = false
    
    if Config.Debug then
        print('[COMPANION-PERF] Performance monitoring shutdown')
        self:GenerateReport() -- Final report
    end
end

-- ================================
-- INTEGRATION HELPERS
-- ================================

-- Helper para wrappear funciones con performance tracking
function PerformanceMonitor:WrapFunction(func, eventType)
    return function(...)
        local startTime = GetGameTimer()
        local success, result = pcall(func, ...)
        local executionTime = GetGameTimer() - startTime
        
        self:TrackEvent(eventType, success, executionTime)
        
        if success then
            return result
        else
            if Config.Debug then
                print(string.format('[COMPANION-PERF] Error in %s: %s', eventType, tostring(result)))
            end
            return nil
        end
    end
end

-- ================================
-- EXPORT PARA OTROS SISTEMAS
-- ================================

-- Hacer disponible globalmente
_G.CompanionPerformanceMonitor = PerformanceMonitor

-- Auto-inicializar si está habilitado
CreateThread(function()
    Wait(1000) -- Esperar a que otros sistemas se inicialicen
    if Config.Debug then
        PerformanceMonitor:Initialize()
    end
end)

-- Cleanup al unload del recurso
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if PerformanceMonitor.running then
            PerformanceMonitor:Shutdown()
        end
    end
end)

if Config.Debug then
    print('[COMPANION-PERF] Performance monitoring system loaded')
end