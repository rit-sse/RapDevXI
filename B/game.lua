--[[
    game 'B'
--]]

local HC = require 'hardoncollider'

local game = {

    gload = function(self)
        -- initialize library
        self.Collider = HC(100, on_collision, collision_stop)
        self.game_dir = "B"

        self.music = love.audio.newSource("B/Resources/f_000240.wav")
        self.sound = love.audio.newSource("B/Resources/BeepWin.wav")

        self.music:setVolume(0.2)
        self.sound:setVolume(3.0)

        self.eTime = 0
        self.timeLimit = 5.0

        --add rectangle
                                            -- x, y,  w, h
        self.rect = self.Collider:addRectangle(15,100,8,32)
        self.rect.x = 15 
        self.rect.y = 100

        self.rect2 = self.Collider:addRectangle(5,0,5,400)
    
        y = math.random( 40, 360)
        self.circle = self.Collider:addCircle(500,y,16)
        self.circle.x = 500
        self.circle.y = y
    
        self.gScore = 0
        self.req = 30

        love.audio.play(self.music)
    end,

    gdraw = function(self)
        love.graphics.setColor(255,0,0)
        love.graphics.setColor(255,255,255)
        --love.graphics.draw(self.circleImg, self.circle.x-16, self.circle.y-16)
        --love.graphics.draw(self.cursor, self.rect.x, self.rect.y)
        self.rect2:draw('fill')
        love.graphics.setColor(255,0,0)
        self.circle:draw('fill')
        love.graphics.setColor(0,255,0)
        self.rect:draw('fill')
        love.graphics.setColor(255,255,255)
        love.graphics.print(self.gScore.."/"..self.req,220,8)
    end,

    gupdate = function(self, dt)
        speed = 300
        if love.keyboard.isDown("up") then
            if self.rect.y > 30 then
                self.rect:move(0,-dt*speed)
                self.rect.y = self.rect.y - dt*speed
            end
        end 
        if love.keyboard.isDown("down") then
            if self.rect.y < (370) then
                self.rect:move(0,dt*speed)
                self.rect.y = self.rect.y + dt*speed
            end
        end 

        self.circle:move(-dt*speed, 0)
        self.circle.x = self.circle.x - dt*speed
        self.Collider:update(dt)
 
        self.eTime = self.eTime + dt
    end,

    goc = function (self, dt, shape_a, shape_b, mtv_x, mtv_y)
        if shape_b == self.circle then
            if shape_a == self.rect2 then
                y = 500
            else
                self.gScore = self.gScore + 10
                y = math.random( 40, 360)
                love.audio.stop(self.sound)
                love.audio.play(self.sound)
            end

            x = 500
            self.circle.y = y
            self.circle:moveTo(x, y)
        end
    end,

    gend = function(self) --function called only by Game Framework
        --asks for pass or fail, cleans up any calls to love
        love.audio.stop(self.music)
        return self.gScore >= self.req
    end
}

return game --returns game
