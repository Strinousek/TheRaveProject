while GetResourceState("ox_inventory") ~= "started" do
    Citizen.Wait(0)
end

local Inventory = exports.ox_inventory
local Items = Inventory:Items()

RegisterWebhook("AMMUNATION", "https://discord.com/api/webhooks/1136613719556751390/_vKBcwyMMbZg67FBM5jbyW5MRYBBFGw6_w5V0SptLee0G10Bht0aufodCYWvsOjWw0iE")

local AmmunationHookId = Inventory:registerHook("buyItem", function(payload)
    if(payload?.shopType == "Ammunation") then
        local xPlayer = ESX.GetPlayerFromId(payload?.toInventory)
        if(xPlayer) then
            if((payload?.itemName or ""):find("WEAPON_") and payload?.metadata.serial) then
                DiscordLog("AMMUNATION", "Ammu-nation", {
                    { name = "Jméno kupujícího", value = xPlayer.get("fullname") },
                    { name = "DOB kupujícího", value = xPlayer.get("dateofbirth") },
                    { name = "CitizenID", value = xPlayer.get("char_identifier") },
                    { name = "Zakoupená střelná zbraň", value = Items[payload?.itemName].label },
                    { name = "Sériové číslo", value = payload?.metadata.serial }
                }, {
                    fields = true,
                    resource = GetCurrentResourceName(),
                })
            end
        end
    end
    return true
end)