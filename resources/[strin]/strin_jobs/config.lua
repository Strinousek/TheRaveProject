DistressJobs = {"fire", "ambulance", "police", "sheriff"}
LawEnforcementJobs = {"police", "sheriff"}

RespawnTimer = 10 * 1000
RespawnLocation = vector3(298.33584594727, -584.37945556641, 43.260829925537)

VehiclePreviewLocation = vector3(-1609.4752197266, -2754.5395507813, 13.944689750671)

ShopLabels = {
    ["Storages"] = "Nákup předmětů",
    ["Armories"] = "Nákup zbraní",
    ["Vehicles"] = "Nákup vozidel",
}

Jobs = {
    ["police"] = {
        Zones = {
            Storages = {
                vector3(456.20928955078, -979.27709960938, 30.68957901001),
            },
            Armories = {
                vector3(461.25555419922, -982.62622070313, 30.68957901001),
            },
            BossOffices = {
                vector3(447.96542358398, -973.25769042969, 30.689577102661),
            },
            Shops = {
                {
                    coords = vector3(455.05435180664, -983.09350585938, 30.68957901001),
                    stocks = {
                        { name = "lockpick", price = 100 },
                        { name = "phone", price = 80 },
                    },
                    target = "Storages",
                },
                {
                    coords = vector3(461.4602355957, -979.48291015625, 30.68957901001),
                    stocks = {
                        { name = "WEAPON_PISTOL50", price = 0 }
                    },
                    target = "Armories",
                },
                {
                    coords = vector3(458.88482666016, -1007.9605102539, 28.265716552734),
                    stocks = {
                        { name = "police", price = 0},
                        { name = "police2", price = 0}
                    },
                    target = "Vehicles",
                },
            },
            Helipads = {
                {
                    coords = vector3(463.03466796875, -982.13525390625, 43.69193649292),
                    spawn = {
                        coords = vector3(450.08776855469, -981.07330322266, 43.691696166992),
                        heading = 90.0,
                    },
                    options = {"maverick"}
                }
            },
        },
        Actions = { "billing", "medical", "mechanic" },
        Blips = {
            sprite = 60,
            colour = 38,
            prefix = "[LSPD]",
            canSee = { "fire", "ambulance" }
        },
        StaticBlips = {
            {
                coords = vector3(431.68566894531, -981.59759521484, 30.710618972778),
                sprite = 60,
                colour = 38,
                label = "~b~Mission Row Police Department"
            }
        }
    },
    ["ambulance"] = {
        Zones = {
            Storages = {
                vector3(309.2922668457, -602.89489746094, 43.291839599609),
            },
            BossOffices = {
                vector3(311.07174682617, -599.37237548828, 43.291820526123),
            },
            Shops = {
                {
                    coords = vector3(455.05435180664, -983.09350585938, 30.68957901001),
                    stocks = {
                        { name = "bandage", price = 100 },
                    },
                    target = "Storages",
                },
                {
                    coords = vector3(458.88482666016, -1007.9605102539, 28.265716552734),
                    stocks = {
                        { name = "ambulance", price = 0},
                    },
                    target = "Vehicles",
                },
            },
        },
        Blips = {
            sprite = 61,
            colour = 49,
            showCone = false,
            prefix = "[EMS]",
            canSee = { "police" }
        },
        StaticBlips = {
            {
                coords = vector3(298.62191772461, -584.3896484375, 43.260818481445),
                sprite = 61,
                colour = 49,
                label = "~r~Pillbox Hospital"
            }
        },
        Actions = { "billing", "medical" },
    },
    ["starscreamers"] = {
        Society = {
            label = "Star Screamers",
        },
        Actions = { "billing", "medical", "mechanic" },
    }
}