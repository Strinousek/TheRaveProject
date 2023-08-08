local open = false
local ScramblerPromises = {}

RegisterNUICallback('scrambler-callback', function(data, cb)
	SetNuiFocus(false, false)
    if(Callback) then
        Callback(data.success)
    else
        ScramblerPromises[#ScramblerPromises]:resolve(data.success)
    end
    open = false
    cb('ok')
end)

local function Scrambler(callback, type, time, mirrored)
    if type == nil then type = "alphabet" end
    if time == nil then time = 10 end
    if mirrored == nil then mirrored = 0 end
    local promiseId = #ScramblerPromises + 1
    if(not callback) then
        ScramblerPromises[promiseId] = promise.new()
    end
    if not open then
        Callbackk = callback
        open = true
        SendNUIMessage({
            action = "scrambler-start",
            type = type,
            time = time,
            mirrored = mirrored,

        })
        SetNuiFocus(true, true)
    end
    if(not callback) then
        return Citizen.Await(ScramblerPromises[promiseId])
    end
end

exports("Scrambler", Scrambler)