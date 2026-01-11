local W, H = 77, 31
local admin = "orange_juice_"
local players = { --игроки для проверки на онлайн {"ник", false}
    { "rustyyy",  false },
    { "Winston22",  false },
}

local gui = require "lib.monitor_gui_lib"
local fluxLib = require "lib.flux_lib"
local meLib = require "lib.me_lib"
local component = require "component"
local computer = require "computer"
local term = require "term"
local chat = component.chat_box

local function init()
    term.clear()
    -- настройка чат бокса
    chat.setName("§4Алиса§7§o")

    gui.init(COLORS.white, COLORS.black)
    local mainFrameColor = 0x3F3ACA
    gui.mainFrame(W, H, "Region Viwer", mainFrameColor)
    gui.frame(2, 2, 36, 6, mainFrameColor)   --рамка для сети
    gui.text(4, 2, "&B[Энерго-система]")
    gui.frame(2, 9, 36, 21, mainFrameColor)  --рамка для процессоров
    gui.text(4, 9, "&B[Процессоры создания]")
    gui.frame(40, 2, 36, 28, mainFrameColor) --рамка для игроков
    gui.text(42, 2, "&B[Игроки]")
end

local function updateEnergy()
    gui.text(3, 5, "                               ")
    gui.text(3, 4, ("&aФлакс сеть: " .. fluxLib.getName()))

    local inputEU = fluxLib.getEnergyInput()
    gui.text(3, 6, "&aЭнергия:    " .. fluxLib.formatDouble(inputEU / 4))
end

local function updatePlayers()
    computer.removeUser(admin)
    for i = 1, #players do
        gui.text(43, i + 3, "&f" .. players[i][1] .. ":")
        if computer.addUser(players[i][1]) then
            gui.text(63, i + 3, "&2В сети   ")
            if not players[i][2] then
                chat.say("§f" .. players[i][1] .. "§2 зашел в игру!")
                players[i][2] = true
            end
        else
            gui.text(63, i + 3, "&4Не в сети")
            if players[i][2] then
                chat.say("§f" .. players[i][1] .. "§4 покинул игру!")
                players[i][2] = false
            end
        end
        computer.removeUser(players[i][1])
    end
    computer.addUser(admin)
end

local function updateMeInfo()
    local tempText
    local cpus, totalFree, totalBusy = meLib.getMeInfo()
    for i = 1, #cpus do
        if not cpus[i].busy then
            tempText = "&fПроцессор #" .. i .. ": &aСвободен"
        else
            tempText = "&fПроцессор #" .. i .. ": &cВ работе"
        end
        gui.text(4, i + 9, tempText)
    end
    gui.text(20, 29, "         ")
    tempText = "&a" .. totalFree .. " &9/&c " .. totalBusy
    gui.text(20, 29, tempText)
    tempText = "&1Всего: &a" .. #cpus
    gui.text(27, 29, tempText)
end

init()
while true do
    updateEnergy()
    updatePlayers()
    updateMeInfo()
    os.sleep(0.05)
end
