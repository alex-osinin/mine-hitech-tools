local service = {}

local reactorRenderer = require("ui.reactor_renderer")
local reactorService = require("service.reactor_service")

local function isClickInsideButton(clickX, clickY, buttonX, buttonY, buttonW, buttonH)
    return clickX >= buttonX and clickX <= buttonX + buttonW - 1
        and clickY >= buttonY and clickY <= buttonY + buttonH - 1
end

local function handleReactorButtons(x, y, state)
    local reactorButtonW, reactorButtonH = 5, 1
    for i, pos in ipairs(reactorRenderer.reactorPanelStartPositions) do
        local buttonX, buttonY = pos.x + 9, pos.y
        if isClickInsideButton(x, y, buttonX, buttonY, reactorButtonW, reactorButtonH) then
            reactorService.toggleReactor(state.reactors.data[i], true)
            return true
        end
    end
    return false
end

function service.handle(x, y, state)
    handleReactorButtons(x, y, state)
end

return service
