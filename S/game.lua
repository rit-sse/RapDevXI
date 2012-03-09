--[[
    game S
--]]

local HC = require 'hardoncollider'

preReq = function(o)
    o.game_dir = "S"
    o.bindings = {"Mouse"}
end

local game = {

    gload = function(self)

        self.Collider = HC(100, on_collision, collision_stop)

        self.eTime = 0
        self.timeLimit = 5
        self.score = 0
        self.goal = 4
        love.graphics.setFont(self.fontSize)
        
        self.targets = {}
        for i=1,4 do
            self.targets[i] = self.Collider:addRectangle(math.random(20,380),math.random(20,380),60,60)
            self.targets[i].index = i
            self.targets[i].hover = false
        end

        self.cursor = self.Collider:addRectangle(0,0,40,40)
        self.cursor:moveTo(love.mouse.getPosition())

    end,

    gdraw = function(self)
        love.graphics.setColor(80, 124, 199)
        love.graphics.rectangle('fill', 0, 0, 400, 400) --bg Shape

        love.graphics.setColor(230,40,60)
        self.cursor:draw('fill')

        love.graphics.setColor(230,130,160)
        if #self.targets ~= 0 then
            for i=1,#self.targets do
                self.targets[i]:draw('fill')
            end
        end
        

    end,

    gupdate = function(self, dt)
        --Elapsed Time does not update; main menu has no time limit
        self.eTime = self.eTime + dt
        self.cursor:moveTo(love.mouse.getPosition())

        self.Collider:update(dt)
    end,

    goc = function (self, dt, shape_a, shape_b, mtv_x, mtv_y)
        if shape_b == self.cursor then
            shape_a.hover = true
        end
    end,

    gcs = function (self, dt, shape_a, shape_b)
        for i=1,#self.targets do
            if self.targets[i] ~= nil then
                self.targets[i].hover = false
            end
        end
    end,

    gmpress = function (self, x, y, button)
        for i=1,#self.targets do
            if self.targets[i] ~= nil and
            self.targets[i].hover then
                table.remove(self.targets, i)
                self.score = self.score + 1
            end
        end
    end,

        
    gend = function(self) --function called only by Game Framework
        --asks for pass or fail, cleans up any calls to love
        love.graphics.setFont(15)
        self.eTime = 2
        return self.score >= self.goal
    end
}

preReq(game)
return game --returns game
