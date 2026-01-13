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
    useMockComponents = true,

    hotReloadModules = {
        "service.chat_handler",
        "service.reactor_service",
        "service.radar_service",
        "service.storage_service",
        "service.energy_service",
        "service.tps_counter",
        "ui.monitor_gui",
        "ui.monitor_renderer"
    },

    -- Профили моков: переключайте activeProfile под нужный сценарий
    activeProfile = "low_coolant_shutdown",

    profiles = {
        -- Сценарий: охлаждения мало => reactor_service должен выключить всё
        low_coolant_shutdown = {
            reactorsCount = 3,
            reactor = {
                idleMode = false,
                energyGeneration = 4500
            },
            me = {
                coolantAmount = 1000 -- << ниже minimum
            },
            flux = {
                networkName = "DEV-LOW-COOLANT",
                energyInput = 800
            },
            radar = {
                players = { "Alex", "Steve" }
            }
        },

        -- Сценарий: охлаждения много => reactor_service должен включить всё
        enough_coolant_startup = {
            reactorsCount = 4,
            reactor = {
                idleMode = false,
                energyGeneration = 9000
            },
            me = {
                coolantAmount = 950000 -- << выше recommended
            },
            flux = {
                networkName = "DEV-OK-COOLANT",
                energyInput = 16000
            },
            radar = {
                players = { "Builder", "Miner", "Engineer" }
            }
        },

        -- Сценарий: реакторы "есть work, но генерации нет" => IDLE в UI
        idle_reactors = {
            reactorsCount = 2,
            reactor = {
                idleMode = true,
                energyGeneration = 0
            },
            me = {
                coolantAmount = 950000
            },
            flux = {
                networkName = "DEV-IDLE",
                energyInput = 2000
            },
            radar = {
                players = { "Observer" }
            }
        },

        -- Сценарий: много игроков => проверка maxUsers + сортировки
        crowded_radar = {
            reactorsCount = 1,
            reactor = {
                idleMode = false,
                energyGeneration = 3000
            },
            me = {
                coolantAmount = 950000
            },
            flux = {
                networkName = "DEV-RADAR",
                energyInput = 5000
            },
            radar = {
                players = {
                    "Zed", "Alex", "Steve", "Builder", "Miner", "Engineer", "Pilot", "Trader", "Guard"
                }
            }
        }
    }
}

return config
