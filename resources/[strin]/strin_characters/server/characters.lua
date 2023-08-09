local ActionCooldowns = {}
local Base = exports.strin_base
local Motels = exports.strin_motels

Base:RegisterWebhook("CHARACTER_CREATE", "https://discord.com/api/webhooks/1137079351842721812/L8tP-2ThcZT9JX7xgm0A512jMB6rglF795TxlxPolnrwva3FCHL0i_wzhW9ol9al_vyx")
Base:RegisterWebhook("CHARACTER_SWITCH", "https://discord.com/api/webhooks/1137079795923030077/05pQWPjrXQQ_SjQREkcupo1uvOU3YEY3I_44FF_c8hgmUHzSLVl8lGIVlWhovgIXv0v9")
Base:RegisterWebhook("CHARACTER_DELETE", "https://discord.com/api/webhooks/1137079706710184088/7YGn_a0D9kUqAsq7TkZ5zXGcvBImY5qbe1W3oiE8J8jn1v5WYhz0mX6WbpQQnsZMCENn")

Citizen.CreateThread(function()
    local file = LoadResourceFile("strin_characters", "server/cache.json")

    if(not file) then
        SaveResourceFile("strin_characters", "server/cache.json", "{}", -1)
    end
end)

local UsersTable = {
    "job", "job_grade", "other_jobs",
    "firstname", "lastname",
    "dateofbirth", "sex", "height", 
    "char_id", "accounts", "inventory",
    "skin", "phone_number"
}

local CharactersTable = {
    "identifier", "job", "job_grade", "other_jobs", 
    "accounts", "firstname", "lastname", "dateofbirth", 
    "skin", "sex", "height", "weight", 
    /*"hair_color", "eyes",*/ "inventory", "phone_number", "char_type", 
    "char_id",
}

local DisabledMultichars = {}

AddEventHandler("strin_actions:playerRestrained", function(restrainedPlayerId)
    local identifier = ESX.GetIdentifier(restrainedPlayerId)
    DisabledMultichars[identifier] = true
end)

AddEventHandler("strin_actions:playerUnrestrained", function(restrainedPlayerId)
    local identifier = ESX.GetIdentifier(restrainedPlayerId)
    if(DisabledMultichars[identifier]) then
        DisabledMultichars[identifier] = false
    end
end)

AddEventHandler("strin_characters:changeMulticharLock", function(identifier, state)
    if(type(state) ~= "boolean") then
        return
    end
    DisabledMultichars[identifier] = state
end)

ESX.RegisterCommand("multichar", "user", function(xPlayer, args)
    local _source = xPlayer.source
    if(DisabledMultichars[xPlayer.identifier]) then
        xPlayer.showNotification("Menu postav momentálně není dostupné!", { type = "error" })
        return
    end
    if(not Motels:IsPlayerInMotelRoom(xPlayer.source)) then
        xPlayer.showNotification("Menu postav lze otevřít pouze v motelu!", { type = "error" })
        return
    end
    --xPlayer.showNotification("Multichar je aktuálně nedostupný.", {type = "error"})
    local characters = GetCharacters(xPlayer.identifier)
    if(not characters or #characters <= 0) then
        xPlayer.kick("Nebyly u vás nalezeny žádné postavy.\nProsíme zkuste se napojit znovu, případně kontaktujte dev. tým.")
        return
    end

    local currentCharacter = GetCurrentCharacter(xPlayer.identifier, true)
    local slots = GetCharacterSlots(xPlayer.identifier)
    TriggerClientEvent("strin_characters:openCharactersMenu", _source, characters, slots, currentCharacter.char_id)
end)

AddEventHandler("strin_characters:createCharacter", function(character, playerId)
    local _source = playerId
    local xPlayer = ESX.GetPlayerFromId(_source)
    local slots = GetCharacterSlots(xPlayer.identifier)
    local characters = GetCharacters(xPlayer.identifier)
    local sanitizedData = {}
    for property,value in pairs(character) do
        if(type(value) ~= "number" and property ~= "skin" and property ~= "inventory" and property ~= "prevInventory" and property ~= "accounts") then
            sanitizedData[property] = type(value) == "string" and ESX.SanitizeString(value) or CreatePropertyTable(value)
        else
            sanitizedData[property] = value
        end
    end

    /*if(not characters or #characters >= slots) then
        xPlayer.showNotification("Nemůžete si vytvořit postavu, když máte plné sloty!", {type = "error"})
        return
    end*/

    local availableSlot = GetAvailableSlot(slots, characters)
    if(not availableSlot) then
        xPlayer.showNotification("Nepodařilo se nám najít místo pro Váš charakter.", {type = "error"})
        return
    end
    
    CreateCharacter(xPlayer.identifier, availableSlot, sanitizedData, characters)
end)

RegisterNetEvent("strin_characters:requestCharacterCreator", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(not xPlayer) then
        return
    end
    if(DisabledMultichars[xPlayer.identifier]) then
        xPlayer.showNotification("Postavy si nelze aktuálně vytvářet!", { type = "error" })
        return
    end
    if(not Motels:IsPlayerInMotelRoom(xPlayer.source)) then
        xPlayer.showNotification("Postavy lze tvořit pouze v motelu!", { type = "error" })
        return
    end
    local slots = GetCharacterSlots(xPlayer.identifier)
    local characters = GetCharacters(xPlayer.identifier)
    local slot = GetAvailableSlot(slots, characters)
    if(not slot or slot == 0) then
        xPlayer.showNotification("Nemáte žádné volné sloty na postavu.")
        return
    end
	ExpectedRegisters[xPlayer.identifier] = true
	TriggerClientEvent('strin_characters:register', xPlayer.source)
end)

RegisterNetEvent("strin_characters:updateCharacter", function(characterId, mode)
    if(type(characterId) ~= "number" or (mode ~= "DELETE" and mode ~= "SWITCH")) then
        return
    end
    local _source = tonumber(source)
    local xPlayer = ESX.GetPlayerFromId(_source)
    if(DisabledMultichars[xPlayer.identifier]) then
        xPlayer.showNotification("Postavy teď nelze měnit / smazat!", { type = "error" })
        return
    end
    if(not Motels:IsPlayerInMotelRoom(xPlayer.source)) then
        xPlayer.showNotification("Postavy lze měnit / smazat pouze v motelu!", { type = "error" })
        return
    end
    local currentCharacterId = xPlayer.get("char_id")
    if(not currentCharacterId) then
        return
    end
    if(currentCharacterId == characterId) then
        local action = (mode == "DELETE") and "smazat postavu" or "se přepnout na postavu"
        xPlayer.showNotification("Nemůžete "..action..", kterou aktuálně jste!", {type = "error"})
        return
    end
    if(not type(characterId) == "number" or (mode ~= "DELETE" and mode ~= "SWITCH")) then
        return
    end
    local nextCharacter = GetSpecificCharacter(xPlayer.identifier, characterId, true)
    if(not next(nextCharacter)) then
        xPlayer.showNotification("Postava s tímto ID neexistuje!", {type = "error"})
        return
    end
    if(mode == "DELETE") then
        DeleteCharacter(xPlayer.identifier, characterId)
        return
    end
    SwitchCharacter(xPlayer.identifier, characterId)
end)

function CreateCharacter(identifier, slot, character, characters)
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    if(not xPlayer) then
        return
    end
    local job = xPlayer.getJob()
    local charactersQueryParameters = {
        xPlayer.identifier,
        job.name,
        job.grade,
        "[]",
        character.accounts,
        character.firstname,
        character.lastname,
        character.dateofbirth,
        character.skin,
        character.sex,
        character.height,
        character.weight,
        /*character.hair_color,
        character.eyes,*/
        character.inventory,
        nil,
        character.char_type,
        slot,
    }
    local usersQueryParameters = {
        "unemployed",
        1,
        "[]",
        character.firstname,
        character.lastname,
        character.dateofbirth,
        character.sex,
        character.height,
        slot,
        character.accounts,
        character.inventory,
        character.skin,
        nil
    }
    if(#characters <= 0) then
        MySQL.prepare(GenerateUsersUpdateQuery(identifier), usersQueryParameters, function()
            MySQL.prepare(GenerateCharactersInsertQuery(), charactersQueryParameters, function()
                Base:DiscordLog("CHARACTER_CREATE", "THE RAVE PROJECT - VYTVOŘENÍ POSTAVY", {
                    { name = "Jméno hráče", value = GetPlayerName(xPlayer.source) },
                    { name = "Identifikace hráče", value = xPlayer.identifier },
                    { name = "Jméno nové postavy", value = character.firstname.." "..character.lastname },
                    { name = "ID nové postavy", value = slot },
                    { name = "Typ nové postavy", value = character.char_type }
                }, {
                    fields = true
                })
                SetPlayerInventory(xPlayer.source, character.inventory)
                SetxPlayerVariables(xPlayer, character, slot)
                xPlayer.showNotification("Postava úspěšně zapsána a uložena.", {type = "success"})
                TriggerClientEvent("strin_characters:characterCreated", xPlayer.source, slot, character)
                TriggerEvent("strin_characters:characterCreated", xPlayer.identifier, slot)
            end)
        end)
        return
    end

    SaveLastCharacter(xPlayer.identifier, function()
        MySQL.prepare(GenerateUsersUpdateQuery(identifier), usersQueryParameters, function()
            MySQL.prepare(GenerateCharactersInsertQuery(), charactersQueryParameters, function()
                Base:DiscordLog("CHARACTER_CREATE", "THE RAVE PROJECT - VYTVOŘENÍ POSTAVY", {
                    { name = "Jméno hráče", value = GetPlayerName(xPlayer.source) },
                    { name = "Identifikace hráče", value = xPlayer.identifier },
                    { name = "Jméno nové postavy", value = character.firstname.." "..character.lastname },
                    { name = "ID nové postavy", value = slot },
                    { name = "Typ nové postavy", value = character.char_type }
                }, {
                    fields = true
                })
                SetPlayerInventory(xPlayer.source, character.inventory)
                xPlayer.setJob("unemployed", 1)
                SetxPlayerVariables(xPlayer, character, slot)
                xPlayer.showNotification("Postava úspěšně zapsána a uložena.", {type = "success"})
                TriggerClientEvent("strin_characters:characterCreated", xPlayer.source, slot, character)
                TriggerEvent("strin_characters:characterCreated", xPlayer.identifier, slot)
            end)
        end)
    end, character.prevInventory, character.prevAccounts)
end

function SwitchCharacter(identifier, characterId)
    SaveLastCharacter(identifier, function()
        local character = GetSpecificCharacter(identifier, characterId, true)
        MySQL.query(GenerateUsersUpdateQuery(identifier), {
            character.job,
            character.job_grade,
            character.other_jobs,
            character.firstname,
            character.lastname,
            character.dateofbirth,
            character.sex,
            character.height,
            characterId,
            character.accounts,
            character.inventory,
            character.skin,
            character.phone_number,
        }, function()
            local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
            Base:DiscordLog("CHARACTER_SWITCH", "THE RAVE PROJECT - PŘEHOZENÍ POSTAVY", {
                { name = "Jméno hráče", value = GetPlayerName(xPlayer.source) },
                { name = "Identifikace hráče", value = identifier },
                { name = "Jméno předchozí postavy", value = xPlayer.get("fullname") },
                { name = "ID předchozí postavy", value = xPlayer.get("char_id") },
                { name = "Typ předchozí postavy", value = xPlayer.get("char_type") },
                { name = "Jméno nové postavy", value = character.firstname.." "..character.lastname },
                { name = "ID nové postavy", value = character.char_id },
                { name = "Typ předchozí postavy", value = character.char_type },
            }, {
                fields = true
            })
            if(ESX.DoesJobExist(character.job, tonumber(character.job_grade))) then
                xPlayer.setJob(character.job, tonumber(character.job_grade))
            else
                xPlayer.showNotification("Postava má neplatný job!", {type = "error"})
                xPlayer.setJob("unemployed", 1)
            end
            local accounts = json.decode(character.accounts)
            for account,money in pairs(accounts) do
                xPlayer.setAccountMoney(account, tonumber(money))
            end
            SetPlayerInventory(xPlayer.source, character.inventory)
            SetxPlayerVariables(xPlayer, character, characterId)
            xPlayer.showNotification("Přehodil/a jste se na postavu s ID: "..characterId)
            TriggerEvent("strin_characters:characterSwitched", xPlayer.identifier, characterId)
            TriggerClientEvent("strin_characters:characterSwitched", xPlayer.source, character)
        end)
    end)
end

function SetxPlayerVariables(xPlayer, character, characterId)
    local columns = {
        "firstname", "lastname", "dateofbirth", "height", "weight",
        "phone_number", "char_type", "char_id", "fullname"
    }
    for _,v in pairs(columns) do
        xPlayer.set(
            v,
            v ~= "fullname" and character[v] or (character.firstname.." "..character.lastname)
        )
        TriggerClientEvent(
            "esx:updatePlayerData", 
            xPlayer.source,
            v, 
            v ~= "fullname" and character[v] or (character.firstname.." "..character.lastname)
        )
    end
end

function DeleteCharacter(identifier, characterId)
    local cachedCharacters = json.decode(LoadResourceFile("strin_characters", "server/cache.json") or "{}")
    local character = GetSpecificCharacter(identifier, characterId, true)
    cachedCharacters[#cachedCharacters + 1] = character
    SaveResourceFile("strin_characters", "server/cache.json", json.encode(cachedCharacters), -1)
    local result = MySQL.query.await("DELETE FROM characters WHERE `identifier` = ? AND `char_id` = ?", {
        identifier,
        characterId
    })
    Base:DiscordLog("CHARACTER_DELETE", "THE RAVE PROJECT - SMAZÁNÍ POSTAVY", {
        { name = "Identifikace hráče", value = identifier },
        { name = "Jméno smazané postavy", value = character.firstname.." "..character.lastname },
        { name = "ID smazané postavy", value = character.char_id },
        { name = "Typ smazané postavy", value = character.char_type }
    }, {
        fields = true
    })
    TriggerEvent("strin_characters:characterDeleted", identifier, characterId)
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    if(not xPlayer) then
        return
    end
    xPlayer.showNotification("Postava s ID: "..characterId.." | Úspěšně smazána!", {type = "success"})
end

exports("DeleteCharacter", DeleteCharacter)

function SaveLastCharacter(identifier, cb, prevInventory, prevAccounts)
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    local currentCharacter = GetCurrentCharacter(identifier, true)
    local characterId = currentCharacter.char_id or 1
    local query = GenerateCharactersUpdateQuery(charId)
    local job = xPlayer.getJob()
    local inventory = json.encode({})
    local accounts = json.encode({})
    if(prevInventory) then
        inventory = (type(prevInventory) == "string") and prevInventory or json.encode(prevInventory)
    else
        inventory = currentCharacter.inventory
    end
    if(prevAccounts) then
        accounts = (type(prevAccounts) == "string") and prevAccounts or json.encode(prevAccounts)
    else
        accounts = currentCharacter.accounts
    end
    local parameters = {
        job.name,
        job.grade,
        currentCharacter.other_jobs,
        accounts,
        currentCharacter.firstname,
        currentCharacter.lastname,
        currentCharacter.dateofbirth,
        currentCharacter.skin,
        currentCharacter.sex,
        currentCharacter.height,
        currentCharacter.weight,
        /*currentCharacter.hair_color,
        currentCharacter.eyes,*/
        inventory,
        currentCharacter.phone_number
    }
    MySQL.prepare(GenerateCharactersUpdateQuery(identifier, characterId), parameters, function()
        cb()
    end)
end

function SetPlayerInventory(playerId, inventory)
    local inventory = (type(inventory) == "string") and json.decode(inventory) or inventory
    Inventory:ClearInventory(playerId)
    for k,v in pairs(inventory) do
        Inventory:AddItem(playerId, v.name, v.count, v.metadata, v.slot)
    end
end

function GetCurrentCharacter(identifier, jsonify)
    local result = MySQL.single.await("SELECT inventory, skin, accounts, job, job_grade, other_jobs, phone_number, char_id FROM users WHERE `identifier` = ?", {
        identifier
    })

    if((not result) or (not result?.char_id)) then
        return nil
    end

    local character = MySQL.single.await("SELECT * FROM characters WHERE `identifier` = ? AND `char_id` = ?", {
        identifier,
        result?.char_id
    })

    if((not character) or (not character?.firstname)) then
        return nil
    end

    character.phone_number = result?.phone_number

    if(xPlayer) then
        local inventory = xPlayer.getInventory(true)
        local skin = SkinChanger:GetSkin(xPlayer.source) or {}
        local other_jobs = json.decode(result?.other_jobs or "{}") or {}
        local accounts = xPlayer.getAccounts(true)
        character.inventory = (jsonify) and json.encode(inventory) or inventory
        character.skin = (jsonify) and json.encode(skin) or skin
        character.accounts = (jsonify) and json.encode(accounts) or accounts
        character.job = xPlayer.getJob().name
        character.job_grade = xPlayer.getJob().grade
        character.other_jobs = (jsonify) and json.encode(other_jobs) or other_jobs
        return character
    end

    character.inventory = (not jsonify) and json.decode(result?.inventory or "{}") or (result?.inventory or "{}")
    character.skin = (not jsonify) and json.decode(result?.skin or "{}") or (result?.skin or "{}")
    character.accounts = (not jsonify) and json.decode(result?.accounts or "{}") or (result?.accounts or "{}")
    character.job = result?.job or "unemployed"
    character.job_grade = result?.job_grade or 1
    character.other_jobs = (not jsonify) and json.decode(result?.other_jobs or "{}") or (result?.other_jobs or "{}")


    return character
end

exports("GetCurrentCharacter", GetCurrentCharacter)

function GetSpecificCharacter(identifier, characterId, jsonify)
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    if(not xPlayer) then
        local currentCharacterId = MySQL.scalar.await("SELECT `char_id` FROM users WHERE `identifier` = ?", {
            identifier
        })
        if(currentCharacterId and currentCharacterId == characterId) then
            return GetCurrentCharacter(identifier, jsonify) 
        end
    end

    if(xPlayer) then
        if(xPlayer.get("char_id") == characterId) then
            return GetCurrentCharacter(identifier, jsonify) 
        end
    end
    
    local character = MySQL.single.await("SELECT * FROM characters WHERE `identifier` = ? AND `char_id` = ?", {
        identifier,
        characterId
    })

    if((not character) or (not character?.firstname)) then
        return nil
    end

    if(not jsonify) then
        character.inventory = json.decode(character.inventory)
        character.skin = json.decode(character.skin)
        character.accounts = json.decode(character.accounts)
        character.other_jobs = json.decode(character.other_jobs)
    end

    return character
end

exports("GetSpecificCharacter", GetSpecificCharacter)

function GetUser(identifier)
    local result = MySQL.single.await("SELECT * FROM users WHERE `identifier` = ?", {identifier}) 
    return result
end

exports("GetUser", GetUser)

function GetCharacterSlots(identifier)
    local slots = MySQL.scalar.await("SELECT character_slots FROM users WHERE `identifier` = ?", {
        identifier
    })
    return slots
end

exports("GetCharacterSlots", GetCharacterSlots)

function GetCharacters(identifier)
    local result = MySQL.query.await("SELECT * FROM characters WHERE `identifier` = ?", {
        identifier
    })
    if(result and next(result)) then
        local activeCharId = MySQL.scalar.await("SELECT `char_id` FROM users WHERE `identifier` = ?", {
            identifier
        })
        for i=1, #result do
            if(result[i].char_id == activeCharId) then
                result[i] = GetCurrentCharacter(identifier, true)
                break
            end
        end
    end
    return result
end

exports("GetCharacters", GetCharacters)

function GetAllCharacters()
    return MySQL.query.await("SELECT * FROM `characters`")
end

exports("GetAllCharacters", GetAllCharacters)

function GetAvailableSlot(slots, characters)
    local predefinedSlots = {}
    for i=1, tonumber(slots) do
        predefinedSlots[i] = i
    end
    
    if((not characters) or (not next(characters))) then
        return 1
    end

    local availableSlots = {}
    for k,v in pairs(predefinedSlots) do
        for i=1, #characters do
            if(characters[i].char_id == v) then
                predefinedSlots[k] = nil
            end
        end
    end
    for _,slot in pairs(predefinedSlots) do
        if(slot) then
            availableSlots[#availableSlots + 1] = slot
        end
    end

    table.sort(availableSlots, function(a,b)
        return a < b
    end)
    if(not next(availableSlots)) then
        return nil
    end
    return availableSlots[1]
end

function GetAvailableSlotForIdentifier(identifier)
    local slots = GetCharacterSlots(identifier)
    local characters = GetCharacters(identifier)
    return GetAvailableSlot(slots or 2, characters or {})
end

exports("GetAvailableSlot", GetAvailableSlotForIdentifier)

function GenerateCharactersInsertQuery()
    local expressions = {}
    for _,column in pairs(CharactersTable) do
        expressions[#expressions+1] = "`"..column.."` = ?"
    end
    return ("INSERT INTO characters SET %s"):format(
        table.concat(expressions, ",")
    )
end

function GenerateUsersUpdateQuery(identifier)
    local expressions = {}
    for _,column in pairs(UsersTable) do
        expressions[#expressions+1] = "`"..column.."` = ?"
    end
    return ("UPDATE users SET %s WHERE `identifier` = '%s'"):format(
        table.concat(expressions, ","),
        identifier
    )
end

function GenerateCharactersUpdateQuery(identifier, slot)
    local expressions = {}
    for _,column in pairs(CharactersTable) do
        if(not (column:find("char_id") or column:find("char_type") or column:find("identifier"))) then
            expressions[#expressions+1] = "`"..column.."` = ?"
        end
    end

    return ("UPDATE characters SET %s WHERE `identifier` = '%s' AND `char_id` = %s"):format(
        table.concat(expressions, ","),
        identifier,
        slot
    )
end

function CreatePropertyTable(table)
    local propertyTable = {}
    for key, value in pairs(table) do
        propertyTable[key] = type(value) == "string" and ESX.SanitizeString(value) or value
    end
    return propertyTable
end

--[[lib.callback.register("strin_characters:getCharacterSkin", function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local character = GetCurrentCharacter(xPlayer.identifier)
	return character.skin or nil
end)]]