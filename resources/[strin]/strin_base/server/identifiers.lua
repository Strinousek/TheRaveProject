local CachedIdentifiers = LoadJSONFile(GetCurrentResourceName(), "server/identifiers.json", "[]")

local function GetPlayerIdentifiersTable(playerId)
    local playerIdentifiers = GetPlayerIdentifiers(playerId)
    local identifiers = {}
    local foundIdentifiersCount = 0
    for k, v in pairs(playerIdentifiers) do
        local separatorIndex = string.find(v, "%:")
        local identifierKey = string.sub(v, 1, separatorIndex - 1)
        local identifierValue = string.sub(v, separatorIndex + 1)
        identifiers[identifierKey] = identifierValue
        foundIdentifiersCount += 1
    end
    return identifiers, foundIdentifiersCount
end

local function DoIdentifiersMatch(playerIdentifiers, desiredIdentifiers)
    local identifiersMatch = false
    for k,v in pairs(desiredIdentifiers) do
        if(v == playerIdentifiers[k]) then
            identifiersMatch = true
            break
        end
    end
    return identifiersMatch
end

AddEventHandler("playerConnecting", function(playerName, setCallback, deferrals)
    deferrals.defer()
    local _source = source
    local identifiers, identifiersCount = GetPlayerIdentifiersTable(_source)

    if (not next(identifiers) or identifiersCount <= 0) then
        deferrals.done()
        -- ban system will get a hold of this
        return
    end

    local foundRecord = false
    for k,v in pairs(CachedIdentifiers) do
        if(v?.identifiers and DoIdentifiersMatch(identifiers, v?.identifiers)) then
            foundRecord = true
            break
        end
    end
    if(foundRecord) then
        deferrals.done()
        return
    end

    table.insert(CachedIdentifiers, {
        name = ESX.SanitizeString(GetPlayerName(_source)),
        identifiers = identifiers,
    })
    SaveResourceFile(GetCurrentResourceName(), "server/identifiers.json", json.encode(CachedIdentifiers), -1)
    
    deferrals.done()
end)