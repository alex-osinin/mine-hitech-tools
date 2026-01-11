local tpsLib = {}
local fs = require("filesystem")
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
    local allTPS = 0
    local realTimeOld, realTimeNew, realTimeDiff
    for _ = 1, num do
        realTimeOld = time()
        os.sleep(timeConstant)
        realTimeNew = time()
        realTimeDiff = realTimeNew - realTimeOld
        allTPS = allTPS + 20000 * timeConstant / realTimeDiff
    end
    local avgTPS = allTPS / num
    return avgTPS < 20 and avgTPS or 20
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

return tpsLib
