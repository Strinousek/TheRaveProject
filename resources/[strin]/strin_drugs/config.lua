Inventory = exports.ox_inventory

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

if(IsDuplicityVersion()) then
    Property = exports.esx_property
    LawEnforcementJobs = exports.strin_jobs:GetLawEnforcementJobs()
    SoilMaterials = {
        2409420175, 3008270349, 3833216577, 223086562,
        1333033863, 4170197704, 3594309083, 2461440131,
        1109728704, 2352068586, 1144315879, 581794674,
        2128369009, -461750719, -1286696947
    }

    -- In minutes
    WeedPlantStageTimers = {
        [1] = 0,
        [2] = 30,
        [3] = 60
    }

    WeedJointPrice = { 200, 400 }
else
    Target = exports.ox_target
    Inventory:displayMetadata({
        state = "Stav"
    })
end