local Charset = {}

for i = 48,  57 do table.insert(Charset, string.char(i)) end
for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

local weaponsByName = {}
local weaponsByHash = {}

CreateThread(function()
	for index, weapon in pairs(Config.Weapons) do
		weaponsByName[weapon.name] = index
		weaponsByHash[joaat(weapon.name)] = weapon
	end
end)

function ESX.GetRandomString(length)
	math.randomseed(GetGameTimer())

	return length > 0 and ESX.GetRandomString(length - 1) .. Charset[math.random(1, #Charset)] or ''
end

function ESX.GetConfig()
	return Config
end

function ESX.GetWeapon(weaponName)
	weaponName = string.upper(weaponName)

	assert(weaponsByName[weaponName], "Invalid weapon name!")

	local index = weaponsByName[weaponName]
	return index, Config.Weapons[index]
end

function ESX.GetWeaponFromHash(weaponHash)
	weaponHash = type(weaponHash) == "string" and joaat(weaponHash) or weaponHash

	return weaponsByHash[weaponHash]
end

function ESX.GetWeaponList(byHash)
	return byHash and weaponsByHash or Config.Weapons
end

function ESX.GetWeaponLabel(weaponName)
	weaponName = string.upper(weaponName)

	assert(weaponsByName[weaponName], "Invalid weapon name!")

	local index = weaponsByName[weaponName]
	return Config.Weapons[index].label or ""
end

function ESX.GetWeaponComponent(weaponName, weaponComponent)
	weaponName = string.upper(weaponName)

	assert(weaponsByName[weaponName], "Invalid weapon name!")
	local weapon = Config.Weapons[weaponsByName[weaponName]]

	for _, component in ipairs(weapon.components) do
		if component.name == weaponComponent then
			return component
		end
	end
end

function ESX.DumpTable(table, nb)
	if nb == nil then
		nb = 0
	end

	if type(table) == 'table' then
		local s = ''
		for i = 1, nb + 1, 1 do
			s = s .. "    "
		end

		s = '{\n'
		for k,v in pairs(table) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			for i = 1, nb, 1 do
				s = s .. "    "
			end
			s = s .. '['..k..'] = ' .. ESX.DumpTable(v, nb + 1) .. ',\n'
		end

		for i = 1, nb, 1 do
			s = s .. "    "
		end

		return s .. '}'
	else
		return tostring(table)
	end
end

function ESX.Round(value, numDecimalPlaces)
	return ESX.Math.Round(value, numDecimalPlaces)
end

function ESX.SanitizeString(text, options)
	local settings = (options ~= nil and next(options)) and options or {sql = true, html = true, cc = true}
	local replacements = {}
	local sanitizedString = tostring(text) or ""
	if(settings.sql) then
		replacements[';'] = ""
		replacements["="] = ""
        replacements["@"] = ""
        replacements["`"] = ""
	end
	if(settings.html) then
		replacements['<span>'] = ""
		replacements["<div>"] = ""
        replacements["div"] = ""
        replacements["span"] = ""
        replacements["script"] = ""
        replacements["src"] = ""
        replacements["<"] = ""
        replacements[">"] = ""
        replacements["/"] = ""
	end
	if(settings.cc) then
		replacements["~r~"] = ""
		replacements["~g~"] = ""
		replacements["~o~"] = ""
		replacements["~c~"] = ""
	end
	if(next(replacements)) then
		for k,v in pairs(replacements) do
			sanitizedString = sanitizedString:gsub("%"..k, v)
		end
	end
	return sanitizedString
end
