local service = {}
local components = require("util.components")
local fluxStorage

function service.init()
    fluxStorage = components.requireComponent("flux_storage")
end

function service.getName()
    return fluxStorage.getNetworkInfo().name
end

local function getInputEnergy()
    return fluxStorage.getEnergyInfo().energyInput
end

function service.updateState(state)
    state.energy.input = getInputEnergy()
end

return service
