require "lib.condition"
require "lib.deepcopy"

STATES = {
    start = {
        text = "Welcome to this tutorial. Please press Enter.",
        transitions = {
            {condition=KeyDown('return'), next="well_done"},
            {condition=TimePassed(5), next="too_slow"}
        },
    },
    well_done = {
        text = "Very good.",
        transitions = {
            {condition=TimePassed(5), next="the_end"}
        }
    },
    too_slow = {
        text = "You are too slow.",
        transitions = {
            {condition=TimePassed(5), next="the_end"}
        }
    },
    the_end = {
        text = "This is the end of our tutorial. Thank you for your cooperation. Restart with 'r'.",
        transitions = {
            {condition=KeyDown('r'), next="start"}
        }
    }
}

function love.load()
    stateSystem = {states=STATES}
    stateSystem.update = function(self, dt)
        for _, t in pairs(self.current.transitions) do
            t.condition:update(dt)
            if t.condition.is_true then
                -- use a copy of the state, since conditions have state.
                self.current = deepcopy(self.states[t.next])
                break
            end
        end
    end
    stateSystem.current = deepcopy(STATES.start)
end

function love.update(dt)
    stateSystem:update(dt)
end

function love.draw()
    local width, height = love.graphics.getDimensions()
    love.graphics.printf(stateSystem.current.text, 0, height/2, width, "center")
end
