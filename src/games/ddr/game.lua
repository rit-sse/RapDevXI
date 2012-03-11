return {

	difficulties = {"medium"},

    PR = "child",
	keys = {"arrows"},
	maxDuration = 9,
	makeGameInstance = function(self, info)
		self.elapsed_time = 0
		self.arrowSpeed = 0.25
		self.hitRange = 50
		self.lost = false
		self.update = function(self, dt)
			self.elapsed_time = self.elapsed_time+dt
			self:checkArrows()
		end
        
		self.getReady = function(self,basePath)
			self.arrow_images = {
				love.graphics.newImage(basePath.."left.png"),
				love.graphics.newImage(basePath.."down.png"),
				love.graphics.newImage(basePath.."up.png"),
				love.graphics.newImage(basePath.."right.png")
			}
		end
		
		self.checkArrows = function(self)
			for i=1,#self.arrows do
				local arrow = self.arrows[i]
				if arrow[4] and self:arrowPosition(arrow,self.elapsed_time)< -self.hitRange then
					self.lost = true
				end
			end
		end
		
		self.draw = function(self)
			for i=1,#self.staticArrows do
				self:drawArrow(self.staticArrows[i],0)
			end
			for i=1,#self.arrows do
				self:drawArrow(self.arrows[i],self.elapsed_time)
			end
			
		end
		
		self.drawArrow = function(self,arrow, elapsed)
			love.graphics.setColor(arrow[3][1],arrow[3][2],arrow[3][3])
			
			if(arrow[4]) then
				love.graphics.draw(self.arrow_images[arrow[2]],
					44*(arrow[2]-1),
					self:arrowPosition(arrow, elapsed))
			end
		end
		
		self.arrowPosition = function(self, arrow,elapsed)
			return self.arrowSpeed*(arrow[1]-math.floor(elapsed*1000))
		end
		
		self.isDone = function(self)
			return self.lost
		end
		
		self.keypressed = function(self,key)
			pcall(function()
				local arrow_direction = ({left=1,down=2,up=3,right=4})[key]
				for i=1,#self.arrows do
					local arrow = self.arrows[i]
					local position = self:arrowPosition(arrow,self.elapsed_time)
					
					if position > -self.hitRange and position< self.hitRange then
						arrow[4]=false
					end
					
				end
			end)
		end
		
		self.getScore = function(self)
			return self.lost and -1 or 1
		end
		
		--time in ms, direction, color, was hit
		self.arrows = {
			{ 1000,1, {255,255,127}, true },
			{ 2000,2, {255,0,0}, true },
			{ 3000,3, {0,0,255}, true },
			{ 4000,4, {0,255,0}, true },
			{ 5000,1, {127,255,255}, true },
			{ 6000,2, {255,127,255}, true },
			{ 7000,3, {255,255,127}, true },
			{ 8000,4, {0,127,0}, true },
		}
		
		self.staticArrows = {
			{ 0,1, {127,127,127,127}, true },
			{ 0,2, {127,127,127,127}, true },
			{ 0,3, {127,127,127,127}, true },
			{ 0,4, {127,127,127,127}, true },
		}
		
    end
}