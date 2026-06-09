-- Диспетчер тача: сначала таб-бар, иначе — активная вью.
local service = {}

local tabBar = require("ui.monitor.components.tab_bar")
local nav = require("ui.monitor.nav")
local monitorRenderer = require("ui.monitor.monitor_renderer")

function service.handle(x, y, state)
    local tab = tabBar.hit(x, y)
    if tab then
        nav.switchView(state, tab)
        return
    end

    local view = monitorRenderer.views[state.ui and state.ui.activeView]
    if view and view.onTouch then
        view.onTouch(x, y, state)
    end
end

return service
