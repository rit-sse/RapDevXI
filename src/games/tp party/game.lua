return {
	standalone_difficulty = "easy",
	difficulties = {"easy","medium","hard","impossible"},
	PR = "child",
	keys = {"arrows"},
	maxDuration = 15,
	makeGameInstance = function(self, info)
        self.done = false
		self.time_limit = ({easy=15, medium=10, hard=8, impossible=4})[info.difficulty]
		self.getReady = function(self, basePath)
            cir1 = {x = 50,                 y = 50,         r = 30} -- the circle left
            box1 = {x = cir1.x,             y = cir1.y-cir1.r,     w = 200, l = 2*cir1.r } -- box
            box2 = {x = cir1.x + cir1.r,    y = cir1.y,     w = 200, l = 800} -- toliet paper
            cir2 = {x = cir1.x + box2.w,    y = cir1.y} -- the circle right
            handL = {x = cir1.x + 30,       y = (cir1.y + (2 * cir1.r)) + 30} -- left hand
            handR = {x = cir2.x + 30,       y = (cir2.y + (2 * cir2.r)) + 30} -- right hand
			
            handL = love.graphics.newImage("hand.png")
            handR = love.graphics.newImage("hand.png")
			self.elapsed_time = 0
		end

        function love.keypressed(key)
            if hand2.y == 2 * cir1.r + 30 and key == "right" then
                hand2.y = 2 * cir1.r + 80
                hand1.y = 2 * cir1.r + 30
                if cir1.r > 5 then -- 5 is the end goal
                    cir1.r = cir1.r - 3
                else
                    self.done = true
                end
            elseif hand1.y == 2*cir1.r + 30 and key == "left" then
                hand1.y = 2*cir1.r + 80
                hand2.y = 2*cir1.r + 30
            end
        end

		self.update = function(self, dt)
			self.elapsed_time = self.elapsed_time+dt	

            box1 = {x = cir1.x,             y = cir1.y - cir1.r,    w = 200, l = 2*cir1.r } -- box
            box2 = {x = cir1.x + cir1.r,    y = cir1.y,             w = 200, l = 800} -- toliet paper
            cir2 = {x = cir1.x + box2.w,    y = cir1.y} -- the circle right			
		end
		
		self.draw = function(self)
            
			--here we just put how much time is left in the upper left corner
			-- look at https://love2d.org/wiki/love.graphics for fun drawing stuff
			love.graphics.print( (self.time_limit-self.elapsed_time).."s left", 0,0)
					
			love.graphics.circle("line", cir1.x, cir1.y, cir1.r, 100)
			love.graphics.circle("line", cir2.x, cir2.y, cir1.r, 100)
			love.graphics.rectangle("line", box1.x, box1.y, box1.w, box1.l)
			love.graphics.rectangle("line", box2.x, box2.y, box2.w, box2.l)
		end
		
		self.isDone = function(self)
			--This can return true to have the game end sooner that the time_limit
			--set for the type of game.
	
			--we are done when we are out of time.
			return self.elapsed_time > self.time_limit
		end
		
		self.getScore = function(self)
			--return a number -1 to 1. anything >0 is a "passing" score

			return -1 --the player always looses. 
		end
		
		self.keypressed = function(self, key)
			print(key.." was pressed")
		end
		
		self.keyreleased = function(self, key)
			print(key.." was released")
		end
	end
}
