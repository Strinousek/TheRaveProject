GYMS = {
    {
        coords = vector3(-1201.1552734375, -1569.0455322266, 4.6101989746094),
        radius = 15.0,
    }
}

LOCALE = "cs"

LOCALES = {
    ["cs"] = {
        ["barbell_curl"] = "Barbell Curl",
        ["reverse_barbell_curl"] = "Reverse Barbell Curl",
        ["chin_up"] = "Přítah podhmatem",
        ["push_up"] = "Klik",
        ["situp"] = "Sedleh",
        ["squat"] = "Dřep",
        ["jumping_jack"] = "Jumping Jack",
    }
}

EXERCISE_TYPES = {
    ["barbell_curl"] = {
        requiresGym = true,
        models = {
            `prop_barbell_01`,
            `prop_weight_rack_02`,
            `prop_weight_rack_01`,  
        },
        prop = {
            model = `prop_curl_bar_01`,
            bone = 28422,
            placement = {
                0.0, 
                0.5, 
                0.2, 
                2.0, 
                2.0, 
                2.0
            }
        },
        anim = {
            dict = "amb@world_human_muscle_free_weights@male@barbell@base",
            clip = "base"
        }
    },
    ["reverse_barbell_curl"] = {
        requiresGym = true,
        models = {
            `prop_barbell_01`,
            `prop_weight_rack_02`,
            `prop_weight_rack_01`,  
        },
        prop = {
            model = `prop_curl_bar_01`,
            bone = 28422,
            placement = {
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0
            }
        },
        anim = {
            dict = "amb@world_human_muscle_free_weights@male@barbell@idle_a",
            clip = "idle_d"
        }
    },
    ["chin_up"] = {
        models = {
            `prop_muscle_bench_05`
        },
        anim = {
            scenario = "PROP_HUMAN_MUSCLE_CHIN_UPS",
        }
    },
    ["push_up"] = {
        anim = {
            dict = "amb@world_human_push_ups@male@idle_a",
            clip = "idle_d",
        }
    },
    ["situp"] = {
        anim = {
            dict = "mouse@situp",
            clip = "situp_clip",
        }
    },
    ["squat"] = {
        anim = {
            dict = "mouse@air_squat",
            clip = "air_squat_clip",
        }
    },
    ["jumping_jack"] = {
        anim = {
            dict = "mouse@jump_jack",
            clip = "jump_jack_clip",
        }
    },
}