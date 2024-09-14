local zlib = {}
local component = require "component"
--local computer = require "computer"
--local serialization = require "serialization"
--local internet = require "internet"
local unicode = require "unicode"
local gpu = component.gpu
local colors = require "lib.colors"

local defaultBackground = colors.black;
local defaultForeground = colors.white;

local function resetColors()
    gpu.setBackground(defaultBackground)
    gpu.setForeground(defaultForeground)
end

local function setForeground(color)
    if color ~= nil then
        gpu.setForeground(color)
    end
end

local function setBackground(color)
    if color ~= nil then
        gpu.setBackground(color)
    end
end

local function setResolution(w, h)
    gpu.setResolution(w or 45, h or 15)
end

function zlib.init(defForeground, defBackground) -- рамка
    defaultForeground = defForeground
    defaultBackground = defBackground
end

function zlib.mainFrame(w, h, text, frameColor) -- рамка
    setResolution(w, h)
    setForeground(frameColor)
    gpu.set(1, 1, "╔")
    gpu.set(1, h, "╚")
    gpu.set(w, 1, "╗")
    gpu.set(w, h, "╝")
    gpu.fill(2, 1, w - 2, 1, "═")
    gpu.fill(2, h, w - 2, 1, "═")
    gpu.fill(1, 2, 1, h - 2, "║")
    gpu.fill(w, 2, 1, h - 2, "║")
    gpu.set(w / 2 - (unicode.len(text) / 2) - 2, 1, "[" .. text .. "]")
    gpu.set(w / 2, h, "[orange_juice_]")
    resetColors()
end

function zlib.text(x, y, text, color) --text
    setForeground(color)
    gpu.set(x, y, text)
    resetColors()
end

--function zlib.hFill(x, y, w, symbol, color) --fill
--    setForeground(color)
--    gpu.fill(x, y, x + w, y, symbol)
--    resetColors()
--end
--
--function zlib.vFill(x, y, h, symbol, color) --fill
--    setForeground(color)
--    gpu.fill(x, y, x, y, symbol)
--    resetColors()
--end

function zlib.line(type, x, y, h, color) -- линия горизонт/вертикаль
    setForeground(color)
    if type == "y" then
        gpu.fill(x, y + 1, 1, h - 2, "|")
    end
    if type == "x" then
        gpu.fill(x + 1, y, h - 2, 1, "=")
    end
    resetColors()
end

function zlib.cube(x, y, w, h, color)
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

function zlib.bar(x, y, fill, w, type, color) -- прогрессбар
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

function zlib.button(x, y, text, bcolor, tcolor) --кнопка
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

return zlib
