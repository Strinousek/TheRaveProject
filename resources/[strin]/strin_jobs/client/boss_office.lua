RegisterNetEvent("strin_jobs:openBossOffice", function(job, employees, vehicles)
    if(source == "" or GetInvokingResource() ~= nil) then
        return
    end
    OpenBossOffice(job, employees, vehicles)
end)

function OpenBossOffice(job, employees, vehicles)
    local elements = {}
    table.insert(elements, {
        label = ([[
            <div style="display: flex; justify-content: space-between; align-items: center">
                Název společnosti <div>%s</div>
            </div>
        ]]):format(job.label),
        value = "label"
    })
    table.insert(elements, {
        label = ([[
            <div style="display: flex; justify-content: space-between; align-items: center">
                Rozpočet <div>%s$</div>
            </div>
        ]]):format(job.balance),
        value = "balance"
    })
    table.insert(elements, {
        label = ([[
            <div style="display: flex; justify-content: space-between; align-items: center">
                Zaměstnanci <div>%sx</div>
            </div>
        ]]):format(#employees),
        value = "employees"
    })
    if(#vehicles > 0) then
        table.insert(elements, {
            label = ([[
                <div style="display: flex; justify-content: space-between; align-items: center">
                    Firemní vozidla <div>%sx</div>
                </div>
            ]]):format(#vehicles),
            value = "vehicles"
        })
    end
    table.insert(elements, {
        label = ([[
            <div style="display: flex; justify-content: space-between; align-items: center">
                Hodnosti <div>%sx</div>
            </div>
        ]]):format(#job.grades),
        value = "grades"
    })
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), job.name.."_bossoffice", {
        title = "Společnost - "..job.label,
        align = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        if(data.current.value == "label") then
            ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), job.name.."_label", {
                title = "Text"
            }, function(data2, menu2)
                TriggerServerEvent("strin_jobs:updateLabel", job.name, data2.value or "")
                menu2.close()
            end,function(data2, menu2)
                menu2.close()
            end)
        end
        if(data.current.value == "employees") then
            OpenEmployeesMenu(job, employees)
        end
        if(data.current.value == "balance") then
            OpenBalanceMenu(job)
        end
        if(data.current.value == "grades") then
            OpenGradesMenu(job)
        end
        if(data.current.value == "vehicles") then
            OpenVehiclesMenu(job, employees, vehicles)
        end
    end, function(data, menu)
        menu.close()
    end)
end

function OpenGradesMenu(job, employees)
    local elements = {}
    for i=1, #job.grades do
        table.insert(elements, {
            label = ([[
                <div style="display: flex; justify-content: space-between; align-items: center">
                    %s (%s) <div>%s$</div>
                </div>
            ]]):format(
                job.grades[i].label,
                i,
                job.grades[i].salary
            ),
            value = i
        })
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), job.name.."_grades", {
        title = "Hodnosti - "..job.label,
        align = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        OpenGradeMenu(job, data.current.value)
    end, function(data, menu)
        menu.close()
    end)
end

function OpenGradeMenu(job, grade)
    local elements = {
        {
            label = ([[
                <div style="display: flex; justify-content: space-between; align-items: center">
                    Změnit výplatní čásku<div>%s$</div>
                </div>
            ]]):format(
                job.grades[grade].salary
            ),
            value = "salary"
        },
        {
            label = ([[
                <div style="display: flex; justify-content: space-between; align-items: center">
                    Změnit název <div>%s</div>
                </div>
            ]]):format(
                job.grades[grade].label
            ),
            value = "label"
        },
    }
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), job.name.."_grades", {
        title = "Hodnost - "..job.grades[grade].label,
        align = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), job.name.."_salary", {
            title = data.current.value == "salary" and "Částka" or "Text"
        }, function(data2, menu2)
            if(data.current.value == "salary") then
                TriggerServerEvent("strin_jobs:updateGrade", job.name, grade, {
                    salary = data2.value or ""
                })
            elseif(data.current.value == "label") then
                TriggerServerEvent("strin_jobs:updateGrade", job.name, grade, {
                    label = data2.value or ""
                })
            end
            menu2.close()
        end,function(data2, menu2)
            menu2.close()
        end)
    end, function(data, menu)
        menu.close()
    end)
end

function OpenBalanceMenu(job)
    local elements = {
        {label = "Vložit peníze", value = "add"},
        {label = "Vybrat peníze", value = "remove"}
    }
    local totalCost = lib.callback.await("strin_jobs:getTotalCost", false, job.name)
    table.insert(elements, {
        label = ([[
            <div style="display: flex; justify-content: space-between; align-items: center">
                Aktuální náklady: <div>%s</div>
            </div>
        ]]):format(totalCost),
        value = "total_cost"
    })
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), job.name.."_balance", {
        title = "Rozpočet - "..job.label,
        align = "center",
        elements = elements
    }, function(data, menu)
        if(data.current.value ~= "total_cost") then
            menu.close()
            ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), job.name.."_money", {
                title = "Částka"
            }, function(data2, menu2)
                if(data.current.value == "add") then
                    TriggerServerEvent("strin_jobs:addMoney", job.name, data2.value or "")
                elseif(data.current.value == "remove") then
                    TriggerServerEvent("strin_jobs:removeMoney", job.name, data2.value or "")
                end
                menu2.close()
            end,function(data2, menu2)
                menu2.close()
            end)
        end
    end, function(data, menu)
        menu.close()
    end)
end

function OpenEmployeesMenu(job, employees, pageNumber, onSubmit)
    local elements = {}
    local pageSize = 8
    local pageCount = (#employees % pageSize == 0) and math.floor(#employees / pageSize) or math.ceil(#employees / pageSize + 0.5)
    if(not pageNumber) then
        pageNumber = 1
    end
    local startIndex = (pageNumber == 1) and 1 or ((pageSize * (pageNumber - 1)) + 1)
    local endIndex = pageNumber * pageSize

    if(pageNumber == 1 and not onSubmit) then
        table.insert(elements, {
            label = "Nabrat nového zaměstnance",
            value = "hire"
        })
    end

    if(pageNumber > 1) then
        table.insert(elements, {
            label = '<span style="color: #e74c3c"> << Předchozí stránka </span>',
            value = "previous_page"
        })
    end

    for i=startIndex, endIndex do
        local employee = employees[i]
        if(employee) then
            table.insert(elements, {
                label = ([[
                    <div style="display: flex; justify-content: space-between; align-items: center">
                        %s <div>%s (%s)</div>
                    </div>
                ]]):format(
                    employee.fullname,
                    job.grades[employee.job_grade].label,
                    employee.job_grade
                ),
                value = i,
                employee = employee
            })
        end
    end

    if(pageNumber < pageCount) then
        table.insert(elements, {
            label = '<span style="color: #2ecc71"> Další stránka >> </span>',
            value = "next_page"
        })
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), job.name.."_employees_"..pageNumber, {
        title = "Zaměstnanci",
        align = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        if(data.current.value == "next_page") then
            OpenEmployeesMenu(job, employees, pageNumber + 1, onSubmit)
            return
        end
        if(data.current.value == "previous_page") then
            OpenEmployeesMenu(job, employees, pageNumber - 1, onSubmit)
            return
        end
        if(data.current.value == "hire") then
            local nearbyPlayers = lib.getNearbyPlayers(GetEntityCoords(ped), 15.0, false)
            if(not next(nearbyPlayers)) then
                ESX.ShowNotification("V okolí nejsou žádní hráči!", {
                    type = "error"
                })
                OpenEmployeesMenu(job, employees, pageNumber, onSubmit)
                return
            end
            local playerElements = {}
            for i=1, #nearbyPlayers do
                nearbyPlayers[i].serverId = GetPlayerServerId(nearbyPlayers[i].id)
                table.insert(playerElements, {
                    label = ESX.SanitizeString(GetPlayerName(nearbyPlayers[i].id)).." - #"..nearbyPlayers[i].serverId,
                    value = nearbyPlayers[i].serverId
                })
            end
            ESX.UI.Menu.Open("default", GetCurrentResourceName(), "hire_players_menu", {
                title = "Nabírací menu",
                align = "center",
                elements = playerElements,
            }, function(data2, menu2)
                menu2.close()
                lib.callback("strin_jobs:hireEmployee", false, function(success, errorMessage)
                    if(not success) then
                        ESX.ShowNotification(errorMessage, { type = "error" })
                        OpenEmployeesMenu(job, employees, pageNumber, onSubmit)
                        return
                    end
                    TriggerServerEvent("strin_jobs:requestBossOffice", ESX?.PlayerData?.job?.name)
                    ESX.ShowNotification("Zaměstnanec registrován.")
                end, data2.current.value)
            end, function(data2, menu2)
                OpenEmployeesMenu(job, employees, pageNumber, onSubmit)
                menu2.close()
            end)
            return
        end
        if(onSubmit) then
            onSubmit(data.current.employee)
            return
        end
        OpenEmployeeMenu(job, data.current.employee)
    end, function(data, menu)
        menu.close()
    end)
end

function OpenEmployeeMenu(job, employee)
    local elements = {
        {label = "Vyhodit", value = "fire"},
        {label = "Změnit hodnost", value = "update"},
    }
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), job.name.."_employee", {
        title = "Zaměstnanec - "..employee.fullname,
        align = "center",
        elements = elements
    }, function(data, menu)
        if(data.current.value == "fire") then
            menu.close()
            TriggerServerEvent("strin_jobs:fireEmployee", job.name, employee.identifier, employee.char_id)
        elseif(data.current.value == "update") then
            menu.close()
            OpenEmployeeGradesMenu(job, employee)
        end
    end, function(data, menu)
        menu.close()
    end)
end

function OpenEmployeeGradesMenu(job, employee)
    local elements = {}
    for i=1, #job.grades do
        table.insert(elements, {
            label = ([[
                <div style="display: flex; justify-content: space-between; align-items: center">
                    %s (%s) <div>%s</div>
                </div>
            ]]):format(
                job.grades[i].label,
                i,
                (i == employee.job_grade and "AKTUÁLNÍ" or "")
            ),
            value = i
        })
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), job.name.."_employee_grade", {
        title = "Zaměstnanec - "..employee.fullname,
        align = "center",
        elements = elements
    }, function(data, menu)
        if(data.current.value ~= employee.job_grade) then
            menu.close()
            TriggerServerEvent("strin_jobs:updateEmployee", job.name, employee.identifier, employee.char_id, data.current.value)
        end
    end, function(data, menu)
        menu.close()
    end)
end

/*
    pageNumber = 3
    pageSize = 8

    pageNumber * pageSize = 24 (start index must be 17)

    (pageSize * (pageNumber - 1)) + 1 = 17

    pageNumber = 2
    pageSize = 8

    pageNumber * pageSize = 16 (start index must be 9)

    (pageSize * (pageNumber - 1)) + 1 = 17

    shout out to all the dumpers, sending regards - strin <3
*/

function OpenVehiclesMenu(job, employees, vehicles, pageNumber)
    local elements = {}
    local pageSize = 8
    local pageCount = (#vehicles % pageSize == 0) and math.floor(#vehicles / pageSize) or (math.ceil(#vehicles / pageSize + 0.5))
    if(not pageNumber) then
        pageNumber = 1
    end
    local startIndex = (pageNumber == 1) and 1 or ((pageSize * (pageNumber - 1)) + 1)
    local endIndex = pageNumber * pageSize
    
    if(pageNumber > 1) then
        table.insert(elements, {
            label = '<span style="color: #e74c3c"> << Předchozí stránka </span>',
            value = "previous_page"
        })
    end
    for i=startIndex, endIndex do
        local vehicle = vehicles[i]
        if(vehicle) then
            local owner = { employeeIndex = nil, identifier = nil, char_id = nil, fullname = nil }
            if(vehicle.owner and type(vehicle.owner) ~= "table") then
                local ownerValues = {}
                for value in string.gmatch(vehicle.owner, "([^:]+)") do
                    table.insert(ownerValues, value)
                end
                owner.identifier = ownerValues[1]
                owner.char_id = tonumber(ownerValues[2])
                for i=1, #employees do
                    local employee = employees[i]
                    if(employee.identifier == owner.identifier and employee.char_id == owner.char_id) then
                        owner.fullname = employee.fullname
                        owner.employeeIndex = i
                        break
                    end
                end
            end
            if(type(vehicle.owner) ~= "table") then
                vehicles[i].owner = owner
            end
            table.insert(elements, {
                label = ([[
                    <div style="display: flex; justify-content: space-between; align-items: center; min-width: 400px;">
                        %s%s<div>%s</div>
                    </div>
                ]]):format(
                    vehicle.model,
                    (vehicle.owner?.identifier) and "<div>"..vehicle.owner?.fullname.."</div>" or "",
                    vehicle.plate
                ),
                value = i,
            })
        end
    end
    if(pageNumber < pageCount) then
        table.insert(elements, {
            label = '<span style="color: #2ecc71"> Další stránka >> </span>',
            value = "next_page"
        })
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), job.name.."_vehicles_"..pageNumber, {
        title = "Firemní vozidla",
        align = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        if(data.current.value == "next_page") then
            OpenVehiclesMenu(job, employees, vehicles, pageNumber + 1)
            return
        end
        if(data.current.value == "previous_page") then
            OpenVehiclesMenu(job, employees, vehicles, pageNumber - 1)
            return
        end
        OpenVehicleMenu(job, employees, vehicles[data.current.value])
    end, function(data, menu)
        menu.close()
    end)
end

function OpenVehicleMenu(job, employees, vehicle)
    local elements = {
        {
            label = ([[
                <div style="display: flex; justify-content: space-between; align-items: center; min-width: 400px;">
                    Přiřadit zaměstnance %s
                </div>
            ]]):format(
                (vehicle.owner?.identifier) and "<div>"..vehicle.owner?.fullname.."</div>" or ""
            ),
            value = "attach_employee"
        }
    }
    if(vehicle.owner?.identifier) then
        table.insert(elements, {
            label = ([[
                <div style="display: flex; justify-content: space-between; align-items: center; min-width: 400px;">
                    Odebrat zaměstnance
                </div>
            ]]):format(
                (vehicle.owner?.identifier) and "<div>"..vehicle.owner?.fullname.."</div>" or ""
            ),
            value = "detach_employee"
        })
    end
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), job.name.."_vehicle", {
        title = vehicle.model.." - "..vehicle.plate,
        align = "center",
        elements = elements
    }, function(data, menu)
        menu.close()
        if(data.current.value == "attach_employee") then
            OpenEmployeesMenu(job, employees, nil, function(employee)
                if(vehicle.owner?.identifier == employee.identifier and vehicle.owner?.char_id == employee.char_id) then
                    return
                end
                TriggerServerEvent("strin_jobs:attachEmployeeToVehicle", vehicle.id, employee.identifier, employee.char_id)
            end)
        end
        if(data.current.value == "detach_employee") then
            TriggerServerEvent("strin_jobs:detachEmployeeFromVehicle", vehicle.id)
        end
    end, function(data, menu)
        menu.close()
    end)
end