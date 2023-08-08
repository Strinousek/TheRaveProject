local SecurityDoorId = "JEWELERY_SECURITY_DOOR"
local SecurityDoorEntity = nil
local SecurityDoorPoint = nil

local JeweleryStatus = {
    Method = nil,
    IsBeingRobbed = false,
    NotifiedCops = false,
    JeweleryCases = {}
}

local IsInJewelery = false

RegisterNetEvent("strin_robberies:syncJeweleryStatus", function(jeweleryStatus)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    JeweleryStatus = jeweleryStatus
    if(JeweleryStatus.IsBeingRobbed) then
        DoorSystemSetDoorState(SecurityDoorId, 0, false, false)
        DoorSystemSetDoorState(SecurityDoorId, 5, false, false)
    end
end)

RegisterNetEvent("strin_robberies:robJeweleryCase", function(jeweleryCaseId)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    if lib.progressCircle({
        duration = JeweleryCaseRobTime,
        position = 'middle',
        useWhileDead = true,
        canCancel = false,
        anim = {
            dict = 'missheist_jewel',
            clip = 'smash_case'
        },
    }) then
        FreezeEntityPosition(ped, false)
    end
end)

lib.callback.register("strin_robberies:lockpickSecurityDoor", function()
    if(SecurityDoorEntity) then
        local ped = PlayerPedId()
        local securityDoorHeading = GetEntityHeading(SecurityDoorEntity)
        SetEntityHeading(ped, securityDoorHeading)
        PlayAnim(ped, "mp_arresting", "a_uncuff")
        --PlayAnim(ped, "mini@safe_cracking", "dial_turn_clock_normal")
        local skillCheckResult = lib.skillCheck({"easy", "medium", "easy", "medium"}, {"q", "w", "e", "r"})
        ClearPedTasks(ped)
        return skillCheckResult
    else
        return nil
    end
end)

Citizen.CreateThread(function()
    AddTextEntry("STRIN_ROBBERIES:JEWELERY", "<FONT FACE='Righteous'>~g~<b>[E]</b>~w~ Dveře</FONT>")
    AddTextEntry("STRIN_ROBBERIES:JEWELERY_CASE", "<FONT FACE='Righteous'>~g~<b>[E]</b>~w~ Vitrína</FONT>")
    local jeweleryPoint = lib.points.new({
        coords = Jewelery.centerCoords,
        distance = 25.0,
    })

    function jeweleryPoint:onEnter()
        IsInJewelery = true
        local state = DoorSystemGetDoorState(SecurityDoorId)
        
        local securityDoorHash = GetHashKey(Jewelery.securityDoorModel)
        SecurityDoorEntity = GetSecurityDoorEntity(securityDoorHash)

        local securityDoorCoords = GetEntityCoords(SecurityDoorEntity)
        SecurityDoorPoint = lib.points.new({
            coords = securityDoorCoords,
            distance = 1.0,
        })
        function SecurityDoorPoint:nearby()
            if(JeweleryStatus.IsBeingRobbed and SecurityDoorPoint) then
                SecurityDoorPoint:remove()
                SecurityDoorPoint = nil
                return
            end
            local textCoords = vector3(securityDoorCoords.x + 0.5, securityDoorCoords.y + 0.4, securityDoorCoords.z)
            if(not JeweleryStatus.IsBeingRobbed) then
                DrawFloatingText(textCoords, "STRIN_ROBBERIES:JEWELERY")
                if(IsControlJustReleased(0, 38)) then
                    TriggerServerEvent("strin_robberies:requestJeweleryRobbery", "SILENT")
                end
            end
        end
        if(state == -1) then
            AddDoorToSystem(SecurityDoorId, securityDoorHash, securityDoorCoords, false, false, false)
            DoorSystemSetDoorState(SecurityDoorId, 4, false, false)
            DoorSystemSetDoorState(SecurityDoorId, 1, false, false)
            return
        end
        if(state == 0 and not JeweleryStatus.IsBeingRobbed) then
            DoorSystemSetDoorState(SecurityDoorId, 4, false, false)
            DoorSystemSetDoorState(SecurityDoorId, 1, false, false)
        end
    end

    function jeweleryPoint:onExit()
        SecurityDoorEntity = nil
        IsInJewelery = false
        if(SecurityDoorPoint) then
            SecurityDoorPoint:remove()
        end
        SecurityDoorPoint = nil
    end

    function jeweleryPoint:nearby()
        if(not JeweleryStatus.IsBeingRobbed) then
            local ped = PlayerPedId()
            if(IsPedShooting(ped)) then
                TriggerServerEvent("strin_robberies:requestJeweleryRobbery", "LOUD")
                -- IsJeweleryBeingRobbed = true
            end
        end
        if(JeweleryStatus.IsBeingRobbed) then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            for i=1, #JeweleryStatus.JeweleryCases do
                local jeweleryCase = JeweleryStatus.JeweleryCases[i]
                if(jeweleryCase.state == "FULL") then
                    local distance = #(coords - jeweleryCase.coords)
                    if(distance >= 1) then
                        local markerCoords = vector3(jeweleryCase.coords.x, jeweleryCase.coords.y, jeweleryCase.coords.z + 1.0)
                        DrawMarker(0, markerCoords, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 255, 0, 0, 255, true)
                    end
                    if(distance < 1) then
                        local textCoords = vector3(jeweleryCase.coords.x, jeweleryCase.coords.y, jeweleryCase.coords.z + 0.5)
                        DrawFloatingText(textCoords, "STRIN_ROBBERIES:JEWELERY_CASE")
                        if(IsControlJustReleased(0, 38)) then
                            TriggerServerEvent("strin_robberies:robJeweleryCase")
                        end
                    end
                end
            end
        end
    end
end)

/*

-- Dev stuff, nebudu to dělat ručně ne xd - strin
RegisterCommand("getjewelerycases", function()
    local jeweleryCases = GetAllJeweleryCases()
    TriggerEvent("clipboard", json.encode(jeweleryCases, { indent = true }))
end)

function GetAllJeweleryCases()
    local foundJeweleryCases = {}
    local objects = GetGamePool("CObject")
    for _, v in pairs(JeweleryCaseTypes) do
        local hash = GetHashKey(v.name)
        for i=1, #objects do  
            if(GetEntityModel(objects[i]) == hash) then
                table.insert(foundJeweleryCases, {
                    coords = GetEntityCoords(objects[i]),
                    content = v.content,
                    size = v.size,
                })
            end
        end
    end
    return foundJeweleryCases
end*/

function GetJeweleryCaseEntity(coords)
    local objects = GetGamePool("CObject")
    local jeweleryCaseEntity = nil
    for i=1, #objects do
        local object = objects[i]
        local objectCoords = GetEntityCoords(object)
        local distance = #(objectCoords - coords)
        if(distance < 1) then
            jeweleryCaseEntity = object
            break
        end
    end
    return jeweleryCaseEntity
end

function GetSecurityDoorEntity(securityDoorHash)
    local objects = GetGamePool("CObject")
    local securityDoor = nil
    for i=1, #objects do  
        local objectModelHash = GetEntityModel(objects[i])
        if(objectModelHash == securityDoorHash) then
            securityDoor = objects[i]
            break
        end
    end
    return securityDoor
end