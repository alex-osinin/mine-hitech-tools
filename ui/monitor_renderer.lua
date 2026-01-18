local renderer = {}
local config = require("config")
local gui = require("ui.monitor_gui")
local reactorRender = require("ui.reactor_renderer")
local radarRender = require("ui.radar_renderer")

local colors = require("util.colors")
local formatter = require("util.formatter")

local W, H = config.screen.width, config.screen.height

function renderer.initUI(log)
    log.info("Initializing UI...")
    gui.init(W, H)

    local frameColor = 0x3F3ACA
    -- рамка для реакторов
    gui.frame(1, 1, W - 1, 19, frameColor)
    gui.text(4, 1, "[Reactors]")

    --local miniFrame W, H = 78, 31
    -- рамка для сети
    gui.frame(1, H - 10, math.floor(W / 2) - 1, 10, frameColor)
    gui.text(4, 21, "[Info]")
    gui.text(4, 23, "Network:")
    gui.text(4, 25, "Energy:")
    gui.text(4, 27, "Buffer:")
    gui.text(4, 29, "TPS:")

    -- рамка радара
    gui.frame(math.floor(W / 2) + 1, H - 10, math.floor(W / 2) - 1, 10, frameColor)
    gui.text(math.floor(W / 2) + 4, 21, "[Radar]")

    gui.text(80, 31, "[made by orange_juice_]", frameColor)
    log.info("UI initialization completed")
end

local function renderEnergy(state)
    local networkName = string.format("%-37s", state.energy.networkName or "")
    gui.text(13, 23, networkName)
    local formattedEnergy = string.format("%-37s", formatter.toDisplaySize(state.energy.input, 3, "Rf/t"))
    gui.text(13, 25, formattedEnergy, colors.lightgreen)
    local formattedBuffer = string.format("%-37s", formatter.toDisplaySize(state.energy.buffer, 3, "Rf"))
    gui.text(13, 27, formattedBuffer, colors.lightgreen)
end

local function getTPSLabel(tps)
    local formattedTps = tps and string.format("%-37.1f", tps) or "-"
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
    return { text = formattedTps, color = color }
end

local function renderTPS(state)
    local tpsLabel = getTPSLabel(state.tps.value)
    gui.label(13, 29, tpsLabel)
end

function renderer.render(state)
    reactorRender.renderReactorSection(state)
    renderEnergy(state)
    renderTPS(state)
    radarRender.renderRadarSection(state)
end

function renderer.debug(stage)
    if config.dev and config.dev.enabled then
        gui.text(W - 8, 2, string.format("%-7s", stage), colors.red)
    end
end

return renderer
