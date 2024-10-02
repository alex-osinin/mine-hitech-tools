local formatter = {}
local prefixes = { "k", "M", "G", "T" }

function formatter.toDisplaySize(size, precision, unit)
    precision = precision or 0
    local prefix = ""
    for i = 1, #prefixes do
        if (size < 1000) then
            break
        end
        prefix = prefixes[i];
        size = size / 1000;
    end
    local formatted = string.format("%." .. precision .. "f", size)
        :gsub("%.?0+$", "")
    if unit then
        return formatted .. " " .. prefix .. unit
    else
        return formatted .. prefix
    end
end

return formatter
