return {
	standalone_difficulty = "easy",
	difficulties = {"easy","medium","hard"},
	
	PR = "child",
	
	keys = {"arrows"},
	maxDuration = 10,
	
	
	makeGameInstance = function(self, info)
		self.launch_v = 150
		self.cannon_l = 50
		self.cannon_v = ({easy=3,medium=6,hard=10})[info.difficulty]
		self.grav = 70
		
		
		self.getReady = function(self, basePath)

			--self.image = love.graphics.newImage(basePath.."sprite.png")
			--self.sound = love.audio.newSource(basePath.."sound.mp3")
			self.launch_time = -1
			self.x = 0
			self.y = 0
			self.vx = 0
			self.vy = 0
			self.elapsed_time = 0
			self.passedx = -10
			
			
			
			self.cx = 0
			self.cy = love.graphics.getHeight()
			self.cx2 = 0
			self.cy2 = 0
			
			
			self.mus = love.audio.newSource(basePath.."music.mp3")
		end

		self.update = function(self, dt)
			self.elapsed_time = self.elapsed_time+dt			
			
			if self.mus then
				love.audio.play(self.mus)
				self.mus = nil
			end
			
			if self.launch_time < 0 then
				-- pre launch, set based on cannon & time
				local theta = (math.sin(self.elapsed_time*self.cannon_v)+1)/2
				theta = theta*math.pi/4+math.pi/8
				
				self.cx2 = self.cx + math.cos(theta)*self.cannon_l
				self.cy2 = self.cy - math.sin(theta)*self.cannon_l
				
				self.x = self.cx2
				self.y = self.cy2
				self.vx = math.cos(theta)*self.launch_v
				self.vy = math.sin(theta)*self.launch_v
			else
				self.x = self.x+self.vx*dt
				self.y = self.y-self.vy*dt
				
				if self.x - self.passedx > love.graphics.getWidth()/2 then
					self.passedx = self.x - love.graphics.getWidth()/2
				end
				
				self.vy = self.vy-self.grav*dt
				
				if self.y > love.graphics.getHeight() then
					self.vy = -self.vy*0.7-20
					self.vx = self.vx*0.9-20
					
					if self.vx <0 then self.vx = 0 end
					if self.vy <0.1 then self.vy = 0 end
					
					if self.vy == 0 then
						self.done = true
					end
					
					self.y = love.graphics.getHeight()-0.5
				end
			end
			
		end
		
		self.draw = function(self)
			local minx = self.passedx
			
			
			
			local linex = (love.graphics.getWidth()-minx)%love.graphics.getWidth()
			
			love.graphics.setLineWidth(1)
			love.graphics.setColor(30,30,30)
			love.graphics.line(linex,0,linex, love.graphics.getHeight())
		
			love.graphics.setColor(127,127,127)
			if self.launch_time >= 0 then
				love.graphics.circle("fill",self.x-minx,self.y,5)
			end
		
		
			love.graphics.setColor(255,255,255)
			love.graphics.setLineWidth(10)
			love.graphics.line(self.cx-minx,self.cy, self.cx2-minx, self.cy2)
			
			love.graphics.setColor(127,127,127)
			love.graphics.circle("fill",self.cx-minx,self.cy,20,10)
		
			
			
			love.graphics.setLineWidth(1)
			
			love.graphics.print(string.format("%d ft",self.x/20),0,0,0,2,2)
			
		end
		
		
		self.isDone = function(self)
			return self.done
		end
		
		self.getScore = function(self)
			local val = ((self.x/20)-27)/10
			if val <-1 then return -1 end
			if val > 1 then return 1 end
			return val
		end
		
		self.keypressed = function(self, key)
			if key==' ' then self.launch_time = self.elapsed_time end
		end
		
		self.keyreleased = function(self, key)
		end
	end
}
