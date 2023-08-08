Target = exports.ox_target
Inventory = exports.ox_inventory

local HoldupBlips = {}

Citizen.CreateThread(function()
    for k,v in pairs(CashRegisters) do
        HoldupBlips[#HoldupBlips + 1] = CreateHoldupBlip(v, "Kasa", 362, 1, 0.4)
    end
    HoldupBlips[#HoldupBlips + 1] = CreateHoldupBlip(Jewelery.centerCoords, "Zlatnictví", 617, 42)
end)

AddEventHandler("onResourceStop", function(resourceName)
    if(GetCurrentResourceName() == resourceName) then
        for _,v in pairs(HoldupBlips) do
            if(DoesBlipExist(v)) then
                RemoveBlip(v)
            end
        end
    end
end)

function CreateHoldupBlip(coords, name, sprite, colour, scale)
	local blip = AddBlipForCoord(coords)
	SetBlipDisplay(blip, 2)
	SetBlipSprite(blip, sprite)
	SetBlipColour(blip, colour)
	SetBlipAsShortRange(blip, true)
	SetBlipScale(blip, scale or 0.8)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("<FONT FACE='Righteous'>"..name.."</FONT>")
	EndTextCommandSetBlipName(blip)
	return blip
end

function Draw2DText(text)
    SetTextFont(ESX.FontId)
    SetTextProportional(0)
    SetTextScale(0.4, 0.4)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.66 - 1.0/2, 1.44 - 1.0/2 + 0.005)
end

function DrawFloatingText(coords, entryName)
    BeginTextCommandDisplayHelp(entryName)
    SetFloatingHelpTextWorldPosition(1, coords)
    SetFloatingHelpTextStyle(1, 1, 72, -1, 3, 0)
    EndTextCommandDisplayHelp(2, false, false, -1)
    SetFloatingHelpTextWorldPosition(0, coords.x, coords.y, coords.z)
end

function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end

function PlayAnim(ped, dict, animName, ...)
    LoadAnimDict(dict, animName)
    if((...) ~= nil) then
        TaskPlayAnim(ped, dict, animName, ...)
        return
    end
    TaskPlayAnim(ped, dict, animName, 1.0, 1.0, -1, 11, 0.0, 0, 0, 0)
    --TaskPlayAnim(ped, dict, animName, 1.0, 1.0, -1, 11, 0.0, 0, 0, 0)
end