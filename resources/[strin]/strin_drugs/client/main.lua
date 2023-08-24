DrugEffectStrength = 0.0

local GANG_AREAS = {
    vector3(217.30010986328, -1739.8660888672, 28.951532363892),
    vector3(337.65951538086, -2044.3520507813, 21.195701599121),
    vector3(556.69750976563, -1834.1633300781, 26.58028793335),
    vector3(-131.70149230957, -2135.837890625, 15.942228317261),
    vector3(-580.71868896484, -1696.7685546875, 24.824825286865),
    vector3(-222.70825195313, -1427.1926269531, 32.94482421875),
    vector3(-157.13949584961, -1622.6182861328, 37.004825592041),
    vector3(80.161987304688, -1908.2202148438, 24.824825286865),
    vector3(174.37782287598, -1752.5985107422, 32.94482421875),
}

function DrawFloatingText(entry, coords)
	BeginTextCommandDisplayHelp(entry)
	SetFloatingHelpTextWorldPosition(1, coords)
	SetFloatingHelpTextStyle(1, 1, 72, -1, 3, 0)
	EndTextCommandDisplayHelp(2, false, false, -1)
	SetFloatingHelpTextWorldPosition(0, coords.x, coords.y, coords.z)
end

function IsInGangArea()
    local isInArea = false
    local coords = GetEntityCoords(cache.ped)
    for i=1, #GANG_AREAS do
        local distance = #(coords - GANG_AREAS[i])
        if(distance < 80) then
            isInArea = true
            break
        end
    end
    return isInArea
end

local GANG_NAMES = {
    "g_m_y", "balla", "grove", "vagos", "soucent", "punk", "fam"
}

function IsModelGangster(modelName)
    local isGangster = false
    if(modelName) then
        for i=1, #GANG_NAMES do
            if(modelName:find(GANG_NAMES[i])) then
                isGangster = true
                break
            end
        end
    end
    return isGangster
end