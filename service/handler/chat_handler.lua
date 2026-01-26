local service = {}

local config = require(_G.PROGRAM .. "_config")
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

local function initReactors(log)
    chatbox.say("§e§lИнициализирую реакторы")
    reactorService.init(log)
    chatbox.say("Готово")
end

local function stopReactors(state, reactorNumber)
    if reactorNumber then
        local reactorData = state.reactors.data[reactorNumber]
        if reactorData then
            chatbox.say("§e§lВыключаю реактор #" .. reactorNumber)
            reactorService.stopReactor(reactorData, true)
        else
            chatbox.say("§cРеактор #" .. reactorNumber .. " не найден")
        end
    else
        chatbox.say("§e§lВыключаю все реакторы")
        reactorService.stopReactors(state.reactors.data, true)
    end
end

local function startReactors(state, reactorNumber)
    if reactorNumber then
        local reactorData = state.reactors.data[reactorNumber]
        if reactorData then
            chatbox.say("§e§lЗапускаю реактор #" .. reactorNumber)
            reactorService.startReactor(reactorData)
        else
            chatbox.say("§cРеактор #" .. reactorNumber .. " не найден")
        end
    else
        chatbox.say("§e§lЗапускаю все реакторы")
        reactorService.startReactors(state.reactors.data)
    end
end

local function tps(state)
    chatbox.say("§fTPS: " .. state.tps.value and string.format("%.1f", state.tps.value) or "-")
end

local function exit(ctx)
    chatbox.say("§e§lЗакрываем лавочку")
    ctx.exit()
end

local function reboot(ctx)
    chatbox.say("§e§lПерезагрузка")
    ctx.reboot()
end

local function parseReactorNumber(msg)
    local num = msg:match("%s+(%d+)$")
    return num and tonumber(num) or nil
end

function service.handle(nick, msg, state, ctx, log)
    if not (permissions and permissions[nick]) then
        return false
    end
    msg = msg and msg:lower() or ""
    if "@help" == msg then
        help()
    elseif msg:match("^@r_init") then
        initReactors(log)
    elseif msg:match("^@r_stop") then
        stopReactors(state, parseReactorNumber(msg))
    elseif msg:match("^@r_start") then
        startReactors(state, parseReactorNumber(msg))
    elseif msg:match("^@tps") then
        tps(state)
    elseif msg == "@exit" then
        exit(ctx)
    elseif msg == "@reboot" then
        reboot(ctx)
    end
end

return service
