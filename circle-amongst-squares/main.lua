bump = require "lib.bump"

function with_color(color, f, ...)
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(color)
    f(...)
    love.graphics.setColor(r, g, b, a)
end

function newSquare()
    local square = {}
    square.width = love.math.random(10, 40)
    square.height = square.width

    square.color = {
        love.math.random(),
        love.math.random(),
        love.math.random(),
        1
    }
    local width, height = love.graphics.getDimensions()

    square.x = love.math.random(0, width)
    square.y = love.math.random(0, height)

    return square
end

function sign(x)
    if x > 0 then
        return 1
    elseif x < 0 then
        return -1
    else
        return 0
    end
end

function move_something()
    -- Find a rect very close to the edge
    -- of visible objects and move it.
    x = circle.x + circle.r
    y = circle.y + circle.r

    for _, sq in pairs(squares) do
        local dx = sq.x + sq.width / 2 - x
        local dy = sq.y + sq.height / 2 - y
        distance = dx * dx + dy * dy

        if 5000 < distance and distance < 8000 then
            local sq_dx = love.math.random(-10, 10)
            local sq_dy = love.math.random(-10, 10)
            sq.x, sq.y = world:move(sq, sq.x + sq_dx, sq.y + sq_dy)
            movesound:setPosition(sign(dx), sign(dy))
            movesound:play()
            return true
        end
    end

    return false
end

--------------------
-- love callbacks --
--------------------
function love.load()
    -- hide mouse cursor
    love.mouse.setVisible(false)

    ambient = love.audio.newSource("res/scary.ogg", "stream")
    ambient:setLooping(true)
    ambient:setVolume(0.1)
    ambient:play()

    movesound = love.audio.newSource("res/movement.ogg", "static")
    next_move_in = love.math.random(10, 20)

    world = bump.newWorld()
    squares = {}
    circle = {x=0, y=0, dx=0, dy=0, speed=100, r=10, color={1, 1, 1, 1}}
    world:add(circle, circle.x, circle.y, circle.r * 2, circle.r * 2)

    for i = 1, 100 do
        local square = newSquare()
        table.insert(squares, square)
        world:add(square, square.x, square.y, square.width, square.height)
    end

    light = love.graphics.newShader("light.glsl")
    light:send("sourcePos", {circle.x + circle.r, circle.y + circle.r})
end

function love.draw()
    love.graphics.setShader(light)

    for _, sq in pairs(squares) do
        love.graphics.setColor(sq.color)
        love.graphics.rectangle("fill", sq.x, sq.y, sq.width, sq.height)
    end

    -- draw the circle to the right/bottom of x, y,
    -- since bump uses these coordinates for collision checks
    love.graphics.setColor(circle.color)
    local x, y = circle.x + circle.r, circle.y + circle.r
    love.graphics.arc("fill", x, y, circle.r, 0, math.pi*2)

    love.graphics.setShader()
end

function love.update(dt)
    -- handle circle movement
    if love.keyboard.isDown("a", "left") then
        circle.dx = - circle.speed
    elseif love.keyboard.isDown("d", "right") then
        circle.dx = circle.speed
    else
        circle.dx = 0
    end

    if love.keyboard.isDown("w", "up") then
        circle.dy = - circle.speed
    elseif love.keyboard.isDown("s", "down") then
        circle.dy = circle.speed
    else
        circle.dy = 0
    end

    local x = circle.x + circle.dx * dt
    local y = circle.y + circle.dy * dt

    if x ~= circle.x or y ~= circle.y then
        circle.x, circle.y = world:move(circle, x, y)
        -- update the light shader source position
        light:send("sourcePos", {circle.x + circle.r, circle.y + circle.r})
    end

    -- handle randomly moving squares
    next_move_in = next_move_in - dt
    if next_move_in <= 0 then
        if move_something() then
            next_move_in = love.math.random(10, 20)
        else
            next_move_in = 0
        end
    end
end

function love.keypressed(key, scancode, isrepeat)
    -- exit on Escape
    if key == "escape" then
        love.event.quit()
    end
end
