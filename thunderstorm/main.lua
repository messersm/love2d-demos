require "lib/gfx"
require "lib/thunderstorm"

EPILEPSY_WARNING = [[
WARNING: This application may potentially trigger seizures for people with photosensitive epilepsy.

You can exit this application now by tabbing the button in the top right.

Tab the screen to continue.
]]

function love.load()
    -- Some information about exiting and used artwork
    infotext = {
        start=1,
        fadein=1,
        fadeout=1,
        do_continue=false,
        text=EPILEPSY_WARNING,
        alpha=0
    }

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

    exitimage = love.graphics.newImage("res/exit.png")
    exitsprite = sprite_from(exitimage)
    exitsprite.x = SCREEN_WIDTH - exitsprite.width

    -- particles and bolts
    thunderstorm = Thunderstorm.new(thundersounds, false)
    thunderstorm:addLayer({width=1920, height=480, min_sound_delay=5.0, max_sound_delay=5.5})
    thunderstorm:addLayer({width=1920, height=710, min_sound_delay=3.0, max_sound_delay=3.5})
    thunderstorm:addLayer({width=1920, height=1080, min_sound_delay=0, max_sound_delay=0})
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

    -- draw exit sprite
    with_color(love.graphics.draw,
        {1, 1, 1, 0.5}, exitsprite.image, exitsprite.x, exitsprite.y)

    -- display infotext
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(r, g, b, infotext.alpha)
    love.graphics.printf(infotext.text, 0, 500, SCREEN_WIDTH / 2, "center", 0, 2, 2)
    love.graphics.setColor(r, g, b, a)
end

function love.update(dt)
    thunderstorm:update(dt)
    rain:update(dt)

    if infotext.start <= 0 then
        -- display or fadeout
        if infotext.fadein <= 0 then
            if infotext.do_continue then
                if infotext.fadeout <= 0 then
                    thunderstorm.active = true
                end
                infotext.alpha = infotext.fadeout
                infotext.fadeout = infotext.fadeout - dt
            else
                infotext.alpha = 1
            end
        else
            infotext.fadein = infotext.fadein - dt
            infotext.alpha = 1 - infotext.fadein
            -- fadein
        end
    else
        infotext.start = infotext.start - dt
    end
end

function love.mousepressed(x, y, button, isTouch)
    if exitsprite.x <= x and
       x <= exitsprite.x + exitsprite.width and
       exitsprite.y <= y and
       y <= exitsprite.y + exitsprite.height then
           love.event.quit()
    else
        infotext.do_continue = true
    end
end
