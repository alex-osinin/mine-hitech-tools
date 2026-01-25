local service = {}

local config = require(_G.PROGRAM .. "_config")
local fs = require("filesystem")
local computer = require("computer")

local t_correction = config.user.timezone * 3600

local function fileTime(file)
    local f = io.open(file, "w")
    if not f then return 0 end
    f:write("test")
    f:close()
    return fs.lastModified(file)
end

function service.currentTimeZ()
    local lastmod = fileTime('/tmp/FWHUY.tmp')
    return tonumber(string.sub(lastmod, 1, -4)) + t_correction
end

function service.currentTimeMillis()
    return fileTime('/tmp/OCOTM.tmp')
end

function service.uptime()
    return computer.uptime()
end

function service.osTime()
    return os.clock() or 0
end

return service
