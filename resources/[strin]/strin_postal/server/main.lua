function GetNearestPostal(coords)
    local nearestPostal = nil

    for i=1, #POSTALS do
        local postal = POSTALS[i]
        local distance = #(coords - vec3(postal.coords.xy, coords.z))
        if not nearestPostal or distance < nearestPostal.distance then
            nearestPostal = {
                data = postal,
                distance = distance
            }
        end
    end

    return nearestPostal.data
end
