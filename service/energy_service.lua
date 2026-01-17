local service = {}
local components = require("util.components")
local fluxStorage

function service.init(log)
    fluxStorage = components.requireComponent("flux_storage", log)
end

function service.updateState(state)
    state.energy.networkName = fluxStorage.getNetworkInfo().name
    local energyInfo = fluxStorage.getEnergyInfo()
    state.energy.input = energyInfo.energyInput
    state.energy.buffer = energyInfo.totalBuffer
end

return service
