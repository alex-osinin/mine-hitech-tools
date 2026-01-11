local chatHandler = {}

local reactorLib = require("lib.ic_reactor_lib")
local system = require("lib.system_lib")
local component = require("component")
local event = require("event")
local computer = require("computer")
local chatbot = component.chat_box

local function help()
    chatbot.say("Команды:")
    chatbot.say("@r_init  - Инициализировать реакторы")
    chatbot.say("@r_start - Запустить все реакторы")
    chatbot.say("@r_stop  - Выключить все реакторы")
    chatbot.say("@exit    - Заершить работу программы")
    chatbot.say("@reboot  - Перезагрузка ПК")
    chatbot.say("Made by orange_juice_")
end
--//fixme тпс по команде
--игроки рядом

local function initReactors()
    chatbot.say("§e§lИнициализирую реакторы")
    reactorLib.initData()
    reactorLib.loadData()
    chatbot.say("Реакторов найдено: " .. reactorLib.getReactorsCount())
end

local function stopReactors()
    chatbot.say("§e§lВыключаю реакторы")
    reactorLib.stopAll()
end

local function startReactors()
    chatbot.say("§e§lЗапускаю реакторы")
    reactorLib.startAll()
end

local function exit()
    chatbot.say("§e§lЗакрываем лавочку")
    os.exit(0)
end

local function reboot()
    chatbot.say("§e§lПерезагрузка")
    computer.shutdown(true)
end

function chatHandler.run(permissions)
    while true do
        local _, _, nick, msg = event.pull("chat_message")
        if permissions[nick] then
            if "@help" == msg then
                help()
            elseif "@r_init" == msg then
                initReactors()
            elseif "@r_stop" == msg then
                stopReactors()
            elseif "@r_start" == msg then
                startReactors()
            elseif "@exit" == msg then
                exit()
            elseif "@reboot" == msg then
                reboot()
            end
        end
    end
end

return chatHandler
