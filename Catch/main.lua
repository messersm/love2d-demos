function newScene()
    local scn = {}
    scn.load = function(self) end
    scn.draw = function(self) end
    scn.update = function(self, dt) end
    scn.keypressed = function(self, key, scancode, isrepeat) end
    scn.mousepressed = function(x, y, button, isTouch) end
    return scn
end

-- a few mathematical functions
abs = math.abs
sign = function(x)
    if x < 0 then
        return -1
    elseif x > 0 then
        return 1
    else
        return 0
    end
end

-- sprite library
Sprite = {}
Sprite.prototype = {}
Sprite.prototype.update = function(self, dt) end
Sprite.__index = function(sprite, key)
    return Sprite.prototype[key]
end
Sprite.new = function()
    local sprite = {}
    setmetatable(sprite, Sprite)
    return sprite
end
Sprite.fromSpritesheet = function(sheet)
    local sprite = Sprite.new()
    sprite.sheet = sheet
    sprite.animation = sheet.animations[sheet.default_animation]
    sprite.frame = 0
    sprite.time = 0
    return sprite
end

function loadSpritesheets(spritesheets)
    for name, sheet in pairs(spritesheets) do
        sheet.image = love.graphics.newImage(sheet.filename)
    end
end

DATA = {}
DATA.spritesheets = {}
DATA.spritesheets.player = {
    filename = "res/robot.png",
    image = nil,
    default_animation = "stand_right",
    animations = {
        walk_left = {
            mirror_x = false,
            mirror_y = false,
            frames = {
                {x=64, y=0, width=64, height=72},
                {x=128, y=0, width=64, height=72},
                {x=192, y=0, width=64, height=72}
            }
        },
        walk_right = {
            mirror_x = true,
            mirror_y = false,
            frames = {
                {x=64, y=0, width=64, height=72},
                {x=128, y=0, width=64, height=72},
                {x=192, y=0, width=64, height=72}
            }
        }
    }
}

-- scene definition
-- intro scene
intro = newScene()

function intro.load(self)
    self.bg = love.graphics.newImage("res/intro.png")
end

function intro.draw(self)
    love.graphics.draw(self.bg, 0, 0)
    love.graphics.print("Catching Lightning", 100, 100)
    love.graphics.print("Tab to start.", 100, 500)
end

function intro.mousepressed(self, x, y, button, isTouch)
    scene = game
end

-- game scene
game = newScene()

function game.load(self)
    self.bg = love.graphics.newImage("res/game.png")
    self.robot = {x=0, y=900, dx=0, dy=0, target_x=0, target_y=900}
    self.robot.image = love.graphics.newImage("res/robot.png")
    self.robot.frame = love.graphics.newQuad(
        64, 0, 64, 64, self.robot.image:getDimensions())
    self.animated_sprites = {}
    self.animated_sprites["robot"] = self.robot

    self.score = 0
    self.highscore = 0
end

function game.draw(self)
    love.graphics.draw(self.bg, 0, 0)

    for name, sprite in pairs(self.animated_sprites) do
        love.graphics.draw(sprite.image, sprite.frame, sprite.x, sprite.y)
    end

    love.graphics.print("Score: " .. self.score, 0, 0, 0, 3, 3)
    love.graphics.print("Highscore: " .. self.highscore, 0, 40, 0, 3, 3)
end

function game.update(self, dt)

    -- make the robot move towards its target
    local dist = self.robot.target_x - self.robot.x
    if abs(dist) >= 10 then
        self.robot.dx = sign(dist) * 10
    elseif abs(dist) < 10 then
        self.robot.x = self.robot.target_x
        self.robot.dx = 0
    else
        self.robot.dx = 0
    end

    self.robot.x = self.robot.x + self.robot.dx
end

function game.mousepressed(self, x, y, button, isTouch)
    self.robot.target_x = x
    self.robot.target_y = y
end

scenes = {intro, game}
scene = intro

-- load resources
function love.load()
    love.window.setFullscreen(true)

    -- music = love.audio.newSource("res/music.ogg", "stream")
    -- music:setLooping(true)
    -- love.audio.play(music)

    rainsnd = love.audio.newSource("res/rain.ogg", "stream")
    rainsnd:setLooping(true)
    love.audio.play(rainsnd)

    loadSpritesheets(DATA.spritesheets)

    for key, scn in pairs(scenes) do
        scn:load()
    end
end

function love.draw()
    scene:draw()
end

function love.update(dt)
    scene:update(dt)
end

function love.keypressed(...)
    scene:keypressed(...)
end

function love.mousepressed(...)
    scene:mousepressed(...)
end
