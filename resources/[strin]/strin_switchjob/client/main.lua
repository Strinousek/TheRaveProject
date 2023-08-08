RegisterNetEvent("strin_switchjob:openMenu")
AddEventHandler("strin_switchjob:openMenu", function(labeledJobs)
    OpenSwitchJobMenu(labeledJobs)
end)

function OpenSwitchJobMenu(labeledJobs)
    if(not next(labeledJobs)) then
        ESX.ShowNotification("~r~Nemáte žádné uložené práce.")
        return
    end
    
    local elements = {}
    for k,v in pairs(labeledJobs) do
        local job = labeledJobs[k]
        table.insert(elements, {label = ("%s - %s - %s"):format(job.label, job.grade_label, job.grade), value = k})
    end

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "strin_switchjob", {
        title = "Seznam zaměstnání",
        align = "center",
        elements = elements,
    }, function(data, menu)
        menu.close()
        if(data.current.value ~= nil) and (data.current.value ~= "xxx") then
            TriggerServerEvent("strin_switchjob:switchJob", data.current.value)
        end
    end, function(data, menu)
        menu.close()
    end)
end
