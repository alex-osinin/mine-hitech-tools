local fluxLib = {}
local component = require "component"
local flux = component.flux_storage

function fluxLib.getInputEnergy()
    return flux.getEnergyInfo().energyInput
end

function fluxLib.getName()
    return flux.getNetworkInfo().name
end

return fluxLib
