local gfx = require "lib/gfx"

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

    background = love.graphics.newImage("res/background.png")
    lightning = {
         love.graphics.newImage("res/lightning3.png")
    }

    -- particles and bolts
    rain_gfx = gfx.RainGFX.new()
    -- drops = generate_drops(1000)
    bolts = {}
    next_bolt_in = 2
    last_bolt = nil

    debug = false
end

function love.draw()
    love.graphics.draw(background, 0, 0)

    -- draw bolts
    for _, bolt in pairs(bolts) do
        if bolt.duration > 0 then
            love.graphics.draw(
                bolt.image, bolt.x, bolt.y, 0, bolt.scale, bolt.scale)
        end
    end

    rain_gfx:draw()

    if debug and last_bolt then
        local msg = string.format(
            "Last bolt: Distance: %d (scale=%.2f), thunder in: %.2fs",
            last_bolt.distance, last_bolt.scale, last_bolt.thunder_eta)
        love.graphics.print(msg, 0, SCREEN_HEIGHT - 20)
    end
end

function love.update(dt)
    -- process the bolts
    -- remove bolts, which sound has been played and keep the rest
    local newbolts = {}
    for _, bolt in pairs(bolts) do
        bolt.duration = bolt.duration - dt
        bolt.thunder_eta = bolt.thunder_eta - dt

        if bolt.thunder_eta <= 0 then
            -- play sound and "discard" bolt
            love.audio.play(bolt.sound)

            if bolt.duration > 0 then
                table.insert(newbolts, bolt)
            end
        else
            table.insert(newbolts, bolt)
        end
    end
    bolts = newbolts

    -- Add new bolts, if required.
    next_bolt_in = next_bolt_in - dt
    if next_bolt_in < 0 then
        next_bolt_in = 0.1 + love.math.random()
        last_bolt = generate_bolt()
        table.insert(bolts, last_bolt)
    end

    rain_gfx:update(dt)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        love.event.quit()
    elseif key == "d" then
        debug = not debug
    end
end

function generate_bolt()
    local bolt = {}
    local MIN_DISTANCE = 1000
    local MAX_DISTANCE = 5000
    local MIN_SCALE = 0.1
    local MAX_SCALE = 2

    bolt.distance = love.math.random(MIN_DISTANCE, MAX_DISTANCE)
    bolt.image = lightning[love.math.random(1, #lightning)]
    bolt.x = love.math.random(SCREEN_WIDTH)
    bolt.y = 0

    --[[
    if bolt.distance - MIN_DISTANCE == 0 then
        bolt.scale = MAX_SCALE
    else
        local ratio = (MAX_DISTANCE - MIN_DISTANCE) / (bolt.distance - MIN_DISTANCE)
        bolt.scale = MIN_SCALE + (MAX_SCALE - MIN_SCALE) * ratio
    end
    ]]--

    bolt.scale = 0.2 + love.math.random() / 4

    bolt.duration = 0.3 -- love.math.random(0.2, 0.2)
    bolt.thunder_eta = bolt.distance / 300
    bolt.sound = thundersounds[love.math.random(1, #thundersounds)]

    return bolt
end
