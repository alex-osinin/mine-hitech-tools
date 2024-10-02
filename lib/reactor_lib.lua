local reactorLib = {}

local fs = require("filesystem")
local component = require("component")
local colors = require("lib.colors")
local gui = require("lib.monitor_gui_lib")

local dataPath = "/home/data"
local fileName = "reactorsData"
local dataFilePath = dataPath .. "/" .. fileName
ReactorState = { WORKING = "1", STOPPED = "0", ERROR = "-1" }

local reactorComponents = {}
local reactorsEnabled

function reactorLib.loadData()
    reactorComponents = {}
    local file = io.open(dataFilePath, "r")
    if file then
        for address in file:lines() do
            --local number, address = string.gmatch(line, "([^ ]+)")
            --local parsed = string.gmatch(line, "([^ ]+)")
            local reactorComponent = component.proxy(address)
            reactorComponent = reactorComponent or 0
            reactorComponents[#reactorComponents + 1] = reactorComponent
            --table.insert(reactorComponents, reactorComponent)
            --device[#device + 1] = component.proxy(line)
        end
        file:close()
    end
end

function reactorLib.initData()
    if not fs.isDirectory(dataPath) then
        fs.makeDirectory(dataPath)
    end
    local file = io.open(dataFilePath, "w")
    if file then
        --local i = 0
        for address, _ in pairs(component.list("reactor_chamber")) do
            --file:write(i, " ", k, "\n")
            file:write(address, "\n")
            --i = i + 1
        end
        file:close()
    end
end

function reactorLib.getReactorsCount()
    return #reactorComponents
end

function reactorLib.powerControl(currentLapisCount, lapisSettings)
    if currentLapisCount < lapisSettings.lapisMinimum and reactorsEnabled == ReactorState.WORKING then
        --Выключение при малом количестве лазурита
        --gpu.set(xr - 26, 4, 'Мало лазурита. Выключение')
        reactorLib.stopAll()
        --gpu.set(xr - 26, 4, 'Реакторы выключены        ')
    elseif currentLapisCount >= lapisSettings.lapisRecomended and reactorsEnabled == ReactorState.STOPPED then
        --Включение при достаточном количестве лазурита
        --gpu.set(xr - 26, 4, 'Включение...              ')
        reactorLib.startAll()
        --gpu.set(xr - 26, 4, 'Реакторы включены        ')
    end
    return ReactorState.ERROR
end

local function stopReactor(reactor)
    if reactor ~= 0 then
        reactor.stopReactor()
    end
end

local function startReactor(reactor)
    if reactor ~= 0 then
        reactor.startReactor()
    end
end

function reactorLib.stopAll()
    for i = 1, #reactorComponents do
        pcall(stopReactor, reactorComponents[i])
    end
    reactorsEnabled = ReactorState.STOPPED
end

function reactorLib.startAll()
    for i = 1, #reactorComponents do
        pcall(startReactor, reactorComponents[i])
    end
    reactorsEnabled = ReactorState.WORKING
end

local function colorizeState(state)
    if state == ReactorState.WORKING then
        return colors.green
    elseif state == ReactorState.STOPPED then
        return colors.red
    else
        return colors.grey
    end
end

local function displayStatus(reactorNumber, state)
    local backgroundColor = colorizeState(state)
    local startX, startY = 4, 4
    local index = reactorNumber - 1
    local x = startX + index % 10 * 7
    local y = startY + math.floor(index / 10) * 3
    gui.rectangle(x, y, 2, 1, backgroundColor)
    local reactorStr = tostring(reactorNumber)
    if reactorNumber < 10 then
        reactorStr = ' ' .. reactorStr
    end
    gui.text(x, y - 1, reactorStr)
end

local function getState(reactor)
    if reactor == 0 then
        return ReactorState.ERROR
    elseif reactor.isReactorWorking() then
        return ReactorState.WORKING, reactor.getReactorEUOutput()
    else
        return ReactorState.STOPPED
    end
end

function reactorLib.showReactorStatuses()
    local working, producing, totalEnergy = 0, 0, 0
    for i = 1, #reactorComponents do
        local reactor = reactorComponents[i]
        --gpu.set(xr - 26, 4, 'Проверка реактора ' .. i .. '       ')
        local success, state, output = pcall(getState, reactor)
        if not success then
            state = ReactorState.ERROR
        end

        if state == ReactorState.WORKING then
            working = working + 1
            totalEnergy = totalEnergy + output
            if output > 0 then
                producing = producing + 1
            end
        end
        displayStatus(i, state)
    end
    return working, producing, totalEnergy
end

return reactorLib
