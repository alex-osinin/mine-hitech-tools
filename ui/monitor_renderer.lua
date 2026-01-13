local renderer = {}
local config = require("config")
local gui = require("ui.monitor_gui")

local reactorService = require("service.reactor_service")

local tps = require("service.tps_counter")
local colors = require("util.colors")
local formatter = require("util.formatter")

local W, H = config.screen.width, config.screen.height

function renderer.initUI(log)
    log.info("Инициализация UI...")
    gui.init(W, H, colors.white, colors.black)

    local frameColor = 0x3F3ACA
    -- рамка для реакторов
    gui.frame(1, 1, W - 1, 19, frameColor)
    gui.text(4, 1, "[Реакторы]", colors.cyan)
    gui.text(W - 20, 18, 'Работают:')
    gui.text(W - 20, 19, 'Без топлива:')
    gui.text(4, 18, 'Выход:')
    gui.text(4, 19, 'Жидкость:')

    --local miniFrame W, H = 78, 31
    -- рамка для сети
    gui.frame(1, H - 10, math.floor(W / 2) - 1, 10, frameColor)
    gui.text(4, 21, "[Инфо]", colors.cyan)
    gui.text(4, 23, "Имя сети:", colors.green)
    gui.text(4, 25, "Энергия:", colors.green)
    gui.text(4, 27, "TPS:", colors.green)

    -- рамка радара
    gui.frame(math.floor(W / 2) + 1, H - 10, math.floor(W / 2) - 1, 10, frameColor)
    gui.text(math.floor(W / 2) + 4, 21, "[Радар]", colors.cyan)

    gui.text(4, 31, "[orange_juice_]", colors.blue)
    log.info("Инициализация UI завершена")
end

local function displayReactorStatus(reactorNumber, reactorState)
    local backgroundColor = reactorService.colorizeReactorState(reactorState)
    local startX, startY = 4, 4
    local index = reactorNumber - 1
    local x = startX + index % 10 * 7
    local y = startY + math.floor(index / 10) * 3
    gui.rectangle(x, y, 2, 1, backgroundColor)
    local reactorStr = tostring(reactorNumber)
    if reactorNumber < 10 then
        reactorStr = ' ' .. reactorStr
    end
    gui.text(x, y - 1, reactorStr)
end

local function renderReactors(state)
    local data = state.reactors.summary;
    gui.text(W - 7, 18, data.working .. "/" .. data.total .. "  ")
    gui.text(W - 7, 19, data.idle .. "/" .. data.total .. "  ")

    gui.text(11, 18, string.format("%-15s", formatter.toDisplaySize(data.energy, 3, "Rf/t")))
    gui.text(20, 19, string.format("%-10s", formatter.toDisplaySize(state.reactors.liquid, 1)))

    local statuses = state.reactors.statuses or {}
    for i = 1, math.min(#statuses, 6) do
        displayReactorStatus(statuses[i].number, statuses[i].state)
    end
end

local function renderEnergy(state)
    local networkName = string.format("%-37s", state.energy.networkName or "")
    gui.text(14, 23, networkName, colors.green)
    local formattedEnergy = string.format("%-37s", formatter.toDisplaySize(state.energy.input, 3, "Rf/t"))
    gui.text(14, 25, formattedEnergy, colors.green)
end

local function renderTPS(state)
    local formattedTps = state.tps.value and string.format("%-37.1f", state.tps.value) or "-"
    gui.text(14, 27, formattedTps, tps.colorizeTPS(state.tps.value))
end

local function renderRadar(state)
    for i = 1, config.radar.maxUsers do
        local player = string.format("%-37s", state.radar.players[i] or "")
        gui.text(math.floor(W / 2) + 4, i + 22, player, colors.red)
    end
end

function renderer.render(state)
    renderReactors(state)
    renderEnergy(state)
    renderTPS(state)
    renderRadar(state)
end

function renderer.debug(symbol)
    gui.text(W - 1, 2, symbol, colors.red)
end

return renderer
