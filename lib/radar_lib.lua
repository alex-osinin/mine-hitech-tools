local radarLib = {}
local component = require "component"
local radar = component.radar

function radarLib.getPlayers(maxRadarUsers)
    local temp = radar.getPlayers()
    local players = {}
    for i = 1, #temp do
        players[i] = temp[i].name
    end
    table.sort(players)
    for i = 1, maxRadarUsers do
        if players[i] ~= nil then
            players[i] = players[i]
        else
            players[i] = ""
        end
    end
    return players
end

return radarLib
