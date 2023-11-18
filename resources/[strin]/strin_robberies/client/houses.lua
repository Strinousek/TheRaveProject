local CurrentHouse = nil
local HousesData = {}
local HousePoints = {}
local IsDoingAction = false


RegisterNetEvent("strin_robberies:syncHouses", function(houses)
    -- on first resource start, if the player reconnected or sum 
    if(not next(HousesData)) then
        while(not ESX.IsPlayerLoaded()) do
            Citizen.Wait(0)
        end
        for house, data in each(houses) do
            if(lib.table.contains(data.players, ESX.GetPlayerData().identifier)) then
                CurrentHouse = house
                TeleportToCoords(Houses[house].houseType.insidePositions.Exit)
                CreateZones(house)
                break
            end
        end
    end
    HousesData = houses
end)

Citizen.CreateThread(function()
    AddTextEntry("STRIN_ROBBERIES:ENTER_HOUSE", "<FONT FACE='Righteous'>~g~<b>[E]</b>~s~ Vstoupit</FONT>")
    AddTextEntry("STRIN_ROBBERIES:SEARCH_PLACE", "<FONT FACE='Righteous'>~g~<b>[E]</b>~s~ Prohledat</FONT>")
    AddTextEntry("STRIN_ROBBERIES:LEAVE_HOUSE", "<FONT FACE='Righteous'>~g~<b>[E]</b>~s~ Odejít</FONT>")
    for house, data in pairs(Houses) do
        local point = lib.points.new({
            coords = data.coords.xyz,
            distance = 1.5,
        })
        function point:nearby()
            if(IsDoingAction) then
                return
            end
            DisplayHelpTextThisFrame("STRIN_ROBBERIES:ENTER_HOUSE", false)
            if(IsControlJustReleased(0, 38)) then
                if not HasWhitelistedJob() and not IsHouseEnterable(house) then
                    EnterHouse(house, true)
                else
                    EnterHouse(house, false)
                end
            end
        end
    end
end)

function IsHouseEnterable(house)
    if HousesData[house] == nil or HousesData[house].locked == nil or HousesData[house].locked then
        return false
    end
    return true
end

function EnterHouse(house, locked)
    if(not locked) then
        local success = lib.callback.await("strin_robberies:enterHouse", false)
        if(not success) then
            return
        end
        CurrentHouse = house
        TeleportToCoords(Houses[house].houseType.insidePositions.Exit)
        CreateZones(house)
        return
    end

    local elements = {}
    local hasLockpick = Inventory:GetItemCount("lockpick") > 0
    table.insert(elements, { label = hasLockpick and "Vloupat se do objektu" or "Nemáte při sobě žádný paklíč.", value = hasLockpick and "rob" or "cancel" })
    table.insert(elements, { label = "Zrušit", value = "cancel" })
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "house_robbery_menu", {
        title = "Vloupání",
        align = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        if(data.current.value == "rob") then
            local houseData = Houses[house]
            SetEntityCoords(cache.ped, houseData.coords.xy, houseData.coords.z - 0.98)
            SetEntityHeading(cache.ped, houseData.coords.w - 180 > 0 and houseData.coords.w - 180 or houseData.coords.w + 180)
            if(lib.progressBar({
                label = "Páčíš zámek..",
                duration = 7000,
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = true,
                    car = true,
                    mouse = false,
                    combat = true
                },
                anim = {
                    dict = "mini@safe_cracking",
                    clip = "idle_base"
                }
            })) then
                local success = lib.callback.await("strin_robberies:lockpickHouse", false)
                if(not success) then
                    return
                end
                CurrentHouse = house
                TeleportToCoords(Houses[house].houseType.insidePositions.Exit)
                CreateZones(house)
            end
        end
    end, function(data, menu)
        menu.close()
    end)
end

function SearchPlace(currentPlace)
    IsDoingAction = true
    if(lib.progressBar({
        label = "Prohledáváš..",
        duration = 4000,
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            mouse = false,
            combat = true
        },
        anim = {
            scenario = "PROP_HUMAN_BUM_BIN",
        }

    })) then
        lib.callback.await("strin_robberies:robHousePlace", false)
        IsDoingAction = false
    end
    IsDoingAction = false
end

function LeaveHouse()
    IsDoingAction = true
    local success = lib.callback.await("strin_robberies:leaveHouse")
    if(success) then
        TeleportToCoords(Houses[CurrentHouse].coords)
        DeleteZones(CurrentHouse)
        Citizen.Wait(1000)
        CurrentHouse = nil
    end
    IsDoingAction = false
end

function HasWhitelistedJob()
    local jobs = exports.strin_jobs:GetDistressJobs()
    if(lib.table.contains(jobs, ESX.PlayerData.job.name)) then
        return true
    end

    return false
end

function TeleportToCoords(coords)
    IsDoingAction = true
    DoScreenFadeOut(1000)
    NetworkFadeOutEntity(cache.ped, true, false)
    Citizen.Wait(1000)

    FreezeEntityPosition(cache.ped, true)
    SetEntityCoords(cache.ped, coords.xyz)
    SetEntityHeading(cache.ped, coords.w)

    while not HasCollisionLoadedAroundEntity(cache.ped) do
        RequestCollisionAtCoord(coords)
        Citizen.Wait(0)
    end

    FreezeEntityPosition(cache.ped, false)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
    NetworkFadeInEntity(cache.ped, true)
    IsDoingAction = false
end

function CreateZones(house)
    if(HasWhitelistedJob()) then
        local coords = Houses[house].houseType.insidePositions["Exit"]
        local point = lib.points.new({
            coords = coords.xyz,
            distance = 0.75,
        })
        table.insert(HousePoints, point)
        function point:nearby()
            if(IsDoingAction) then
                return
            end
            DisplayHelpTextThisFrame("STRIN_ROBBERIES:LEAVE_HOUSE", false)
            if(IsControlJustReleased(0, 38)) then
                LeaveHouse()
            end
        end
        return
    end

    for place, coords in pairs(Houses[house].houseType.insidePositions) do
        local point = lib.points.new({
            coords = coords.xyz,
            distance = 0.75,
        })
        table.insert(HousePoints, point)
        function point:nearby()
            if(IsDoingAction) then
                return
            end
            if(place == "Exit") then
                DisplayHelpTextThisFrame("STRIN_ROBBERIES:LEAVE_HOUSE", false)
                if(IsControlJustReleased(0, 38)) then
                    LeaveHouse()
                end
                return
            end
            DisplayHelpTextThisFrame("STRIN_ROBBERIES:SEARCH_PLACE", false)
            if(IsControlJustReleased(0, 38)) then
                SearchPlace(place)
            end
        end
    end
end

function DeleteZones(house)
    for i=1, #HousePoints do
        HousePoints[i]:remove()
    end
    HousePoints = {}
end
