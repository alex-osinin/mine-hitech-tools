-- Роутер вью: рисует хром (таб-бар, подвал) и диспатчит на активную вью
local renderer = {}

local config = require(_G.PROGRAM .. "_config")
local gui = require("ui.monitor.monitor_gui")
local colors = require("util.colors")

local tabBar = require("ui.monitor.components.tab_bar")

local W, H = config.screen.width, config.screen.height

-- реестр вью (id → модуль). touch_handler берёт его отсюда.
local views = {
    overview = require("ui.monitor.views.overview"),
    detail   = require("ui.monitor.views.reactor_detail"),
}
renderer.views = views

function renderer.initUI(log)
    log.info("Initializing UI...")
    gui.init(W, H, colors.bgScreen, colors.textPrimary)
    log.info("UI initialization completed")
end

function renderer.cleanup()
    gui.cleanup()
end

local function drawFooter()
    gui.rectangle(1, H, W, 1, colors.bgCard)
    local author = "made by " .. (config.user and config.user.nick or "")
    gui.text(W - #author - 1, H, author, colors.textMuted, colors.bgCard)
end

local function drawTPS(tps)
    local tpsVal = tps and tps.value
    local tpsStr = tpsVal and string.format("TPS %.1f", tpsVal) or "TPS --.-"
    local tpsColor = tpsVal and tpsVal >= 18 and colors.statusOn
            or tpsVal and tpsVal >= 12 and colors.statusWarn
            or colors.statusError
    gui.text(W - #tpsStr - 1, 1, tpsStr, tpsColor, colors.bgCard)
end

function renderer.render(state)
    state.ui = state.ui or { activeView = "overview", viewChanged = true }
    local view = views[state.ui.activeView] or views.overview

    if state.ui.viewChanged then
        gui.rectangle(1, 2, W, H - 2, colors.bgScreen)
        tabBar.draw(state.ui.activeView)
        drawFooter()
        view.onEnter(state)
        state.ui.viewChanged = false
    end
    -- TPS в правом верхнем углу таб-бара (всегда обновляем)
    drawTPS(state.tps)

    view.render(state)
end

function renderer.debug(stage)
    if config.dev and config.dev.enabled then
        gui.text(2, H, string.format("%-8s", stage), colors.statusError)
    end
end

return renderer
