local open = false
local MazePromises = {}

RegisterNUICallback('maze-callback', function(data, cb)
	SetNuiFocus(false, false)
    if(Callback) then
        Callback(data.success)
    else
        MazePromises[#MazePromises]:resolve(data.success)
    end
    open = false
    cb('ok')
end)

local function Maze(callback, speed)
    if speed == nil then speed = 10 end
    local promiseId = #MazePromises + 1
    if(not callback) then
        MazePromises[promiseId] = promise.new()
    end
    if not open then
        Callback = callback
        open = true
        SendNUIMessage({
            action = "maze-start",
            speed = speed,
        })
        SetNuiFocus(true, true)
    end
    if(not callback) then
        return Citizen.Await(MazePromises[promiseId])
    end
end

exports("Maze", Maze)
