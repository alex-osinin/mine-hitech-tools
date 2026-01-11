local systemLib = {}
local thread = require("thread")

function systemLib.run(func, timer)
    return thread.create(function(f, t)
        while true do
            f()
            os.sleep(t)
        end
    end, func, timer)
end

return systemLib
