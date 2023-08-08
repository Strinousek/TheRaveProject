SkinChanger = exports.skinchanger
InMenu = false
local lastSkin = nil
local currentPromise = nil
local currentOnConfirmCallback = nil
local currentOnCancelCallback = nil

function GetSkinParts(restrict)
    local components, maxValues = SkinChanger:GetData()
    for dataKey, dataValue in pairs(maxValues) do
        for i=1, #components do
            if(components[i].name == dataKey) then
                components[i].max = dataValue
            end
        end
    end
    local skinParts = {}
    for i=1, #components do
        local component = components[i]
        if(not restrict) then
            local value = component.componentId == 0 and GetPedPropIndex(PlayerPedId(), component.componentId) or component.value
            skinParts[#skinParts + 1] = {
                label = component.label,
                name = component.name,
                value = value,
                min = component.min,
                max = component.max
            }
        end
        if(restrict and next(restrict)) then
            for j=1, #restrict do
                local restrictedComponentName = restrict[j]
                if(component.name == restrictedComponentName) then
                    local value = component.componentId == 0 and GetPedPropIndex(PlayerPedId(), component.componentId) or component.value
                    skinParts[#skinParts + 1] = {
                        label = component.label,
                        name = component.name,
                        value = value,
                        min = component.min,
                        max = component.max
                    }
                end
            end
        end
    end
    return skinParts
end

-- if callbacks are omitted then return promise
function OpenSkinMenu(onConfirmCallback, onCancelCallback, restrict)
    if(InMenu or Camera.active) then
        return
    end
    
    SetNUIStatus(true)
    Camera.Activate(500)
    local parts = GetSkinParts(restrict)
    lastSkin = SkinChanger:GetSkin()
    SendNUIMessage({
        action = "showMenu",
        parts = parts
    })
    currentOnConfirmCallback = onConfirmCallback or nil
    currentOnCancelCallback = onCancelCallback or nil
    if(not onConfirmCallback and not onCancelCallback) then
        currentPromise = promise.new()
        return table.unpack(Citizen.Await(currentPromise))
    end
end

exports("OpenSkinMenu", OpenSkinMenu)

function CloseSkinMenu(action)
    SetNUIStatus(false)
    Camera.Deactivate()
    SendNUIMessage({
        action = "hideMenu"
    })
    local savedLastSkin = lib.table.deepclone(lastSkin)
    lastSkin = nil
    if(action == "confirm") then
        local skin = SkinChanger:GetSkin()
        if(currentOnConfirmCallback) then
            currentOnConfirmCallback(skin, savedLastSkin)
            return
        end

        if(currentPromise) then
            currentPromise:resolve({skin, savedLastSkin})
            currentPromise = nil
        end
    elseif(action == "cancel") then
        if(currentOnCancelCallback) then
            currentOnCancelCallback({}, savedLastSkin)
            return
        end

        if(currentPromise) then
            currentPromise:resolve({{}, savedLastSkin})
            currentPromise = nil
        end
    end
end

RegisterNUICallback("changeSkinPart", function(data, cb)
    local skinPart = data.part
    local component = SkinChanger:GetComponent(skinPart)
    local skinPartValue = tonumber(data.value) or component.min
    TriggerEvent("skinchanger:change", skinPart, skinPartValue)
    if((skinPart:find("_1") and component.componentId ~= nil) or (skinPart:find("arms") and not skinPart:find("_2"))) then
        local textureComponentName = skinPart:find("arms") and "arms_2" or skinPart:gsub("_1", "_2")
        local textureComponent = SkinChanger:GetComponent(textureComponentName)
        SendNUIMessage({
            action = "updateSkinPart",
            part = textureComponentName,
            min = textureComponent.min,
            max = textureComponent.max
        })
    end
    cb("ok")
end)

RegisterNUICallback('setCameraView', function(data, cb)
    Camera.SetView(data.view or "head")
    cb("ok")
end)

RegisterNUICallback('updateCameraRotation', function(data, cb)
    Camera.mouseX = tonumber(data.x)
    Camera.mouseY = tonumber(data.y)
    Camera.updateRot = true
    cb("ok")
end)

RegisterNUICallback('updateCameraZoom', function(data, cb)
    Camera.radius = Camera.radius + (tonumber(data.zoom))
    Camera.updateZoom = true
    cb("ok")
end)

RegisterNUICallback("cancelMenu", function(data, cb)
    CloseSkinMenu("cancel")
    cb("ok")
end)

RegisterNUICallback("confirmMenu", function(data, cb)
    CloseSkinMenu("confirm")
    cb("ok")
end)

function SetNUIStatus(display)
    InMenu = display
    SetNuiFocus(display, display)
end

/*RegisterCommand("skin", function()
    IsModelLoaded = true
    InMenu = false
    OpenSkinMenu()
end)*/

/*RegisterCommand("hp", function(_, args)
    SetEntityHealth(PlayerPedId(), tonumber(args[1]))
end)*/

RegisterCommand('reloadchar', function()
    local ped = PlayerPedId()
    local previousHealth  = GetEntityHealth(ped)
    lib.callback("strin_skin:getSavedSkin", false, function(skin)
        local isMale = skin.sex == 0
        TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
            TriggerEvent('skinchanger:loadSkin', skin, function()
                local ped = PlayerPedId()
                ClearPedBloodDamage(ped)
                ResetPedVisibleDamage(ped)
                ClearPedLastWeaponDamage(ped)
                NetworkSetFriendlyFireOption(true)
                SetCanAttackFriendly(ped, true, true)     
                SetEntityHealth(ped, previousHealth)     
            end)
            TriggerEvent('esx:restoreLoadout')
        end)
    end)
    ClearPedTasks(ped)
end, false)