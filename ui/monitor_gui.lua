local lib = {}
local component = require("component")
local unicode = require("unicode")
local term = require("term")
local colors = require("util.colors")
local gpu = component.gpu

local defaultBackground = colors.black;
local defaultForeground = colors.white;

local function resetColors()
    gpu.setBackground(defaultBackground)
    gpu.setForeground(defaultForeground)
end

local function setForeground(color)
    if color then
        gpu.setForeground(color)
    end
end

local function setBackground(color)
    if color then
        gpu.setBackground(color)
    end
end

function lib.init(w, h, defForeground, defBackground)
    term.clear()
    gpu.setResolution(w or 104, h or 31)
    defaultForeground = defForeground
    defaultBackground = defBackground
end

function lib.text(x, y, text, color) --text
    setForeground(color)
    gpu.set(x, y, text)
    resetColors()
end

function lib.rectangle(x, y, w, h, color) --filled rectangle
    setBackground(color)
    gpu.fill(x, y, w, h, ' ')
    resetColors()
end

function lib.hFill(x, y, w, symbol, color) --fill
    setForeground(color)
    gpu.fill(x, y, w, y, symbol)
    resetColors()
end

function lib.vFill(x, y, h, symbol, color) --fill
    setForeground(color)
    gpu.fill(x, y, x, h, symbol)
    resetColors()
end

function lib.fill(x, y, w, h, symbol, color) --fill
    setForeground(color)
    gpu.fill(x, y, w, h, symbol)
    resetColors()
end

function lib.line(type, x, y, h, color) -- линия горизонт/вертикаль
    setForeground(color)
    if type == "y" then
        gpu.fill(x, y + 1, 1, h - 2, "|")
    end
    if type == "x" then
        gpu.fill(x + 1, y, h - 2, 1, "=")
    end
    resetColors()
end

function lib.frame(x, y, w, h, color)
    setForeground(color)
    gpu.set(x, y, "╔")
    gpu.set(x, y + h, "╚")
    gpu.set(x + w, y, "╗")
    gpu.set(x + w, y + h, "╝")
    gpu.fill(x + 1, y, w - 1, 1, "═")
    gpu.fill(x + 1, y + h, w - 1, 1, "═")
    gpu.fill(x, y + 1, 1, h - 1, "║")
    gpu.fill(x + w, y + 1, 1, h - 1, "║")
    resetColors()
end

function lib.bar(x, y, fill, w, type, color) -- прогрессбар
    setBackground(0xF0F0F0)
    gpu.fill(x, y - 1, 1, w, "▄")
    gpu.fill(x, y + 1, 1, w, "▄")
    setBackground(color)
    if type == "y" then
        gpu.fill(x, y, w, fill, "▄")
    else
        gpu.fill(x, y, fill, w, "▄")
    end
    resetColors()
end

function lib.button(x, y, text, bcolor, tcolor) --кнопка
    setForeground(bcolor)
    local h = 2
    local w = 3 + unicode.len(text)
    gpu.set(x, y, "╔")
    gpu.set(x, y + h, "╚")
    gpu.set(x + w, y, "╗")
    gpu.set(x + w, y + h, "╝")
    gpu.fill(x + 1, y, w - 1, 1, "═")
    gpu.fill(x + 1, y + h, w - 1, 1, "═")
    gpu.fill(x, y + 1, 1, h - 1, "║")
    gpu.fill(x + w, y + 1, 1, h - 1, "║")
    setForeground(tcolor)
    gpu.set(x + 2, y + 1, text)
    resetColors()
end

return lib
