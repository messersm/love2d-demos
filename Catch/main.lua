local sprite = require "lib/sprite"

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

function loadSpritesheets(spritesheets)
    for name, sheet in pairs(spritesheets) do
        sheet.image = love.graphics.newImage(sheet.filename)

        -- build quads
        for _, animation in pairs(sheet.animations) do
            animation.quads = {}
            for _, dims in pairs(animation.frames) do
                table.insert(animation.quads, love.graphics.newQuad(
                    dims.x, dims.y, dims.width, dims.height,
                    sheet.image:getDimensions()))
            end
        end
    end
end

DATA = {}
DATA.spritesheets = {
    robot = {
        filename = "res/robot.png",
        default_animation = "stand_right",
        animations = {
            stand_right = {
                frames = {
                    {x=0, y=0, width=64, height=64}
                }
            },
            stand_left = {
                frames = {
                    {x=0, y=0, width=64, height=64, sx=-1}
                }
            },
            walk_right = {
                frames = {
                    {x=64, y=0, width=64, height=64, duration=0.15},
                    {x=128, y=0, width=64, height=64, duration=0.15},
                    {x=192, y=0, width=64, height=64, duration=0.15}
                }
            },
            walk_left = {
                frames = {
                    {x=64, y=0, width=64, height=64, sx=-1, duration=0.15},
                    {x=128, y=0, width=64, height=64, sx=-1, duration=0.15},
                    {x=192, y=0, width=64, height=64, sx=-1, duration=0.15}
                }
            }
        }
    },
    lightning = {
        filename = "res/lightning.png",
        default_animation = "default",
        animations = {
            default = {
                frames = {
                    {x=0, y=0, width=100, height=175, duration=0.01},
                    -- {x=0, y=175, width=100, height=175, duration=0.1},
                    {x=100, y=0, width=100, height=175, duration=0.01},
                    -- {x=100, y=175, width=100, height=175, duration=0.1},
                    {x=200, y=0, width=100, height=175, duration=0.01},
                    -- {x=200, y=175, width=100, height=175, duration=0.1},
                    {x=300, y=0, width=100, height=175, duration=0.01},
                    -- {x=300, y=175, width=100, height=175, duration=0.1},
                    {x=400, y=0, width=100, height=175, duration=0.01},
                    -- {x=400, y=175, width=100, height=175, duration=0.1},
                    {x=500, y=0, width=100, height=175, duration=0.01},
                    -- {x=500, y=175, width=100, height=175, duration=0.1}
                }
            }
        }
    }
}

-- scene definition
-- intro scene
menu = newScene()

function menu.load(self)
    self.bg = love.graphics.newImage("res/menu.png")
    self.lightning = sprite.AnimatedSprite.new(DATA.spritesheets.lightning)
end

function menu.draw(self)
    love.graphics.draw(self.bg, 0, 0)
    love.graphics.print("Catching Lightning", 100, 100)
    love.graphics.print("Tab to start.", 100, 500)
    self.lightning:draw()
end

function menu.update(self, dt)
    self.lightning:update(dt)
end

function menu.mousepressed(self, x, y, button, isTouch)
    scene = game
end

-- game scene
game = newScene()

function game.load(self)
    self.bg = love.graphics.newImage("res/game.png")
    self.robot = Robot.new()
    self.robot.y = 900
    self.entities = {self.robot}
    self.surges = {}
    self.minnextsurge = 5.0
    self.maxnextsurge = 20.0
    self.nextsurge = love.math.random(self.minnextsurge, self.maxnextsurge)
    self.minsurgetime = 5.0
    self.maxsurgetime = 20.0

    self.score = 0
    self.highscore = 0
end

function game.draw(self)
    love.graphics.draw(self.bg, 0, 0)

    for _, entity in pairs(self.entities) do
        entity:draw()
    end

    -- draw surges
    for _, surge in pairs(self.surges) do
        local t = string.format("%.2f", surge.time)
        love.graphics.print(
            "Surge detected: " .. t .. "s", surge.x, surge.y)
    end

    love.graphics.print("Score: " .. self.score, 0, 0, 0, 3, 3)
    love.graphics.print("Highscore: " .. self.highscore, 0, 40, 0, 3, 3)
end

function game.createSurge(self)
    -- Creates a new electrical surge
    local surge = {}
    surge.x = love.math.random(0, 1920)
    surge.y = love.math.random(0, 1080)
    surge.time = love.math.random(self.minsurgetime, self.maxsurgetime)
    return surge
end

function game.update(self, dt)
    -- create new surges
    self.nextsurge = self.nextsurge - dt
    if self.nextsurge <= 0 then
        table.insert(self.surges, self:createSurge())
        self.nextsurge = love.math.random(self.minnextsurge, self.maxnextsurge)
    end

    -- process present surges
    local surges = {}

    for key, surge in pairs(self.surges) do
        surge.time = surge.time - dt

        if surge.time <= 0 then
            -- TODO: create lightning
            self.surges[key] = nil
        else
            -- keep this surge
            table.insert(surges, surge)
        end
    end
    self.surges = surges

    self.robot:update(dt)

end

function game.mousepressed(self, x, y, button, isTouch)
    self.robot:moveTo(x, y)
end

Robot = {}
Robot.new = function()
    local robot = {
        x=0, y=0, width=64, height=64, dx=0, dy=0,
        target_x=0, target_y=0
    }
    robot.sprite = sprite.AnimatedSprite.new(DATA.spritesheets.robot)
    setmetatable(robot, Robot)
    print("new Robot created.")
    print("self.sprite.animation_name: " .. string.format("%s", robot.sprite.animation_name))
    print("self.sprite.animation: " .. string.format("%s", robot.sprite.animation))
    return robot
end

Robot.__index = function(robot, key)
    return Robot.prototype[key]
end

Robot.prototype = {}
Robot.prototype.update = function(self, dt)
    -- make the robot move towards its target
    local dist = self.target_x - self.x

    if dist <= -10 then
        self.dx = -10
        self.sprite:setAnimation("walk_left")
    elseif dist >= 10 then
        self.dx = 10
        self.sprite:setAnimation("walk_right")
    elseif dist < 10 then
        self.x = self.target_x
        self.sprite:setAnimation("stand_right")
    elseif dist > -10 then
        self.x = self.target_x
        self.sprite:setAnimation("stand_left")
    end

    self.x = self.x + self.dx
    self.sprite:update(dt)
end
Robot.prototype.draw = function(self)
    self.sprite:draw(self.x, self.y)
end
Robot.prototype.moveTo = function(self, x, y)
    self.target_x = x - self.width / 2
    self.target_y = y - self.height / 2
end

scenes = {menu, game}
scene = menu

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
