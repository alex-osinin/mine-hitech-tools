-- util/mock_components.lua
local mock = {}
local cfg = require("config")
local profile = cfg.dev.profiles[cfg.dev.activeProfile]

local function now()
    return (os.clock and os.clock()) or 0
end

local function addr(prefix)
    return (prefix or "mock") .. "-" .. tostring(math.floor(now() * 1000))
end

local function mkChatBox()
    return {
        address = addr("chatbox"),
        type = "chat_box",
        setName = function() end,
        say = function() end
    }
end

local function mkFluxStorage()
    local fluxCfg = profile.flux or {}
    return {
        address = addr("flux"),
        type = "flux_storage",
        getNetworkInfo = function()
            return { name = fluxCfg.networkName or "MOCK-NET" }
        end,
        getEnergyInfo = function()
            return { energyInput = fluxCfg.energyInput or 0, totalBuffer = fluxCfg.totalBuffer or 0}
        end
    }
end

local function mkRadar(index)
    local radarCfg = profile.radar or {}
    return {
        address = addr("radar"),
        type = "radar",
        slot = function() return index end,
        getPlayers = function()
            local names = radarCfg.players or {}
            local out = {}
            for i = 1, #names do
                out[i] = { name = names[i] }
            end
            return out
        end
    }
end

local function mkReactor(index)
    local rCfg = profile.reactor or {}
    local work = true
    if rCfg.idleMode then
        work = true
    end
    local active = work

    return {
        address = addr("reactor"),
        type = "htc_reactors_nuclear_reactor",
        slot = function() return index end,

        hasWork = function() return active end,
        activate = function() active = true; return true end,
        deactivate = function() active = false; return true end,

        getEnergyGeneration = function()
            if not active then return 0 end
            if rCfg.idleMode then return 0 end
            return rCfg.energyGeneration or 0
        end
    }
end

local function mkMEController()
    local meCfg = profile.me or {}
    return {
        address = addr("me"),
        type = "me_controller",

        getCpus = function()
            return {
                { busy = false },
                { busy = true },
                { busy = false }
            }
        end,

        getItemsInNetwork = function(itemInfo)
            -- В вашем коде есть 2 режима использования:
            -- 1) me.getItemsInNetwork() -> список предметов в сети
            -- 2) me.getItemsInNetwork(itemInfo) -> { { size = N } }, ...
            if itemInfo == nil then
                return {
                    { name = "ae2fc:fluid_drop", damage = nil, size = meCfg.coolantAmount or 0 }
                }
            end

            -- если спрашивают именно "охлаждайку" — отдаём настроенное количество
            if itemInfo.name == "ae2fc:fluid_drop" then
                return { { size = meCfg.coolantAmount or 0 } }, nil, nil
            end

            return nil, nil, nil
        end,

        getCraftables = function(_)
            return nil, nil, nil
        end
    }
end

function mock.getPrimary(typeName)
    if typeName == "flux_storage" then return mkFluxStorage() end
    if typeName == "me_controller" then return mkMEController() end
    if typeName == "chat_box" then return mkChatBox() end
    return nil
end

function mock.listAll(typeName)
    if typeName == "radar" then
        return { mkRadar() }
    end

    if typeName == "htc_reactors_nuclear_reactor" then
        local n = profile.reactorsCount or 1
        local list = {}
        for i = 1, n do list[i] = mkReactor(i) end
        return list
    end

    return {}
end

return mock