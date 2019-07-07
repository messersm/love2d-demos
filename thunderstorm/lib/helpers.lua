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

function with_color(f, color, ...)
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(color)
    f(...)
    love.graphics.setColor(r, g, b, a)
end

function sprite_from(image, x, y, r, sx, sy)
    local spr = {}
    spr.image = image
    spr.x = x or 0
    spr.y = y or 0
    spr.r = r or 0
    spr.sx = sx or 1
    spr.sy = sy or 1
    local width, height = image:getDimensions()
    spr.width = math.abs(width * spr.sx)
    spr.height = math.abs(height * spr.sy)
    return spr
end

-- build and return the module
local m = {}
m.randfloat = randfloat
m.parse_keywords = parse_keywords
m.sprite_from = sprite_from
m.with_color = with_color

return m
