local radarLib = {}
local component = require "component"

local radars = {}

function radarLib.init()
    for address, _ in pairs(component.list("radar")) do
        table.insert(radars, component.proxy(address))
    end
end

function radarLib.getPlayers(maxRadarUsers)
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
        if i == maxRadarUsers then
            break
        end
        table.insert(playerNames, playerName)
        i = i + 1
    end
    table.sort(playerNames)
    return playerNames
end

return radarLib
