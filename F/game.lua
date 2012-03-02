--[[
    game 'F'
--]]

local HC = require 'hardoncollider'

local game = {
	gload = function(self)
        -- initialize library
        self.Collider = HC(100, on_collision, collision_stop)
        self.game_dir = "F"

        self.music = love.audio.newSource("B/Resources/f_000240.wav")
        self.sound = love.audio.newSource("B/Resources/BeepWin.wav")

        self.music:setVolume(0.2)
        self.sound:setVolume(3.0)

        self.count = 0

        self.eTime = 0
        self.timeLimit = 10

        x = 87.5
        y = 15
        self.bricks = {}
        for i = 1, 12 do
        	self.bricks[i] = self.Collider:addRectangle(x,y,75,15)
        	self.bricks[i].x = x
        	self.bricks[i].y = y
        	if i%3 == 0 then
        		y = y+15
        		x = 87.5
        	else
        		x = x+75
        	end
        end

        self.paddle = self.Collider:addRectangle(155,385,90,10)
        self.paddle.x = 155
        self.paddle.y = 385

        self.ball = self.Collider:addCircle(200,200,6)
        self.ball.x = 200
        self.ball.y = 200

        self.gScore = 0
        self.goal  = 3

        love.audio.play(self.music)
    end,

    gdraw = function(self)
    	reds={51,255,35,255}
    	greens = {153,48,142,215}
    	blues = {204,48,35,0}
    	for i = 1, 12 do
    		if i%4 == 0 then
    			love.graphics.setColor(reds[4],greens[4],blues[4])
    		else
    			love.graphics.setColor(reds[i%4],greens[i%4], blues[i%4])
    		end
    		love.graphics.rectangle("fill", self.bricks[i].x, self.bricks[i].y, 75,15)
    	end
    	love.graphics.setColor(240,255,240)
    	love.graphics.rectangle("fill", self.paddle.x, self.paddle.y, 90, 10)
    	love.graphics.circle("fill", self.ball.x, self.ball.y, 6)
    end,

    gupdate = function(self, dt)
    	speed=250
    	if love.keyboard.isDown("left") then
            if self.paddle.x > 0 then
                self.paddle:move(-dt*speed,0)
                self.paddle.x = self.paddle.x - dt*speed
            end
        end 
        if love.keyboard.isDown("right") then
            if self.paddle.x < (400-90) then
                self.paddle:move(dt*speed,0)
                self.paddle.x = self.paddle.x + dt*speed
            end
        end 
        self.Collider:update(dt)
    end,

    goc = function(self, dt, shape_a, shape_b, mtv_x, mtv_y)
    end,

    gend = function(self)
    	love.audio.stop(self.music)
        return self.gScore >= self.goal
	end
}

return game