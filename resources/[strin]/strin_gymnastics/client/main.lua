local Fatigue = 0.0
local StrengthBuffer = 0.0
local IsExercising = false
local CurrentProp = nil

Citizen.CreateThread(function()
    for k,v in pairs(EXERCISE_TYPES) do
        if(v.models) then
            exports.ox_target:addModel(v.models, {
                {
                    label = _U(k),
                    icon = "fa-solid fa-dumbbell",
                    onSelect = function(data)
                        StartExercise(k, {
                            entity = data.entity
                        })
                    end,
                    canInteract = function()
                        return not IsExercising
                    end,
                }
            })
        end
        RegisterCommand(k:gsub("%_", ""), function()
            if(IsExercising) then
                return
            end
            local data = nil
            if(v.models) then
                ESX.ShowNotification("Takové cviky lze pouze provádět přes stroje!", { type = "error" })
                return
            end
            if(v.requiresGym) then
                local gymIndex, gym = GetNearestGym()
                if(not gym) then
                    ESX.ShowNotification("Takové cviky lze pouze provádět v posilovně!", { type = "error" })
                    return
                end
                data = { gymIndex = gymIndex, gym = gym }
            end
            StartExercise(k, data)
        end)
        ::skipLoop::
    end

    while true do
        if(Fatigue > 0) then
            Fatigue -= 1.0
        end
        Citizen.Wait(1500)
    end
end)

AddEventHandler("strin_base:cancelledAnimation", function()
    if(IsExercising) then
        IsExercising = false
        if(CurrentProp) then
            DeleteEntity(CurrentProp)
        end
    end
end)

function StartExercise(exerciseType, data)
    local exercise = EXERCISE_TYPES[exerciseType]
    local totalReps = 0
    local repsPerSet = 5.0
    IsExercising = true
    if(exerciseType == "chin_up") then
        local entity = data.entity
        local heading = GetEntityHeading(entity)
        local coords = GetEntityCoords(entity)
        local headingRadius = math.rad(heading + 90.0)
        local coordsOffset = vector3(math.cos(headingRadius), math.sin(headingRadius), -1.0)
        SetEntityCoords(cache.ped, coords + coordsOffset)
        SetEntityHeading(cache.ped, GetEntityHeading(entity) + 180)
        TaskStartScenarioInPlace(cache.ped, exercise.anim?.scenario, 0.0, true)
        Citizen.Wait(2600)
        Citizen.CreateThread(function()
            local startingFatigue = Fatigue
            while IsPedUsingScenario(cache.ped, exercise.anim?.scenario) and totalReps < CalculateMaxReps(repsPerSet, startingFatigue) do
                Citizen.Wait(2600)
                totalReps += 1
            end
            ClearPedTasks(cache.ped)
            if(totalReps == 0) then
                ESX.ShowNotification("Jste vyčerpaný/á, dejte si chvilku pauzu.")
            else
                Fatigue += math.floor((totalReps * 40 / 10) * 2.0)
            end
            IsExercising = false
        end)
    else
        if(exercise.anim?.dict) then
            local timeBetweenReps = 1000
            local timeBeforeFirstRep = 250
            if(exerciseType == "squat" or exerciseType == "situp") then
                timeBetweenReps = 2000
            elseif(exerciseType == "jumping_jack") then
                timeBetweenReps = 900
            elseif(exerciseType == "barbell_curl") then
                timeBetweenReps = 4500
                timeBeforeFirstRep = 0
            elseif(exerciseType == "reverse_barbell_curl") then
                timeBetweenReps = 4500
                timeBeforeFirstRep = 5000
                repsPerSet = 2.0
            end
            RequestAnimDict(exercise.anim.dict)
            while not HasAnimDictLoaded(exercise.anim.dict) do
                Citizen.Wait(0)
            end
            TaskPlayAnim(
                cache.ped, 
                exercise.anim.dict, 
                exercise.anim.clip, 
                5.0,
                5.0,
                -1, 
                1,
                0,
                false, 
                false, 
                false
            )
            Citizen.CreateThread(function()
                Citizen.Wait(timeBeforeFirstRep)
                local startingFatigue = Fatigue
                while IsEntityPlayingAnim(cache.ped, exercise.anim.dict, exercise.anim.clip, 3) and totalReps < CalculateMaxReps(repsPerSet, startingFatigue) do
                    Citizen.Wait(timeBetweenReps)
                    totalReps += 1
                end
                ClearPedTasks(cache.ped)
                if(totalReps == 0) then
                    ESX.ShowNotification("Jste vyčerpaný/á, dejte si chvilku pauzu.")
                else
                    Fatigue += math.floor((totalReps * 30 / 10) * 1.75)
                end
                IsExercising = false
            end)
            RemoveAnimDict(exercise.anim.dict)
        end
        if(exercise.prop) then
            CurrentProp = CreateObject(exercise.prop.model, GetEntityCoords(cache.ped), true, true, true)
            --SetEntityHeading(CurrentProp, GetEntityHeading(cache.ped) + 90.0)
            --SetEntityRotation(CurrentProp, exercise.prop?.placement[4], exercise.prop?.placement[5], exercise.prop?.placement[6], 1)
            AttachEntityToEntity(
                CurrentProp, 
                cache.ped, 
                GetPedBoneIndex(cache.ped, exercise.prop?.bone),
                table.unpack(exercise.prop?.placement),
                false, 
                false,
                false, 
                false, 
                2, 
                true
            )
            
            Citizen.CreateThread(function()
                while IsExercising do
                    Citizen.Wait(0)
                end
                DeleteEntity(CurrentProp)
            end)
        end
    end
end

function GetNearestGym()
    local coords = GetEntityCoords(cache.ped)
    local gymIndex, gym
    for i=1, #GYMS do
        local distance = #(coords - GYMS[i].coords)
        if(distance <= GYMS[i].radius) then
            gymIndex = i
            gym = GYMS[i]
            break
        end
    end
    return gymIndex, gym
end

function CalculateMaxReps(repsPerSet, startingFatigue)
    return math.ceil((repsPerSet + (repsPerSet * StrengthBuffer)) - (startingFatigue / 10))
end

/*StartExercise("chin_up", {
    entity = 947202
})

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3000)
        ExecuteCommand("ensure "..GetCurrentResourceName())
    end
end)*/

function _U(entry, ...)
    return LOCALES[LOCALE][entry]:format(...) 
end