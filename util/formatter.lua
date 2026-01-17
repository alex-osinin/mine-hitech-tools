local formatter = {}
local prefixes = { "k", "M", "G", "T" }

function formatter.toDisplaySize(size, precision, unit)
    if not size then
        return "-"
    end
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

-- example format='%Y.%m.%d %H:%M:%S'
function formatter.timeToStr(format, time)
    if not format or not time then
        return "-"
    end
    return os.date(format, time)
end

return formatter
