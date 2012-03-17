return {
	standalone_difficulty = "easy",
	difficulties = {"easy"},
	
	PR = "child",
	
	keys = {"arrows"},
	
	maxDuration = 15,
	
	makeGameInstance = function(self, info)
		self.getReady = function(self, basePath)
			--self.sound = love.audio.newSource(basePath.."sound.mp3")
			
			self.umbrellas = {
				love.graphics.newImage(basePath.."umbrella1.png"),
				love.graphics.newImage(basePath.."umbrella2.png"),
				love.graphics.newImage(basePath.."umbrella3.png")
			}
			self.arrows = {
				left=love.graphics.newImage(basePath.."arrowL.png"),
				right=love.graphics.newImage(basePath.."arrowR.png")
			}
			
			self.done = false
			self.score = -1
			self.img = 1
			self.elapsed = 0
		end
		
		self.draw = function(self)
			love.graphics.setColor(255,255,255)
			love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
			love.graphics.draw(self.arrows.left, love.graphics.getWidth()/2-5*math.sin(self.elapsed*5)-self.arrows.left:getWidth()-30,5)
			love.graphics.draw(self.arrows.right, love.graphics.getWidth()/2+5*math.sin(self.elapsed*5)+30,5)
			
			if self.img <4 then
				love.graphics.draw(self.umbrellas[self.img],love.graphics.getWidth()/2-self.umbrellas[self.img]:getWidth()/2,
					100)
			end
			
			love.graphics.setColor(0,0,0)
			love.graphics.print("OR",love.graphics.getWidth()/2-15,12,0,2,2)
			love.graphics.print("Umbrella",10,12,0,2,2)
			love.graphics.print("Gun",love.graphics.getWidth()/2+80,12,0,2,2)
			
			
		end
		
		self.update = function(self, dt) self.elapsed = self.elapsed+dt end
		
		self.isDone = function(self)
			return self.done
		end
		
		self.getScore = function(self)
			return self.score 
		end
		
		self.keypressed = function(self, key)
			if key =='left' then
				if self.img ==3 then
					self.done = true
					self.score = 1
				end
				self.img = self.img +1
			end
			if key =='right' then
				self.score = -1
				self.done = true
			end
		end
		
	end
}
