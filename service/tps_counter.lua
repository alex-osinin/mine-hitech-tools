local service = {}
local time = require("util.time")

local lastUptime = nil
local lastRealTime = nil

local function measureTPS()
    local currentUptime = time.uptime()
    local currentRealTime = time.currentTimeMillis()

    if not lastUptime or not lastRealTime then
        lastUptime = currentUptime
        lastRealTime = currentRealTime
        return nil
    end

    local uptimeDiff = currentUptime - lastUptime
    local realTimeDiff = (currentRealTime - lastRealTime) / 1000
    if realTimeDiff <= 0 then
        return nil
    end

    local tps = (uptimeDiff * 20) / realTimeDiff

    lastUptime = currentUptime
    lastRealTime = currentRealTime

    tps = tps > 20 and 20 or tps
    return math.floor(tps * 10 + 0.5) / 10
end

function service.updateState(state)
    state.tps.value = measureTPS()
end

function service.colorizeTPS(tps)
    local color
    if not tps then
        color = COLORS.white
    elseif tps > 15 then
        color = COLORS.green
    elseif tps > 10 then
        color = COLORS.yellow
    else
        color = COLORS.red
    end
    return color
end

return service
