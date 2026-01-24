local renderer = {}
local config = require("config")
local gui = require("ui.monitor_gui")

local buffer = gui.allocateBuffer(46, 7)

function renderer.renderRadarSection(state)
    gui.activateBuffer(buffer)
    local maxPerColumn = 7
    for i = 1, config.radar.maxUsers do
        local rawName = state.radar.players[i] or ""
        local player = rawName:sub(1, 22)
        local column = math.floor((i - 1) / maxPerColumn)
        gui.text(column == 0 and 1 or 25, (i - 1) % maxPerColumn + 1, player)
    end
    gui.drawBuffer(56, 23, buffer)
end

return renderer
