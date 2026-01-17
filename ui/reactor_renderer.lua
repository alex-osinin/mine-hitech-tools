local renderer = {}
local config = require("config")
local gui = require("ui.monitor_gui")

local reactorService = require("service.reactor_service")

local colors = require("util.colors")
local formatter = require("util.formatter")

local buffer = gui.allocateBuffer(26, 6)
local startRenderPositions = {
    { x = 8,  y = 3 },
    { x = 40, y = 3 },
    { x = 72, y = 3 },
    { x = 8,  y = 11 },
    { x = 40, y = 11 },
    { x = 72, y = 11 }
}

local function getStateLabel(state)
    if state == reactorService.ReactorState.WORKING then
        return { "ON", "▒", colors.green }
    elseif state == reactorService.ReactorState.IDLE then
        return { "ON", " ", colors.green }
    elseif state == reactorService.ReactorState.STOPPED then
        return { "OFF", " ", colors.gray }
    else
        return { "ERR", "X", colors.red }
    end
end

local function getCoolingTypeLabel(cooling)
    local coolingType = cooling and cooling.type or "-"
    if coolingType == reactorService.CoolingType.LIQ then
        return { "LIQ", colors.cyan }
    elseif coolingType == reactorService.CoolingType.AIR then
        return { "AIR", colors.lightblue }
    else
        return { "" }
    end
end

local function getCoolantSummaryLabel(currentLiquidCount)
    local currentLiquidCountStr = formatter.toDisplaySize(currentLiquidCount, 1);
    local recommendedLiquidCountStr = formatter.toDisplaySize(config.reactors.cooling.limits.recommended, 1);

    local stateColor
    local coolingSettings = config.reactors.cooling.limits
    if currentLiquidCount < coolingSettings.minimum then
        stateColor = colors.red
    elseif currentLiquidCount < coolingSettings.recommended then
        stateColor = colors.yellow
    else
        stateColor = colors.cyan
    end
    return { currentLiquidCountStr .. "/" .. recommendedLiquidCountStr, stateColor }
end

local function formatDurationMinutes(seconds)
    if not seconds then
        return "-"
    end
    local t = formatter.timeToStr("*t", seconds)
    return string.format("%dh %02dm", t.hour, t.min)
end

--Example:
--  AIR    [ON]   LVL:1
--███████  Power: 120 kRf/t
-- ▌▌▒▐▐   Temp:  9998 °C
-- ▌▌▒▐▐   Cool:  1200 mB/s
-- ▌▌▒▐▐   Rods:  0h 15m
--███████  [======·········]
local function renderReactorCell(reactorData)
    local pos = startRenderPositions[reactorData.number]

    local statusLabel = getStateLabel(reactorData.state)
    local coolingTypeLabel = getCoolingTypeLabel(reactorData.cooling)
    local level = reactorData.level or "-"
    local power = reactorData.energy and formatter.toDisplaySize(reactorData.energy, 3, "Rf/t") or "-"
    local coolant = reactorData.cooling and reactorData.cooling.consume or "-"
    local temp = reactorData.temperature and reactorData.temperature .. " °C" or "-"
    local rods = formatDurationMinutes(reactorData.durability)

    local w, h = 26, 6
    gui.setActiveBuffer(buffer)
    gui.fill(1, 1, w, h, " ")

    gui.text(10, 1, string.format("[%s]", statusLabel[1]), statusLabel[3])
    gui.text(17, 1, "LVL:" .. level)
    gui.text(3, 1, coolingTypeLabel[1], coolingTypeLabel[2])

    gui.text(10, 2, "Power:")
    gui.text(17, 2, power, colors.lightgreen)
    gui.text(10, 3, "Temp:")
    gui.text(17, 3, temp, colors.orange)
    if reactorData.cooling and reactorData.cooling.type == reactorService.CoolingType.LIQ then
        gui.text(10, 4, "Cool:")
        gui.text(17, 4, coolant .. " mB/s", colors.cyan)
    end
    gui.text(10, 5, "Rods:")
    gui.text(17, 5, rods)

    gui.text(1, 2, "███████")
    gui.text(2, 3, "▌▌ ▐▐", coolingTypeLabel[2])
    gui.text(2, 4, "▌▌ ▐▐", coolingTypeLabel[2])
    gui.text(2, 5, "▌▌ ▐▐", coolingTypeLabel[2])
    gui.text(1, 6, "███████")

    --todo считать максимальный ресурс стержней от типа
    gui.progressBar(12, 6, 15, reactorData.durability, 4 * 60 * 60, "[", "]")

    local coreSymbol = statusLabel[2]
    gui.text(4, 3, coreSymbol, colors.brightorange)
    gui.text(4, 4, coreSymbol, colors.brightorange)
    gui.text(4, 5, coreSymbol, colors.brightorange)

    gui.drawBuffer(1, 1, w, h, pos.x, pos.y, buffer)
end

local function renderSummary(stats)
    gui.text(8, 19, "Output:")
    gui.text(16, 19, string.format("%-10s", formatter.toDisplaySize(stats.energy, 3, "Rf/t")), colors.lightgreen)
    if stats.byCoolingType.liquid > 0 then
        gui.text(72, 19, "Consumption:")
        gui.text(85, 19, string.format("%-10s", stats.coolant.consumption .. " mB/s"), colors.cyan)

        --fixme разобраться в чем измерять жидкость
        gui.text(40, 19, "Coolant:")
        local coolantInfoLabel = getCoolantSummaryLabel(stats.coolant.available)
        gui.text(49, 19, string.format("%-10s", coolantInfoLabel[1]), coolantInfoLabel[2])
    end
end

function renderer.renderReactorSection(state)
    renderSummary(state.reactors.stats)

    local data = state.reactors.data or {}
    for i = 1, math.min(#data, 6) do
        renderReactorCell(data[i])
    end
end

return renderer
