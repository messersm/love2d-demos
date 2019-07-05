RainGFX = {}
RainGFX.new = function(args)
    local width, height = love.graphics.getDimensions()

    local defaults = {
        count = 1000,
        min_x = 0,
        max_x = width,
        min_y = 0,
        max_y = height,
        min_speed = height / 2,
        max_speed = (height * 3) / 2,
        min_length = 10,
        max_length = 50
    }

    local t = {}

    if args then
        for key, value in pairs(defaults) do
            t[key] = args[key] or value
        end
    else
        for key, value in pairs(defaults) do
            t[key] = value
        end
    end

    t.drops = {}

    for i = 1, t.count, 1 do
        local drop = {}
        drop.x = love.math.random(t.min_x, t.max_x)
        drop.y = love.math.random(t.min_y, t.max_y)
        drop.length = love.math.random(t.min_length, t.max_length)
        drop.speed = love.math.random(t.min_speed, t.max_speed)
        table.insert(t.drops, drop)
    end

    t.update = function(t, dt)
        for _, drop in pairs(t.drops) do
            drop.y = drop.y + drop.speed * dt
            if drop.y > t.max_y then
                drop.y = t.min_y
            end
        end
    end

    t.draw = function(t)
        -- draw rain
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(0.5, 0.5, 0.5, 0.1)

        for _, drop in pairs(t.drops) do
            love.graphics.line(drop.x, drop.y, drop.x, drop.y + drop.length)
        end
        -- reset color
        love.graphics.setColor(r, g, b, a)
    end

    return t
end

return {RainGFX = RainGFX}
