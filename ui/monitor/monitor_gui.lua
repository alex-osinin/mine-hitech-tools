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
    lib.setBackground(defaultBackground)
    lib.setForeground(defaultForeground)
end

-- загрузка кастомной палитры в 16 слотов GPU T3
function lib.applyPalette(palette)
    if not palette or not gpu.setPaletteColor then return end
    for i = 1, math.min(#palette, 16) do
        pcall(gpu.setPaletteColor, i - 1, palette[i])
    end
end

function lib.init(w, h, defBackground, defForeground)
    term.clear()
    defaultBackground = defBackground or defaultBackground;
    defaultForeground = defForeground or defaultForeground;
    gpu.setResolution(w or 104, h or 31)
    lib.applyPalette(colors.palette)
    resetColors()
    gpu.fill(1, 1, w, h, " ")
end

function lib.text(x, y, text, color, bg)
    lib.setForeground(color)
    if bg then
        local prev = currentBackground
        lib.setBackground(bg)
        gpu.set(x, y, text .. "")
        lib.setBackground(prev)
    else
        gpu.set(x, y, text .. "")
    end
end

function lib.label(x, y, label, bg)
    lib.setForeground(label.color)
    if bg then
        local prev = currentBackground
        lib.setBackground(bg)
        gpu.set(x, y, label.text .. "")
        lib.setBackground(prev)
    else
        gpu.set(x, y, label.text .. "")
    end
end

function lib.rectangle(x, y, w, h, color)
    local prev = currentBackground
    lib.setBackground(color)
    gpu.fill(x, y, w, h, ' ')
    lib.setBackground(prev)
end

function lib.hFill(x, y, w, symbol, color)
    lib.setForeground(color)
    gpu.fill(x, y, w, y, symbol)
end

function lib.vFill(x, y, h, symbol, color)
    lib.setForeground(color)
    gpu.fill(x, y, x, h, symbol)
end

-- заливка ГЛИФОМ: fg — цвет символа, bg (опц.) — разовый фон под ним
function lib.fill(x, y, w, h, symbol, fg, bg)
    lib.setForeground(fg)
    if bg then
        local prev = currentBackground
        lib.setBackground(bg)
        gpu.fill(x, y, w, h, symbol)
        lib.setBackground(prev)
    else
        gpu.fill(x, y, w, h, symbol)
    end
end

-- стереть прямоугольник пробелами; bg (опц.) — разовый фон, иначе текущий ambient
function lib.clear(x, y, w, h, bg)
    if bg then
        local prev = currentBackground
        lib.setBackground(bg)
        gpu.fill(x, y, w, h, " ")
        lib.setBackground(prev)
    else
        gpu.fill(x, y, w, h, " ")
    end
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

function lib.frame(x, y, w, h, color) -- w,h — размеры в ячейках (как rectangle)
    local x2, y2 = x + w - 1, y + h - 1
    lib.setForeground(color)
    gpu.set(x, y, "╔")
    gpu.set(x, y2, "╚")
    gpu.set(x2, y, "╗")
    gpu.set(x2, y2, "╝")
    gpu.fill(x + 1, y, w - 2, 1, "═")
    gpu.fill(x + 1, y2, w - 2, 1, "═")
    gpu.fill(x, y + 1, 1, h - 2, "║")
    gpu.fill(x2, y + 1, 1, h - 2, "║")
end

-- одинарная рамка с заголовком, вписанным в верхнюю границу: ┌─ TITLE ──┐
-- w,h — размеры в ячейках (как rectangle)
function lib.panel(x, y, w, h, title, frameColor, titleColor)
    local x2, y2 = x + w - 1, y + h - 1
    lib.setForeground(frameColor)
    gpu.set(x, y, "┌")
    gpu.set(x2, y, "┐")
    gpu.set(x, y2, "└")
    gpu.set(x2, y2, "┘")
    gpu.fill(x + 1, y, w - 2, 1, "─")
    gpu.fill(x + 1, y2, w - 2, 1, "─")
    gpu.fill(x, y + 1, 1, h - 2, "│")
    gpu.fill(x2, y + 1, 1, h - 2, "│")
    if title then
        lib.setForeground(titleColor or frameColor)
        gpu.set(x + 2, y, " " .. title .. " ")
    end
end

function lib.button(x, y, text, bcolor, tcolor)
    lib.setForeground(bcolor)
    local h = 2
    local w = 3 + unicode.len(text)
    lib.frame(x, y, w + 1, h + 1, bcolor) -- frame теперь в размерах: +1 к старым offset'ам
    lib.setForeground(tcolor)
    gpu.set(x + 2, y + 1, text)
end

-- горизонтальный бар на восьмушках
function lib.bar(x, y, w, value, maxValue, fillColor, emptyColor)
    local frac = 0
    if value and maxValue and maxValue > 0 then
        frac = value / maxValue
    end
    if frac < 0 then frac = 0 elseif frac > 1 then frac = 1 end
    local backup = currentBackground
    lib.setForeground(emptyColor or colors.slate)
    lib.setBackground(emptyColor or colors.slate)
    gpu.fill(x, y, w, 1, " ")
    local full = math.floor(frac * w)
    lib.setForeground(fillColor)
    if full > 0 then
        gpu.fill(x, y, full, 1, "█")
    end
    if full < w then
        local e = math.floor((frac * w - full) * 8 + 0.5)
        if e >= 8 then
            gpu.set(x + full, y, "█")
        elseif e >= 1 then
            gpu.set(x + full, y, ({ "▏", "▎", "▍", "▌", "▋", "▊", "▉" })[e])
        end
    end
    lib.setBackground(backup)
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
    local index = gpu.allocateBuffer(w, h)
    -- ВАЖНО: у каждого VRAM-буфера своя палитра. Если не синхронизировать её с экранной,
    -- bitblt перенесёт ИНДЕКСЫ цветов, и экран переинтерпретирует их своей палитрой
    local prev = (gpu.getActiveBuffer and gpu.getActiveBuffer()) or 0
    gpu.setActiveBuffer(index)
    lib.applyPalette(colors.palette)
    gpu.setActiveBuffer(prev)
    return { index = index, width = w, height = h }
end

function lib.activateBuffer(buffer, backgroundColor)
    gpu.setActiveBuffer(buffer.index)
    if backgroundColor then
        lib.setBackground(backgroundColor)
        lib.clear(1, 1, buffer.width, buffer.height)
    end
end

function lib.drawBuffer(destX, destY, buffer)
    gpu.setActiveBuffer(0)
    gpu.bitblt(0, destX, destY, buffer.width, buffer.height, buffer.index, 1, 1)
    resetColors()
end

function lib.cleanup()
    -- fixme проблемы с накоплением буферов
    gpu.freeAllBuffers()
    term.clear()
end

return lib
