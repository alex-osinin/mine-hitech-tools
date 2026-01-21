local service = {}

local config = require("config")
local tpsService = require("service.tps_counter")
local reactorService = require("service.reactor_service")
local components = require("util.components")

local chatbox
local permissions = config.chatbox.permissions or {}

function service.init(log)
    chatbox = components.requireComponent("chat_box", log)
    chatbox.setName("§4" .. config.chatbox.name .. "§7§o")
    chatbox.say("§fHello world!")
end

local function help()
    chatbox.say("Команды:")
    chatbox.say("@r_init  - Инициализировать реакторы")
    chatbox.say("@r_start - Запустить все реакторы")
    chatbox.say("@r_stop  - Выключить все реакторы")
    chatbox.say("@tps     - Вывести текущий ТПС")
    chatbox.say("@exit    - Заершить работу программы")
    chatbox.say("@reboot  - Перезагрузка ПК")
    chatbox.say("Made by orange_juice_")
end

local function initReactors()
    chatbox.say("§e§lИнициализирую реакторы")
    reactorService.init()
    chatbox.say("Готово")
end

local function stopReactors()
    chatbox.say("§e§lВыключаю реакторы")
    reactorService.stopAll()
end

local function startReactors()
    chatbox.say("§e§lЗапускаю реакторы")
    reactorService.startAll()--fixme dont work
end

local function tps()
    local tps = string.format("%.1f", tpsService.calc())
    chatbox.say("§fTPS: " .. tps)
end

local function exit(ctx)
    chatbox.say("§e§lЗакрываем лавочку")
    ctx.exit()
end

local function reboot(ctx)
    chatbox.say("§e§lПерезагрузка")
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
