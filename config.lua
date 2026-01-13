local config = {}

config.chatbox = {
    name = "Алиса",
    permissions = {
        ["orange_juice_"] = true,
    }
}

config.reactors = {
    cooling = {
        item = { name = "ae2fc:fluid_drop" },
        limits = {
            minimum = 50000,
            recommended = 900000
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
