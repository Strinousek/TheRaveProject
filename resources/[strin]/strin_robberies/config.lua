/*
	Cash Registers Config
*/

CashRegistersHashes = {
    -- `v_ret_gc_cashreg`, -- store register (clothe stores etc..)
    `prop_till_01`,
    `p_till_01_s`,
    `prop_till_02`
}

CashRegisters = {
	vector3(-46.76, -1758.04, 29.42),
	vector3(-47.86, -1759.35, 29.42),
	vector3(24.41, -1347.45, 29.5),
	vector3(24.49, -1345.04, 29.5),
	vector3(372.57, 326.44, 103.57),
	vector3(373.08, 328.78, 103.57),
	vector3(-706.06, -913.59, 19.22),
	vector3(-706.07, -915.4, 19.22),
}

CashRegistersRobberyTime = 1200 * 1000 -- 1200 * 1000
CashRegistersRefreshTime = 30 * 60000 -- 30 * 60000 
CashRegistersRequiredCops = 2 -- 2

CashRegistersPayOut = { 3000, 4000 }

/*
	Jewelery Config
*/

-- JeweleryRobberyTime = 1200 * 1000 -- 1200 * 1000
JeweleryRefreshTime = 60 * 60000 -- 30 * 60000 
JeweleryRequiredCops = 4 -- 4
--JeweleryRequiredCops = 0 -- 4
JeweleryCaseRobTime = 3 * 1000

/*JeweleryCaseTypes = {
    {
        name = "des_jewel_cab_start,
		size = "medium,
		content = { ""ring", ""watch" },
    }, -- {"37228785"]
    {
        name = "des_jewel_cab2_start,
		size = "medium,
		content = { ""ring"" },
    }, -- {"1846370968"]
    {
        name = "des_jewel_cab3_start,
		size = "medium,
		content = { ""ring"" },
    }, -- {"1768229041"]
    {
        name = "des_jewel_cab4_start,
		size = "medium,
		content = { ""ring"" },
    }, -- {"-1880169779"]
    {
        name = "prop_jewel_glass,
		size = "small,
		content = { ""necklace"" },
    }, -- {"1982992541"]

	-- Nepoužité modely šperků / krabiček od šperků apod, save for later use yk - strin
    --["-1469834270"] = "des_jewel_cab_end,
    --["-1425822065"] = "des_jewel_cab_root,
    --["-1342906936"] = "des_jewel_cab_root2,
    --["1097883532"] = "des_jewel_cab2_end,
    --["728048740"] = "des_jewel_cab2_root,
    --["-1762788570"] = "des_jewel_cab2_rootb,
    --["2103335194"] = "des_jewel_cab3_end,
    --["1488444473"] = "des_jewel_cab3_root,
    --["2035340319"] = "des_jewel_cab3_rootb,
    --["-677416883"] = "des_jewel_cab4_end,
    --["-1087326352"] = "des_jewel_cab4_root,
    --["-1255152186"] = "des_jewel_cab4_rootb,
    --["-304401110"] = "prop_jewel_glass_root,
}*/

JeweleryCases = {
   {
      coords = vector3(
          -619.9662475585938,
          -226.197998046875,
          37.64522552490234
        ),
      content = {
          "ring",
          "watch"
        },
      size = "medium"
    },
    {
      coords = vector3(
          -620.1763916015625,
          -230.78652954101563,
          37.64522552490234
    ),
      content = {
          "ring",
          "watch"
        },
      size = "medium"
    },
    {
      coords = vector3(
          -626.5438842773438,
          -233.60470581054688,
          37.64522552490234
    ),
      content = {
          "ring",
          "watch"
        },
      size = "medium"
    },
    {
      coords = vector3(
          -627.5945434570313,
          -234.36776733398438,
          37.64522552490234
    ),
      content = {
          "ring",
          "watch"
        },
      size = "medium"
    },
    {
      coords = vector3(
          -619.8483276367188,
          -234.9137420654297,
          37.64522552490234
    ),
      content = {
          "ring",
          "watch"
        },
      size = "medium"
    },
    {
      coords = vector3(
          -622.6159057617188,
          -232.5635986328125,
          37.64522552490234
    ),
      content = {
          "ring",
          "watch"
        },
      size = "medium"
    },
    {
      coords = vector3(
          -617.0855712890625,
          -230.16268920898438,
          37.64522552490234
    ),
      content = {
          "ring"
        },
      size = "medium"
    },
    {
      coords = vector3(
          -626.324951171875,
          -239.0508575439453,
          37.64522552490234
    ),
      content = {
          "ring"
        },
      size = "medium"
    },
    {
      coords = vector3(
          -623.6146850585938,
          -228.62472534179688,
          37.64522552490234
    ),
      content = {
          "ring"
        },
      size = "medium"
    },
    {
      coords = vector3(
          -619.2030639648438,
          -227.24819946289063,
          37.64522552490234
    ),
      content = {
          "ring"
        },
      size = "medium"
    },
    {
      coords = vector3(
          -618.7984008789063,
          -234.1509246826172,
          37.64522552490234
    ),
      content = {
          "ring"
        },
      size = "medium"
    },
    {
      coords = vector3(
          -625.3299560546875,
          -227.3697052001953,
          37.64522552490234
    ),
      content = {
          "ring"
        },
      size = "medium"
    },
    {
      coords = vector3(
          -627.2114868164063,
          -234.89422607421876,
          37.64522552490234
    ),
      content = {
          "ring"
        },
      size = "medium"
    },
    {
      coords = vector3(
          -617.8491821289063,
          -229.11276245117188,
          37.64522552490234
    ),
      content = {
          "ring"
        },
      size = "medium"
    },
    {
      coords = vector3(
          -625.275146484375,
          -238.28814697265626,
          37.64522552490234
    ),
      content = {
          "ring"
        },
      size = "medium"
    },
    {
      coords = vector3(
          -621.5175170898438,
          -228.9473876953125,
          37.64522552490234
    ),
      content = {
          "ring"
        },
      size = "medium"
    },
    {
      coords = vector3(
          -620.5214233398438,
          -232.88229370117188,
          37.64522552490234
    ),
      content = {
          "ring"
        },
      size = "medium"
    },
    {
      coords = vector3(
          -626.1613159179688,
          -234.13148498535157,
          37.64522552490234
    ),
      content = {
          "ring"
        },
      size = "medium"
    },
    {
      coords = vector3(
          -623.955810546875,
          -230.7262725830078,
          37.64522552490234
    ),
      content = {
          "ring"
        },
      size = "medium"
    },
    {
      coords = vector3(
          -624.2796020507813,
          -226.60655212402345,
          37.64522552490234
    ),
      content = {
          "ring"
        },
      size = "medium"
    },
    {
      coords = vector3(
          -628.1244506835938,
          -226.657958984375,
          37.90004348754883
    ),
      content = {
          "necklace"
        },
      size = "small"
    },
    {
      coords = vector3(
          -627.9912719726563,
          -225.1247100830078,
          37.90004348754883
    ),
      content = {
          "necklace"
        },
      size = "small"
    },
    {
      coords = vector3(
          -627.05078125,
          -223.9077911376953,
          37.90004348754883
    ),
      content = {
          "necklace"
        },
      size = "small"
    },
    {
      coords = vector3(
          -616.0143432617188,
          -234.87042236328126,
          37.90004730224609
    ),
      content = {
          "necklace"
        },
      size = "small"
    },
    {
      coords = vector3(
          -616.1475830078125,
          -236.4036865234375,
          37.90004730224609
    ),
      content = {
          "necklace"
        },
      size = "small"
    },
    {
      coords = vector3(
          -617.0880737304688,
          -237.62059020996095,
          37.90004730224609
    ),
      content = {
          "necklace"
        },
      size = "small"
    },
    {
      coords = vector3(
          -618.5360107421875,
          -238.13902282714845,
          37.90004730224609
    ),
      content = {
          "necklace"
        },
      size = "small"
    },
    {
      coords = vector3(
          -620.0354614257813,
          -237.79193115234376,
          37.89984512329101
    ),
      content = {
          "necklace"
        },
      size = "small"
    },
    {
      coords = vector3(
          -625.602783203125,
          -223.38937377929688,
          37.90004348754883
    ),
      content = {
          "necklace"
        },
      size = "small"
    },
    {
      coords = vector3(
          -624.1033935546875,
          -223.73646545410157,
          37.90004348754883
    ),
      content = {
          "necklace"
        },
      size = "small"
    }
}

Jewelery = {
    centerCoords = vector3(-624.62414550781, -232.45332336426, 38.057014465332),
	  securityDoorModel = "v_ilev_j2_door"
}

/*
	Bank Config
*/

BanksRefreshTime = 60 * 60000 -- 30 * 60000 
BanksRequiredCops = 6 -- 6
BanksRobTime = 15 * 60000
--BanksRobTime = 1 * 15000
BanksHackingTimers = { 30, 20, 20, 10 }
--BanksHackingTimers = { 30 }
--BanksVaultDoorModel = "v_ilev_gb_vauldr"
BanksDeviceModel = "p_ld_id_card_01"
BanksPayOut = { 5000, 6000 }

Banks = {
    {
        coords = vector3(147.07473754882813, -1045.070556640625, 29.36812782287597),
        codeLock = {
            coords = vector3(146.771225, -1046.119507, 29.368101),
            heading = 250.40830993652,
        },
    },
    {
        coords = vector3(-1211.43359375, -335.5160217285156, 37.78129196166992),
        codeLock = {
            coords = vector3(-1210.816406, -336.573364, 37.781075),
            heading = 298.14511108398,
        },
    },
    {
        coords = vector3(-353.8560485839844, -54.1714859008789, 49.04552459716797),
        codeLock = {
            coords = vector3(-354.046478, -55.331898, 49.036621),
            heading = 248.19436645508,
        },
    },
    {
        coords = vector3(311.2804870605469, -283.23974609375, 4.17374420166015),
        codeLock = {
            coords = vector3(314.666901, -282.389435, 61.361099),
            heading = 234.86322021484,
        },
    },
    {
        coords = vector3(-2957.62451171875, 481.6453857421875, 15.69703483581543),
        codeLock = {
            coords = vector3(-2956.502930, 481.694519, 15.697084),
            heading = 356.89260864258,
        },
    },
    {
        coords = vector3(1176.2742919921876, 2711.68505859375, 38.08882904052734),
        codeLock = {
            coords = vector3(1176.158081, 2712.890381, 38.088020),
            heading = 87.77075958252,
        },
    }
}

/*
  HOUSES
*/

HousesTypes = {
  ["LOW_TIER"] = {
      reportChance = 5,
      chanceToFindNothing = 55,
      items = {
          { item = "phone", chance = 5, minCount = 1, maxCount = 1 },
          { item = "ring", chance = 5, minCount = 1, maxCount = 2 },
          { item = "watch", chance = 5, minCount = 1, maxCount = 1 },
          { item = "necklace", chance = 5, minCount = 1, maxCount = 1 },
          { item = "lockpick", chance = 10, minCount = 1, maxCount = 1 },
          { item = "toolkit", chance = 20, minCount = 1, maxCount = 1 },
          { item = "weed_seed", chance = 30, minCount = 1, maxCount = 2 },
      },
      needPoliceCount = 2,
      insidePositions = {
          ["Exit"] = vec4(265.01303100586, -1001.1868286132, -99.008689880372, 0.83740812540054),
          ["Saffron"] = vec3(265.937714, -999.368348, -99.008666),
          ["Kitchen"] = vec3(265.805358, -996.243408, -99.008666),
          ["Shelves"] = vec3(262.050964, -995.239990, -99.008666),
          ["TV"] = vec3(256.789948, -996.051270, -99.008666),
          ["Bedroom"] = vec3(262.027314, -1002.559998, -99.008666),
          ["Mirror"] = vec3(255.623292, -1000.462220, -99.009842)
      }
  },
  ["MID_TIER"] = {
      reportChance = 80,
      chanceToFindNothing = 55,
      items = {
          { item = "phone", chance = 20, minCount = 1, maxCount = 1 },
          { item = "ring", chance = 10, minCount = 1, maxCount = 3 },
          { item = "watch", chance = 10, minCount = 1, maxCount = 2 },
          { item = "necklace", chance = 10, minCount = 1, maxCount = 2 },
          { item = "weed_seed", chance = 30, minCount = 1, maxCount = 2 },
      },
      needPoliceCount = 5,
      insidePositions = {
          ["Exit"] = vector4(346.752106, -1002.687072, -99.196258, 357.81),
          ["Saffron"] = vector3(342.23, -1003.29, -99.0),
          ["Speaker"] = vector3(338.14, -997.69, -99.2),
          ["Laptop"] = vector3(350.91, -999.26, -99.2),
          ["Bag of Cocaine"] = vector3(349.19, -994.83, -99.2),
          ["Book"] = vector3(345.3, -995.76, -99.2),
          ["Coupon"] = vector3(346.14, -1001.55, -99.2),
          ["Toothpaste"] = vector3(347.23, -994.09, -99.2),
          ["Lottery Ticket"] = vector3(339.23, -1003.35, -99.2)
      }
  },
  ["HIGH_TIER"] = {
      reportChance = 95,
      chanceToFindNothing = 55,
      items = {
        { item = "phone", chance = 15, minCount = 1, maxCount = 1 },
        { item = "ring", chance = 20, minCount = 2, maxCount = 3 },
        { item = "watch", chance = 20, minCount = 2, maxCount = 3 },
        { item = "necklace", chance = 20, minCount = 2, maxCount = 4 },
        { item = "weed_seed", chance = 10, minCount = 2, maxCount = 3 },
        { item = "joint", chance = 10, minCount = 1, maxCount = 3 },
      },
      needPoliceCount = 5,
      insidePositions = {
          ["Exit"] = vector4(-787.48413085938, 315.70617675782, 187.9133758545, 270.08288574218),
          ["Saffron"] = vec3(-788.957886, 320.741302, 187.313248),
          ["Kitchen #1"] = vec3(-783.327454, 325.411712, 187.313248),
          ["Kitchen #2"] = vec3(-782.004090, 330.077392, 187.313248),
          ["TV"] = vec3(-781.370544, 338.451324, 187.113678),
          ["Books"] = vec3(-792.645020, 329.171875, 187.313400),
          ["Heist storage"] = vec3(-794.997680, 326.787872, 187.313340),
          ["Heist computer"] = vec3(-798.083740, 322.035584, 187.313340),
          ["Stair saffron"] = vec3(-793.373352, 341.711944, 187.113678),
          ["Bedroom saffron"] = vec3(-800.065612, 338.434052, 190.716018),
          ["Locker #1"] = vec3(-799.149902, 328.694580, 190.716018),
          ["Locker #2"] = vec3(-796.366760, 328.144348, 190.716004),
          ["Bathroom"] = vec3(-806.068360, 332.405182, 190.716004)
      }
  }
}

Houses = {
  ["LOW_TIER_1"] = {
      coords = vector4(1439.9510498046, -1480.2639160156, 63.621147155762, 344.99169921875),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_2"] = {
      coords = vector4(1391.0789794922, -1508.3510742188, 58.43571472168, 27.841844558716),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_3"] = {
      coords = vector4(1344.6776123046, -1513.2449951172, 54.585018157958, 357.40856933594),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_4"] = {
      coords = vector4(1334.0083007812, -1566.462524414, 54.447093963624, 26.486280441284),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_5"] = {
      coords = vector4(1205.712524414, -1607.1795654296, 50.736503601074, 215.91757202148),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_6"] = {
      coords = vector4(1203.4724121094, -1670.4978027344, 42.98184967041, 215.35614013672),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_7"] = {
      coords = vector4(1314.3514404296, -1733.125366211, 54.700096130372, 292.40447998046),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_8"] = {
      coords = vector4(1241.1490478516, -1725.7978515625, 52.024227142334, 21.665655136108),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_9"] = {
      coords = vector4(377.73178100586, -2066.3830566406, 21.754623413086, 229.9900817871),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_10"] = {
      coords = vector4(388.68139648438, -2025.8564453125, 23.403129577636, 66.319847106934),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_11"] = {
      coords = vector4(377.2367553711, -2004.0202636718, 24.245515823364, 159.1927947998),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_12"] = {
      coords = vector4(250.80558776856, -2011.9210205078, 19.258785247802, 49.714580535888),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_13"] = {
      coords = vector4(375.8370666504, -1873.3664550782, 26.034967422486, 51.236057281494),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_14"] = {
      coords = vector4(566.24487304688, -1778.1442871094, 29.353143692016, 334.7201538086),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_15"] = {
      coords = vector4(554.64196777344, -1766.2067871094, 29.312232971192, 245.14688110352),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_16"] = {
      coords = vector4(552.44995117188, -1765.39453125, 33.442581176758, 241.41784667968),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_17"] = {
      coords = vector4(559.25463867188, -1750.914428711, 33.442588806152, 243.1700744629),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_18"] = {
      coords = vector4(295.35369873046, -1767.4598388672, 29.102558135986, 44.40385055542),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_19"] = {
      coords = vector4(470.6789855957, -1561.2846679688, 32.82721710205, 228.91326904296),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_20"] = {
      coords = vector4(430.17001342774, -1559.4747314454, 32.823333740234, 319.89874267578),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_21"] = {
      coords = vector4(460.44500732422, -1573.5128173828, 32.824443817138, 232.24485778808),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_22"] = {
      coords = vector4(-29.20470046997, -1869.3747558594, 25.33507347107, 231.6229095459),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_23"] = {
      coords = vector4(-30.070446014404, -1787.683227539, 27.820589065552, 317.04580688476),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_24"] = {
      coords = vector4(115.5834350586, -1685.7084960938, 33.49084854126, 231.84379577636),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_25"] = {
      coords = vector4(200.10475158692, -1717.4931640625, 29.474201202392, 296.79635620118),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_26"] = {
      coords = vector4(214.9253692627, -1693.251586914, 29.692222595214, 37.374946594238),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_27"] = {
      coords = vector4(182.88832092286, -1688.7075195312, 29.67063331604, 237.97708129882),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_28"] = {
      coords = vector4(-19.570234298706, -1550.7830810546, 30.676733016968, 50.03609085083),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_29"] = {
      coords = vector4(-69.262321472168, -1526.778930664, 34.235233306884, 320.82794189454),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_30"] = {
      coords = vector4(-35.73694229126, -1555.3193359375, 30.676733016968, 318.69680786132),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_31"] = {
      coords = vector4(-120.03304290772, -1574.4460449218, 34.176342010498, 139.81312561036),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_32"] = {
      coords = vector4(-224.24298095704, -1674.474975586, 34.463314056396, 357.5297241211),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_33"] = {
      coords = vector4(-121.31495666504, -1653.117553711, 32.56432723999, 142.56224060058),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_34"] = {
      coords = vector4(-147.7469177246, -1596.251586914, 38.212619781494, 240.25482177734),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_35"] = {
      coords = vector4(-216.5677947998, -1648.3937988282, 34.46322631836, 179.76997375488),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_36"] = {
      coords = vector4(-138.79573059082, -1658.9692382812, 36.514152526856, 237.0506286621),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_37"] = {
      coords = vector4(-121.61269378662, -1290.5515136718, 29.355710983276, 275.24697875976),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["LOW_TIER_38"] = {
      coords = vector4(133.22546386718, -1328.7561035156, 34.002498626708, 307.02685546875),
      houseType = HousesTypes["LOW_TIER"]
  },
  ["MID_TIER_1"] = {
      coords = vector4(-957.3041381836, -1566.759399414, 5.0187458992004, 108.65511322022),
      houseType = HousesTypes["MID_TIER"]
  },
  ["MID_TIER_2"] = {
      coords = vector4(-1063.0949707032, -1641.5561523438, 4.4911875724792, 312.95495605468),
      houseType = HousesTypes["MID_TIER"]
  },
  ["MID_TIER_3"] = {
      coords = vector4(-1078.2329101562, -1613.2375488282, 8.0473823547364, 302.19357299804),
      houseType = HousesTypes["MID_TIER"]
  },
  ["MID_TIER_4"] = {
      coords = vector4(-1093.6120605468, -1608.2810058594, 8.4588069915772, 305.02108764648),
      houseType = HousesTypes["MID_TIER"]
  },
  ["MID_TIER_5"] = {
      coords = vector4(-1144.0732421875, -1528.9401855468, 4.3452463150024, 123.14791107178),
      houseType = HousesTypes["MID_TIER"]
  },
  ["MID_TIER_6"] = {
      coords = vector4(-1150.8819580078, -1519.2153320312, 4.358250617981, 123.87828826904),
      houseType = HousesTypes["MID_TIER"]
  },
  ["MID_TIER_7"] = {
      coords = vector4(-1204.5219726562, -1021.9776000976, 5.9451127052308, 299.82635498046),
      houseType = HousesTypes["MID_TIER"]
  },
  ["MID_TIER_8"] = {
      coords = vector4(-1064.7055664062, -1057.4013671875, 6.4116525650024, 304.36849975586),
      houseType = HousesTypes["MID_TIER"]
  },
  ["MID_TIER_9"] = {
      coords = vector4(-1184.7005615234, -1045.2147216796, 2.1502439975738, 302.69815063476),
      houseType = HousesTypes["MID_TIER"]
  },
  ["MID_TIER_10"] = {
      coords = vector4(-673.05676269532, -981.23596191406, 22.340850830078, 178.18501281738),
      houseType = HousesTypes["MID_TIER"]
  },
  ["MID_TIER_11"] = {
      coords = vector4(-675.92950439454, -884.76153564454, 24.442680358886, 91.441329956054),
      houseType = HousesTypes["MID_TIER"]
  },
  ["MID_TIER_12"] = {
      coords = vector4(-1712.8016357422, -477.32983398438, 41.649452209472, 277.07681274414),
      houseType = HousesTypes["MID_TIER"]
  },
  ["MID_TIER_13"] = {
      coords = vector4(-1583.6497802734, -265.84478759766, 48.274982452392, 266.99096679688),
      houseType = HousesTypes["MID_TIER"]
  },
  ["MID_TIER_14"] = {
      coords = vector4(-410.74645996094, 159.5998840332, 73.732887268066, 259.18215942382),
      houseType = HousesTypes["MID_TIER"]
  },
  ["MID_TIER_15"] = {
      coords = vector4(-341.02062988282, 34.532775878906, 52.110355377198, 174.10987854004),
      houseType = HousesTypes["MID_TIER"]
  },
  ["MID_TIER_16"] = {
      coords = vector4(79.211891174316, -58.094482421875, 68.135429382324, 70.41944885254),
      houseType = HousesTypes["MID_TIER"]
  },
  ["MID_TIER_17"] = {
      coords = vector4(141.45469665528, -90.159469604492, 72.469116210938, 252.19720458984),
      houseType = HousesTypes["MID_TIER"]
  },
  ["MID_TIER_18"] = {
      coords = vector4(322.17245483398, -146.65382385254, 64.557716369628, 161.5998840332),
      houseType = HousesTypes["MID_TIER"]
  },
  ["MID_TIER_19"] = {
      coords = vector4(191.98303222656, 331.5291442871, 105.3996887207, 276.41870117188),
      houseType = HousesTypes["MID_TIER"]
  },
  ["HIGH_TIER_1"] = {
      coords = vector4(216.44435119628, 620.49877929688, 187.75685119628, 74.529731750488),
      houseType = HousesTypes["HIGH_TIER"]
  },
  ["HIGH_TIER_2"] = {
      coords = vector4(128.08323669434, 565.9828491211, 183.95948791504, 13.116044998168),
      houseType = HousesTypes["HIGH_TIER"]
  },
  ["HIGH_TIER_3"] = {
      coords = vector4(-70.449180603028, 359.169921875, 112.44513702392, 154.654006958),
      houseType = HousesTypes["HIGH_TIER"]
  },
  ["HIGH_TIER_4"] = {
      coords = vector4(-297.75091552734, 379.74154663086, 112.09530639648, 17.48217201233),
      houseType = HousesTypes["HIGH_TIER"]
  },
  ["HIGH_TIER_5"] = {
      coords = vector4(-378.72024536132, 548.69793701172, 124.04608917236, 232.05072021484),
      houseType = HousesTypes["HIGH_TIER"]
  },
  ["HIGH_TIER_6"] = {
      coords = vector4(-307.38409423828, 643.35284423828, 176.13484191894, 117.0717163086),
      houseType = HousesTypes["HIGH_TIER"]
  },
  ["HIGH_TIER_7"] = {
      coords = vector4(-167.55686950684, 916.00909423828, 235.6554260254, 42.985126495362),
      houseType = HousesTypes["HIGH_TIER"]
  },
  ["HIGH_TIER_8"] = {
      coords = vector4(-565.7494506836, 761.18444824218, 185.42039489746, 42.985126495362),
      houseType = HousesTypes["HIGH_TIER"]
  },
  ["HIGH_TIER_9"] = {
      coords = vector4(-745.89361572266, 589.7060546875, 142.615234375, 62.036220550538),
      houseType = HousesTypes["HIGH_TIER"]
  },
  ["HIGH_TIER_10"] = {
      coords = vector4(-972.3031616211, 752.21697998046, 176.38061523438, 47.425468444824),
      houseType = HousesTypes["HIGH_TIER"]
  },
  ["HIGH_TIER_11"] = {
      coords = vector4(-2009.2062988282, 367.52465820312, 94.814422607422, 272.41589355468),
      houseType = HousesTypes["HIGH_TIER"]
  }
}


    -- létat noclipem kolem mapy fakt nebudu lmao - strin
/*
    if(not IsDuplicityVersion()) then
        local ped = PlayerPedId()
        local vaultCodeLocks = {}
        for k,v in pairs(Banks) do
            RequestCollisionAtCoord(v.coords)
            SetEntityCoords(ped, v.coords)
            FreezeEntityPosition(ped, true)
            while not HasCollisionLoadedAroundEntity(ped) do
                Citizen.Wait(0)
            end
            FreezeEntityPosition(ped, false)
            Citizen.Wait(10000)
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            vaultCodeLocks[k] = {
                codeLock = {
                    coords = coords,
                    heading = heading
                }
            }
            if(k == #Banks) then
                break
            end
            Citizen.Wait(500)
        end
        TriggerEvent("clipboard", ESX.DumpTable(vaultCodeLocks))
    end
*/