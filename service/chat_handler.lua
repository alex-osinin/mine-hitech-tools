local service = {}

local config = require("config")
local reactorLib = require("service.void_reactor_lib")
local tpsLib = require("service.tps")
local components = require("util.components")

local chatbot
local permissions = (config.permissions and config.permissions.chat) or {}

function service.init()
    chatbot = components.requireComponent("chat_box")
    chatbot.setName("§4Алиса§7§o")
    chatbot.say("§fHello world!")
end

local function help()
    chatbot.say("Команды:")
    chatbot.say("@r_init  - Инициализировать реакторы")
    chatbot.say("@r_start - Запустить все реакторы")
    chatbot.say("@r_stop  - Выключить все реакторы")
    chatbot.say("@tps     - Вывести текущий ТПС")
    chatbot.say("@exit    - Заершить работу программы")
    chatbot.say("@reboot  - Перезагрузка ПК")
    chatbot.say("Made by orange_juice_")
end
--игроки рядом

local function initReactors()
    chatbot.say("§e§lИнициализирую реакторы")
    reactorLib.init()
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

local function tps()
    local tps = string.format("%.1f", tpsLib.calc())
    chatbot.say("§fTPS: " .. tps)
end

local function exit(ctx)
    chatbot.say("§e§lЗакрываем лавочку")
    ctx.exit()
end

local function reboot(ctx)
    chatbot.say("§e§lПерезагрузка")
    ctx.reboot()
end

function service.handle(nick, msg, ctx)
    if not (permissions and permissions[nick]) then
        return false
    end
    if "@help" == msg then
        help()
    elseif "@r_init" == msg then
        initReactors()
    elseif "@r_stop" == msg then
        stopReactors()
    elseif "@r_start" == msg then
        startReactors()
    elseif msg == "@tps" or msg == "@TPS" then
        tps()
    elseif "@exit" == msg then
        exit(ctx)
    elseif "@reboot" == msg then
        reboot(ctx)
    end
end

return service
