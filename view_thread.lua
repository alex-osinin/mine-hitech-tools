local W, H = 77, 31

local thread = require "thread"
local component = require "component"
local computer = require "computer"
local term = require "term"

local colors = require "lib.colors"
local fluxLib = require "lib.flux_lib"
local gui = require "lib.monitor_gui_lib"
local radarLib = require "lib.radar_lib"
local tpsLib = require "lib.tps_lib"
local chat = component.chat_box

local function init()
    term.clear()
    -- настройка чат бокса
    chat.setName("§4Алиса§7§o")
    chat.say("§fHello world!")
    gui.init(colors.white, colors.black)
    local mainFrameColor = 0x3F3ACA
    gui.mainFrame(W, H, "Region Viwer", mainFrameColor)
    --рамка для сети
    gui.frame(2, 22, 36, 8, mainFrameColor)
    gui.text(4, 22, "[Инфо]", colors.cyan)
    --рамка для процессоров
    gui.frame(2, 2, 36, 19, mainFrameColor)
    gui.text(4, 2, "[Процессоры создания]", colors.cyan)
    --рамка для игроков
    gui.frame(40, 2, 36, 14, mainFrameColor)
    gui.text(42, 2, "[Игроки]", colors.cyan)
    --рамка радара
    gui.frame(40, 17, 36, 13, mainFrameColor)
    gui.text(42, 17, "[Радар]", colors.cyan)
end

local function updateEnergy()
    gui.text(4, 24, "Флакс сеть: " .. fluxLib.getName(), colors.green)
    gui.text(4, 26, "Энергия:    ", colors.green)
    while true do
        local energyInput = fluxLib.getInputEnergy()
        local formatted = fluxLib.formatDouble(energyInput)
        gui.text(16, 26, formatted .. "     ", colors.green)
        os.sleep(1)
    end
end

local function updateTPS()
    gui.text(4, 28, "TPS:", colors.green)
    while true do
        local tps = tpsLib.calc()
        local formattedTps = tpsLib.format(tps)
        gui.text(16, 28, formattedTps .. "      ", tpsLib.colorByTPS(tps))
        os.sleep(0.1)
    end
end

 local function updateRadar()
     local maxRadarUsers = 9
     while true do
         local currentPlayers = radarLib.getPlayers(maxRadarUsers)
         for i = 1, maxRadarUsers do
             gui.text(43, i + 18, "               ")
             if currentPlayers[i] ~= nil then
                 gui.text(43, i + 18, currentPlayers[i])
             end
         end
         os.sleep(1)
     end
 end

-- local function updatePlayers()
--     while true do
--         computer.removeUser(admin)
--         for i = 1, #players do
--             local raw = players[i][1] .. ":"
--             gui.text(43, i + 3, raw, colors.white)
--             if computer.addUser(players[i][1]) then
--                 gui.text(63, i + 3, "В сети   ", colors.green)
--                 if not players[i][2] then
--                     chat.say("§f" .. players[i][1] .. "§2 зашел в игру!")
--                     players[i][2] = true
--                 end
--             else
--                 gui.text(63, i + 3, "Не в сети", colors.red)
--                 if players[i][2] then
--                     chat.say("§f" .. players[i][1] .. "§4 покинул игру!")
--                     players[i][2] = false
--                 end
--             end
--             computer.removeUser(players[i][1])
--         end
--         computer.addUser(admin)
--         os.sleep(5)
--     end
-- end

-- local function updateMeInfo()
--     while true do
--         local cpus, _, _ = meLib.getCPUInfo()
--         local max = math.min(#cpus, 12)
--         for i = 1, max do
--             gui.text(4, i + 3, "Процессор #")
--             gui.text(15, i + 3, i .. ":")
--             if cpus[i].busy then
--                 gui.text(20, i + 3, "В работе", colors.red)
--             else
--                 gui.text(20, i + 3, "Свободен", colors.green)
--             end
--         end
--         os.sleep(0.1)
--     end
-- end

init()
local energyThread = thread.create(updateEnergy)
-- local meThread = thread.create(updateMeInfo)
-- local playersThread = thread.create(updatePlayers)
local tpsThread = thread.create(updateTPS)
local radarThread = thread.create(updateRadar)

thread.waitForAll({
    energyThread,
--     meThread,
--     playersThread,
    tpsThread,
    radarThread
})
