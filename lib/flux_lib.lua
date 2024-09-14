local fluxLib = {}
local component = require "component"
local flux = component.flux_controller

function fluxLib.getInputEnergy()
    local arr = {}
    for i = 1, 50 do
        table.insert(arr, flux.getEnergyInfo().energyInput)
        os.sleep(0.05)
    end
    local freq = {}
    for i = 1, #arr do
        if freq[arr[i]] == nil then
            freq[arr[i]] = 1
        else
            freq[arr[i]] = freq[arr[i]] + 1
        end
    end
    local max_freq = 0
    local max_val = nil
    for k, v in pairs(freq) do
        if v > max_freq then
            max_freq = v
            max_val = k
        end
    end
    return max_val
end

function fluxLib.formatDouble(rf)
    if (rf <= 0 or rf / 1000 <= 1) then
        return string.format("%.3f", tostring(rf)) .. " Rf/t"
    elseif rf / 1000000 >= 1 then
        return string.format("%.3f", tostring(rf / 1000000)) .. " MRf/t"
    else
        return string.format("%.1f", tostring(rf / 1000)) .. " kRf/t"
    end
end

function fluxLib.formatInt(rf)
    if (rf <= 0 or rf / 1000 <= 1) then
        return string.format("%d", math.floor(rf)) .. " Rf/t"
    elseif rf / 1000000 >= 1 then
        return string.format("%d", math.floor(rf / 1000000)) .. " MRf/t"
    else
        return string.format("%d", math.floor(rf / 1000)) .. " kRf/t"
    end
end

function fluxLib.getName()
    return flux.getNetworkInfo().name
end

return fluxLib
