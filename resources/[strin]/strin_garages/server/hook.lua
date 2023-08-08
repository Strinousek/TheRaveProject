while GetResourceState("ox_inventory") ~= "started" do
    Citizen.Wait(0)
end

local Admin = exports.strin_admin
local Inventory = exports.ox_inventory

local OpenInventoryHookId = Inventory:registerHook('openInventory', function(payload)
    local _source = payload?.source
    local vehicleIdentifier = payload?.inventoryId:sub(6)
    if(vehicleIdentifier == "XXXXXXXX") then
        TriggerClientEvent("esx:showNotification", _source, "Nejprve musíte vrátit SPZ vozidlu.", {
            type = "error"
        })
        return false
    end

    local targetInventory = Inventory:GetInventory(payload?.inventoryId)

    if(SpawnedVehicles[targetInventory.netid]) then
        return true
    end

    local plate = MySQL.scalar.await("SELECT `plate` FROM `owned_vehicles` WHERE `vehicle_identifier` = ?", {
        vehicleIdentifier
    })

    if(not plate) then
        return true
    end

    local vehicleFound = false
    for k,v in pairs(SpawnedVehicles) do
        if(v == vehicleIdentifier) then
            vehicleFound = true
            break
        end
    end
    if(not vehicleFound) then
        Admin:BanOnlinePlayer(nil, payload?.source, -1, "Exploiting kufrů a gloveboxů")
        return false
    end
    /*targetInventory.dbId 
    MySQL.scalar.await()
    print(SpawnedVehicles[targetInventory.netid])
    print(json.encode(targetInventory))
    -- Admin:BanOnlinePlayer(nil, payload?.source, -1, "Exploiting kufrů a gloveboxů")*/
    return true
end, {
    inventoryFilter = {
        '^glove[%w]+',
        '^trunk[%w]+',
    }
})