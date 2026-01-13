package.loaded["config"] = nil
local config = require("config")

-- only for developing
if config.dev and config.dev.enabled then
    for _, m in ipairs(config.dev.hotReloadModules or {}) do
        package.loaded[m] = nil
    end
end
--

local computer = require("computer")
local event = require("event")
local keyboard = require("keyboard")
local term = require("term")

local ui = require("ui.monitor_renderer")
local chatHandler = require("service.chat_handler")
local tpsCounter = require("service.tps_counter")
local reactorService = require("service.reactor_service")
local fluxService = require("service.energy_service")
local radarService = require("service.radar_service")
local storageService = require("service.storage_service")

local loggerFactory = require("util.logger")
local log = loggerFactory.new({ file = "monitor_view.log" })

local running = true

local ctx = {
    exit = function()
        running = false
    end,
    reboot = function()
        computer.shutdown(true)
    end
}

local state = {
    reactors = {
        summary = { working = 0, idle = 0, total = 0, energy = 0 },
        statuses = {},
        liquid = -1
    },
    energy = {
        networkName = 0,
        input = 0
    },
    tps = { value = 0 },
    radar = { players = {} }
}

local function initComponents()
    log.info("Инициализация компонентов...")
    storageService.init(log)
    fluxService.init(log)
    radarService.init(log)
    reactorService.init(log)
    chatHandler.init(log)
    log.info("Инициализация компонентов завершена")
end

local function safeCall(name, fn, ...)
    local args = { ... }
    local function runner()
        return fn(table.unpack(args))
    end
    local ok, err = xpcall(runner, debug.traceback)
    if not ok then
        log.errorT(name, err)
        if type(err) == "table" and err.__fatal then
            term.clear()
            io.stderr:write(err.message or ("Fatal error in " .. tostring(name)))
            os.exit(err.code or 1)
        end
    end
end

log.info("Старт приложения")
log.infoT("Конфигурация: ", config)
safeCall("initComponents", initComponents)
safeCall("initUI", ui.initUI, log)

local nextAt = {
    reactors = 0,
    radar = 0,
    tps = 0,
    energy = 0,
    render = 0
}

log.info("Запуск планировщика")
while running do
    local now = computer.uptime()
    if now >= nextAt.reactors then
        nextAt.reactors = now + config.updateTimers.reactors
        safeCall("updateReactorsData", reactorService.updateState, state)
    end

    if now >= nextAt.radar then
        nextAt.radar = now + config.updateTimers.radar
        safeCall("updateRadarData", radarService.updateState, state)
    end

    if now >= nextAt.tps then
        nextAt.tps = now + config.updateTimers.tps
        safeCall("updateTPSData", tpsCounter.updateState, state)
    end

    if now >= nextAt.energy then
        nextAt.energy = now + config.updateTimers.energy
        safeCall("updateEnergyData", fluxService.updateState, state)
    end

    if now >= nextAt.render then
        nextAt.render = now + config.updateTimers.render
        safeCall("render", ui.render, state)
    end

    -- ждём события, но не спим дольше ближайшего таймера
    local soonest = math.min(nextAt.reactors, nextAt.radar, nextAt.tps, nextAt.energy, nextAt.render)
    local timeout = soonest - computer.uptime()
    if timeout < 0 then timeout = 0 end
    if timeout > 0.25 then timeout = 0.25 end

    local name, _, a2, a3, _ = event.pull(timeout)
    if name == "key_down" then
        local code = a3
        if code == keyboard.keys.delete then
            ctx.exit()
        end
    elseif name == "chat_message" then
        local nick = a2
        local msg = a3
        safeCall("chatHandler", chatHandler.handle, nick, msg, ctx)
    end
end
log.info("Завершение работы приложения")

term.clear()
os.exit(0)
