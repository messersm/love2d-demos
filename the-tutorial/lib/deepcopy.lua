function deepcopy(x)
    if type(x) == "table" then
        local t = {}
        for key, value in pairs(x) do
            t[key] = deepcopy(value)
        end
        return t
    else
        return x
    end
end

return {deepcopy=deepcopy}
