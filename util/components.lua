local util = {}

local component = require("component")
local config = require("config")
local mock
if config.dev and config.dev.enabled and config.dev.useMockComponents then
    mock = require("test.mock_components")
end

function util.requireComponent(typeName, log)
    local c = util.findFirst(typeName, log)
    if not c then
        local msg = string.format("Missing component: %s\n", typeName)
        log.error(msg)
        io.stderr:write(msg)
        os.exit(1)
    end
    return c
end

function util.findFirst(typeName, log)
    log.info("Searching for component of type: " .. typeName)
    if component.isAvailable(typeName) then
        local primary = component.getPrimary(typeName)
        log.info("Found component - type: " .. typeName .. ", address: " .. primary.address)
        return primary
    elseif config.dev and config.dev.enabled and config.dev.useMockComponents then
        local proxy = mock.getPrimary(typeName)
        if proxy then
            log.warn("Using MOCK component - type: " .. typeName .. ", address: " .. proxy.address)
            return proxy
        end
    end

    log.warn("Component not found: " .. typeName)
    return nil
end

function util.findAll(typeName, log)
    log.info("Searching for all components of type: " .. typeName)
    local components = {}
    for address, _ in pairs(component.list(typeName)) do
        log.info("Found component - type: " .. typeName .. ", address: " .. address)
        table.insert(components, component.proxy(address))
    end
    if #components == 0 and config.dev and config.dev.enabled and config.dev.useMockComponents then
        local list = mock.listAll(typeName) or {}
        for i = 1, #list do
            log.warn("Using MOCK component for type: " .. typeName .. " (index " .. i .. ")")
            table.insert(components, list[i])
        end
    end

    log.info("Total found components of type " .. typeName .. ": " .. #components)
    return components
end

return util
