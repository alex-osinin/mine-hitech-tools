local config = {}

config.user = {
    nick = "orange_juice_",
    timezone = 4
}

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
    maxUsers = 14
}

config.dev = {
    enabled = true,
    useMockComponents = true,

    hotReloadModules = {
        "service.handler.chat_handler",
        "service.handler.touch_handler",
        "service.reactor_service",
        "service.radar_service",
        "service.storage_service",
        "service.energy_service",
        "service.tps_counter",
        "ui.monitor_gui",
        "ui.monitor_renderer",
        "ui.reactor_renderer",
        "ui.radar_renderer",
        "util.components",
        "util.logger",
        "util.formatter",
        "util.time",
        "util.colors",
        "test.mock_components"
    },

    mocks = {
        reactors = {
            {
                active = false,
                energy = 9000,
                level = 6,
                temperature = 7200,
                rodDecayRemaining = 1800,
                rodDecayTotal = 8000
            },
            {
                active = true,
                energy = 6984,
                level = 5,
                temperature = 6100,
                rodDecayRemaining = 18000,
                rodDecayTotal = 20000
            },
            {
                error = true
            },
            {
                active = true,
                energy = 4500,
                level = 6,
                temperature = 7200,
                rodDecayRemaining = 3900,
                rodDecayTotal = 4000,
                cooling = {
                    active = true,
                    consume = 1200
                }
            },
            {
                active = true,
                energy = 3200,
                level = 5,
                temperature = 6100,
                rodDecayRemaining = 14000,
                rodDecayTotal = 20000,
            },
            {
                active = false,
                energy = 5100,
                level = 6,
                temperature = 7800,
                rodDecayRemaining = 4528,
                rodDecayTotal = 8000,
                cooling = {
                    active = true,
                    consume = 2400
                }
            }
        },
        me = {
            coolantAmount = 1000000
        },
        flux = {
            networkName = "TEST_NETWORK_NAME",
            energyInput = 800,
            totalBuffer = 600
        },
        radar = {
            players = {
                "Zed", "Alex", "Steve", "Builder", "Miner", "Engineereeeeeeeeeeeeeeee", "12345678910111213141516171819",
                "wewhy6hyhy", "gtgtgtg", "ijoinon", "Trader", "Guard", "wegwgweg", "gtgtgtg", "z12345678910111213141516171819"
            }
        }
    }
}

return config
