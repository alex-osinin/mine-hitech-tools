local fluxLib = {}
local component = require "component"
local flux = component.flux_storage
local prefixes = { "k", "M", "G" }

function fluxLib.getInputEnergy()
    return flux.getEnergyInfo().energyInput
end

function fluxLib.format(rf, precision)
    local prefix = ""
    for i = 1, #prefixes do
        if (rf < 1024) then
            break
        end
        prefix = prefixes[i];
        rf = rf / 1000;
    end
    local formattedRf = string.format("%." .. precision .. "f", rf)
        :gsub("%.?0+$", "")
    return formattedRf .. " " .. prefix .. "Rf/t"
end

function fluxLib.formatDouble(rf)
    return fluxLib.format(rf, 3)
end

function fluxLib.formatInt(rf)
    return fluxLib.format(rf, 0)
end

function fluxLib.getName()
    return flux.getNetworkInfo().name
end

return fluxLib
