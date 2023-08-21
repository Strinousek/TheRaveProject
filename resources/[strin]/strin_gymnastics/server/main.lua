
do
    for k,v in pairs(EXERCISE_TYPES) do
        if(v.prop) then
            exports.strin_base:RegisterWhitelistedEntity(v.prop.model)
        end
    end
end