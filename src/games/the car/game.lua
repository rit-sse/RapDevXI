return {
    
	difficulties = {"easy","medium","hard","impossible"},
    PR = "sse",
	
    keys = {"full keyboard"},
	maxDuration = 5,
	
    makeGameInstance = function(self, info)
		self.elapsed_time = 0
		self.mash_goal = ({easy=5, medium=10, hard=15, impossible=20})[info.difficulty]
		self.push = 0
		self.won = false
		self.update = function(self, dt)
			self.elapsed_time = self.elapsed_time+dt
			self.push=self.push-dt*self.mash_goal
			if self.push<0 then self.push = 0 end
			if self.push>60 then self.push = 60 end
			self.won = self.push >50
			if not self.playing then
				self.playing = true
				love.audio.play(self.sound)
			end
		end
        
		self.playing = false
		self.getReady = function(self, basePath)
			self.poop = love.graphics.newImage(basePath.."poop.png")
			self.sound = love.audio.newSource(basePath.."gogogo.mp3")
		end
		
		self.draw = function(self)
			love.graphics.setColor(255,255,255)
			love.graphics.draw(self.poop,love.graphics.getWidth()/2, self.push, 0, 1, 1, self.poop:getWidth()/2, self.poop:getHeight())
			
			
			love.graphics.setColor(255,255,255)
			love.graphics.draw(self.poop,love.graphics.getWidth()/2, 80-(self.push/2), math.pi/2, 1, 1, self.poop:getHeight()/2, self.poop:getWidth())
			
			love.graphics.setColor(80,80,255)
			love.graphics.rectangle("fill",0,40,love.graphics.getWidth(),love.graphics.getHeight())
			
			love.graphics.setColor(255,255,255)
			love.graphics.print("MASH SPACE", 30, love.graphics.getHeight()/2,0,3,3)
			
		end
		
		self.keypressed = function(self, key) 
			if key==' ' then
				self.push = self.push + 3
			end
		end
		
		self.getScore = function(self) return self.won and 1 or -1 end
		
    end
}
