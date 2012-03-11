return {

	difficulties = {"medium"},

    PR = "child",
	keys = {"arrows"},
	maxDuration = 30,
	makeGameInstance = function(self, info)
		self.elapsed_time = 0
		self.arrowSpeed = 0.25
		self.hitRange = 30
		self.lost = false
		self.update = function(self, dt)
			if not self.playing then
				self.playing = true
				love.audio.play(self.sound)
			end
			
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
			self.sound = love.audio.newSource(basePath.."heman30.mp3")
			self.playing = false
			self.ddr_score = 50
		end
		
		self.checkArrows = function(self)
			for i=1,#self.arrows do
				local arrow = self.arrows[i]
				if arrow[4] and self:arrowPosition(arrow,self.elapsed_time)< -self.hitRange then
					arrow[4] = false
					self.ddr_score = self.ddr_score - 75
				end
			end
		end
		
		self.draw = function(self)
			love.graphics.print(""..self.ddr_score,love.graphics.getWidth()-100,10)
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
			return self.ddr_score < -100
		end
		
		self.keypressed = function(self,key)
			pcall(function()
				local arrow_direction = ({left=1,down=2,up=3,right=4})[key]
				
				local extraHit = true
				
				for i=1,#self.arrows do
					local arrow = self.arrows[i]
					local position = self:arrowPosition(arrow,self.elapsed_time)
					
					if position > -self.hitRange and position< self.hitRange and arrow[4]
						and arrow[2]==arrow_direction then
						arrow[4]=false
						extraHit = false
						self.ddr_score = self.ddr_score + (50 - math.abs(position))
					end
				end
				
				if extraHit then
					--self.lost = true
					self.ddr_score = self.ddr_score - 25
				end
				
			end)
		end
		
		self.getScore = function(self)
			return self.ddr_score /((#self.arrows+1)*50)
		end
		
		--time in ms, direction, color, was hit
		self.arrows = {
{  1092,1, {255,255,127}, true },
{  1492,1, {255,255,127}, true },
{  1892,1, {255,255,127}, true },
{  2326,1, {255,255,127}, true },
{  2742,1, {255,255,127}, true },
{  3159,4, {255,255,127}, true },
{  3409,3, {255,255,127}, true },
{  3609,1, {255,255,127}, true },
{  4026,2, {255,255,127}, true },
{  4442,3, {255,255,127}, true },
{  4875,1, {255,255,127}, true },
{  5092,4, {255,255,127}, true },
{  5359,3, {255,255,127}, true },
{  5526,1, {255,255,127}, true },
{  5742,2, {255,255,127}, true },
{  5942,4, {255,255,127}, true },
{  6359,3, {255,255,127}, true },
{  6559,1, {255,255,127}, true },
{  6976,2, {255,255,127}, true },
{  7192,4, {255,255,127}, true },
{  7442,3, {255,255,127}, true },
{  7659,1, {255,255,127}, true },
{  8076,2, {255,255,127}, true },
{  8476,3, {255,255,127}, true },
{  8892,1, {255,255,127}, true },
{  9359,4, {255,255,127}, true },
{  9776,3, {255,255,127}, true },
{  9965,1, {255,255,127}, true },
{  10392,3, {255,255,127}, true },
{  10842,3, {255,255,127}, true },
{  11309,3, {255,255,127}, true },
{  11409,1, {255,255,127}, true },
{  11692,1, {255,255,127}, true },
{  12093,4, {255,255,127}, true },
{  12542,3, {255,255,127}, true },
{  12876,1, {255,255,127}, true },
{  13092,2, {255,255,127}, true },
{  13276,4, {255,255,127}, true },
{  13526,3, {255,255,127}, true },
{  13742,1, {255,255,127}, true },
{  14109,1, {255,255,127}, true },
{  14492,4, {255,255,127}, true },
{  14959,3, {255,255,127}, true },
{  15443,1, {255,255,127}, true },
{  15910,4, {255,255,127}, true },
{  16343,1, {255,255,127}, true },
{  16777,4, {255,255,127}, true },
{  17043,3, {255,255,127}, true },
{  17277,1, {255,255,127}, true },
{  17643,2, {255,255,127}, true },
{  17877,4, {255,255,127}, true },
{  18093,3, {255,255,127}, true },
{  18327,1, {255,255,127}, true },
{  18510,2, {255,255,127}, true },
{  18727,4, {255,255,127}, true },
{  18993,3, {255,255,127}, true },
{  19210,1, {255,255,127}, true },
{  19543,2, {255,255,127}, true },
{  19977,3, {255,255,127}, true },
{  20193,1, {255,255,127}, true },
{  20577,4, {255,255,127}, true },
{  20843,3, {255,255,127}, true },
{  21060,1, {255,255,127}, true },
{  21277,2, {255,255,127}, true },
{  21710,3, {255,255,127}, true },
{  22160,1, {255,255,127}, true },
{  22510,4, {255,255,127}, true },
{  22960,3, {255,255,127}, true },
{  23343,1, {255,255,127}, true },
{  23660,2, {255,255,127}, true },
{  24060,2, {255,255,127}, true },
{  24510,3, {255,255,127}, true },
{  24727,2, {255,255,127}, true },
{  24927,3, {255,255,127}, true },
{  25143,2, {255,255,127}, true },
{  25327,3, {255,255,127}, true },
{  25560,2, {255,255,127}, true },
{  26110,1, {255,255,127}, true },
{  26527,4, {255,255,127}, true },
{  26793,4, {255,255,127}, true },
{  26827,3, {255,255,127}, true },
{  27227,1, {255,255,127}, true },
		}
		
		self.staticArrows = {
			{ 0,1, {127,127,127,127}, true },
			{ 0,2, {127,127,127,127}, true },
			{ 0,3, {127,127,127,127}, true },
			{ 0,4, {127,127,127,127}, true },
		}
		
    end
}