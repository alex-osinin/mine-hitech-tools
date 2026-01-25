local service = {}

local config = require(_G.PROGRAM .. "_config")
local components = require("util.components")
local serialization = require("serialization")
local computer = require("computer")

local modem

function service.init(log)
    if config.dev and config.dev.useModem then
        modem = components.requireComponent("modem", log)
        if modem.isWireless() then
            modem.setStrength(32)
            modem.open(321)
        end
    end
end

-- Example:
-- data = { type = "chat_message", args = { "orange_juice_", "@r_start" } }
local function sendEvent(from, data, log)
    log.infoT("[modem] Sending event: ", data)
    if data.type and data.args then
        computer.pushSignal(data.type, from, table.unpack(data.args))
    end
end

-- Example:
-- { type = "event", data = {...} } }
function service.handle(from, payload, log)
    if not config.dev or not config.dev.useModem or not config.dev.enabled then
        return
    end
    log.info("[modem] Received message: " .. payload)
    local ok, packet = pcall(serialization.unserialize, payload)
    if ok and packet.type and packet.data then
        if packet.type == "event" then
            sendEvent(from, packet.data, log)
        end
    end
end

return service
