local meLib = {}
local component = require "component"
local me = component.me_controller

function meLib.getCPUInfo()
    local cpus = me.getCpus()
    local totalFree = 0
    local totalBusy = 0
    for i = 1, #cpus do
        if not cpus[i].busy then
            totalFree = totalFree + 1
        else
            totalBusy = totalBusy + 1
        end
    end
    return cpus, totalFree, totalBusy
end

local function searchItem(itemsInNetwork, itemInfo)
    for i = 1, #itemsInNetwork do
        if itemsInNetwork[i].name == itemInfo.name and itemsInNetwork[i].damage == itemInfo.meta then
            return itemsInNetwork[i].size
        end
    end
    return 0
end

function meLib.getItemsQuantity(itemInfos)
    local itemsInNetwork = me.getItemsInNetwork()
    local sizes = {}
    for i = 1, #itemInfos do
        if itemsInNetwork ~= false then
            sizes[i] = searchItem(itemsInNetwork, itemInfos[i])
        else
            sizes[i] = "-"
        end
    end
    return sizes
end

function meLib.getItemQuantity(itemInfo)
    local item, _, _ = me.getItemsInNetwork(itemInfo)
    if not item then
        return -1
    end
    return item[1].size
end

--function zlib.itemSize(name, dmg) --item size in me network
--    for _, i in pairs(me.getAvailableItems()) do
--        if i.fingerprint.id == name and i.fingerprint.dmg == dmg then
--            return i.size
--        end
--    end
--    return 0
--end

function meLib.formatItemQuantity(quantity)
    local number = tonumber(quantity)
    if number == nil or number < 10000 then
        return quantity
    elseif number < 1000000 then
        return math.floor(number / 1000) .. " k"
    else
        return string.format("%.1f", tostring(number / 1000000)) .. " M"
    end
end

return meLib
