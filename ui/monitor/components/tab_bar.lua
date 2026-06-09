-- Верхняя строка вкладок
local tabBar = {}

local config = require(_G.PROGRAM .. "_config")
local gui = require("ui.monitor.monitor_gui")
local colors = require("util.colors")

local W = config.screen.width
local ROW = 1

local TABS = {
    { id = "overview", label = "OVERVIEW" },
}

local hitboxes = {}

function tabBar.draw(activeId)
    gui.rectangle(1, ROW, W, 1, colors.bgCard) -- фон полоски
    hitboxes = {}
    local x = 2
    for _, tab in ipairs(TABS) do
        local w = #tab.label + 2
        if tab.id == activeId then
            gui.rectangle(x, ROW, w, 1, colors.accentCoolant) -- подсветка активной
            gui.text(x + 1, ROW, tab.label, colors.bgScreen, colors.accentCoolant)
        else
            gui.text(x + 1, ROW, tab.label, colors.textMuted, colors.bgCard)
        end
        hitboxes[#hitboxes + 1] = { x0 = x, x1 = x + w, id = tab.id }
        x = x + w + 1
    end
end

function tabBar.hit(x, y)
    if y ~= ROW then return nil end
    for _, hb in ipairs(hitboxes) do
        if x >= hb.x0 and x < hb.x1 then return hb.id end
    end
    return nil
end

return tabBar
