local chatPermissions = {
    ["orange_juice_"] = true,
}
local lapisSettings = {
    lapisMinimum = 50000,
    lapisRecomended = 900000,
    lapisPrecraftSize = 50000
}

local W, H = 104, 31

local updateReactorsTimer = 65
local updateTPSTimer = 5
local updateRadarTimer = 1
local updateEnergyTimer = 10
local maxRadarUsers = 7

-- ONLY FOR DEVELOPING
-- todo добавить конфиг и условие
package.loaded["handler.chat_handler"] = nil
package.loaded["lib.system_lib"] = nil
package.loaded["lib.void_reactor_lib"] = nil
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
local term = require("term")
local thread = require("thread")
local chatMessageHandler = require("handler.chat_handler")
local formatter = require("lib.formatter")
local system = require("lib.system_lib")
local reactorLib = require("lib.void_reactor_lib")
local fluxLib = require("lib.flux_lib")
local tpsLib = require("lib.tps_lib")
local radarLib = require("lib.radar_lib")
local meLib = require("lib.me_lib")
local gui = require("lib.monitor_gui_lib")
local colors = require("lib.colors")
-- add buffering
local chatbot = component.chat_box
local lapisBlockItem = { name = 'minecraft:lapis_block', damage = 0 }

local function init()
    -- todo проверять все необходимые компоненты и писать что-то
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
    gui.text(W - 20, 18, 'Включено:')
    gui.text(W - 20, 19, 'Без топлива:')
    gui.text(4, 18, 'Выход:')
    gui.text(4, 19, 'Блоки лазурита:')

    --local miniFrameW, H = 78, 31
    -- рамка для сети
    gui.frame(1, H - 10, W / 2 - 1, 10, frameColor)
    gui.text(4, 21, "[Инфо]", colors.cyan)
    gui.text(4, 23, "Имя сети: " .. fluxLib.getName(), colors.green)
    gui.text(4, 25, "Энергия:", colors.green)
    gui.text(4, 27, "TPS:", colors.green)

    -- рамка радара
    gui.frame(W / 2 + 1, H - 10, W / 2 - 1, 10, frameColor)
    gui.text(W / 2 + 4, 21, "[Радар]", colors.cyan)

    gui.text(4, 31, "[orange_juice_]", colors.blue)
end

local function updateReactors()
    gui.fill(3, 3, 74, 13, ' ')
    local working, producesEnergy, energy = reactorLib.showReactorStatuses()

    gui.text(W - 7, 18, working .. '/' .. reactorLib.getReactorsCount() .. "  ")
    gui.text(W - 7, 19, working - producesEnergy .. '/' .. working .. "  ")

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
        gui.text(W / 2 + 4, i + 22, player, colors.red)
    end
end

local function exit()
    term.clear()
    os.exit(0)
end

init()
local chatHandlerThread = thread.create(chatMessageHandler.run, chatPermissions, exit)
reactorLib.stopAll()

system.run(updateReactors, updateReactorsTimer)
system.run(updateRadar, updateRadarTimer)
system.run(updateTPS, updateTPSTimer)
system.run(updateEnergy, updateEnergyTimer)

while true do
    event.pull(0.5)
    if keyboard.isKeyDown(keyboard.keys.delete) or chatHandlerThread:status() == "dead" then
        exit()
    end
end
