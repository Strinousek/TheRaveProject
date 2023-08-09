local BedHashes = {`v_med_bed2`, `v_med_bed1`, `v_med_emptybed`}
local CurrentBed = nil
local Target = exports.ox_target

local Animations = {
    Dict = "missfbi1",
    Name = "cpr_pumpchest_idle"
}

AddEventHandler("esx:onPlayerDeath", function()
    if(CurrentBed) then
        local ped = PlayerPedId()
        ClearPedTasks(ped)
        CurrentBed = nil
    end
end)

Citizen.CreateThread(function()
    AddTextEntry("STRIN_BASE:CANCEL", "<FONT FACE='Righteous'>~g~<b>[X]</b>~s~ Zrušit~</FONT>")
    /*ESX.Game.SpawnLocalObject(BedHashes[1], vector3(217.64546203613, -774.35504150391, 30.821104049683), function()
        
    end)*/
    Target:addModel(BedHashes, {
        {
            label = "Lehnout si na postel",
            onSelect = function(data)
                local bedEntity = data.entity
                CurrentBed = bedEntity
                LoadAnimDict(Animations.Dict)
                
                local ped = PlayerPedId()
                local bedCoords = GetEntityCoords(CurrentBed)
                local bedHeading = GetEntityHeading(CurrentBed)
            
                SetEntityCoords(ped, bedCoords)
                SetEntityHeading(ped, bedHeading + 180.0)
                
                TaskPlayAnim(ped, Animations.Dict, Animations.Name, 8.0, -8.0, -1, 1, 0, false, false, false)
                while true do
                    DisplayHelpTextThisFrame("STRIN_BASE:CANCEL")
                    if(IsEntityDead(ped) or not CurrentBed or not DoesEntityExist(CurrentBed)) then
                        break
                    end

                    if(IsControlJustReleased(0, 73)) then
                        ClearPedTasks(ped)
                        CurrentBed = nil
                    end
                    Citizen.Wait(0)
                end
            end,
            canInteract = function()
                local ped = PlayerPedId()
                return not IsEntityDead(ped) and not CurrentBed
            end
        }
    })
end)

function LoadAnimDict(dict)
	if not HasAnimDictLoaded(dict) then
		RequestAnimDict(dict)

		while not HasAnimDictLoaded(dict) do
			Citizen.Wait(0)
		end
	end
end