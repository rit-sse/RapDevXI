--[[
    game 'F'
    By the awesome spectacular Kristen Mills.
    With Guidence from the hardoncollider pong tutorial
    http://vrld.github.com/HardonCollider/tutorial.html
--]]

local HC = require 'hardoncollider'

preReq = function(o)
    o.game_dir = "F"
    o.bindings = {"Left", "Right"}
end


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
        self.timeLimit = 6

        x = 72.5
        y = 15
        self.bricks = {}
        for i = 1, 12 do
        	self.bricks[i] = self.Collider:addRectangle(x,y,75,15)
        	self.bricks[i].x = x
        	self.bricks[i].y = y
        	if i%3 == 0 then
        		y = y+30
        		x = 72.5
        	else
        		x = x+90
        	end
        end

        self.paddle = self.Collider:addRectangle(155,385,90,10)
        self.paddle.x = 155
        self.paddle.y = 385

        self.ball = self.Collider:addCircle(200,200,6)
        self.ball.x = 200
        self.ball.y = 200

        self.ball.velocity= {x=0, y= 250}

        self.top = self.Collider:addRectangle(0,-100,400,100)
        self.left = self.Collider:addRectangle(-100,0,100,400)
        self.right = self.Collider:addRectangle(400,0,100,400)
        self.bottom = self.Collider:addRectangle(0,400,400,100)

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
    	love.graphics.setColor(170,170,170)
    	love.graphics.rectangle("fill", self.paddle.x, self.paddle.y, 90, 10)
        love.graphics.setColor(240,255,240)
    	love.graphics.circle("fill", self.ball.x, self.ball.y, 6)
        love.graphics.print("Score:"..self.gScore, 300, 5)
        love.graphics.print("Goal: 3", 300, 27)
    end,

    gupdate = function(self, dt)
    	speed=250
        x = self.ball.x + self.ball.velocity.x*dt*5
        y = self.ball.y + self.ball.velocity.y*dt*1.2
        self.ball:moveTo(x, y)
        self.ball.x = x
        self.ball.y = y
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
        self.eTime = self.eTime + dt
    end,
    --[[
        Fun fact: It took me way too long to realize that if two shapes are
        drawn touching that counts as a collision. I was
        having problems where the ball was just kind of shaking in place until
        I added the else condiional that just returned if neither shape was the ball
        due to the walls colliding
    ]]--
    goc = function(self, dt, shape_a, shape_b, mtv_x, mtv_y)
        local object
        if shape_a == self.ball then 
            object = shape_b
        elseif shape_b == self.ball then
            object = shape_a
        else
            return 
        end

        if object == self.right or object == self.left then --ball bounces off the side wall
            self.ball.velocity.x = -self.ball.velocity.x
        elseif object == self.bottom then -- ball hit the bottom aka done
            self.ball.velocity = {x=0,y=0}
            self.Collider:remove(self.ball)
        elseif object == self.top then --ball hit the top
            self.ball.velocity.y = -self.ball.velocity.y
        else -- ball hit the paddle or a brick
            px,py = object:center()
            bx,by = self.ball:center()
            self.ball.velocity.x = bx-px
            self.ball.velocity.y = -self.ball.velocity.y
            for i = 1, 12 do
                if self.bricks[i] == object then 
                    self.bricks[i].x = -500  --there is probably a better way to remove a brick
                    self.bricks[i].y = -500  --but for now off the screen we go
                    self.Collider:remove(self.bricks[i])
                    love.audio.stop(self.sound)
                    love.audio.play(self.sound)
                    self.gScore = self.gScore +1
                end
            end
            -- keep the ball moving at the same speed
            len = math.sqrt(self.ball.velocity.x^2 + self.ball.velocity.y^2)
            self.ball.velocity.x = self.ball.velocity.x / len *250
            self.ball.velocity.y = self.ball.velocity.y / len *250
        end
        
    end,

    gend = function(self)
    	love.audio.stop(self.music)
        return self.gScore >= self.goal
	end
}

preReq(game)
return game
