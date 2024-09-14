local guiLib = {}
local component = require "component"
local glasses = component.glasses

function guiLib.createItem(name, meta, x, y)
    local icon = glasses.addItem2D()
    icon.setItem(name, meta)
    icon.addScale(32, 32, 1)
    icon.addTranslation(x, y, 0)
    return icon
end

function guiLib.createBox(width, height, x, y)
    local box = glasses.addBox2D()
    box.setSize(width, height)
    box.addTranslation(x, y, 0)
    box.addColor(0, 0, 0, 0.3)
    box.addColor(0, 0, 0, 0.3)
    return box
end

function guiLib.createText(x, y)
    local text = glasses.addText2D()
    text.setFont("Monospaced.bold")
    text.setFontSize(15)
    text.addTranslation(x, y, 0)
    --text.addScale(1.5, 1.5, 1)
    return text
end

function guiLib.removeAll()
    glasses.removeAll()
end

return guiLib
