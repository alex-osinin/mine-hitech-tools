local component = require("component")

local service = {}

function service.requireComponent(typeName)
    if not component.isAvailable(typeName) then
        io.stderr:write(("Missing component: %s\n"):format(typeName))
        os.exit(1)
    end
    return component.getPrimary(typeName)
end

function service.getAll(typeName)
    local components = {}
    for address, _ in pairs(component.list(typeName)) do
        table.insert(components, component.proxy(address))
    end
    return components
end

return service