--[[
    game 'A'
--]]

local HC = require 'hardoncollider'

local game = {

    gload = function(self)
        -- initialize library
        self.Collider = HC(100, on_collision, collision_stop)
        self.game_dir = "A"

        self.music = love.audio.newSource("A/Resources/f_000240.wav")
        self.sound = love.audio.newSource("A/Resources/BeepWin.wav")
        self.cursor = love.graphics.newImage("A/Resources/block.gif")
        self.circleImg = love.graphics.newImage("A/Resources/circlePoint.gif")

        self.music:setVolume(0.2)
        self.sound:setVolume(3.0)

        self.eTime = 0
        self.timeLimit = 5.0

        --add rectangle
                                  -- x,y,  w, h
        self.rect = self.Collider:addRectangle(0,350,32,32)
        self.rect.x = 0 
        self.rect.y = 350
    
        self.circle = self.Collider:addCircle(300,300,32)
        self.circle.x = 300
        self.circle.y = 300
    
        self.gScore = 0
        self.req = 30

        love.audio.play(self.music)
    end,

    gdraw = function(self)
        love.graphics.setColor(255,0,0)
        love.graphics.setColor(255,255,255)
        love.graphics.draw(self.circleImg, self.circle.x-32, self.circle.y-32)
        love.graphics.draw(self.cursor, self.rect.x, self.rect.y)
        love.graphics.setColor(255,255,255)
        love.graphics.print(self.gScore.."/"..self.req,220,8)
    end,

    gupdate = function(self, dt)
        speed = 275
        if love.keyboard.isDown("up") then
            if self.rect.y > 50 then
                self.rect:move(0,-dt*speed)
                self.rect.y = self.rect.y - dt*speed
            end
        end 
        if love.keyboard.isDown("down") then
            if self.rect.y < (400-32) then
                self.rect:move(0,dt*speed)
                self.rect.y = self.rect.y + dt*speed
            end
        end 
        if love.keyboard.isDown("left") then
            if self.rect.x > 0 then
                self.rect:move(-dt*speed,0)
                self.rect.x = self.rect.x - dt*speed
            end
        end 
        if love.keyboard.isDown("right") then
            if self.rect.x < (400-32) then
                self.rect:move(dt*speed,0)
                self.rect.x = self.rect.x + dt*speed
            end
        end 
        self.Collider:update(dt)
 
        self.eTime = self.eTime + dt
    end,

    goc = function (self, dt, shape_a, shape_b, mtv_x, mtv_y)
        if shape_b == self.circle then
            self.gScore = self.gScore + 10
            x = math.random( 0, 400)
            y = math.random( 50, 400)

            self.circle.x = x
            self.circle.y = y
            self.circle:moveTo(x, y)
            love.audio.stop(self.sound)
            love.audio.play(self.sound)
        end
    end,

    request = function(self) --returns a list of data asked for from the framework
        return {}
    end,

    fillRequest = function(self, data) --data returned by the framework from request
    end,   

    gkpress = function(self, key)
    end,
        
    gend = function(self) --function called only by Game Framework
        --asks for pass or fail, cleans up any calls to love
        love.audio.stop(self.music)
        return self.gScore >= self.req
    end
}

return game --returns game
