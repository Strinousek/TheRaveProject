local skills = {}

Citizen.CreateThread(function()
    for k, v in pairs(SKILLS) do
        skills[k] = v.default
        UpdateSkill(k, true, v.default, false)
    end

    Citizen.Wait(500)

    TriggerEvent("chat:addSuggestion", "/skills", "Vypíše seznam schopností vaší postavy")
    TriggerEvent("chat:addSuggestion", "/schopnosti", "Vypíše seznam schopností vaší postavy")

    /*
        local loadedSkills = lib.callback.await("strin_skills:getSkills", false)
        for k, v in pairs(loadedSkills) do
            changeSkill(k, true, v, false)
        end
    */
    while true do
        Citizen.Wait(REDUCE_TIMER)
        for k, v in pairs(SKILLS) do
            UpdateSkill(k, false, v.reduce, false)
        end

        TriggerServerEvent("strin_skills:updateSkills", skills)
    end
end)

function UpdateSkill(skillName, setting, amount, save)
    if not SKILLS[skillName] then
        return
    end

    if setting then
        skills[skillName] = amount
    else
        local valueBefore = skills[skillName]
        if amount < 0 or valueBefore <= 99.5 then
            local notificationType = "success"
            if(amount <= -0.05) then
                notificationType = "error"
            end
            ESX.ShowNotification((notificationType == "success" and "+" or "")..amount.."% "..SKILLS[skillName].label, {
                type = notificationType
            })
        end

        skills[skillName] = skills[skillName] + amount
    end

    if skills[skillName] > 100 then
        skills[skillName] = 100
    elseif skills[skillName] < 0 then
        skills[skillName] = 0
    end

    SKILLS[skillName].effect(skills[skillName])

    if save then
        TriggerServerEvent("strin_skills:updateSkills", skills)
    end
end

RegisterCommand("skills", function()
    ShowSkills()
end)

RegisterCommand("schopnosti", function()
    ShowSkills()
end)

function ShowSkills()
    local elements = {}

    for k, v in pairs(SKILLS) do
        table.insert(elements, {
            label = "<div style='display: flex; justify-content: space-between; align-items: center;'><div><strong>"..v.label.."</strong>:</div> "..string.format("%.2f", skills[k]).."%</div>",
            value = k
        })
    end

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "skill_menu", {
        title = "Schopnosti",
        align = "center",
        elements = elements,
    }, function(data, menu)
        ESX.ShowNotification(SKILLS[data.current.value]?.tooltip or "Tato schopnost má zvláštní způsob učení nebo není dostupná.")
    end, function(data, menu)
        menu.close()
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)

        local change = 0.0

        if IsPedRunning(cache.ped) then
            change = change + 0.2
        end

        if IsPedSprinting(cache.ped) then
            change = change + 0.3
        end

        if cache.vehicle and IsPedOnAnyBike(cache.ped) then
            local vehicle = cache.vehicle
            if DoesEntityExist(vehicle) and IsThisModelABicycle(GetEntityModel(vehicle)) and GetEntitySpeed(vehicle) > 5.0 then
                change = change + 0.3
            end
        end

        if change > 0 then
            UpdateSkill("stamina", false, change, true)
        end
    end
end)