-- Вкладка Overview
local view = {}

local gui = require("ui.monitor.monitor_gui")
local colors = require("util.colors")
local config = require(_G.PROGRAM .. "_config")
local nav = require("ui.monitor.nav")
local reactorRender = require("ui.monitor.reactor_renderer")

local W = config.screen.width

function view.onEnter(state)
    -- статичный хром: рамка панели (рисуется один раз при входе)
    gui.panel(1, 3, W, 22, "REACTORS", colors.bgFrame, colors.teal)
    gui.panel(1, 25, 41, 9, "ENERGY", colors.bgFrame, colors.teal)
    gui.panel(42, 25, W - 41, 9, "PLAYERS", colors.bgFrame, colors.teal)
end

function view.render(state)
    reactorRender.renderReactorSection(state)
end

function view.onTouch(x, y, state)
    local data = state.reactors.data or {}
    for i, pos in ipairs(reactorRender.reactorCardPositions) do
        local r = data[i]
        if r and x >= pos.x and x < pos.x + reactorRender.CARD_W
            and y >= pos.y and y < pos.y + reactorRender.CARD_H then
            state.ui.detailReactor = r.number
            nav.switchView(state, "detail")
            return true
        end
    end
    return false
end

return view
