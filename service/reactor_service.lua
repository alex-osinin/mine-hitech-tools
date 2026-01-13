local service = {}

local storageService = require("service.storage_service")

local config = require("config")
local components = require("util.components")
local colors = require("util.colors")

local ReactorState = {
    WORKING = 2,
    IDLE = 1,
    STOPPED = 0,
    ERROR = -1
}

local reactorComponents = {}

local coolingLiquidItem = config.reactors.cooling.item
local coolingSettings = config.reactors.cooling.limits

function service.init(log)
    reactorComponents = components.findAll("htc_reactors_nuclear_reactor", log)
end

function service.getReactorsCount()
    return #reactorComponents
end

local function powerControl(currentLiquidCount)
    if currentLiquidCount < coolingSettings.minimum then
        --Выключение при малом количестве охлаждения
        service.stopAll()
    elseif currentLiquidCount >= coolingSettings.recommended then
        --Включение при достаточном количестве охлаждения
        service.startAll()
    end
end

local function startReactor(reactor)
    if reactor and not reactor.hasWork() then
        reactor.activate()
    end
end

function service.startAll()
    for i = 1, #reactorComponents do
        startReactor(reactorComponents[i])
    end
end

local function stopReactor(reactor)
    if reactor and reactor.hasWork() then
        reactor.deactivate()
    end
end

function service.stopAll()
    for i = 1, #reactorComponents do
        stopReactor(reactorComponents[i])
    end
end

local function getState(reactor)
    if reactor == nil then
        return ReactorState.ERROR
    elseif reactor.hasWork() then
        if reactor.getEnergyGeneration() > 0 then
            return ReactorState.WORKING, reactor.getEnergyGeneration()
        else
            return ReactorState.IDLE
        end
    else
        return ReactorState.STOPPED
    end
end

local function getReactorsData()
    local result = {
        summary = { working = 0, idle = 0, total = #reactorComponents, energy = 0 },
        statuses = {}
    }

    for i = 1, #reactorComponents do
        local reactor = reactorComponents[i]

        local success, state, output = pcall(getState, reactor)
        if not success then
            state = ReactorState.ERROR
            output = 0
        end

        if state == ReactorState.WORKING then
            result.summary.working = result.summary.working + 1
            result.summary.energy = result.summary.energy + (output or 0)
        elseif state == ReactorState.IDLE then
            result.summary.idle = result.summary.idle + 1
        end

        table.insert(result.statuses, {
            number = i,
            state = state,
            energy = output or 0
        })
    end
    return result
end

function service.updateState(state)
    state.reactors = getReactorsData()

    local currentLiquidCount = storageService.getItemQuantity(coolingLiquidItem)
    state.reactors.liquid = currentLiquidCount

    if currentLiquidCount ~= -1 then
        powerControl(currentLiquidCount)
    end
end

function service.colorizeReactorState(reactorState)
    if reactorState == ReactorState.WORKING then
        return colors.green
    elseif reactorState == ReactorState.IDLE then
        return colors.yellow
    elseif reactorState == ReactorState.STOPPED then
        return colors.grey
    else
        return colors.red
    end
end

return service
