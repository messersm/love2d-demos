require "lib/gfx"
require "lib/thunderstorm"

function love.load()
    -- Some information about exiting and used artwork
    infotext = {
        {start=5, time=5, fadein=1, fadeout=1, text="Press Escape to exit."}
    }
    infotime = 0
    infoindex = 1

    -- sound
    rainsound = love.audio.newSource("res/rain.ogg", "stream")
    rainsound:setLooping(true)
    love.audio.play(rainsound)

    thundersounds = {
        love.audio.newSource("res/thunder1.ogg", "static")
    }

    -- graphics
    SCREEN_WIDTH, SCREEN_HEIGHT = love.graphics.getDimensions()

    sky = love.graphics.newImage("res/sky.png")
    background = love.graphics.newImage("res/background.png")
    foreground = love.graphics.newImage("res/foreground.png")

    -- particles and bolts
    thunderstorm = Thunderstorm.new(thundersounds)
    -- TODO: Add correct width and height for each layer.
    thunderstorm:addLayer()
    thunderstorm:addLayer()
    thunderstorm:addLayer()
    rain = RainGFX.new()
end

function love.draw()
    love.graphics.draw(sky, 0, 0)
    thunderstorm:drawLayer(1)
    love.graphics.draw(background, 0, 0)
    thunderstorm:drawLayer(2)
    love.graphics.draw(foreground, 0, 0)
    thunderstorm:drawLayer(3)
    rain:draw()
end

function love.update(dt)
    thunderstorm:update(dt)
    rain:update(dt)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        love.event.quit()
    elseif key == "d" then
        debug = not debug
    end
end
