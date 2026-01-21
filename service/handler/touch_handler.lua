local service = {}

local config = require("config")
local reactorRenderer = require("ui.reactor_renderer")
local reactorService = require("service.reactor_service")

local permissions = config.chatbox.permissions or {}

local function register(clickX, clickY, buttonX, buttonY, buttonW, buttonH)
    return clickX >= buttonX and clickX <= buttonX + buttonW - 1
        and clickY >= buttonY and clickY <= buttonY + buttonH - 1
end

function service.handle(x, y, state, log)
    log.info(string.format("click %d %d", x, y))
    local buttonW, buttonH = 5, 1
    for i, pos in ipairs(reactorRenderer.reactorPanelStartPositions) do
        local buttonX, buttonY = pos.x + 9, pos.y
        if register(x, y, buttonX, buttonY, buttonW, buttonH) then
            log.info(string.format("тык реактор %d %d %d %d %d", i, buttonX, buttonY, pos.x, pos.y))
            local reactorData = state.reactors.data[i]
            if reactorData and reactorData.state then
                if reactorData.state == reactorService.ReactorState.WORKING then
                    reactorService.stopReactorByData(reactorData, true)
                elseif reactorData.state == reactorService.ReactorState.STOPPED
                        or reactorData.state == reactorService.ReactorState.STOPPED_MANUALLY then
                    reactorService.startReactorByData(reactorData)
                end
            end
        end
    end
end

return service
