
LUMBERJACK_LOG_VEHICLES = {
    `bodhi2`, `caracara2`, `dloader`, `dubsta3`, `everon`,
    `kalahari`, `kamacho`, `rebel`, `rebel2`, `riata`, `sandking`,
    `sandking2`, `yosemite3`, `guardian`, `tiptruck`, `sadler`,
    `bison`, `bison`, `bobcatxl`
}

LUMBERJACK_LOG_AXES = {
    `WEAPON_HATCHET`,
    `WEAPON_BATTLEAXE`
}

LUMBERJACK_DROP_OFF_COORDS = vector3(1207.6315917969, 1856.4282226563, 78.911529541016)

LUMBERJACK_CHOP_TIME = 2 * 3000
LUMBERJACK_TREE_LOG_PRICE = 120

LUMBERJACK_LOG_MODEL = `prop_log_01`
LUMBERJACK_TREE_MODEL = `prop_tree_jacada_02`

LUMBERJACK_ANIMATIONS = {
    ["LOG"] = {
        dict = "anim@heists@box_carry@",
        clip = "idle",
    },
    ["CHOPPING"] = {
        dict = "melee@hatchet@streamed_core",
        clip = "plyr_rear_takedown_b",
    },
}

LUMBERJACK_TREE_SPOTS = {
    {
        vector3(1448.8431396484, 1315.7213134766, 114.6813583374),
        vector3(1438.7122802734, 1302.3394775391, 113.26952362061),
        vector3(1431.1046142578, 1310.3514404297, 113.5249786377),
    },
    {
        vector3(1422.5356445313, 1319.6436767578, 109.92990875244),
        vector3(1430.2136230469, 1327.2947998047, 110.70417022705),
        vector3(1445.5656738281, 1330.3978271484, 112.82506561279),
    },
    {
        vector3(1461.3983154297, 1341.0971679688, 113.11226654053),
        vector3(1468.7124023438, 1353.0932617188, 112.31470489502),
        vector3(1479.0294189453, 1343.0034179688, 113.24984741211),
    },
    {
        vector3(1418.2062988281, 1360.3353271484, 106.89709472656),
        vector3(1400.5701904297, 1346.3265380859, 105.65790557861),
        vector3(1387.5881347656, 1355.2336425781, 104.6410369873),
    },
    {
        vector3(1394.7447509766, 1372.3970947266, 104.91941070557),
        vector3(1387.7901611328, 1386.3521728516, 104.06980895996),
        vector3(1400.9133300781, 1393.3972167969, 104.34912109375),
    }
}