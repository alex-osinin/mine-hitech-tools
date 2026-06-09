-- Детальный экран одного реактора (открывается кликом по карточке)
local view = {}

local unicode = require("unicode")
local gui = require("ui.monitor.monitor_gui")
local colors = require("util.colors")
local config = require(_G.PROGRAM .. "_config")
local nav = require("ui.monitor.nav")
local reactorRender = require("ui.monitor.reactor_renderer")
local reactorService = require("service.reactor_service")
local ReactorState = reactorService.ReactorState

local W, H = config.screen.width, config.screen.height

local toggleHit, backHit -- хитбоксы кнопок

local function findReactor(state, number)
    for _, r in ipairs(state.reactors.data or {}) do
        if r.number == number then return r end
    end
    return nil
end

-- увеличенная картинка реактора 16×10 (плиты ████ + стержни ▌▌▌▌ ▒▒▒▒ ▐▐▐▐)
local function drawBigReactor(x, y, d)
    local plate = string.rep("█", 16)
    gui.text(x, y, plate, colors.white)
    gui.text(x, y + 1, plate, colors.white)
    for row = y + 2, y + 7 do
        gui.text(x, row, "▌▌▌▌", d.columnColor)
        gui.text(x + 12, row, "▐▐▐▐", d.columnColor)
        gui.text(x + 6, row, string.rep(d.coreSymbol, 4), colors.accentTemp)
    end
    gui.text(x, y + 8, plate, colors.white)
    gui.text(x, y + 9, plate, colors.white)
end

-- поле "Ключ:  значение" с паддингом значения (затирает старое, без мигания)
local function field(x, y, key, label)
    gui.text(x, y, key, colors.textMuted)
    gui.text(x + 10, y, string.format("%-24s", label.text), label.color)
end

local function drawButton(x, y, label, fg, bg)
    local text = " " .. label .. " "
    local w = unicode.len(text)
    gui.rectangle(x, y, w, 1, bg)
    gui.text(x, y, text, fg, bg)
    return { x0 = x, x1 = x + w, y = y }
end

local function insideHit(hit, x, y)
    return hit and y == hit.y and x >= hit.x0 and x < hit.x1
end

function view.onEnter(state)
    local n = state.ui.detailReactor or "?"
    gui.panel(1, 3, W, H - 3, "REACTOR  #" .. n, colors.bgFrame, colors.teal)
end

function view.render(state)
    local r = findReactor(state, state.ui.detailReactor)
    if not r then return end
    local d = reactorRender.deriveCard(r)
    local isErr = r.state == ReactorState.ERROR

    drawBigReactor(4, 5, d)

    local cx = 24
    if isErr then
        gui.text(cx, 7, string.format("%-30s", "НЕ ОТВЕЧАЕТ (DISCONNECTED)"), colors.statusError)
    else
        field(cx, 5, "Cooling", d.coolingTypeLabel)
        field(cx, 6, "Level", d.levelLabel)
        field(cx, 7, "Power", d.powerLabel)
        field(cx, 8, "Temp", d.tempLabel)
        field(cx, 9, "Coolant", d.coolantLabel)
        gui.text(cx, 10, "Rods", colors.textMuted)
        gui.text(cx + 10, 10, string.format("%-24s", d.rodsLabel.text .. "  (" .. d.rodsPercentLabel.text .. ")"), d.rodsLabel.color)
    end

    -- доп. поле под тип схемы (заглушка — определение по компонентам позже)
    gui.text(cx, 12, "Scheme", colors.textMuted)
    gui.text(cx + 10, 12, "—  (определение по компонентам: TODO)", colors.textMuted)

    -- кнопки управления
    local on = r.state == ReactorState.WORKING or r.state == ReactorState.IDLE
    toggleHit = drawButton(cx, 15, on and "Выключить" or "Включить", colors.bgScreen,
        on and colors.statusWarn or colors.statusOn)
    backHit = drawButton(toggleHit.x1 + 2, 15, "‹ Назад", colors.textSecondary, colors.bgFrame)
end

function view.onTouch(x, y, state)
    if insideHit(backHit, x, y) then
        nav.back(state)
        return true
    end
    if insideHit(toggleHit, x, y) then
        local r = findReactor(state, state.ui.detailReactor)
        if r then reactorService.toggleReactor(r, true) end
        return true
    end
    return false
end

return view
