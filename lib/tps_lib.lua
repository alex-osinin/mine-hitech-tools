local tpsLib = {}
local fs = require("filesystem")
--local c = require("component")
local timeConstant = 2
local num = 3
local file = "/tmp/DEFG"

local function time()
    local f = io.open(file, "w")
    f:write("test")
    f:close()
    return (fs.lastModified(file))
end

function tpsLib.calc()
    local avgTPS = 0
    local realTimeOld
    local realTimeNew
    local realTimeDiff
    for i = 1, num do
        realTimeOld = time()
        os.sleep(timeConstant)
        realTimeNew = time()
        realTimeDiff = realTimeNew - realTimeOld
        avgTPS = avgTPS + 20000 * timeConstant / realTimeDiff
    end
    return avgTPS / num
end

function tpsLib.colorByTPS(tps)
    local color
    if tps <= 10 then
        color = COLORS.red
        --gpu.setForeground(0xcc4c4c)
    elseif tps <= 15 then
        color = COLORS.yellow
        --gpu.setForeground(0xf2b233)
    elseif tps > 15 then
        color = COLORS.green
        --gpu.setForeground(0x7fcc19)
    end
    return color
end

function tpsLib.format(tps)
    return string.format("%.1f", tostring(tps))
end

return tpsLib
