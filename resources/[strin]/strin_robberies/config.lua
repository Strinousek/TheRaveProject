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