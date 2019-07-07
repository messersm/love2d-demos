require "lib/helpers"

Thunderstorm = {
    prototype={},
    LAYER_DEFAULTS = {
        x = 0,
        y = 0,
        width = 1920,
        height = 1080,
        min_sound_delay = 0.1,
        max_sound_delay = 0.3
    }
}

Thunderstorm.new = function(sounds, active)
    local active = active or (active == nil)
    local t = {sounds=sounds, active=active, layers={}, next_bolt_in=2}
    setmetatable(t, Thunderstorm)
    return t
end

Thunderstorm.__index = function(self, key)
    return Thunderstorm.prototype[key]
end

Thunderstorm.prototype.addLayer = function(self, keywords)
    local t = parse_keywords(keywords, Thunderstorm.LAYER_DEFAULTS)
    t.bolts = {}
    table.insert(self.layers, t)
end

Thunderstorm.prototype.update = function(self, dt)
    for _, layer in pairs(self.layers) do
        local newbolts = {}
        for _, bolt in pairs(layer.bolts) do
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

            bolt.sound_delay = bolt.sound_delay - dt
            if bolt.sound_delay <= 0 and not bolt.sound_played then
                love.audio.play(bolt.sound)
                bolt.sound_played = true
            end

            -- Keep bolts, which pulses haven't all been
            -- dispayed yet or which sound hasn't been played.
            if bolt.sound_delay > 0 or bolt.pulses[bolt.pulse_idx] ~= nil then
                table.insert(newbolts, bolt)
            end
        end
        layer.bolts = newbolts
    end

    -- Create a new bolt, if required.
    self.next_bolt_in = self.next_bolt_in - dt
    if self.next_bolt_in <= 0 and self.active then
        -- only add bolts, if we are set to active
        local index = love.math.random(1, #self.layers)
        local bolt = self:newBolt(self.layers[index])
        table.insert(self.layers[index].bolts, bolt)
        self.next_bolt_in = randfloat(5.0, 10.0)
    end

end

Thunderstorm.prototype.newBolt = function(self, layer)
    local bolt = {}

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
    bolt.sound = self.sounds[love.math.random(1, #self.sounds)]
    bolt.sound_delay = randfloat(layer.min_sound_delay, layer.max_sound_delay)
    bolt.sound_played = false

    return bolt
end

Thunderstorm.prototype.drawLayer = function(self, index)
    local layer = self.layers[index]

    for _, bolt in pairs(layer.bolts) do
        local pulse = bolt.pulses[bolt.pulse_idx]
        if pulse ~= nil and pulse.eta <= 0 and pulse.duration > 0 then
            -- print(string.format("Drawing pulse: %d", bolt.pulse_idx))
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(1, 1, 1, pulse.alpha)
            love.graphics.rectangle("fill", layer.x, layer.y, layer.width, layer.height)
            love.graphics.setColor(r, g, b, a)
        end
    end
end

return {Thunderstorm=Thunderstorm}
