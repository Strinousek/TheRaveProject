local SpawnedSyntheticPickupables = {}

RegisterNetEvent("", function()
    local _source = source
end)

AddEventHandler("esx:playerLoaded", function (playerId, xPlayer)
    TriggerClientEvent("strin_drugs:syncSyntheticPickupables", playerId, SpawnedSyntheticPickupables)
end)

/*
    ---@param locations table<integer, { item?: string, coords: vector3, radius: number, count: number }>
    function SetupLocationsZones(locations)
        for i=1, #locations do
            local location = locations[i]
            print(json.encode(location, {indent = true}))
            lib.zones.sphere({
                coords = location.coords,
                radius = location.radius,
                onEnter = function(self)
                    print(self.id)
                end,
                onExit = function(self)
                    print(self.id)
                end,
                debug = true,
            })
        end
    end
*/

Citizen.CreateThread(function()
    while true do
        for k,v in pairs(SyntheticDrugs) do
            if(not SpawnedSyntheticPickupables[k]) then
                SpawnedSyntheticPickupables[k] = {
                    harvestables = {},
                    chemicals = {}
                }
            end
            if(#SpawnedSyntheticPickupables[k].harvestables < #v.harvestables) then

            end
        end
        Citizen.Wait(30000)
    end
end)