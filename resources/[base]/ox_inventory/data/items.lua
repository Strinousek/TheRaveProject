return {

	['bandage'] = {
		label = 'Bandáž',
		weight = 115,
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 },
			prop = { model = `prop_rolled_sock_02`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
			disable = { move = true, car = true, combat = true },
			usetime = 2500,
		}
	},

	['armour'] = {
		label = 'Neprůstřelná vesta',
		weight = 3000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 3500
		}
	},

	['parachute'] = {
		label = 'Padák',
		weight = 8000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 1500
		}
	},

	['toolkit'] = {
		label = 'Toolkit',
		weight = 500,
	},

	['lockpick'] = {
		label = 'Paklíč',
		weight = 160,
	},

	['phone'] = {
		label = 'Mobil',
		weight = 190,
		stack = false,
		consume = 0,
		client = {
			add = function(total)
				if total > 0 then
					pcall(function() return exports.npwd:setPhoneDisabled(false) end)
				end
			end,

			remove = function(total)
				if total < 1 then
					pcall(function() return exports.npwd:setPhoneDisabled(true) end)
				end
			end
		}
	},

	['money'] = {
		label = 'Peníze',
	},

	['ring'] = {
		label = 'Prsten',
		weight = 25,
	},

	['watch'] = {
		label = 'Hodinky',
		weight = 100,
	},

	['necklace'] = {
		label = 'Náhrdelník',
		weight = 100,
	},

	['driving_license'] = {
		label = 'Driving License',
		stack = false,
		consume = 0,
		server = {
			export = "strin_base.use_item"
		}
	},

	['identification_card'] = {
		label = 'Identification Card',
		consume = 0,
		stack = false,
		server = {
			export = "strin_base.use_item"
		}
	},

	['ccw_permit'] = {
		label = 'CCW Permit',
		consume = 0,
		stack = false,
		/*server = {
			export = "strin_base.use_item"
		}*/
	},

	['fsc_card'] = {
		label = 'Firearms Safety Certificate',
		consume = 0,
		stack = false,
		/*server = {
			export = "strin_base.use_item"
		}*/
	},

	['handcuffs'] = {
		label = 'Pouta',
		stack = false,
		weight = 100,
	},

	['hackdeck'] = {
		label = 'Hackdeck',
		stack = false,
		weight = 500,
	},

	/*["flower_pot"] = {

	}*/

	["weed_shredder"] = {
		label = "Drtička na konopí",
		stack = false,
		close = true,
		weight = 25,
		consume = 0,
		server = {
			export = "strin_base.use_item"
		}
	},

	['weed_seed'] = {
		label = "Semínko konopí",
		stack = true,
		close = true,
		weight = 10,
		consume = 0,
		/*client = {
			anim = {
				dict = "random@domestic",
				clip = "pickup_low"
			},
			usetime = 1000
		},*/
		server = {
			export = "strin_base.use_item"
		}
	},

	["weed_bud"] = {
		label = "Palice konopí",
		stack = true,
	},

	["weed"] = {
		label = "Tráva",
		stack = true
	},

	["smoke_papers"] = {
		label = "Papírky",
		stack = true,
		close = true,
		consume = 0,
		server = {
			export = "strin_base.use_item"
		}
	},

	["joint"] = {
		label = "Joint",
		stack = true,
		close = true,
		consume = 1,
		server = {
			export = "strin_base.use_item"
		}
	},

	["lsd"] = {
		label = "LSD",
		stack = true,
		close = true,
		consume = 1,
		server = {
			export = "strin_base.use_item"
		}
	},

	["ticket"] = {
		label = "Lístek",
		stack = false,
		consume = 0,
		server = {
			export = "strin_base.use_item"
		}
	},

	["lighter"] = {
		label = "Zapalovač",
		stack = false,
		weight = 25,
		close = true,
	},

	['zipties'] = {
		label = 'Stahovací pásky',
		stack = true
	},

	['radio'] = {
		label = 'Radio',
		weight = 1000,
		stack = false,
		allowArmed = true,
		client = {
			event = "ac_radio:openRadio",
		}
	},

	["ammobox"] = {
		label = 'Krabice s náboji',
		weight = 100,
		stack = false,
		consume = 0,
		server = {
			export = "strin_base.use_item"
		}
	},

	['water'] = {
		label = 'Voda',
		weight = 500,
	},

	['fertilizer'] = {
		label = 'Hnojivo',
		weight = 500,
	},

	['dehydrator'] = {
		label = 'Sušička',
		weight = 20000,
		consume = 1,
		server = {
			export = "strin_base.use_item"
		}
	},

	["averagewhisky"] = {
		label = "Whisky (10 let zrání)",
		weight = 500,
		consume = 1,
		stack = true,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["goodwhisky"] = {
		label = "Whisky (20 let zrání)",
		weight = 500,
		consume = 1,
		stack = true,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["awesomewhisky"] = {
		label = "Whisky (30 let zrání)",
		weight = 500,
		consume = 1,
		stack = true,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["gin"] = {
		label = "Gin",
		weight = 100,
		consume = 1,
		stack = true,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["jager"] = {
		label = "Jagermeister",
		weight = 500,
		consume = 1,
		stack = true,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["vine"] = {
		label = "Víno",
		weight = 1500,
		consume = 1,
		stack = true,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["vodka"] = {
		label = "Vodka",
		weight = 1500,
		consume = 1,
		stack = true,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["ephedrine"] = {
		label = "Efedrin",
		weight = 20000,
		consume = 0,
		stack = false,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["phenylactic_acid"] = {
		label = "Kyselina fenolyctová",
		weight = 20000,
		consume = 0,
		stack = false,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["meth_box"] = {
		label = "Krabice s methem",
		weight = 5000,
		consume = 1,
		stack = false,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["meth_brick"] = {
		label = "Cihla methu",
		weight = 700,
		consume = 1,
		stack = true,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["meth_pooch"] = {
		label = "Sáček s methem",
		weight = 1,
		consume = 1,
		stack = true,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["poppy_leaves"] = {
		label = "Listy máku setýho",
		weight = 10,
		consume = 0,
		stack = true,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["citric_acid"] = {
		label = "Kyselina citronová",
		weight = 20000,
		consume = 0,
		stack = false,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["heroin_box"] = {
		label = "Krabice heroinu",
		weight = 5000,
		consume = 1,
		stack = false,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["heroin_brick"] = {
		label = "Cihla heroinu",
		weight = 700,
		consume = 1,
		stack = true,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["heroin_pooch"] = {
		label = "Sáček s heroinem",
		weight = 1,
		consume = 1,
		stack = true,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["coca_leaves"] = {
		label = "Listy koky",
		weight = 10,
		consume = 0,
		stack = true,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["sulphuric_acid"] = {
		label = "Kyselina sírová",
		weight = 20000,
		consume = 0,
		stack = false,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["coke_box"] = {
		label = "Krabice kokainu",
		weight = 5000,
		consume = 1,
		stack = false,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["coke_brick"] = {
		label = "Cihla kokainu",
		weight = 700,
		consume = 1,
		stack = true,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["coke_pooch"] = {
		label = "Sáček s kokainem",
		weight = 1,
		consume = 1,
		stack = true,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},

	["pooch"] = {
		label = "Sáček",
		weight = 0,
		--consume = 1,
		stack = true,
		close = true,
		/*server = {
			export = "strin_base.use_item"
		}*/
	},

	["lottery_ticket"] = {
		label = "LÍstek do loterie",
		weight = 5,
		consume = 0,
		stack = false,
		close = true,
		server = {
			export = "strin_base.use_item"
		}
	},
	--[[['mastercard'] = {
		label = 'Mastercard',
		stack = false,
		weight = 10,
	},

	['testburger'] = {
		label = 'Test Burger',
		weight = 220,
		degrade = 60,
		client = {
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			export = 'ox_inventory_examples.testburger'
		},
		server = {
			export = 'ox_inventory_examples.testburger',
			test = 'what an amazingly delicious burger, amirite?'
		},
		buttons = {
			{
				label = 'Lick it',
				action = function(slot)
					print('You licked the burger')
				end
			},
			{
				label = 'Squeeze it',
				action = function(slot)
					print('You squeezed the burger :(')
				end
			},
			{
				label = 'What do you call a vegan burger?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('A misteak.')
				end
			},
			{
				label = 'What do frogs like to eat with their hamburgers?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('French flies.')
				end
			},
			{
				label = 'Why were the burger and fries running?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('Because they\'re fast food.')
				end
			}
		},
		consume = 0.3
	},

	['black_money'] = {
		label = 'Dirty Money',
	},

	['burger'] = {
		label = 'Burger',
		weight = 220,
		client = {
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			notification = 'You ate a delicious burger'
		},
	},

	['cola'] = {
		label = 'eCola',
		weight = 350,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ecola_can`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			notification = 'You quenched your thirst with cola'
		}
	},

	['scrapmetal'] = {
		label = 'Scrap Metal',
		weight = 80,
	},]]	--[[['mustard'] = {
		label = 'Mustard',
		weight = 500,
		client = {
			status = { hunger = 25000, thirst = 25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_food_mustard`, pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
			usetime = 2500,
			notification = 'You.. drank mustard'
		}
	},

	['water'] = {
		label = 'Water',
		weight = 500,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 2500,
			cancel = true,
			notification = 'You drank some refreshing water'
		}
	},]]

	--[[['garbage'] = {
		label = 'Garbage',
	},

	['paperbag'] = {
		label = 'Paper Bag',
		weight = 1,
		stack = false,
		close = false,
		consume = 0
	},]]
	
	--[[['panties'] = {
		label = 'Knickers',
		weight = 10,
		consume = 0,
		client = {
			status = { thirst = -100000, stress = -25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
			usetime = 2500,
		}
	},]]
}
