function randfloat(...)
    arg1, arg2 = ...
    local min, max
    if arg1 == nil and arg2 == nil then
        min = 0
        max = 1
    elseif arg2 == nil then
        min = 0
        max = arg1
    else
        min = arg1
        max = arg2
    end

    return min + love.math.random() * (max - min)
end

function parse_keywords(keywords, defaults)
    local t = {}
    -- Writes values into t, reading from keywords, falling back to defaults
    if keywords == nil then
        for key, value in pairs(defaults) do
            t[key] = value
        end
    else
        for key, value in pairs(defaults) do
            t[key] = keywords[key] or value
        end
    end

    return t
end

return {randfloat=randfloat}
