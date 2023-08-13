AddEventHandler("strin_characters:characterDeleted", function(identifier, characterId)
    MySQL.query.await("DELETE FROM `user_licenses` WHERE `owner` = ?", {
        identifier..":"..characterId
    })
end)

function GetLicenseTypes()
    local licenseTypes = {}
    for k,v in pairs(LICENSES) do
        table.insert(licenseTypes, k)
    end
    return licenseTypes
end

ESX.RegisterCommand("givelicense", "user", function(xPlayer, args)
    if(not args.citizenId or not args.licenseType or not LICENSES[args.licenseType]) then
        return
    end
    local _source = xPlayer?.source
    if(not _source) then
        xPlayer = {
            showNotification = function(message) print(message) end,
            getJob = function() return { name = "police", grade_name = "boss" } end,
            getGroup = function() return "admin" end,
        }
    end
    local citizenId = ESX.SanitizeString(args.citizenId)
    local job = xPlayer.getJob()
    if((not lib.table.contains(exports.strin_jobs:GetLawEnforcementJobs(), job.name) or job.grade_name ~= "boss") and xPlayer.getGroup() ~= "admin") then
        xPlayer.showNotification("Neoprávněná akce!", { type = "error" })
        return
    end
    local identifier, characterId
    if(citizenId:len() < 20) then
        local result = MySQL.single.await("SELECT `identifier`, `char_id` FROM `characters` WHERE `char_identifier` = ?", {
            citizenId
        })
        if(result and next(result)) then
            identifier = result.identifier
            characterId = result.char_id
        end
    else
        local separatorIndex = citizenId:find(":")
        if(separatorIndex) then
            identifier = citizenId:sub(1, separatorIndex - 1)
            characterId = citizenId:sub(1, separatorIndex + 1)
        end
    end
    if(not identifier or not characterId) then
        xPlayer.showNotification("Nezdařilo se najít postavu!", { type = "error" })
        return
    end
    local hasLicense = CheckLicense(identifier, args.licenseType, characterId)
    if(hasLicense) then
        xPlayer.showNotification("Tato postava již tuto licenci má!", { type = "error" })
        return
    end

    MySQL.insert("INSERT INTO `user_licenses` SET `owner` = ?, `type` = ?", {
        identifier..":"..characterId,
        args.licenseType
    }, function()
        xPlayer.showNotification("Postavě byla přidělena licence - "..args.licenseType)
    end)
end, true, {
    help = "Dát licenci postavě",
    arguments = {
        { name = "citizenId", help = "CitizenID | identifier:char_id ", type = "string" },
        { name = "licenseType", help = table.concat(GetLicenseTypes(), " | "), type = "string" }
    }
})

ESX.RegisterCommand("removelicense", "user", function(xPlayer, args)
    if(not args.citizenId or not args.licenseType or not LICENSES[args.licenseType]) then
        return
    end
    local _source = xPlayer?.source
    if(not _source) then
        xPlayer = {
            showNotification = function(message) print(message) end,
            getJob = function() return { name = "police", grade_name = "boss" } end,
            getGroup = function() return "admin" end,
        }
    end
    local citizenId = ESX.SanitizeString(args.citizenId)
    local job = xPlayer.getJob()
    if((not lib.table.contains(exports.strin_jobs:GetLawEnforcementJobs(), job.name) or job.grade_name ~= "boss") and xPlayer.getGroup() ~= "admin") then
        xPlayer.showNotification("Neoprávněná akce!", { type = "error" })
        return
    end
    local identifier, characterId
    if(citizenId:len() < 20) then
        local result = MySQL.single.await("SELECT `identifier`, `char_id` FROM `characters` WHERE `char_identifier` = ?", {
            citizenId
        })
        if(result and next(result)) then
            identifier = result.identifier
            characterId = result.char_id
        end
    else
        local separatorIndex = citizenId:find(":")
        if(separatorIndex) then
            identifier = citizenId:sub(1, separatorIndex - 1)
            characterId = citizenId:sub(1, separatorIndex + 1)
        end
    end
    if(not identifier or not characterId) then
        xPlayer.showNotification("Nezdařilo se najít postavu!", { type = "error" })
        return
    end
    local hasLicense = CheckLicense(identifier, args.licenseType, characterId)
    if(not hasLicense) then
        xPlayer.showNotification("Tato postava tuto licenci nemá!", { type = "error" })
        return
    end

    MySQL.query("DELETE FROM `user_licenses` WHERE `owner` = ? AND `type` = ?", {
        identifier..":"..characterId,
        args.licenseType
    }, function()
        xPlayer.showNotification("Postavě byla odendána licence - "..args.licenseType)
    end)
end, true, {
    help = "Odebrat licenci postavě",
    arguments = {
        { name = "citizenId", help = "CitizenID | identifier:char_id ", type = "string" },
        { name = "licenseType", help = table.concat(GetLicenseTypes(), " | "), type = "string" }
    }
})

function AddLicense(identifier, licenseType, characterId)
    if(not characterId) then
       characterId = MySQL.scalar.await("SELECT `char_id` FROM `users` WHERE `identifier` = ?", { identifier })
    end
    local owner = identifier..":"..characterId
	return MySQL.insert.await('INSERT INTO `user_licenses` SET `owner` = ?, `type` = ?', { owner, licenseType })
end

exports("AddLicense", AddLicense)

function RemoveLicense(identifier, licenseType, characterId)
    if(not characterId) then
        characterId = MySQL.scalar.await("SELECT `char_id` FROM `users` WHERE `identifier` = ?", { identifier })
    end
    local owner = identifier..":"..characterId
	return MySQL.update.await('DELETE FROM `user_licenses` WHERE `owner` = ? AND `type` = ?', { owner, licenseType })
end

exports("RemoveLicense", RemoveLicense)

function GetLicense(licenseType, cb)
    cb({
        type = licenseType,
        label = LICENSES[licenseType]
    })
end

exports("GetLicense", GetLicense)

function GetLicenses(identifier, characterId)
    if(not characterId) then
        local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
        if(xPlayer) then
            characterId = xPlayer.get("char_id")
        else
            characterId = MySQL.scalar.await("SELECT `char_id` FROM `users` WHERE `identifier` = ?", { identifier })
        end
    end
    local owner = identifier..":"..characterId
	local licenses = MySQL.query.await('SELECT `type` FROM `user_licenses` WHERE `owner` = ?', { owner })
    for k,v in pairs(licenses) do
        licenses[k].label = LICENSES[v.type]
    end
    return licenses
end

exports("GetLicenses", GetLicenses)

function CheckLicense(identifier, licenseType, characterId)
    local licenses = GetLicenses(identifier, characterId)
    local licenseFound = false
    for k,v in pairs(licenses) do
        if(v.type == licenseType) then
            licenseFound = true
            break
        end
    end
    return licenseFound
end

lib.callback.register("strin_licenses:hasLicense", function(source, licenseType, characterId)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return false
    end
    return CheckLicense(xPlayer.identifier, licenseType, characterId or xPlayer.get("char_id"))
end)

exports("CheckLicense", CheckLicense)

function IsValidLicenseType(licenseType)
	local isValid = false
	for k,v in pairs(LICENSES) do
		if k == licenseType then
			isValid = true
			break
		end
	end
	return isValid
end

/*
    esx_license compatability
*/

AddEventHandler('esx_license:getLicensesList', function(cb)
    local licenses = {}
    for k,v in pairs(LICENSES) do
        table.insert(licenses, {
            type = k,
            label = v,
        })
    end
	cb(licenses)
end)

AddEventHandler('esx_license:addLicense', function(playerId, licenseType, cb)
	local xPlayer = ESX.GetPlayerFromId(playerId)
    if(not xPlayer) then
        return
    end
    if(not IsValidLicenseType(licenseType)) then
        return
    end
    local result = AddLicense(xPlayer.identifier, licenseType, xPlayer.get("char_id"))
    if(cb) then
        cb(result == 0)
    end
end)