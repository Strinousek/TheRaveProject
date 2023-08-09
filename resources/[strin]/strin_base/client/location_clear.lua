local locations = {
    {
        pos = vector3(970.37, -125.43, 74.35),
        vehicles = true,
        peds = true,
        range = 40.0
    },
    {
        pos = vector3(1201.22, -1473.39, 34.86),
        vehicles = true,
        peds = true,
        range = 40.0
    },
    {
        pos = vector3(116.86, -1286.6, 28.27),
        vehicles = true,
        peds = true,
        range = 40.0
    },
    {
        pos = vector3(-42.795127868652,-1097.3454589844,26.422357559204),
        vehicles = true,
        peds = true,
        range = 40.0
    },
    {
        pos = vector3(1990.6981201172,3052.2944335938,47.215278625488),
        vehicles = true,
        peds = true,
        range = 40.0
    },
    {
        pos = vector3(841.957, -2211.146, 35.41941),
        vehicles = false,
        peds = true,
        range = 40.0
    },
    {
        pos = vector3(92.03736114502,3726.9291992188,39.533626556396),
        vehicles = true,
        peds = true,
        range = 40.0
    },
    {
        pos = vector3(1408.5128173828,1119.4259033203,114.83773040771),
        vehicles = true,
        peds = true,
        range = 40.0
    },
    {
        pos = vector3(425.81588745117,-980.99682617188,30.709856033325),
        vehicles = true,
        peds = true,
        range = 15.0
    },
}
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)
        for k,v in pairs(locations) do
            if(v.peds) then
                ClearAreaOfPeds(v.pos.x, v.pos.y, v.pos.z, v.range, 0)
            end
            if(v.vehicles) then
                ClearAreaOfVehicles(v.pos.x, v.pos.y, v.pos.z, v.range, false, false, false, false, false)
            end
        end
    end
end)