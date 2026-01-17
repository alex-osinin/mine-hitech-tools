local service = {}

local storageService = require("service.storage_service")

local config = require("config")
local components = require("util.components")

local ReactorState = {
    WORKING = 2,
    IDLE = 1,
    STOPPED = 0,
    ERROR = -1
}
service.ReactorState = ReactorState
local CoolingType = {
    AIR = 0,
    LIQ = 1
}
service.CoolingType = CoolingType

local reactorComponents = {}

local coolantItem = config.reactors.cooling.item
local coolingSettings = config.reactors.cooling.limits

function service.init(log)
    reactorComponents = components.findAll("htc_reactors_nuclear_reactor", log)
end

local function getManagedReactors()
    local managed = {}
    for _, reactor in ipairs(reactorComponents) do
        if components.isConnected(reactor) and reactor.isActiveCooling() then
            table.insert(managed, reactor)
        end
    end
    return managed
end

function service.controlReactors(reactorsData, log)
    if reactorsData.stats.byCoolingType.liquid == 0 then
        return
    end

    local currentLiquidCount = reactorsData.stats.coolant.available
    if currentLiquidCount < coolingSettings.minimum then
        if service.stopAll(getManagedReactors()) then
            log.warn("Coolant low: stopping liquid-cooled reactors.")
        end
    elseif currentLiquidCount >= coolingSettings.recommended then
        if service.startAll(getManagedReactors()) then
            log.info("Coolant sufficient: starting liquid-cooled reactors.")
        end
    end
end

local function startReactor(reactor)
    if reactor and not reactor.hasWork() then
        return reactor.activate()
    end
    return false
end

function service.startAll(managedReactors)
    local startedAny = false
    for _, reactor in ipairs(managedReactors or reactorComponents) do
        if startReactor(reactor) then
            startedAny = true
        end
    end
    return startedAny
end

local function stopReactor(reactor)
    if reactor and reactor.hasWork() then
        return reactor.deactivate()
    end
    return false
end

function service.stopAll(managedReactors)
    local stoppedAny = false
    for _, reactor in ipairs(managedReactors or reactorComponents) do
        if stopReactor(reactor) then
            stoppedAny = true
        end
    end
    return stoppedAny
end

local function getState(reactor)
    if not components.isConnected(reactor) then
        return ReactorState.ERROR
    elseif reactor.hasWork() then
        if reactor.getEnergyGeneration() > 0 then
            return ReactorState.WORKING
        else
            return ReactorState.IDLE
        end
    else
        return ReactorState.STOPPED
    end
end

local function getMaxDecayRodTime(reactor, isLiquidCooled)
    local rodsStatuses = reactor.getAllFuelRodsStatus()
    if not rodsStatuses then
        return nil
    end

    local maxTotalTime = -1
    local maxRemainingTime = -1
    for _, rodStatus in pairs(rodsStatuses) do
        local remainingTime = rodStatus.fuel or rodStatus[6]
        local totalTime = rodStatus.maxFuel or rodStatus[8]

        -- Сначала ищем максимальное общее время распада для случаев, когда несколько типов стержней
        if totalTime > maxTotalTime then
            maxTotalTime = totalTime
            maxRemainingTime = remainingTime
        -- При равном общем времени выбираем с большим оставшимся
        elseif totalTime == maxTotalTime and remainingTime > maxRemainingTime then
            maxRemainingTime = remainingTime
        end
    end

    if maxTotalTime < 0 then
        return nil
    end
    local divisor = isLiquidCooled and 2 or 1
    return math.floor(maxRemainingTime / divisor), math.floor(maxTotalTime/ divisor)
end

local function getReactorData(reactor, number, stats)
    local success, state = pcall(getState, reactor)
    if not success or state == ReactorState.ERROR then
        return {
            number = number,
            state = state
        }
    end
    local energy = reactor.getEnergyGeneration()
    if state == ReactorState.WORKING then
        stats.byState.working = stats.byState.working + 1
        stats.energy = stats.energy + energy
    elseif state == ReactorState.IDLE then
        stats.byState.idle = stats.byState.idle + 1
    elseif state == ReactorState.STOPPED then
        stats.byState.stopped = stats.byState.stopped + 1
    end
    local coolingType = reactor.isActiveCooling() and CoolingType.LIQ or CoolingType.AIR
    local coolantConsume = reactor.getFluidCoolantConsume()
    if coolingType == CoolingType.LIQ then
        stats.byCoolingType.liquid = stats.byCoolingType.liquid + 1
        stats.coolant.consumption = stats.coolant.consumption + coolantConsume
    else
        stats.byCoolingType.air = stats.byCoolingType.air + 1
    end
    local rodDecayRemaining, rodDecayTotal = getMaxDecayRodTime(reactor, coolingType == CoolingType.LIQ)

    return {
        number = number,
        state = state,
        level = reactor.getReactorLevel(),
        energy = energy,
        temperature = reactor.getTemperature(),
        fuel = {
            remainingTime = rodDecayRemaining,
            totalTime = rodDecayTotal
        },
        cooling = {
            type = coolingType,
            consume = coolantConsume
        }
    }
end

local function getReactorsData()
    local stats = {
        byState = {
            working = 0,
            idle = 0,
            stopped = 0
        },
        byCoolingType = {
            air = 0,
            liquid = 0
        },
        total = #reactorComponents,
        energy = 0,
        coolant = {
            available = 0,
            consumption = 0
        }
    }
    local data = {}
    for i = 1, #reactorComponents do
        table.insert(data, getReactorData(reactorComponents[i], i, stats))
    end
    return { stats = stats, data = data }
end

function service.updateState(state)
    state.reactors = getReactorsData()

    local currentCoolantCount = storageService.getItemQuantity(coolantItem)
    state.reactors.stats.coolant.available = currentCoolantCount
end

return service
