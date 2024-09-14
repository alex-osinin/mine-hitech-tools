--нужно:
-- поправить расчет времени
-- поменять шрифт (мб с поддержкой русского)
-- поменять цвет на бирюзовый для тпс и на жеьлый для времени
-- переписать получение итема в сети, функция getItemsInNetwork([filter:table]):table может принимать фильтр
-- 9h2MSAxS
-- uey3RdbF
-- Tzr54Kh5
-- https://computercraft.ru/topic/5926-openglasses-nebolshoy-monitoring-territorii/
-- https://github.com/Starchasers/OCGlasses/wiki
local term = require "term"
local thread = require "thread"
local component = require "component"
local tpsLib = require "tps_lib"
local guiLib = require "glasses_gui_lib"
local radarLib = require "radar_lib"
local fluxLib = require "flux_lib"
local meLib = require "me_lib"
local timeLib = require "time_lib"

itemsInfo = {
    { name = "ic2:nuclear",         meta = 3 },
    { name = "ic2stuff:pf_matter",  meta = 0 },
}

term.clear()
guiLib.removeAll()

function updatePlayersNear()
    players_box = guiLib.createBox(130, 20, 2, 164)
    players_text = guiLib.createText(5, 162)
    players_text.setText("Players near")

    maxRadarUsers = 10
    positionY = 168
    playersW = {}
    for i = 1, maxRadarUsers do
        positionY = positionY + 16
        playerText = guiLib.createText(5, positionY)
        playersW[i] = playerText
    end

    while true do
        players = radarLib.getPlayers(maxRadarUsers)
        for i = 1, #playersW do
            playersW[i].setText(players[i])
        end
        os.sleep(1)
    end
end

function updateTps()
    tps_box = guiLib.createBox(130, 20, 2, 2)

    tps_title = guiLib.createText(28, 0)
    tps_title.addColor(0, 0, 0.5, 1)
    tps_title.setText("TPS:")

    tps_value = guiLib.createText(68, 0)
    while true do
        tps = tpsLib.calc()
        tps_value.setText(tpsLib.format(tps))
        if tps <= 10 then
            tps_value.addColor(1, 0, 0, 1)
        elseif tps <= 15 then
            tps_value.addColor(1, 1, 0, 1)
        elseif tps > 15 then
            tps_value.addColor(0, 1, 0, 1)
        end
        os.sleep(1)
    end
end

function updateRes()
    item_box = guiLib.createBox(130, 60, 2, 100)
    itemTextWidgets = {}

    iconPosition = { x = 0.25, y = 3.1 }
    textPosition = { x = 40, y = 103 }
    for i = 1, #itemsInfo do
        guiLib.createItem(itemsInfo[i].name, itemsInfo[i].meta, iconPosition.x, iconPosition.y)
        iconPosition.y = iconPosition.y + 0.8
        itemTextWidgets[i] = guiLib.createText(textPosition.x, textPosition.y)
        textPosition.y = textPosition.y + 26
    end
    --errorSpace = guiLib.createText(130, 0)
    --errorSpace.addColor(1, 0, 0, 1)
    while true do
        quantities = meLib.getItemsQuantity(itemsInfo)
        for i = 1, #quantities do
            formattedQuantity = meLib.formatItemQuantity(quantities[i])
            itemTextWidgets[i].setText(formattedQuantity)
        end
        --if meLib.getPercentFreeSpace() < 10 then
        --    errorSpace.setText("Внимание! Свободного места в МЭ сети меньше 10%!")
        --else
        --    errorSpace.setText("")
        --end
        os.sleep(65)
    end
end

function updateTime()
    time_box = guiLib.createBox(130, 20, 2, 26)

    time_title = guiLib.createText(20, 25)
    time_title.setText("Time:")

    time_value = guiLib.createText(68, 25)
    while true do
        time = timeLib.getTime()
        time_value.setText(time)
        os.sleep(1)
    end
end

function updateEnergy()
    energy_box = guiLib.createBox(130, 50, 2, 50)

    kvg_stuff_icon = guiLib.createItem("advanced_solar_panels:machines", 1, 0.35, 1.8)
    kvg_stuff_icon.addScale(1.2, 1.2, 1)

    energy_text = guiLib.createText(55, 65)
    while true do
        local energyInput = fluxLib.getInputEnergy()
        local formatted = fluxLib.formatInt(energyInput)
        energy_text.setText(formatted)
        os.sleep(1)
    end
end

function errorHandler(err)
    print("ERROR:", err)
end

--xpcall(func, errorHandler)

local playersThread = thread.create(updatePlayersNear)
local energyThread = thread.create(updateEnergy)
local resThread = thread.create(updateRes)
local timeThread = thread.create(updateTime)
local tpsThread = thread.create(updateTps)

thread.waitForAll({ playersThread, tpsThread, energyThread, resThread, timeThread })
