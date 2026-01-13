local factory = {}

local fs = require("filesystem")
local serialization = require("serialization")
local time = require("util.time")

local function ensureDir(path)
    if fs.exists(path) then return end
    fs.makeDirectory(path)
end

local function nowStr()
    return string.format("%8.2f", time.uptime())
end

function factory.new(opts)
    opts = opts or {}
    local dir = opts.dir or "/var/log"
    local file = opts.file or "view.log"
    local path = dir .. "/" .. file

    ensureDir(dir)

    local self = {}

    function self.write(level, msg)
        local f = io.open(path, "a")
        if not f then return false end
        f:write(string.format("[%s] [%-5s] %s\n", nowStr(), tostring(level), tostring(msg)))
        f:close()
        return true
    end

    function self.info(msg) return self.write("INFO", msg) end
    function self.infoT(msg, table) return self.write("INFO", tostring(msg) .. ": " .. serialization.serialize(table, true)) end
    function self.warn(msg) return self.write("WARN", msg) end
    function self.error(msg) return self.write("ERROR", msg) end
    function self.errorT(msg, err) return self.write("ERROR", tostring(msg) .. ": " .. tostring(err)) end

    return self
end

return factory