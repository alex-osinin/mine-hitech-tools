local config = {}

config.chatbox = {
    name = "Алиса",
    permissions = {
        ["orange_juice_"] = true,
    }
}

config.reactors = {
    lapis = {
        item = { name = "minecraft:lapis_block", damage = 0 },
        limits = {
            minimum = 50000,
            recommended = 900000,
            precraftSize = 50000 -- todo реализовать прекрафт
        }
    }
}

config.screen = {
    width = 104,
    height = 31
}

config.updateTimers = {
    reactors = 10,
    tps = 5,
    energy = 10,
    radar = 1,
    render = 0.2
}

config.radar = {
    maxUsers = 7
}

config.dev = {
    enabled = true,
    hotReloadModules = {
        "service.chat_handler",
        "service.reactor_service",
        "service.radar_service",
        "service.storage_service",
        "service.energy_service",
        "service.tps_counter",
        "ui.monitor_gui",
        "ui.monitor_renderer"
    }
}

return config
