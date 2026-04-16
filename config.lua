Config = Config or {}

Config.LogsImage = ""
Config.WebHook = ""
Config.FuelSystem = "LegacyFuel"
Config.UsePreviewMenuSync = false
Config.UseMarkerInsteadOfMenu = true
Config.SetVehicleTransparency = 'low'

Config.Vehicles = {
    [1] = {
        vehiclename = "Police Cruiser",
        vehicle     = "police",
        price       = 0,
        grade       = 0,
        job         = "police"
    },
    [2] = {
        vehiclename = "State Patrol Charger",
        vehicle     = "npolchar",
        price       = 0,
        grade       = 0,
        job         = "state"
    }
}

Config.RepairLocations = {
    {
        coords   = vector3(449.31, -976.0, 25.0),
        distance = 5.0
    }
}

Config.BoatsLocations = {
    {
        coords = vector3(-3075.82, 3201.35, 2.2),
        spawnCoords = vector4(-3053.38, 3179.07, -0.42, 222.72),
        despawnCoords = vector4(-3053.38, 3179.07, -0.42, 222.72)
    }
}

Config.OrtakHeli = {
    police = {
        coords       = vector3(449.31, -981.31, 43.69),
        spawnCoords  = vec4(449.31, -981.31, 43.69, 358.27),
        despawnCoords= vec4(449.31, -981.31, 43.69, 358.27)
    },
    state = {
        coords       = vector3(850.96, -1397.68, 26.13),
        spawnCoords  = vector4(850.96, -1397.68, 26.13, 143.67),
        despawnCoords= vector4(850.96, -1397.68, 26.13, 143.67)
    },
    ranger = {
        coords       = vector3(426.45, 721.05, 199.08),
        spawnCoords  = vector4(426.45, 721.05, 199.08, 91.21),
        despawnCoords= vector4(426.45, 721.05, 199.08, 91.21)
    },
    sheriff = {
        coords       = vector3(2511.33, -342.96, 118.19),
        spawnCoords  = vector4(2511.42, -342.81, 118.19, 49.52),
        despawnCoords= vector4(2511.42, -342.81, 118.19, 49.52)
    }
}