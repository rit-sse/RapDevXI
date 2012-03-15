return {

	difficulties = {"impossible","easy","medium","hard","impossible"},
    PR = "child",
	keys = {"arrows"},
	maxDuration = 30,
	makeGameInstance = function(self, info)
		self.elapsed_time = 0
		self.arrowSpeed = ({easy=0.15, medium=0.15, hard=0.15, impossible=0.2})[info.difficulty]
		self.hitRange = ({easy=50, medium=40, hard=20, impossible=10})[info.difficulty]
		self.dif = info.difficulty
		self.lost = false
		self.update = function(self, dt)
			if not self.playing then
				self.playing = true
				love.audio.play(self.sound)
			end
			
			self.elapsed_time = self.elapsed_time+dt
			self:checkArrows()
			
			
			for i=1,#self.staticArrows do
				local colors = self.staticArrows[i][3]
				for j=1,#colors do
					local distance = 127-colors[j]
					colors[j] = colors[j]+distance*(dt/0.25)
				end
			end
			
			
		end
        
		self.getReady = function(self,basePath)
			self.arrow_images = {
				love.graphics.newImage(basePath.."left.png"),
				love.graphics.newImage(basePath.."down.png"),
				love.graphics.newImage(basePath.."up.png"),
				love.graphics.newImage(basePath.."right.png")
			}
			self.back_images = {
				love.graphics.newImage(basePath.."back1.png"),
				love.graphics.newImage(basePath.."back2.png")
			}
			self.sound = love.audio.newSource(basePath.."heman30.mp3")
			self.playing = false
			self.ddr_score = 5*self.hitRange
			
			if self.dif == "impossible" then
				local newArrows = {}
				
				for i=1,#self.arrows do
					if i%2 == 0 then
						local newArrow = {self.arrows[i][1],self.arrows[i][2],self.arrows[i][3],self.arrows[i][4]}
						newArrow[2] = ((self.arrows[i][2]+math.floor(i*17.3))%4)+1
						
						setmetatable(newArrow,self.arrows[i])
						table.insert(newArrows, newArrow)
					end
				end
				for i=1,#newArrows do
					table.insert(self.arrows, newArrows[i])
				end
			else
				print(self.dif)
			end
			
			for i=1,#self.arrows do
				local x = self.arrows[i][1]/2000
				self.arrows[i][3] = { 255*math.sin(x*math.pi/2), 127, 255*math.cos(x*math.pi/3)}
			end
			
		end
		
		self.checkArrows = function(self)
			for i=1,#self.arrows do
				local arrow = self.arrows[i]
				if arrow[4] and self:arrowPosition(arrow,self.elapsed_time)< -self.hitRange then
					arrow[4] = false
					self.ddr_score = self.ddr_score - self.hitRange*1.5
					
					self.staticArrows[arrow[2]][3]={127,0,0}
				end
			end
		end
		
		self.draw = function(self)
			
			
			
			local backImage = self.back_images[ (math.floor(self.elapsed_time*2)%2)+1]
			love.graphics.draw(backImage, love.graphics.getWidth()/2-backImage:getWidth()/2,
				love.graphics.getHeight()/2-backImage:getHeight()/2,0,1,1)
			
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
			--return self.ddr_score < -100
			return false
		end
		
		self.keypressed = function(self,key)
			pcall(function()
				local arrow_direction = ({left=1,down=2,up=3,right=4})[key]
				
				local extraHit = true
				
				print( string.format("{  %d,%d, {255,255,127}, true },",self.elapsed_time*1000,arrow_direction))
				
				for i=1,#self.arrows do
					local arrow = self.arrows[i]
					local position = self:arrowPosition(arrow,self.elapsed_time)
					
					if position > -self.hitRange and position< self.hitRange and arrow[4]
						and arrow[2]==arrow_direction then
						arrow[4]=false
						extraHit = false
						self.ddr_score = self.ddr_score + (self.hitRange - math.abs(position))
						self.staticArrows[arrow_direction][3]={0,127,0}
					end
				end
				
				if extraHit then
					--self.lost = true
					self.ddr_score = self.ddr_score - self.hitRange
					self.staticArrows[arrow_direction][3]={127,0,0}
				end
				
			end)
		end
		
		self.getScore = function(self)
			return self.ddr_score /((#self.arrows+5)*self.hitRange)
		end
		
		--time in ms, direction, color, was hit
		self.arrows = {
{  416,1, {255,255,127}, true },
{  800,4, {255,255,127}, true },
{  1350,1, {255,255,127}, true },
{  1833,4, {255,255,127}, true },
{  2266,1, {255,255,127}, true },
{  2733,4, {255,255,127}, true },
{  3133,1, {255,255,127}, true },
{  3616,3, {255,255,127}, true },
{  4000,4, {255,255,127}, true },
{  4416,2, {255,255,127}, true },
{  4866,1, {255,255,127}, true },
{  5283,3, {255,255,127}, true },
{  5633,4, {255,255,127}, true },
{  6083,2, {255,255,127}, true },
{  6533,1, {255,255,127}, true },
{  6966,1, {255,255,127}, true },
{  7300,2, {255,255,127}, true },
{  7750,4, {255,255,127}, true },
{  8116,3, {255,255,127}, true },
{  8566,1, {255,255,127}, true },
{  8950,2, {255,255,127}, true },
{  9434,4, {255,255,127}, true },
{  9817,3, {255,255,127}, true },
{  10334,3, {255,255,127}, true },
{  10817,3, {255,255,127}, true },
{  11217,3, {255,255,127}, true },
{  11584,4, {255,255,127}, true },
{  12034,2, {255,255,127}, true },
{  12451,1, {255,255,127}, true },
{  12917,3, {255,255,127}, true },
{  13234,1, {255,255,127}, true },
{  13717,2, {255,255,127}, true },
{  14151,4, {255,255,127}, true },
{  14601,3, {255,255,127}, true },
{  15017,4, {255,255,127}, true },
{  15451,2, {255,255,127}, true },
{  15884,1, {255,255,127}, true },
{  16335,3, {255,255,127}, true },
{  16734,1, {255,255,127}, true },
{  17217,3, {255,255,127}, true },
{  17634,1, {255,255,127}, true },
{  18034,3, {255,255,127}, true },
{  18468,1, {255,255,127}, true },
{  18917,2, {255,255,127}, true },
{  19301,4, {255,255,127}, true },
{  19734,3, {255,255,127}, true },
{  20134,4, {255,255,127}, true },
{  20584,3, {255,255,127}, true },
{  20967,4, {255,255,127}, true },
{  21351,3, {255,255,127}, true },
{  21717,4, {255,255,127}, true },
{  22151,2, {255,255,127}, true },
{  22584,1, {255,255,127}, true },
{  23018,3, {255,255,127}, true },
{  23401,1, {255,255,127}, true },
{  23884,2, {255,255,127}, true },
{  24368,3, {255,255,127}, true },
{  24768,1, {255,255,127}, true },
{  25252,2, {255,255,127}, true },
{  25701,3, {255,255,127}, true },
{  26134,1, {255,255,127}, true },
{  26551,2, {255,255,127}, true },
{  26784,4, {255,255,127}, true },
{  27185,3, {255,255,127}, true },
		}
		
		self.staticArrows = {
			{ 0,1, {127,127,127}, true },
			{ 0,2, {127,127,127}, true },
			{ 0,3, {127,127,127}, true },
			{ 0,4, {127,127,127}, true },
		}
		
    end
}