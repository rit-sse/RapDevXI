--[[
	game 'E' 
]]--

local HC = require 'hardoncollider'

local game = {

    gload = function(self)
        -- initialize library
        self.Collider = HC(100, on_collision, collision_stop)
        self.game_dir = "E"
        self.basketImg = love.graphics.newImage("E/Resources/basket.gif")
        self.cherryImg = love.graphics.newImage("E/Resources/cherry.gif")

        self.music = love.audio.newSource("B/Resources/f_000240.wav")
        self.sound = love.audio.newSource("B/Resources/BeepWin.wav")

        self.music:setVolume(0.2)
        self.sound:setVolume(3.0)

        self.count = 0

        self.eTime = 0
        self.timeLimit = 10
        self.basket = self.Collider:addRectangle(200,375,90,20)
        self.basket.x = 200
        self.basket.y = 375
        x = math.random(0, 350)
        self.cherry = self.Collider:addRectangle(0, x, 15, 17)
        self.cherry.x = x
        self.cherry.y = 400

        self.gScore = 0
        self.goal  = 3

        love.audio.play(self.music)
    end,

    gdraw = function(self)
 		love.graphics.setColor(255,255,255)
  		love.graphics.draw(self.basketImg, self.basket.x, self.basket.y,0,3,1)
 		love.graphics.draw(self.cherryImg, self.cherry.x, self.cherry.y)
        love.graphics.print("Score:"..self.gScore, 300, 5)
        love.graphics.print("Goal: 3", 300, 27)
    end,

    gupdate = function(self, dt)
        speed = 250
    	if self.cherry.y < 400 then 
    		self.cherry:move(0,dt*speed*.8)
    		self.cherry.y = self.cherry.y +dt*speed*.8
            self.cherry.x = self.cherry.x +dt +math.sin(self.cherry.y/20)*5
    	else
    		x = math.random( 0, 350)
    		self.cherry.x = x
    		self.cherry.y = 0
    		self.cherry:moveTo(x, 0)
    	end
        if love.keyboard.isDown("left") then
            if self.basket.x > 0 then
                self.basket:move(-dt*speed,0)
                self.basket.x = self.basket.x - dt*speed
            end
        end 
        if love.keyboard.isDown("right") then
            if self.basket.x < (400-32) then
                self.basket:move(dt*speed,0)
                self.basket.x = self.basket.x + dt*speed
            end
        end 
        self.Collider:update(dt)
 
        self.eTime = self.eTime + dt
    end,

    goc = function (self, dt, shape_a, shape_b, mtv_x, mtv_y)
    	if shape_b == self.cherry or shape_a == self.cherry then
    	 	self.gScore = self.gScore + 1
    	 	x = math.random( 0, 350)
        	self.cherry.x = x
        	self.cherry.y = 0
        	self.cherry:moveTo(x, 0)
            love.audio.stop(self.sound)
            love.audio.play(self.sound)
        end
    end,

    gend = function(self) --function called only by Game Framework
        love.audio.stop(self.music)
        return self.gScore >= self.goal
    end
}

return game --returns game
