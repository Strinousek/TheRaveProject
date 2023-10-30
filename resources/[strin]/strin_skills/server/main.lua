RegisterNetEvent("strin_skills:updateSkills", function(skills)
    local _source = source 
    if skills ~= nil then
        --exports.data:updateCharVar(_source, "skills", skills)
        TriggerEvent("strin_skills:skillsUpdated", _source, skills)
    end
end)