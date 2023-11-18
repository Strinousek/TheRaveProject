local CurrentHouse = nil
local HousesData = {}
local IsDoingAction = false

RegisterNetEvent("rob_houses:sync")
AddEventHandler("rob_houses:sync", function(data, requestedInstance)
    HousesData = data
    if requestedInstance then
        for house, houseData in pairs(HousesData) do
            if houseData.players then
                for _, player in each(houseData.players) do
                    if player == ESX.PlayerData.identifier then
                        --TriggerServerEvent("instance:joinInstance", "rob_house_" .. house)
                        break
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    for house, data in pairs(Houses) do
        exports.ox_target:addBoxZone({
            coords = data.coords,
            distance = 1.5,
            options = {
                {
                    label = "Vstoupit",
                    icon = "fa-solid fa-hand",
                    canInteract = function()
                        return not IsDoingAction
                    end,
                    onSelect = function()
                        if not HasWhitelistedJob() and not IsHouseEnterable(house) then
                            EnterHouse(house, true)
                        else
                            EnterHouse(house, false)
                        end
                    end,
                }
            }
        })
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
        CurrentHouse = house
        TeleportToCoords(Houses[house].houseType.insidePositions.Exit)
        CreateZones(house)

        --TriggerServerEvent("instance:joinInstance", "rob_house_" .. house)
        --TriggerServerEvent("rob_houses:joinHouse", house)
        return
    end

    local elements = {}
    if(Inventory:GetItemCount("lockpick") > 0) then
        table.insert(elements, { label = "Vloupat se do objektu", value = "rob" })
    end
    table.insert(elements, { label = "Zrušit", value = "cancel" })
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "house_robbery_menu", {
        title = "Vloupání",
        align = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        if(data.current.value == "rob") then
            TriggerServerEvent("rob_houses:lockpick", house)
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
        IsDoingAction = false
        local wasRobbed = false
        for _, place in each(HousesData[CurrentHouse].robbed) do
            if place == currentPlace then
                wasRobbed = true
                break
            end
        end
        if not wasRobbed then
            table.insert(HousesData[CurrentHouse].robbed, currentPlace)
            --TriggerServerEvent("rob_houses:robbedHousePlace", currentHouse, currentPlace)
        else
            ESX.ShowNotification("Tato část už je prázdná!", { type = "error" })
        end
        return 
    end
    IsDoingAction = false
end

function LeaveHouse()
    TeleportToCoords(Houses[CurrentHouse].coords)
    DeleteZones(CurrentHouse)
    --TriggerServerEvent("instance:quitInstance")
    --TriggerServerEvent("rob_houses:leaveHouse", currentHouse)
    Citizen.Wait(1000)
    CurrentHouse = nil
end

function HasWhitelistedJob()
    local jobs = exports.strin_jobs:GetDistressJobs()
    if(lib.table.contains(jobs, ESX.PlayerData.job.name)) then
        return true
    end

    return false
end

function TeleportToCoords(coords)
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
end

RegisterNetEvent("rob_houses:lockpick")
AddEventHandler("rob_houses:lockpick", function(house)
    doingAction = true
    local houseData = Config.RobPlaces[house]
    local playerPed = PlayerPedId()
    local playerServerId = GetPlayerServerId(PlayerId())
    SetEntityCoords(playerPed, houseData.Coords.xy, houseData.Coords.z - 0.98)
    SetEntityHeading(playerPed, houseData.Coords.w - 180 > 0 and houseData.Coords.w - 180 or houseData.Coords.w + 180)
    TriggerServerEvent("sound:playSound", "lockpick", 3.0, GetEntityCoords(playerPed), "rob_house_" .. playerServerId)

    exports.progressbar:startProgressBar({
        Duration = 7500,
        Label = "Páčíš zámek..",
        CanBeDead = false,
        CanCancel = true,
        DisableControls = {
            Movement = true,
            CarMovement = true,
            Mouse = false,
            Combat = true
        },
        Animation = {
            animDict = "mini@safe_cracking",
            anim = "idle_base"
        }
    }, function(finished)
        TriggerServerEvent("sound:stopSound", "rob_house_" .. playerServerId)
        doingAction = false
        if finished then
            TriggerServerEvent("rob_houses:unlockHouse", house)
            enterHouse(house, false)
        end
    end)
end)
RegisterNetEvent("rob_houses:searchResult")
AddEventHandler("rob_houses:searchResult", function(item, count)
    if not item then
        exports.notify:display({
            type = "error",
            title = "Neúspěch",
            text = "Nic jsi zde nenašel",
            icon = "fas fa-search",
            length = 3000
        })
    else
        local itemData = exports.inventory:getItem(item)
        exports.notify:display({
            type = "success",
            title = "Úspěch",
            text = "Našel jsi " .. count .. "x " .. itemData.label,
            icon = "fas fa-search",
            length = 3000
        })
    end
end)

RegisterNetEvent("rob_houses:error")
AddEventHandler("rob_houses:error", function(errorMessage)
    if errorMessage == "weightExceeded" then
        errorMessage = "Tolik toho neuneseš!"
    elseif errorMessage == "spaceExceeded" then
        errorMessage = "Nemáš u sebe místo!"
    end

    exports.notify:display({
        type = "error",
        title = "Chyba",
        text = errorMessage,
        icon = "fas fa-times",
        length = 3000
    })
end)

function CreateZones(house)
    if(HasWhitelistedJob()) then
        local place = "Exit"
        local coords = Houses[house].houseType.insidePositions["Exit"]
        exports.ox_target:addBoxZone({
            name = "house-"..place,
            coords = coords.xyz,
            distance = 1.0,
            options = {
                {
                    label = "Odejít",
                    icon = "fas fa-door-open",
                    onSelect = function()
                        LeaveHouse()
                    end,
                }
            }
        })
        return
    end
    for place, coords in pairs(Houses[house].houseType.insidePositions) do
        exports.ox_target:addBoxZone({
            name = "house-"..place,
            coords = coords.xyz,
            distance = 1.0,
            options = {
                {
                    label = place == "Exit" and "Odejít" or "Prohledat",
                    icon = place == "Exit" and "fas fa-door-open" or "fas fa-search",
                    onSelect = function()
                        if place == "Exit" then
                            LeaveHouse()
                        else
                            searchPlace(place)
                        end
                    end,
                }
            }
        })
    end
end

function DeleteZones(house)
    for place, _ in pairs(Houses[house].houseType.insidePositions) do
        exports.ox_target:removeZone("house-"..place)
    end
end
