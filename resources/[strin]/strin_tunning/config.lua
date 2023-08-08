Inventory = exports.ox_inventory
VehicleShop = exports.strin_vehicleshop

if(IsDuplicityVersion()) then
    StrinJobs = exports.strin_jobs
    Base = exports.strin_base
    Society = exports.strin_society
end

TunningZones = {
    /*{
        label = "Star Screamers",
        coords = vector3(0, 0, 0)
    },*/
    {
        label = "Star Screamers",
        coords = vector3(731.74468994141, -1088.7290039063, 22.169044494629),
        society = "police",
        societyCut = 0.20,
    },
}

MaxTicketsPerVehicle = 3

CarParts = {
    Upgrades = {
        modEngine = {
            label = _U("engine"),
            modType = 11,
            price = {13.95, 32.56, 65.12, 139.53}
        },
        modBrakes = {
            label = _U("brakes"),
            modType = 12,
            price = {4.65, 9.3, 18.6, 13.95}
        },
        modTransmission = {
            label = _U("transmission"),
            modType = 13,
            price = {13.95, 20.93, 46.51}
        },
        modSuspension = {
            label = _U("suspension"),
            modType = 15,
            price = {3.72, 7.44, 14.88, 29.77, 40.2}
        },
        modArmor = {
            label = _U("armor"),
            modType = 16,
            price = {69.77, 116.28, 130.00, 150.00, 180.00, 190.00}
        },
        modTurbo = {
            label = _U("turbo"),
            modType = 17,
            price = {55.81}
        },
    },
    Cosmetics = {
        modPlateHolder = {
            label = _U('modplateholder'),
            modType = 25,
            price = 3.49
        },
        modVanityPlate = {
            label = _U('modvanityplate'),
            modType = 26,
            price = 1.1
        },
        modTrimA = {
            label = _U('interior'),
            modType = 27,
            price = 6.98
        },
        modOrnaments = {
            label = _U('trim'),
            modType = 28,
            price = 0.9
        },
        modDashboard = {
            label = _U('dashboard'),
            modType = 29,
            price = 4.65
        },
        modDial = {
            label = _U('speedometer'),
            modType = 30,
            price = 4.19
        },
        modDoorSpeaker = {
            label = _U('door_speakers'),
            modType = 31,
            price = 5.58
        },
        modSeats = {
            label = _U('seats'),
            modType = 32,
            price = 4.65
        },
        modSteeringWheel = {
            label = _U('steering_wheel'),
            modType = 33,
            price = 4.19
        },
        modShifterLeavers = {
            label = _U('gear_lever'),
            modType = 34,
            price = 3.26
        },
        modAPlate = {
            label = _U('quarter_deck'),
            modType = 35,
            price = 4.19
        },
        modSpeakers = {
            label = _U('speakers'),
            modType = 36,
            price = 6.98
        },
        modTrunk = {
            label = _U('trunk'),
            modType = 37,
            price = 5.58
        },
        modHydraulics = {
            label = _U('hydraulic'),
            modType = 38,
            price = 5.12
        },
        modEngineBlock = {
            label = _U('engine_block'),
            modType = 39,
            price = 5.12
        },
        modAirFilter = {
            label = _U('air_filter'),
            modType = 40,
            price = 3.72
        },
        modStruts = {
            label = _U('struts'),
            modType = 41,
            price = 6.51
        },
        modArchCover = {
            label = _U('arch_cover'),
            modType = 42,
            price = 4.19
        },
        modAerials = {
            label = _U('aerials'),
            modType = 43,
            price = 1.12
        },
        modTrimB = {
            label = _U('wings'),
            modType = 44,
            price = 6.05
        },
        modTank = {
            label = _U('fuel_tank'),
            modType = 45,
            price = 4.19
        },
        modWindows = {
            label = _U('windows'),
            modType = 46,
            price = 4.19
        },
        modLivery = {
            label = _U('stickers'),
            modType = 48,
            price = 9.3
        },
        wheels = {
            modFrontWheels = {
                label = _U('wheel_type'),
                modType = 23,
                wheelTypes = {
                    {
                        index = 0,
                        label = _U('sport'),
                        price = 4.65
                    }, 
                    {
                        index = 1,
                        label = _U('muscle'),
                        price = 4.19
                    },
                    {
                        index = 2,
                        label = _U('lowrider'),
                        price = 4.65
                    },
                    {
                        index = 3,
                        label = _U('suv'),
                        price = 4.19
                    },
                    {
                        index = 4,
                        label = _U('allterrain'),
                        price = 4.19
                    },
                    {
                        index = 5,
                        label = _U('tuning'),
                        price = 5.12
                    },
                    {
                        index = 6,
                        label = _U('motorcycle'),
                        price = 3.26
                    },
                    {
                        index = 7,
                        label = _U('highend'),
                        price = 5.12
                    }
                }
            },
            wheelColor = {
                label = _U('wheel_color'),
                modType = 'wheelColor',
                price = 0.66
            },
            tyreSmokeColor = {
                label = _U('tyresmoke'),
                modType = 'tyreSmokeColor',
                price = 1.12
            }
        },
    
        /*plateIndex = {
            label = _U('licenseplates'),
            parent = 'cosmetics',
            modType = 'plateIndex',
            price = 1.1
        },*/
        respray = {
            color1 = {
                label = _U('primary'),
                modType = 'color1',
                price = 1.12
            },
            color2 = {
                label = _U('secondary'),
                modType = 'color2',
                price = 0.66
            },
            pearlescentColor = {
                label = _U('pearlescent'),
                modType = 'pearlescentColor',
                price = 0.88
            },
        },
        modXenon = {
            label = _U('headlights'),
            modType = 22,
            price = 3.72
        },
        windowTint = {
            label = _U('windowtint'),
            modType = 'windowTint',
            price = 1.12
        },
        modHorns = {
            label = _U('horns'),
            modType = 14,
            price = 1.12
        },
        neonColor = {
            label = _U('neons'),
            modType = 'neonColor',
            price = 1.12
        },
        bodyparts = {
            modSpoilers = {
                label = _U('spoilers'),
                modType = 0,
                price = 4.65
            },
            modFrontBumper = {
                label = _U('frontbumper'),
                modType = 1,
                price = 5.12
            },
            modRearBumper = {
                label = _U('rearbumper'),
                modType = 2,
                price = 5.12
            },
            modSideSkirt = {
                label = _U('sideskirt'),
                modType = 3,
                price = 4.65
            },
            modExhaust = {
                label = _U('exhaust'),
                modType = 4,
                price = 5.12
            },
            modFrame = {
                label = _U('cage'),
                modType = 5,
                price = 5.12
            },
            modGrille = {
                label = _U('grille'),
                modType = 6,
                price = 3.72
            },
            modHood = {
                label = _U('hood'),
                modType = 7,
                price = 4.88
            },
            modFender = {
                label = _U('leftfender'),
                modType = 8,
                price = 5.12
            },
            modRightFender = {
                label = _U('rightfender'),
                modType = 9,
                price = 5.12
            },
            modRoof = {
                label = _U('roof'),
                modType = 10,
                price = 5.58
            },
        }
    }
}

CarNeons = {
    { label = "Žádný", r = 0, g = 0, b = 0 },
    { label = _U('white'), r = 255, g = 255, b = 255 },
    { label = "Slate Gray", r = 112, g = 128, b = 144 },
    { label = "Blue", r = 0, g = 0, b = 255 },
    { label = "Light Blue", r = 0, g = 150, b = 255 },
    { label = "Navy Blue", r = 0, g = 0, b = 128 },
    { label = "Sky Blue", r = 135, g = 206, b = 235 },
    { label = "Turquoise", r = 0, g = 245, b = 255 },
    { label = "Mint Green", r = 50, g = 255, b = 155 },
    { label = "Lime Green", r = 0, g = 255, b = 0 },
    { label = "Olive", r = 128, g = 128, b = 0},
    { label = _U('yellow'), r = 255, g = 255, b = 0 },
    { label = _U('gold'), r = 255, g = 215, b = 0 },
    { label = _U('orange'), r = 255, g = 165, b = 0 },
    { label = _U('wheat'), r = 245, g = 222, b = 179 },
    { label = _U('red'), r = 255, g = 0, b = 0 },
    { label = _U('pink'), r = 255, g = 161, b = 211 },
    { label = _U('brightpink'), r = 255, g = 0, b = 255 },
    { label = _U('purple'), r = 153, g = 0, b = 153 },
    { label = "Ivory", r = 41, g = 36, b = 33 }
}

CarXenonColours = {
    { label = 'Žádné xenony', value = 255 },
    { label = 'Darkblue', value = 1 },
    { label = 'Lightblue', value = 2 },
    { label = 'Turquoise', value = 3 },
    { label = 'Green', value = 4 },
    { label = 'Yellow', value = 5 },
    { label = 'Gold', value = 6 },
    { label = 'Orange', value = 7 },
    { label = 'Red', value = 8 },
    { label = 'Pink', value = 9 },
    { label = 'Violet', value = 10 },
    { label = 'Purple', value = 11 },
    { label = 'Ultraviolet', value = 12 },
}

CarWindowTintNames = {
    "Pure Black",
    "Darksmoke",
    "Lightsmoke",
    "Limo",
    "Green",
}

CarHornNames = {
    [-1] = "Default Horn",
    [0] = "Truck Horn", -- lua indexing SO FUN PÍČO fix yo fuckoing lang
    "Cop Horn",
    "Clown Horn",
    "Musical Horn 1",
    "Musical Horn 2",
    "Musical Horn 3",
    "Musical Horn 4",
    "Musical Horn 5",
    "Sad Trombone",
    "Classical Horn 1",
    "Classical Horn 2",
    "Classical Horn 3",
    "Classical Horn 4",
    "Classical Horn 5",
    "Classical Horn 6",
    "Classical Horn 7",
    "Scale - Do",
    "Scale - Re",
    "Scale - Mi",
    "Scale - Fa",
    "Scale - Sol",
    "Scale - La",
    "Scale - Ti",
    "Scale - Do",
    "Jazz Horn 1",
    "Jazz Horn 2",
    "Jazz Horn 3",
    "Jazz Horn Loop",
    "Star Spangled Banner 1",
    "Star Spangled Banner 2",
    "Star Spangled Banner 3",
    "Star Spangled Banner 4",
    "Classical Horn 8 Loop",
    "Classical Horn 9 Loop",
    "Classical Horn 10 Loop",
    "Classical Horn 8",
    "Classical Horn 9",
    "Classical Horn 10",
    "Funeral Loop",
    "Funeral",
    "Spooky Loop",
    "Spooky",
    "San Andreas Loop",
    "San Andreas",
    "Liberty City Loop",
    "Liberty City",
    "Festive 1 Loop",
    "Festive 1",
    "Festive 2 Loop",
    "Festive 2",
    "Festive 3 Loop",
    "Festive 3"
}

CarColours = {
    "black", "white", "red", "pink", "blue", "yellow",
    "green", "orange", "brown", "purple", "chrome", "gold"
}