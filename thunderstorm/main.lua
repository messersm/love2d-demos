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

    sky = love.graphics.newImage("res/sky.png")
    background = love.graphics.newImage("res/background.png")
    foreground = love.graphics.newImage("res/foreground.png")

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
    love.graphics.draw(sky, 0, 0)
    love.graphics.draw(background, 0, 0)

    -- draw bolts
    for _, bolt in pairs(bolts) do
        -- no bolts are drawn right now
        --[[
        if bolt.duration > 0 then
            love.graphics.draw(
                bolt.image, bolt.x, bolt.y, 0, bolt.scale, bolt.scale)
        end
        ]]--

        -- draw pulses
        local pulse = bolt.pulses[bolt.pulse_idx]
        if pulse ~= nil and pulse.eta <= 0 and pulse.duration > 0 then
            print(string.format("Drawing pulse: %d", bolt.pulse_idx))
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(1, 1, 1, pulse.alpha)
            love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
            love.graphics.setColor(r, g, b, a)
        end
    end

    love.graphics.draw(foreground, 0, 0)

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

        -- proceed to the next pulse, if the
        -- current has already been drawn
        local pulse = bolt.pulses[bolt.pulse_idx]

        if pulse ~= nil then
            if pulse.eta < 0 then
                if pulse.duration < 0 then
                    bolt.pulse_idx = bolt.pulse_idx + 1
                else
                    pulse.duration = pulse.duration - dt
                end
            else
                pulse.eta = pulse.eta - dt
            end
        end

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
        next_bolt_in = 5 + love.math.random(20)
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

    -- A bolt has an initial pulse and up to 3 more
    local pulse_count = love.math.random(2, 3)
    bolt.pulses = {
        {eta=0, duration=randfloat(0.1, 0.2), alpha=0.5},
        {eta=randfloat(0.5, 1.0), duration=randfloat(0.1, 0.2), alpha=0.3}
    }
    for i = 1, pulse_count - 1 do
        local eta = randfloat(0.1, 0.2)
        local duration = randfloat(0.1, 0.2)
        table.insert(bolt.pulses, {eta=eta, duration=duration, alpha=0.3})
    end
    bolt.pulse_idx = 1

    bolt.duration = 0.3 -- love.math.random(0.2, 0.2)
    bolt.thunder_eta = bolt.distance / 300
    bolt.sound = thundersounds[love.math.random(1, #thundersounds)]

    return bolt
end

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
