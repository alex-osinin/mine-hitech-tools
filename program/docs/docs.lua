local component = require("component")
local shell = require("shell")
local filesystem = require("filesystem")
local term = require("term")

local function getMethodsDocs(address, typeName)
    local lines = { "Component: " .. typeName, "Address: " .. address, "" }
    local methods = component.methods(address)
    for name, _ in pairs(methods) do
        local docs = component.doc(address, name)
        table.insert(lines, ("Method: %s\nDocs: %s\n"):format(name, docs or "N/A"))
    end
    return table.concat(lines, "\n")
end

local function uploadToPastebin(content, filename)
    local tmpPath = "/tmp/" .. filename
    local file = io.open(tmpPath, "w")
    if not file then
        io.stderr:write("Error: Unable to open temporary file for writing\n")
        return
    end
    file:write(content)
    file:close()

    shell.execute("pastebin put " .. tmpPath)

    filesystem.remove(tmpPath)
end

local typeName = ...

if not typeName or typeName == "" then
    io.stderr:write("Usage: docs <componentType>\n")
    return
end

-- Берём первый попавшийся компонент указанного типа (точное совпадение).
local address = component.list(typeName, true)()

if not address then
    io.stderr:write(("Component type '%s' not found.\n"):format(typeName))
    return
end

local docs = getMethodsDocs(address, typeName)

print(docs)
io.write("\nUpload to Pastebin? [y/n]: ")
local input = term.read()
input = input and input:gsub("%s+", "") or ""
if input:lower() == "y" then
    uploadToPastebin(docs, typeName .. "_methods.txt")
end
