local config = {
    user = {
        nick = "orange_juice_",
        timezone = 4
    },
    chatbox = {
        name = "Алиса",
        permissions = {
            ["orange_juice_"] = true,
        }
    },
    reactors = {
        cooling = {
            item = { name = "ae2fc:fluid_drop" },
            limits = {
                minimum = 50000,
                recommended = 900000
            }
        }
    },
    screen = {
        width = 104,
        height = 31
    },
    updateTimers = {
        reactors = 10,
        tps = 5,
        energy = 1,
        radar = 1,
        render = 0.2
    },
    energy = {
        -- Окно усреднения input в секундах
        -- Значение на экране обновляется раз в это время.
        windowSeconds = 5
    },
    radar = {
        maxUsers = 14
    }
}

return config
