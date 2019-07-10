---------------------
-- Condition class --
---------------------
Condition = {}

Condition.new = function(c)
    local c = c or {}
    function c.update(self, dt) end
    setmetatable(c, Condition)
    return c
end

Condition.combine = function(f, init, ...)
    local c = Condition.new({others={...}})
    function c.update(self, dt)
        self.is_true = init
        for _, other in pairs(self.others) do
            other:update(dt)
            f(self, other)
        end
    end
    return c
end

Condition.sequence = function(...)
    local c = Condition.new({idx=1, others={...}})
    function c.update(self, dt)
        if self.idx > #self.others then
            self.is_true = true
        else
            local other = self.others[self.idx]
            other:update(dt)
            if other.is_true then
                self.idx = self.idx + 1
            end
        end
    end
    return c
end

Condition.oneof = function(...)
    local f = function(self, other)
        self.is_true = self.is_true or other.is_true
    end
    return Condition.combine(f, false, ...)
end

Condition.allof = function(...)
    local f = function(self, other)
        self.is_true = self.is_true and other.is_true
    end
    return Condition.combine(f, true, ...)
end

Condition.noneof = function(...)
    local f = function(self, other)
        self.is_true = self.is_true and not other.is_true
    end
    return Condition.combine(f, true, ...)
end

Condition.__concat = Condition.sequence
Condition.__unm = Condition.noneof
Condition.__add = Condition.oneof
Condition.__mul = Condition.allof

-- requires lua 5.3
Condition.__bnot = Condition.noneof
Condition.__bor = Condition.oneof
Condition.__band = Condition.allof

-----------------------------------------
-- Some default condition constructors --
-----------------------------------------
function KeyDown(key)
    local c = Condition.new({key=key})
    function c.update(self, dt)
        if love.keyboard.isDown(self.key) then
            self.is_true = true
        else
            self.is_true = false
        end
    end
    return c
end

function TimePassed(time)
    local c = Condition.new({time=time})
    function c.update(self, dt)
        self.time = self.time - dt
        if self.time <= 0 then
            self.is_true = true
        end
    end
    return c
end

function MouseAt(x, y, width, height)
    local c = Condition.new({x=x, y=y, width=width, height=height})
    function c.update(self, dt)
        local mx, my = love.mouse.getX(), love.mouse.getY()
        if self.x <= mx and mx <= self.x + self.width then
            if self.y <= my and my <= self.y + self.height then
                self.is_true = true
            else
                self.is_true = false
            end
        else
            self.is_true = false
        end
    end
    return c
end

return {
    Condition=Condition, TimePassed=TimePassed,
    KeyDown=KeyDown, MouseAt=MouseAt
}
