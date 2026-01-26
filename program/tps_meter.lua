package.loaded["config"] = nil
_G.PROGRAM = "tps_meter"
local config = require(_G.PROGRAM .. "_config")

local event = require("event")
local component = require("component")
local keyboard = require("keyboard")
local computer = require("computer")
local tpsCounter = require("service.tps_counter")

local chatbox = component.chat_box
local permissions = config.chatbox.permissions or {}
local running = true

chatbox.setName("§4" .. config.chatbox.name .. "§7§o")
chatbox.say("§e§lДостаю линейку...")

local state = {
    tps = { value = 0 }
}
local nextAt = {
    tps = 0
}

while running do
    local now = computer.uptime()
    if now >= nextAt.tps then
        nextAt.tps = now + config.updateTimers.tps
        tpsCounter.updateState(state)
        io.write("\nTPS: " .. tostring(state.tps.value))
    end

    local name, _, a2, a3 = event.pull(0.2)
    if name == "chat_message" then
        local nick = a2
        if not (permissions and permissions[nick]) then
            return false
        end
        local msg = a3 and a3:lower() or ""
        if msg:match("^@tps") then
            local tps = state.tps.value and string.format("%.1f", state.tps.value) or "-"
            chatbox.say("§fTPS: " .. tps)
        end
    elseif name == "key_down" then
        local code = a3
        if code == keyboard.keys.delete then
            running = false
        end
    end
end
chatbox.say("§e§lПрячу линейку...")
