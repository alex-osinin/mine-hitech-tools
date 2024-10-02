local systemLib = {}
local term = require("term")
local thread = require("thread")

function systemLib.run(func, timer)-- todo rename
    thread.create(function(f, t)
        while true do
            f()
            os.sleep(t)
        end
    end, func, timer)
end

function systemLib.exit() -- todo sa[jl bp cjc gjnjrf
    term.clear()
    os.exit(0)
end

return systemLib
