bump = require "bump"

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

function love.load()
    world = bump.newWorld()
    squares = {}
    circle = {x=0, y=0, dx=0, dy=0, speed=100, r=10, color={1, 0, 1, 1}}
    world:add(circle, circle.x, circle.y, circle.r * 2, circle.r * 2)

    for i = 1, 100 do
        local square = newSquare()
        table.insert(squares, square)
        world:add(square, square.x, square.y, square.width, square.height)
    end
end

function love.draw()
    for _, sq in pairs(squares) do
        with_color(sq.color, love.graphics.rectangle,
            "fill", sq.x, sq.y, sq.width, sq.height)
    end

    -- draw the circle to the right/bottom of x, y,
    -- since bump uses these coordinates for collision
    -- checks
    with_color(circle.color, love.graphics.arc, "fill",
        circle.x + circle.r, circle.y + circle.r, circle.r, 0, math.pi*2)
end

function love.update(dt)
    -- handle keyboard input
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
    -- circle.x, circle.y = world:move(circle, x - circle.r, y - circle.r)
    circle.x, circle.y = world:move(circle, x, y)
end
