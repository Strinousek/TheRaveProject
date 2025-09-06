ESX.RegisterCommand("convertvehicles", "admin", function(xPlayer)
    if(xPlayer.identifier ~= "strinova licence was here") then
        return
    end

    local vehicles = MySQL.query.await("SELECT * FROM vehicles")
    local vehicleCategories = MySQL.query.await("SELECT * FROM vehicle_categories")
    local convertedVehicles = {}
    for _, category in pairs(vehicleCategories) do
        convertedVehicles[category.name] = {
            label = category.label,
            vehicles = {}
        }
    end
    for _, vehicle in pairs(vehicles) do
        if(convertedVehicles[vehicle.category]) then
            table.insert(convertedVehicles[vehicle.category].vehicles, {
                name = vehicle.model,
                price = vehicle.price
            })
        end
    end

    SaveResourceFile("strin_vehicleshop", "converted_vehicles.lua", SerializeTable(convertedVehicles), -1)
    xPlayer.showNotification("Konvertace vozidel z databáze úspěšná!", {type = "success"})
end)

function SerializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then tmp = tmp .. name .. " = " end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp =  tmp .. SerializeTable(v, type(k) ~= "number" and k or nil, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end

    return tmp
end