-- Sprite module for Catching Thunder
local AnimatedSprite = {}

AnimatedSprite.new = function(sheet)
    local sprite = {time=0, frameno=1, sheet=sheet}
    setmetatable(sprite, AnimatedSprite)
    sprite:setAnimation(sheet.default_animation)
    return sprite
end

AnimatedSprite.prototype = {}

AnimatedSprite.prototype.update = function(self, dt)
    self.time = self.time + dt
    local frame = self.animation.frames[self.frameno]
    local duration = frame.duration or 1
    if self.time > duration then
        self.time = 0
        self.frameno = self.frameno + 1
    end

    if self.frameno > #self.animation.frames then
        self.frameno = 1
    end
end

AnimatedSprite.prototype.draw = function(self, x, y)
    local quad = self.animation.quads[self.frameno]
    local frame = self.animation.frames[self.frameno]
    local r = frame.r or 0
    local sx = frame.sx or 1
    local sy = frame.sy or 1
    local posx = x or self.x or 0
    local posy = y or self.y or 0
    love.graphics.draw(self.sheet.image, quad, posx, posy, r, sx, sy)
end

AnimatedSprite.prototype.setAnimation = function(self, name, restart)
    print(string.format("setAnimation(self=%s, name=%s, restart=%s)", self, name, restart))
    if self.animation_name ~= name or restart then
        print("Setting animation to " .. name)

        self.animation_name = name
        self.animation = self.sheet.animations[name]
        self.frameno = 1
        self.time = 0
    else
        print("Animation already set to " .. name)
        print("self.animation = " .. string.format("%s", self.animation))
    end
end

AnimatedSprite.__index = function(sprite, key)
    return AnimatedSprite.prototype[key]
end

return {AnimatedSprite=AnimatedSprite}
