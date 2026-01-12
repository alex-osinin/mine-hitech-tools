local DATE_FORMAT = '%Y.%m.%d %H:%M:%S'
local TIME_ZONE = 2
local FILE = '/tmp/UNIX123.tmp'
local t_correction = TIME_ZONE * 3600
local service = {}
local fs = require("filesystem")

function service.realDateTime()
    local file = io.open(FILE, 'w')
    file:write('')
    file:close()
    local lastmod = tonumber(string.sub(fs.lastModified(FILE), 1, -4)) + t_correction

    return os.date(DATE_FORMAT, lastmod)
end

return service
