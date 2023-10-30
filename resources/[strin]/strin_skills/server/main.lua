local DefaultSkillsJSON = nil

Citizen.CreateThread(function()
    local defaultSkills = {}
    for k,v in pairs(SKILLS) do
        defaultSkills[k] = v.default
    end
    DefaultSkillsJSON = json.encode(defaultSkills)
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `character_skills` (
	        `char_identifier` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	        `skills` MEDIUMTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	        INDEX `char_identifier` (`char_identifier`(191)) USING BTREE
        )
        COLLATE='utf8mb4_bin'
        ENGINE=InnoDB	
    ]])
    MySQL.query.await([[
		ALTER TABLE `character_skills` 
            ADD IF NOT EXISTS `char_identifier` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
            ADD IF NOT EXISTS `skills` MEDIUMTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin';
    ]])
    MySQL.rawExecute("SELECT * FROM `character_skills`", function(results)
        if(not results or #results == 0) then
            local characters = MySQL.query.await("SELECT * FROM `characters`")
            for i=1, #characters do
                local character = characters[i]
                MySQL.insert("INSERT INTO `character_skills` SET `char_identifier` = ?, `skills` = ?", {
                    character.char_identifier, 
                    DefaultSkillsJSON
                })
            end
        end
    end)
end)

lib.callback.register("strin_skills:getSkills", function(playerId)
    local _source = playerId
    local xPlayer = ESX.GetPlayerFromId(_source)
    local characterIdentifier = xPlayer?.get("char_identifier")
    if(not characterIdentifier) then
        return json.decode(DefaultSkillsJSON)
    end
    local skills = MySQL.prepare.await("SELECT `skills` FROM `character_skills` WHERE `char_identifier` = ?", {
        characterIdentifier
    })
    return (skills) and json.decode(skills) or json.decode(DefaultSkillsJSON)
end)

AddEventHandler("strin_characters:characterCreated", function(identifier, characterId)
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    local characterIdentifier = xPlayer?.get("char_identifier")
    if(not characterIdentifier) then
        return
    end
    MySQL.insert("INSERT INTO `character_skills` SET `char_identifier` = ?, `skills` = ?", {
        characterIdentifier, 
        DefaultSkillsJSON
    })
end)

RegisterNetEvent("strin_skills:updateSkills", function(receivedSkills)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local characterIdentifier = xPlayer?.get("char_identifier")
    if(not characterIdentifier) then
        return
    end
    local skills = ValidateSkills(receivedSkills)
    if(skills) then
        MySQL.update.await("UPDATE `character_skills` SET `skills` = ? WHERE `char_identifier` = ?", {
            json.encode(skills),
            characterIdentifier
        })
        TriggerEvent("strin_skills:skillsUpdated", _source, skills)
    end
end)

function ValidateSkills(skills)
    local validatedSkills = {}
    for k,v in pairs(skills) do
        if(not SKILLS[k] or not tonumber(v)) then
            validatedSkills = {}
            break
        end
        validatedSkills[k] = tonumber(v)
    end
    return next(validatedSkills) and validatedSkills or nil
end