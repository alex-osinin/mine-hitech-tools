local component = require("component")

local service = {}

function service.requireComponent(typeName, log)
    local c = service.findFirst(typeName, log)
    if not c then
        local msg = string.format("Missing component: %s\n", typeName)
        log.error(msg)
        io.stderr:write(msg)
        os.exit(1)
    end
    return c
end

function service.findFirst(typeName, log)
    log.info("Searching for component of type: " .. typeName)
    if not component.isAvailable(typeName) then
        log.warn("Component not found: " .. typeName)
        return nil
    end
    local primary = component.getPrimary(typeName)
    log.info("Found component - type: " .. typeName .. ", address: " .. primary.address)
    return primary
end

function service.findAll(typeName, log)
    log.info("Searching for all components of type: " .. typeName)
    local components = {}
    for address, _ in pairs(component.list(typeName)) do
        log.info("Found component - type: " .. typeName .. ", address: " .. address)
        table.insert(components, component.proxy(address))
    end
    log.info("Total found components of type " .. typeName .. ": " .. #components)
    return components
end

return service
