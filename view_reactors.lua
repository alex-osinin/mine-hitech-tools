local chatPermissions = {
    ["orange_juice_"] = true,
}
local lapisSettings = {
    lapisMinimum = 50000,
    lapisRecomended = 900000,
    lapisPrecraftSize = 50000
}

local W, H = 78, 31

local updateReactorsTimer = 65
local updateTPSTimer = 5
local updateRadarTimer = 1
local updateEnergyTimer = 10
local maxRadarUsers = 7

-- ONLY FOR DEVELOPING
package.loaded["chat_handler"] = nil
package.loaded["lib.system_lib"] = nil
package.loaded["lib.reactor_lib"] = nil
package.loaded["lib.radar_lib"] = nil
package.loaded["lib.me_lib"] = nil
package.loaded["lib.monitor_gui_lib"] = nil
package.loaded["lib.colors"] = nil
package.loaded["lib.flux_lib"] = nil
package.loaded["lib.tps_lib"] = nil
--

local component = require("component")
local event = require("event")
local keyboard = require("keyboard")
local thread = require("thread")
local chatMessageHandler = require("chat_handler")
local formatter = require("lib.formatter")
local system = require("lib.system_lib")
local reactorLib = require("lib.reactor_lib")
local fluxLib = require("lib.flux_lib")
local tpsLib = require("lib.tps_lib")
local radarLib = require("lib.radar_lib")
local meLib = require("lib.me_lib")
local gui = require("lib.monitor_gui_lib")
local colors = require("lib.colors")

local chatbot = component.chat_box
local lapisBlockItem = { name = 'minecraft:lapis_block', damage = 0 }

local function init()
    gui.init(W, H, colors.white, colors.black)
    -- настройка чат бокса
    chatbot.setName("§4Алиса§7§o")
    chatbot.say("§fHello world!")
    radarLib.init()
    reactorLib.loadData()

    local frameColor = 0x3F3ACA
    -- рамка для реакторов
    gui.frame(1, 1, W - 1, 19, frameColor)
    gui.text(4, 1, "[Реакторы]", colors.cyan)
    gui.text(58, 18, 'Включено:')
    gui.text(58, 19, 'Без топлива:')
    gui.text(4, 18, 'Выход:')
    gui.text(4, 19, 'Блоки лазурита:')

    -- рамка для сети
    gui.frame(1, 21, 38, 10, frameColor)
    gui.text(4, 21, "[Инфо]", colors.cyan)
    gui.text(4, 23, "Имя сети: " .. fluxLib.getName(), colors.green)
    gui.text(4, 25, "Энергия:", colors.green)
    gui.text(4, 27, "TPS:", colors.green)

    -- рамка радара
    gui.frame(40, 21, 38, 10, frameColor)
    gui.text(43, 21, "[Радар]", colors.cyan)

    gui.text(4, 31, "[orange_juice_]", colors.blue)
end

local function updateReactors()
    gui.fill(3, 3, 74, 13, ' ')
    local working, producesEnergy, energy = reactorLib.showReactorStatuses()

    gui.text(71, 18, working .. '/' .. reactorLib.getReactorsCount() .. "  ")
    gui.text(71, 19, working - producesEnergy .. '/' .. working .. "  ")

    local currentLapisCount = meLib.getItemQuantity(lapisBlockItem)

    gui.text(11, 18, string.format("%-15s", formatter.toDisplaySize(energy, 3, "Rf/t")))
    gui.text(20, 19, string.format("%-10s", formatter.toDisplaySize(currentLapisCount, 1)))
    if currentLapisCount ~= -1 then
        reactorLib.powerControl(currentLapisCount, lapisSettings)
    end
end

local function updateEnergy()
    local energyInput = fluxLib.getInputEnergy()
    local formattedEnergy = string.format("%-37s", formatter.toDisplaySize(energyInput, 3, "Rf/t"))
    gui.text(14, 25, formattedEnergy, colors.green)
end

local function updateTPS()
    local tps = tpsLib.calc()
    local formattedTps = string.format("%-37.1f", tps)
    gui.text(14, 27, formattedTps, tpsLib.colorByTPS(tps))
end

local function updateRadar()
    local currentPlayers = radarLib.getPlayers(maxRadarUsers)
    for i = 1, maxRadarUsers do
        local player = string.format("%-37s", currentPlayers[i] or "")
        gui.text(45, i + 22, player, colors.red)
    end
end

init()
thread.create(chatMessageHandler.run, chatPermissions)
reactorLib.stopAll()

system.run(updateReactors, updateReactorsTimer)
system.run(updateRadar, updateRadarTimer)
system.run(updateTPS, updateTPSTimer)
system.run(updateEnergy, updateEnergyTimer)

while true do
    event.pull(0.1)
    if keyboard.isKeyDown(keyboard.keys.delete) then
        system.exit()
        break
    end
end
