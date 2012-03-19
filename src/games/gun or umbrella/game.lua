return {
	standalone_difficulty = "easy",
	difficulties = {"easy"},
	
	PR = "child",
	
	keys = {"arrows"},
	
	maxDuration = 15,
	
	makeGameInstance = function(self, info)
		self.getReady = function(self, basePath)
			self.umbrellas = {
				love.graphics.newImage(basePath.."umbrella1.png"),
				love.graphics.newImage(basePath.."umbrella2.png"),
				love.graphics.newImage(basePath.."umbrella3.png")
			}
			self.arrows = {
				left=love.graphics.newImage(basePath.."arrowL.png"),
				right=love.graphics.newImage(basePath.."arrowR.png")
			}

			self.policeCharger = {
				img=love.graphics.newImage(basePath.."policeCharger.png"),
				width=224,
				height=120
			}
			self.policeCharger.x = love.graphics.getWidth()
			self.policeCharger.y = love.graphics.getHeight() * 1/8
			self.policeCharger.dx = -self.policeCharger.x

			self.policeInter = {
				img=love.graphics.newImage(basePath.."policeInter.png"),
				width=322,
				height=120
			}
			self.policeInter.x = -self.policeInter.width
			self.policeInter.y = love.graphics.getHeight() * 2/3
			self.policeInter.dx = self.policeInter.width * 2
			
			self.back = love.audio.newSource(basePath.."rain.mp3")
			self.siren = love.audio.newSource(basePath.."siren.ogg")
			self.play = false
			self.policeTime = 2

			self.state = 'playing'			
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
			
			if self.state == 'police' then
				love.graphics.setColor(255,255,255)
				love.graphics.draw(self.policeCharger.img, self.policeCharger.x, self.policeCharger.y)
				love.graphics.draw(self.policeInter.img, self.policeInter.x, self.policeInter.y)
			end
			
		end
		
		self.update = function(self, dt) 
			self.elapsed = self.elapsed+dt 
			if not self.play then
				self.play = true
				love.audio.play(self.back)
			end

			if self.state == 'police' then
				local derp = 0

				if self.policeInter.x <= -self.policeInter.width * 1/6 then
					self.policeInter.x = self.policeInter.x + self.policeInter.dx * dt
					derp = derp + 1
				end

				if self.policeCharger.x >= love.graphics.getWidth() * 5/8 then
					self.policeCharger.x = self.policeCharger.x + self.policeCharger.dx * dt
					derp = derp + 1
				end

				self.policeTime = self.policeTime - dt
				if self.policeTime < 0 then
					self.done = true
				end
			end
		end
		
		self.isDone = function(self)
			return self.done
		end
		
		self.getScore = function(self)
			return self.score 
		end
		
		self.keypressed = function(self, key)
			if self.state == 'playing' then
				if key =='left' then
					if self.img ==3 then
						self.done = true
						self.score = 1
					end
					self.img = self.img +1
				end
				if key =='right' then
					love.audio.stop(self.back)
					love.audio.play(self.siren)
					self.score = -1
					self.state = 'police'
					self.done = false
				end
			end
		end
		
	end
}
