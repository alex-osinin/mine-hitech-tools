local lib = {}
local component = require("component")
local unicode = require("unicode")
local term = require("term")
local colors = require("util.colors")
local gpu = component.gpu

local defaultBackground = colors.black;
local defaultForeground = colors.white;
local currentBackground = defaultBackground;
local currentForeground = defaultForeground;

function lib.setForeground(color)
    local newColor = color or defaultForeground
    if newColor ~= currentForeground then
        gpu.setForeground(newColor)
        currentForeground = newColor
    end
end

function lib.setBackground(color)
    local newColor = color or defaultBackground
    if newColor ~= currentBackground then
        gpu.setBackground(newColor)
        currentBackground = newColor
    end
end

local function resetColors()
    gpu.setBackground(defaultBackground)
    gpu.setForeground(defaultForeground)
end

function lib.init(w, h)
    term.clear()
    gpu.setResolution(w or 104, h or 31)
    resetColors()
end

function lib.text(x, y, text, color)
    lib.setForeground(color)
    gpu.set(x, y, text)
end

function lib.label(x, y, label)
    lib.setForeground(label.color)
    gpu.set(x, y, label.text)
end

function lib.rectangle(x, y, w, h, color) --filled rectangle
    lib.setBackground(color)
    gpu.fill(x, y, w, h, ' ')
end

function lib.hFill(x, y, w, symbol, color)
    lib.setForeground(color)
    gpu.fill(x, y, w, y, symbol)
end

function lib.vFill(x, y, h, symbol, color)
    lib.setForeground(color)
    gpu.fill(x, y, x, h, symbol)
end

function lib.fill(x, y, w, h, symbol, color)
    lib.setForeground(color)
    gpu.fill(x, y, w, h, symbol)
end

function lib.line(type, x, y, h, color) -- линия горизонт/вертикаль
    lib.setForeground(color)
    if type == "y" then
        gpu.fill(x, y + 1, 1, h - 2, "|")
    end
    if type == "x" then
        gpu.fill(x + 1, y, h - 2, 1, "=")
    end
end

function lib.frame(x, y, w, h, color)
    lib.setForeground(color)
    gpu.set(x, y, "╔")
    gpu.set(x, y + h, "╚")
    gpu.set(x + w, y, "╗")
    gpu.set(x + w, y + h, "╝")
    gpu.fill(x + 1, y, w - 1, 1, "═")
    gpu.fill(x + 1, y + h, w - 1, 1, "═")
    gpu.fill(x, y + 1, 1, h - 1, "║")
    gpu.fill(x + w, y + 1, 1, h - 1, "║")
end

function lib.button(x, y, text, bcolor, tcolor)
    lib.setForeground(bcolor)
    local h = 2
    local w = 3 + unicode.len(text)
    lib.frame(x, y, w, h, bcolor)
    lib.setForeground(tcolor)
    gpu.set(x + 2, y + 1, text)
end

function lib.progressBar(x, y, segmentCount, value, maxValue, prefix, suffix)
    if not value or not maxValue then
        gpu.set(x, y, (prefix or "") .. string.rep("·", segmentCount) .. (suffix or ""))
        return
    end
    if value < 0 then value = 0 end
    if value > maxValue then value = maxValue end

    local filled = math.floor((value / maxValue) * segmentCount + 0.000001)
    if filled > segmentCount then filled = segmentCount end

    local bar = string.rep("=", filled) .. string.rep("·", segmentCount - filled)
    gpu.set(x, y, (prefix or "") .. bar .. (suffix or ""))
end

function lib.allocateBuffer(w, h)
    return { index = gpu.allocateBuffer(w, h), width = w, height = h}
end

function lib.activateBuffer(buffer)
    gpu.setActiveBuffer(buffer.index)
    lib.fill(1, 1, buffer.width, buffer.height, " ")
end

function lib.drawBuffer(destX, destY, buffer)
    gpu.setActiveBuffer(0)
    gpu.bitblt(0, destX, destY, buffer.width, buffer.height, buffer.index, 1, 1)
    resetColors()
end

return lib
