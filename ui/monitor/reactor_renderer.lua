local renderer = {}
local config = require(_G.PROGRAM .. "_config")
local gui = require("ui.monitor.monitor_gui")

local reactorService = require("service.reactor_service")
local ReactorState = reactorService.ReactorState
local CoolingType = reactorService.CoolingType

local colors = require("util.colors")
local formatter = require("util.formatter")

local W = config.screen.width

-- карточка реактора (буфер)
local CARD_W, CARD_H = 38, 8
local buffer = gui.allocateBuffer(CARD_W, CARD_H)

-- сетка 3×2 внутри рамки реакторов
local startRenderPositions = {
    { x = 3, y = 3 }, { x = 42, y = 3 }, { x = 81, y = 3 },
    { x = 3, y = 12 }, { x = 42, y = 12 }, { x = 81, y = 12 }
}
renderer.reactorPanelStartPositions = startRenderPositions

local function getStateRenderInfo(state)
    if state == ReactorState.WORKING then
        return colors.statusOn, "▒"
    elseif state == ReactorState.IDLE then
        return colors.statusWarn, " "
    elseif state == ReactorState.STOPPED
        or state == ReactorState.STOPPED_MANUALLY then
        return colors.statusOff, " "
    else
        return colors.statusError, "X"
    end
end

local function getCoolingTypeLabel(cooling)
    local coolingType = cooling and cooling.type or "-"
    if coolingType == CoolingType.LIQ then
        return { text = "LIQ", color = colors.accentCoolant }
    elseif coolingType == CoolingType.AIR then
        return { text = "AIR", color = colors.accentAir }
    else
        return { text = "", color = colors.accentError }
    end
end

local function getCoolantLabel(cooling)
    local coolingType = cooling and cooling.type or "-"
    if coolingType == CoolingType.LIQ then
        return { text = (cooling.consume or "-") .. " mB/s", color = colors.accentCoolant }
    else
        return { text = "-", color = colors.textMuted }
    end
end

local function getCoolantSummaryLabel(currentLiquidCount)
    local currentLiquidCountStr = formatter.toDisplaySize(currentLiquidCount, 1);
    local recommendedLiquidCountStr = formatter.toDisplaySize(config.reactors.cooling.limits.recommended, 1);

    local stateColor
    local coolingSettings = config.reactors.cooling.limits
    local warning = false
    if currentLiquidCount < coolingSettings.minimum then
        stateColor = colors.statusError
        warning = true
    elseif currentLiquidCount < coolingSettings.recommended then
        stateColor = colors.statusWarn
        warning = true
    else
        stateColor = colors.accentCoolant
    end
    local text = currentLiquidCountStr .. "/" .. recommendedLiquidCountStr .. (warning and " ⚠" or "")
    return { text = text, color = stateColor }
end

local function formatFuelRemainingTime(seconds)
    if not seconds then
        return "-"
    end
    local t = formatter.timeToStr("*t", seconds)
    return string.format("%dh %02dm", t.hour, t.min)
end

-- данные карточки из состояния реактора
local function deriveCard(reactorData)
    local statusColor, coreSymbol = getStateRenderInfo(reactorData.state)
    if reactorData.state == ReactorState.ERROR then
        return {
            statusColor = statusColor,
            columnColor = colors.statusError,
            coreSymbol = coreSymbol
        }
    end

    local level = reactorData.level or "-"
    local power = reactorData.energy and formatter.toDisplaySize(reactorData.energy, 2, "Rf/t") or "-"
    local temperature = reactorData.temperature and (reactorData.temperature .. " °C") or "-"
    local time = formatFuelRemainingTime(reactorData.fuel and reactorData.fuel.remainingTime)
    local coolingTypeLabel = getCoolingTypeLabel(reactorData.cooling)
    -- цвет температуры по значению
    local tempColor = colors.textMuted
    if reactorData.temperature and reactorData.temperature > 0 then
        tempColor = reactorData.temperature >= 8000 and colors.statusError or colors.accentTemp
    end

    -- бар = остаток жизненного цикла стержней в %
    local total = reactorData.fuel and reactorData.fuel.totalTime
    local remaining = reactorData.fuel and reactorData.fuel.remainingTime
    local pct = (total and total > 0 and remaining) and math.floor(remaining / total * 100) or nil
    local fuelColor = colors.statusOn
    if pct then
        if pct < 10 then
            fuelColor = colors.statusError
        elseif pct < 25 then
            fuelColor = colors.statusWarn
        end
    end
    local rodsPercent = pct and (pct .. "%") or "-"

    return {
        statusColor = statusColor,
        columnColor = coolingTypeLabel.color,
        coreSymbol = coreSymbol,
        coolingTypeLabel = coolingTypeLabel,
        levelLabel = { text = level, color = colors.textPrimary },
        powerLabel = { text = power, color = colors.accentEnergy },
        coolantLabel = getCoolantLabel(reactorData.cooling),
        tempLabel = { text = temperature, color = tempColor },
        rodsLabel = { text = time, color = colors.textPrimary },
        rodsPercentLabel = { text = rodsPercent, color = colors.textMuted },
        fuelBar = { remaining = remaining, total = total, color = fuelColor }
    }
end

-- Пример карточки:
-- ▌   AIR    LVL 6
-- ▌ ███████  Power   120 kRf/t
-- ▌  ▌▌▒▐▐   Temp    9998 °C
-- ▌  ▌▌▒▐▐   Cool    -
-- ▌  ▌▌▒▐▐   Rods    0h 15m
-- ▌ ███████  ████████████░░░▏ 62%
local function renderReactorPanel(reactorData)
    local pos = startRenderPositions[reactorData.number]
    if not pos then return end
    local renderData = deriveCard(reactorData)

    gui.activateBuffer(buffer, colors.bgCard)
    -- статус-полоса
    gui.fill(1, 1, 1, CARD_H, "█", renderData.statusColor)
    gui.text(CARD_W - 2, 2, "#" .. reactorData.number)

    -- графика реактора
    gui.text(3, 3, "███████", colors.white)
    for row = 4, 6 do
        gui.text(4, row, "▌▌ ▐▐", renderData.columnColor)
        gui.text(6, row, renderData.coreSymbol, colors.accentTemp)
    end
    gui.text(3, 7, "███████", colors.white)

    if reactorData.state == ReactorState.ERROR then
        gui.text(12, 5, "DISCONNECTED", colors.statusError)
        gui.drawBuffer(pos.x, pos.y, buffer)

        return
    end
    -- заголовок
    gui.label(5, 2, renderData.coolingTypeLabel)
    gui.text(12, 2, "LVL", colors.white)
    gui.label(16, 2, renderData.levelLabel)

    -- данные одной колонкой
    gui.text(12, 3, "Power", colors.textMuted);
    gui.label(20, 3, renderData.powerLabel)
    gui.text(12, 4, "Temp", colors.textMuted);
    gui.label(20, 4, renderData.tempLabel)
    gui.text(12, 5, "Cool", colors.textMuted);
    gui.label(20, 5, renderData.coolantLabel)
    gui.text(12, 6, "Rods", colors.textMuted);
    gui.label(20, 6, renderData.rodsLabel)
    -- бар топлива
    local barW = CARD_W - 18
    local fuelBar = renderData.fuelBar
    gui.text(11, 7, "▕", colors.textMuted)
    gui.bar(12, 7, barW, fuelBar.remaining, fuelBar.total, fuelBar.color)
    gui.text(12 + barW, 7, "▏", colors.textMuted)
    gui.label(13 + barW, 7, renderData.rodsPercentLabel)

    gui.drawBuffer(pos.x, pos.y, buffer)
end

local function renderSummary(stats)
    local y = 21
    if stats.total == 0 then
        gui.fill(2, y, W - 3, 1, " ")
        return
    end
    local third = math.floor((W - 4) / 3) + 1
    -- значения фикс. ширины (%-Ns) затирают старое прямо в ячейках — без очистки всей строки, значит без мигания
    gui.text(3, y, "Output", colors.textMuted)
    gui.text(12, y, string.format("%-18s", formatter.toDisplaySize(stats.energy, 3, "Rf/t")), colors.accentEnergy)
    if stats.byCoolingType.liquid > 0 then
        gui.text(3 + third, y, "Coolant", colors.textMuted)
        local label = getCoolantSummaryLabel(stats.coolant.available)
        gui.text(3 + third + 9, y, string.format("%-16s", label.text), label.color)
        gui.text(3 + 2 * third, y, "Consumption", colors.textMuted)
        gui.text(3 + 2 * third + 13, y, string.format("%-12s", stats.coolant.consumption .. " mB/s"), colors.accentCoolant)
    else
        gui.fill(3 + third, y, W - 3 - third, 1, " ")
    end
end

function renderer.renderReactorSection(state)
    renderSummary(state.reactors.stats)

    local data = state.reactors.data or {}
    for i = 1, math.min(#data, 6) do
        renderReactorPanel(data[i])
    end
end

return renderer
