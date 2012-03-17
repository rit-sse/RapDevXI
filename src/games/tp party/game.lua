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
			self.cir1 = {x = 50, y = 50, r = 30} -- the circle left
			self.box1 = {x = self.cir1.x, y = self.cir1.y-self.cir1.r, w = 200, l = 2*self.cir1.r } -- box
			self.box2 = {x = self.cir1.x + self.cir1.r, y = self.cir1.y, w = 200, l = 800} -- toliet paper
			self.cir2 = {x = self.cir1.x + self.box2.w, y = self.cir1.y, r = self.cir1.r} -- the circle right
			self.handL = {x = self.cir1.x + 36 + self.cir1.r, y = 200} -- left hand
			self.handR = {x = self.cir2.x + -36 + self.cir1.r, y = 150} -- right hand
			self.handLoc = {up = 150, down = 200} --up and down values
			self.handL.img = love.graphics.newImage("hand.png")
			self.handR.img = love.graphics.newImage("hand.png")
			self.elapsed_time = 0
		end
		
		self.keypressed = function(self, key)
			if self.handR.y == self.handLoc.up and key == "right" then
				self.handR.y = self.handLoc.down
				self.handL.y = self.handLoc.up
				if self.cir1.r > 5 then -- 5 is the end goal
					self.cir1.r = self.cir1.r - .75
				else
					self.done = true
				end
			elseif self.handR.y == self.handLoc.down and key == "left" then
				self.handR.y = self.handLoc.up
				self.handL.y = self.handLoc.down
			end
		end
		
		self.update = function(self, dt)
			self.elapsed_time = self.elapsed_time+dt	
			
			self.box1 = {x = self.cir1.x, y = self.cir1.y - self.cir1.r, w = 200, l = 2*self.cir1.r } -- box
			self.box2 = {x = self.cir1.x + self.cir1.r, y = self.cir1.y, w = 200, l = 800} -- toliet paper
			self.cir2 = {x = self.cir1.x + self.box2.w, y = self.cir1.y} -- the circle right
			
			self.handL.x = self.cir1.x + 36 + self.cir1.r -- left hand
			self.handR.x = self.cir2.x + -36 + self.cir1.r -- right hand			
		end
		
		self.draw = function(self)
			--here we just put how much time is left in the upper left corner
			-- look at https://love2d.org/wiki/love.graphics for fun drawing stuff
			love.graphics.print( (self.time_limit-self.elapsed_time).."s left", 0,0)
			
			love.graphics.circle("fill", self.cir1.x, self.cir1.y, self.cir1.r, 100)
			love.graphics.circle("fill", self.cir2.x, self.cir2.y, self.cir1.r, 100)
			love.graphics.rectangle("fill", self.box1.x, self.box1.y, self.box1.w, self.box1.l)
			love.graphics.rectangle("fill", self.box2.x, self.box2.y, self.box2.w, self.box2.l)
			love.graphics.setColor(130,130,130)
			love.graphics.circle("fill", self.cir1.x, self.cir1.y, 3, 100)
			love.graphics.setColor(0,0,0)
			love.graphics.circle("line", self.cir1.x, self.cir1.y, self.cir1.r, 100)
			love.graphics.setColor(255,255,255)
			love.graphics.draw(self.handL.img, self.handL.x, self.handL.y, 0, -3, 3)
			love.graphics.draw(self.handR.img, self.handR.x, self.handR.y, 0, 3, 3)
		end
		
		self.isDone = function(self)
			--This can return true to have the game end sooner that the time_limit
			--set for the type of game.
			
			--we are done when we are out of time.
			return self.elapsed_time > self.time_limit
		end
		
		self.getScore = function(self)
			--return a number -1 to 1. anything >0 is a "passing" score
			if self.done then
				return 1
			end
			return -1 --the player always looses. 
		end
		
	end
}
