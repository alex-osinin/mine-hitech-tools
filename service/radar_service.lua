local service = {}
local config = require("config")
local components = require("util.components")

local radars = {}

function service.init(log)
    radars = components.findAll("radar", log)
end
-- todo добавить предопределенный список игроков онлайн/нет
local function getPlayers()
    local players = {}
    for i = 1, #radars do
        local radarPlayers = radars[i].getPlayers()
        for j = 1, #radarPlayers do
            players[radarPlayers[j].name] = true
        end
    end

    local playerNames = {}
    local i = 0
    for playerName, _ in pairs(players) do
        if i == config.radar.maxUsers then
            break
        end
        table.insert(playerNames, playerName)
        i = i + 1
    end
    table.sort(playerNames)
    return playerNames
end

function service.updateState(state)
    state.radar.players = getPlayers() or {}
end

return service
