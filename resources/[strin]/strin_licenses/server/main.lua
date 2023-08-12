function AddLicense(identifier, licenseType, characterId)
    if(not characterId) then
       characterId = MySQL.scalar.await("SELECT `char_id` FROM `users` WHERE `identifier` = ?", { identifier })
    end
    local owner = identifier..":"..characterId
	return MySQL.insert.await('INSERT INTO `user_licenses` SET `owner` = ?, `type` = ?', { owner, licenseType })
end

function RemoveLicense(identifier, licenseType, characterId)
    if(not characterId) then
        characterId = MySQL.scalar.await("SELECT `char_id` FROM `users` WHERE `identifier` = ?", { identifier })
    end
    local owner = identifier..":"..characterId
	return MySQL.update.await('DELETE FROM `user_licenses` WHERE `owner` = ? AND `type` = ?', { owner, licenseType })
end

function GetLicense(licenseType, cb)
    cb({
        type = licenseType,
        label = LICENSES[licenseType]
    })
end

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
        licenses.label = LICENSES[v.type]
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