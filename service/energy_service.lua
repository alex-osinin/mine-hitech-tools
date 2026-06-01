local service = {}
local config = require(_G.PROGRAM .. "_config")
local components = require("util.components")

local fluxStorage

-- Размер окна усреднения input в секундах. Значение на экране обновляется раз в WINDOW_SECONDS
local WINDOW_SECONDS = (config.energy and config.energy.windowSeconds) or 5

-- Сколько сэмплов укладывается в окно при текущем интервале опроса энергии
local SAMPLES = math.max(1, math.floor(WINDOW_SECONDS / config.updateTimers.energy + 0.5))

-- Имя сети практически не меняется в рантайме, опрашиваем его раз в ~30 сэмплов
local NAME_REFRESH_EVERY = 30

local windowSum
local windowCount
local sampleCount

function service.init(log)
    fluxStorage = components.requireComponent("flux_storage", log)
    windowSum = 0
    windowCount = 0
    sampleCount = 0
end

function service.updateState(state)
    if sampleCount % NAME_REFRESH_EVERY == 0 then
        state.energy.networkName = fluxStorage.getNetworkInfo().name
    end
    sampleCount = sampleCount + 1

    local energyInfo = fluxStorage.getEnergyInfo()
    local rawInput = energyInfo.energyInput or 0
    windowSum = windowSum + rawInput
    windowCount = windowCount + 1

    if windowCount >= SAMPLES then
        state.energy.input = math.floor(windowSum / windowCount + 0.5)
        windowSum = 0
        windowCount = 0
    elseif state.energy.input == nil then
        -- На старте, пока первое окно не заполнилось, показываем хоть что-то
        state.energy.input = rawInput
    end

    state.energy.buffer = energyInfo.totalBuffer
end

return service
