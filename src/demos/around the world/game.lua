return {
    
	difficulties = {"easy","medium","hard","impossible"},
    PR = "child",
    keys = {"arrows"},
	maxDuration = 10000,
    makeGameInstance = function(self, info)
		self.elapsed_time = 0
		self.time_limit = ({easy=30, medium=20, hard=15, impossible=10})[info.difficulty]
		self.fps = 0
		
		self.update = function(self, dt)
			self.elapsed_time = self.elapsed_time+dt
			
			if love.keyboard.isDown("left") then
				self.r = self.r-dt*25	
			end
			if love.keyboard.isDown("right") then
				self.r = self.r+dt*25	
			end
			
			if love.keyboard.isDown("down") then
				self.h = self.h + 60*dt
			end
			if love.keyboard.isDown("up") then
				self.h = self.h - 60*dt
			end
			
			if self.r<0 then self.r = self.r + self.d.width end
			self.fps = 1/dt
		end
        
		self.getReady = function(self, basePath)
			--self.world = require('world')
			
			self.worldImage = love.graphics.newImage(basePath.."world.png")
			
			self.h = love.graphics.getHeight()/2
			self.d={}
			self.d.height = self.worldImage:getHeight()
			self.d.width = self.worldImage:getWidth()
			self.r = 0
		end
		
		self.draw = function(self)
			love.graphics.print( string.format("%.2f FPS",self.fps), 0,0)
			
			for x=1,self.d.width/4+1 do
				for y=1,self.d.height do
					self:drawElement(x,x+math.floor(self.r),y,y)
				end
				for y=1,self.d.height do
					local mx = self.d.width/2-x+1
					self:drawElement(mx,mx+math.floor(self.r),y,y)
				end
			end
			
			love.graphics.setColor(255,0,0)
			love.graphics.rectangle("fill",0,self.h,love.graphics.getWidth(),1)
			love.graphics.rectangle("fill",love.graphics.getWidth()/2,0,1,love.graphics.getHeight())
		end
		
		self.drawElement = function(self, x,c,y,yc)
			while c > self.d.width do
				c = c-self.d.width
			end
			while yc> self.d.height do
				yc = yc-self.d.height
			end
			
			
			local xportion = (x-1)/self.d.width*2
			local yportion = (y-1)/self.d.height
			
			local xscale = math.sin(yportion*math.pi)
			
			xportion = math.sin(xportion*math.pi-math.pi/2)
			yportion = math.sin(yportion*math.pi-math.pi/2)
			
			
			local x = xscale*xportion*100+love.graphics.getWidth()/2
			local y = yportion*100+love.graphics.getHeight()/2
			
			--love.graphics.setColor(self.world[yc][c][1],self.world[yc][c][2],self.world[yc][c][3])
			--love.graphics.circle("line", x,y,5)
			
			local quad = love.graphics.newQuad(c,yc, 1, 1, self.d.width, self.d.height)
			love.graphics.drawq(self.worldImage, quad, x, y,0,10,7)
		end
		
		self.isDone = function(self)
			--we are done when we are out of time.
			--return self.elapsed_time > self.time_limit
			return false
		end
		
		self.keypressed = function(self,key)
			if key=='return' then
				print(string.format('{%.2f, %.2f, "location"},',self.r,self.h))
			end
		end
		
    end
}
