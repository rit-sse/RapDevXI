return {
 
	difficulties = {"easy","medium","hard","impossible"},
	PR = "child",
	keys = {"space"},
	
	maxDuration = 15,
	
	makeGameInstance = function(self, info)
		self.elapsed_time = 0
		self.time_limit = ({easy=5, medium=5, hard=5, impossible=5})[info.difficulty]
		self.time_left = self.time_limit
		
		self.pct = 0
		self.keyval = 0.1
		self.speed = ({easy=0.5, medium=0.6, hard=0.7, impossible=1.5})[info.difficulty]
		self.getReady = function(self, basePath)
			self.sound = love.audio.newSource(basePath.."theme.mp3")
			self.scream = love.audio.newSource(basePath.."scream.mp3")
			self.back = love.graphics.newImage(basePath.."back.png")
		
		end
		self.lost =  false
		self.playing = false
		self.update = function(self, dt)
			if not self.playing then
				love.audio.play(self.sound)
				self.playing = true
			end
		
			self.elapsed_time = self.elapsed_time+dt
			self.time_left = self.time_limit - self.elapsed_time
			self.pct = self.pct+self.speed*dt
			if self.pct>0.5 then
				self.pct = 5
				if not self.lost then 
					self.lostTime = self.elapsed_time 
					love.audio.stop()
					love.audio.play(self.scream)
				end
				self.lost = true
			end
			if self.pct<0 then self.pct =0 end
		end
        
		self.draw = function(self)
			love.graphics.setColor(255,255,255)
			if self.lost then
				love.graphics.draw(self.back,love.graphics.getWidth()/2-self.back:getWidth(),
				love.graphics.getHeight()/2-self.back:getHeight(),0,2,2,0,0)
			else
				love.graphics.draw(self.back,love.graphics.getWidth()/2-self.back:getWidth()/2,
				love.graphics.getHeight()/2-self.back:getHeight()/2,0,1,1,0,0)
			end
			
			
			if self.lost then
				if self.elapsed_time-self.lostTime<1 then
					love.graphics.setColor(0,0,0)
					love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
				end
			else
				love.graphics.setColor(0,0,0)
				love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight()*self.pct)
				love.graphics.rectangle("fill",0,love.graphics.getHeight()*(1-self.pct),love.graphics.getWidth(),love.graphics.getHeight()*self.pct)
			end
		end
		
		self.keypressed = function(self,key)
			if key==' ' then
				self.pct = self.pct - self.keyval
			end
		end
		
		self.isDone = function(self)
			if self.lost then
				return self.elapsed_time - self.lostTime >2
			else
				return self.time_left <0
			end
		end
		
		self.getScore = function(self)
			return self.lost and -1 or 1
		end
		
    end
}
