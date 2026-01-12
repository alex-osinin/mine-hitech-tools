local factory = {}

local fs = require("filesystem")
local computer = require("computer")

local function ensureDir(path)
    if fs.exists(path) then return end
    fs.makeDirectory(path)
end

local function nowStr()
    return computer.uptime()
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
        f:write(string.format("[%s] [%s] %s\n", nowStr(), tostring(level), tostring(msg)))
        f:close()
        return true
    end

    function self.info(msg) return self.write("INFO", msg) end
    function self.warn(msg) return self.write("WARN", msg) end
    function self.error(msg) return self.write("ERROR", msg) end

    return self
end

return factory