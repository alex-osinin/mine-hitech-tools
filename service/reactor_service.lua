local service = {}

local storageService = require("service.storage_service")

local config = require(_G.PROGRAM .. "_config")
local components = require("util.components")

local ReactorState = {
    WORKING = 3,
    IDLE = 2,
    STOPPED_MANUALLY = 1,
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

local function getManagedReactors(reactorsData)
    local managed = {}
    for _, reactor in ipairs(reactorsData.data) do
        if reactor.cooling and reactor.cooling.type == CoolingType.LIQ and reactor.state ~= ReactorState.STOPPED_MANUALLY then
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
        if service.stopReactors(getManagedReactors(reactorsData)) then
            log.warn("Coolant low: stopping liquid-cooled reactors.")
        end
    elseif currentLiquidCount >= coolingSettings.recommended then
        if service.startReactors(getManagedReactors(reactorsData)) then
            log.info("Coolant sufficient: starting liquid-cooled reactors.")
        end
    end
end

local function startComponent(reactorComponent)
    if reactorComponent and not reactorComponent.hasWork() then
        return reactorComponent.activate()
    end
    return false
end

function service.startReactor(reactorData)
    local started = startComponent(reactorComponents[reactorData.number])
    if started then
        reactorData.state = ReactorState.WORKING
    end
    return started
end

function service.startReactors(reactorsData)
    local startedAny = false
    for _, reactorData in ipairs(reactorsData) do
        if service.startReactor(reactorData) then
            startedAny = true
        end
    end
    return startedAny
end

local function stopComponent(reactorComponent)
    if reactorComponent and reactorComponent.hasWork() then
        return reactorComponent.deactivate()
    end
    return false
end

function service.stopReactor(reactorData, manual)
    local stopped = stopComponent(reactorComponents[reactorData.number])
    if stopped then
        reactorData.state = manual and ReactorState.STOPPED_MANUALLY or ReactorState.STOPPED
    end
    return stopped
end

function service.stopReactors(reactorsData, manual)
    local stoppedAny = false
    for _, reactorData in ipairs(reactorsData) do
        if service.stopReactor(reactorData, manual) then
            stoppedAny = true
        end
    end
    return stoppedAny
end

function service.toggleReactor(reactorData, manual)
    local currentState = reactorData and reactorData.state
    if currentState == ReactorState.WORKING then
        service.stopReactor(reactorData, manual)
    elseif currentState == ReactorState.STOPPED or currentState == ReactorState.STOPPED_MANUALLY then
        service.startReactor(reactorData)
    end
end

local function getState(reactor, oldState)
    if not components.isConnected(reactor) then
        return ReactorState.ERROR
    elseif reactor.hasWork() then
        if reactor.getEnergyGeneration() > 0 then
            return ReactorState.WORKING
        else
            return ReactorState.IDLE
        end
    else
        return oldState == ReactorState.STOPPED_MANUALLY and ReactorState.STOPPED_MANUALLY or ReactorState.STOPPED
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
    return math.floor(maxRemainingTime / divisor), math.floor(maxTotalTime / divisor)
end

local function getReactorData(reactor, number, stats, oldData)
    local success, state = pcall(getState, reactor, oldData and oldData.state)
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
    elseif state == ReactorState.STOPPED or state == ReactorState.STOPPED_MANUALLY then
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

local function getReactorsData(oldState)
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
        local newData = getReactorData(reactorComponents[i], i, stats, oldState and oldState.data[i])
        table.insert(data, newData)
    end
    return { stats = stats, data = data }
end

function service.updateState(state)
    state.reactors = getReactorsData(state.reactors)

    local currentCoolantCount = storageService.getItemQuantity(coolantItem)
    state.reactors.stats.coolant.available = currentCoolantCount
end

return service
