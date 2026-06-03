local renderer = {}
local config = require(_G.PROGRAM .. "_config")
local gui = require("ui.monitor.monitor_gui")
local reactorRender = require("ui.monitor.reactor_renderer")
local radarRender = require("ui.monitor.radar_renderer")

local colors = require("util.colors")
local formatter = require("util.formatter")

local W, H = config.screen.width, config.screen.height

function renderer.initUI(log)
    log.info("Initializing UI...")
    gui.init(W, H, colors.darkblue, colors.white)

    local frameColor = 0x2B3A52
    -- панель реакторов (заголовок вписан в рамку)
    gui.panel(1, 1, W - 1, 21, "REACTORS", frameColor, colors.cyan)
    log.info("UI initialization completed")
end

function renderer.cleanup()
    gui.cleanup()
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
    -- энергия / TPS / радар пока не отрисовываем — в работе только панель реакторов
end

function renderer.debug(stage)
    if config.dev and config.dev.enabled then
        gui.text(W - 12, H, string.format("%-10s", stage), colors.red)
    end
end

return renderer
