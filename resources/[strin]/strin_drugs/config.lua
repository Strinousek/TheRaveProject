Inventory = exports.ox_inventory
Base = exports.strin_base
LawEnforcementJobs = exports.strin_jobs:GetLawEnforcementJobs()

WeedModelHashes = {
    `bkr_prop_weed_bud_02a`,
    `prop_weed_02`,
    `prop_weed_01`,
    /*
        `bkr_prop_weed_01_small_01a`,
        `bkr_prop_weed_01_small_01b`,
        `bkr_prop_weed_01_small_01c`
    */
}

MicrowavesModelHashes = {
    `prop_microwave_1`,
    `prop_micro_01`,
    `prop_micro_02`,
    `prop_micro_04`,
    `prop_micro_cs_01`,
    `prop_micro_cs_01_door`,
}

DehydratorModelHash = `bkr_prop_coke_dehydrator_01`
LSDPrice = 200

if(IsDuplicityVersion()) then
    Property = exports.esx_property
    SoilMaterials = {
        2409420175, 3008270349, 3833216577, 223086562,
        1333033863, 4170197704, 3594309083, 2461440131,
        1109728704, 2352068586, 1144315879, 581794674,
        2128369009, -461750719, -1286696947
    }

    WeedPlantStageTimers = { [1] = 0, [2] = 30, [3] = 60 }
    WeedJointPrice = { 20, 40 }
    WeedBudHarvestAmount = { 1, 3 }

    ---If field `item` is not set in `locations` element and neither in `SyntheticDrugLoot`, the `drug key name` is used. Avoid this please.
    ---@class SyntheticDrugLoot
    ---@field item? string Default name of item that will be given to player after he picks up the loot on all locations that don't have the `item` field set.
    ---@field itemCount? integer Amount of `item` that will be given to player after he picks up the loot. Default is `1`.
    ---@field respawnCount integer | true `true` to respawn all or `integer` to respawn only specified amount if needed
    ---@field respawnTimer integer Time in milliseconds for the desired spot to spawn new loot.  
    ---@field locations table<integer, { item?: string, coords: vector3, radius: number, count: number }>

    ---@class SyntheticDrug
    ---@field harvestables SyntheticDrugLoot
    ---@field chemicals SyntheticDrugLoot

    ---@type table<string, SyntheticDrug>
    SyntheticDrugs = {
        meth = {
            harvestables = {
                item = "ephedrine",
                respawnCount = 1,
                respawnTimer = 6,
                locations = {
                    {
                        coords = vector3(815.80456542969, 156.9449005127, 80.96996307373),
                        radius = 30,
                        count = 5,
                    }
                }
            },
            chemicals = {
                item = "phenylactic_acid",
                respawnCount = 1,
                respawnTimer = 6,
                locations = {
                    {
                        coords = vector3(0, 0, 0),
                        radius = 30,
                        count = 5,
                    }
                }
            },
        }
    }

    WeightingSpots = {
        
    }
else
    Target = exports.ox_target
    /*Inventory:displayMetadata({
        state = "Stav"
    })*/
end