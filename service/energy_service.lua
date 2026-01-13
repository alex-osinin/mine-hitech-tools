local service = {}
local components = require("util.components")
local fluxStorage

function service.init(log)
    fluxStorage = components.requireComponent("flux_storage", log)
end

local function getName()
    return fluxStorage.getNetworkInfo().name
end

local function getInputEnergy()
    return fluxStorage.getEnergyInfo().energyInput
end

function service.updateState(state)
    state.energy.networkName = getName()
    state.energy.input = getInputEnergy()
end

return service
