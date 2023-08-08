local LoadedCharacterData = {}

do
    local columns = {}
    columns[#columns + 1] = "`id` INT(11) NOT NULL AUTO_INCREMENT,"
    columns[#columns + 1] = "`owner` VARCHAR(255) NOT NULL,"
    for k,v in pairs(CHARACTER_DATA_TYPES) do
        if(type(v) ~= "table") then
            local __type = (
                v == "number" and "INT(11)" or 
                (v == "string" and "VARCHAR(50)")
            )
            columns[#columns + 1] = ("`%s` %s %s,"):format(
                k:lower(),
                __type,
                "NOT NULL"
            )
        else
            local __type = (
                v.type == "number" and "INT(11)" or 
                (v.type == "string" and "VARCHAR(50)")
            )
            columns[#columns + 1] = ("`%s` %s %s,"):format(
                k:lower(),
                __type,
                (v.optional and "DEFAULT NULL" or "NOT NULL")..((not v.optional and v.default) and (" DEFAULT "..v.default) or "")
            )
        end
    end
    MySQL.query.await(([[CREATE TABLE IF NOT EXISTS `character_data` (
        %s
        PRIMARY KEY (`id`),
        UNIQUE KEY (`id`)
    )]]):format(table.concat(columns, "\n")))
    
    local data = MySQL.query.await("SELECT * FROM `character_data`")
    if(data and next(data)) then
        for _,character in pairs(data) do
            table.insert(LoadedCharacterData, character)
        end
    end
end

function GetCharacterDataFromIdentifier(identifier, characterId)
    local owner = identifier..":"..characterId
    local dataPool = {}
    for k,v in pairs(LoadedCharacterData) do
        if(v and v.owner == owner) then
            table.insert(dataPool, v)
        end
    end
    return dataPool
end

exports("GetCharacterDataFromIdentifier", GetCharacterDataFromIdentifier)

function GetCharacterDataFromId(id)
    local dataPool = {}
    for k,v in pairs(LoadedCharacterData) do
        if(v and v.id == tonumber(id)) then
            table.insert(dataPool, v)
        end
    end
    return dataPool
end

exports("GetCharacterDataFromId", GetCharacterDataFromId)

function CreateCharacterData(identifier, characterId, data)
    local expressions = {}
    local validatedData = {}
    for k,v in pairs(CHARACTER_DATA_TYPES) do
        if(data[k] or v.default) then
            validatedData[k] = data[k] or v.default
            expressions[#expressions + 1] = "`"..k.."` = @"..k
        end
    end
    local insertId = nil
    if(next(validatedData)) then
        validatedData["owner"] = identifier..":"..characterId
        insertId = MySQL.insert.await(("INSERT INTO `character_data` SET %s"):format(
            table.concat(expressions, ",")
        ), validatedData)
        validatedData["id"] = insertId
        LoadedCharacterData[insertId] = validatedData
    end
    return insertId ~= nil and LoadedCharacterData[insertId] or nil
end

exports("CreateCharacterData", CreateCharacterData)

CreateCharacterData({
    firstname = "Abraham",
    lastname = "Lincoln"
})