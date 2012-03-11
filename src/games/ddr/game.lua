return {

	difficulties = {"easy","medium","hard","impossible"},
    PR = "child",
	keys = {"arrows"},
	maxDuration = 30,
	makeGameInstance = function(self, info)
		self.elapsed_time = 0
		self.arrowSpeed = ({easy=0.15, medium=0.15, hard=0.15, impossible=0.2})[info.difficulty]
		self.hitRange = ({easy=50, medium=40, hard=20, impossible=10})[info.difficulty]
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
			self.sound = love.audio.newSource(basePath.."heman30.mp3")
			self.playing = false
			self.ddr_score = 5*self.hitRange
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
{  435,1,   {255,255,127}, true },{  768,1,   {255,255,127}, true },{  1151,1,  {255,255,127}, true },{  1501,1,  {255,255,127}, true },{  1901,1,  {255,255,127}, true },{  2285,1,  {255,255,127}, true },{  2751,1,  {255,255,127}, true },{  3034,4,  {127,255,127}, true },{  3251,3,  {255,255,127}, true },{  3401,1,  {255,255,127}, true },{  3601,2,  {0,255,127}, true },{  4018,3,  {255,0,127}, true },{  4384,1,  {0,255,127}, true },{  4751,2,  {255,0,127}, true },{  4968,3,  {0,255,127}, true },{  5168,1,  {255,0,127}, true },{  5351,2,  {0,255,127}, true },{  5651,3,  {255,0,127}, true },{  5934,1,  {0,255,127}, true },{  6334,4,  {127,0,127}, true },{  6551,3,  {0,255,127}, true },{  6984,1,  {255,0,127}, true },{  7184,3,  {0,255,127}, true },{  7385,1,  {255,0,127}, true },{  7534,2,  {0,255,127}, true },{  8018,3,  {255,0,127}, true },{  8368,1,  {0,255,127}, true },{  8834,4,  {127,255,127}, true },{  9284,3,  {255,255,127}, true },{  9601,2,  {255,255,127}, true },{  9851,3,  {255,255,127}, true },{  10068,1, {255,127,127}, true },
{  10484,1, {255,127,127}, true },
{  10901,1, {255,127,127}, true },
{  11301,1, {255,127,127}, true },
{  11501,4, {127,255,127}, true },
{  11735,3, {255,255,127}, true },
{  11918,1, {255,255,127}, true },
{  12151,2, {255,255,127}, true },
{  12401,4, {127,255,127}, true },
{  12635,3, {255,255,127}, true },
{  12901,3, {255,255,127}, true },
{  13185,4, {127,255,127}, true },
{  13368,2, {255,255,127}, true },
{  13618,1, {255,255,127}, true },
{  13934,3, {255,255,127}, true },
{  14401,1, {0,255,127}, true },
{  14884,4, {255,255,127}, true },
{  15401,1, {255,127,127}, true },
{  15868,4, {127,255,0}, true },
{  16335,1, {255,255,0}, true },
{  16619,4, {0,127,127}, true },
{  16919,3, {255,255,127}, true },
{  17052,1, {255,255,127}, true },
{  17252,2, {255,255,127}, true },
{  17619,3, {0,255,127}, true },
{  17786,1, {255,255,127}, true },
{  18002,2, {255,127,127}, true },
{  18202,4, {255,255,127}, true },
{  18419,3, {127,255,127}, true },
{  18585,1, {255,255,127}, true },
{  18836,2, {255,255,127}, true },
{  19036,4, {0,255,127}, true },
{  19269,3, {255,255,127}, true },
{  19552,1, {255,127,127}, true },
{  20002,2, {127,255,127}, true },
{  20269,3, {255,255,127}, true },
{  20619,1, {255,0,127}, true },
{  20852,4, {255,255,127}, true },
{  21102,3, {255,0,127}, true },
{  21285,1, {255,255,127}, true },
{  21685,2, {0,255,127}, true },
{  22119,3, {0,255,127}, true },
{  22452,2, {0,255,127}, true },
{  23002,1, {0,255,127}, true },
{  23402,4, {255,255,127}, true },
{  23652,3, {255,255,127}, true },
{  24152,1, {255,255,127}, true },
{  24452,4, {255,0,127}, true },
{  24702,3, {255,0,127}, true },
{  24919,1, {255,0,127}, true },
{  25085,2, {255,0,127}, true },
{  25336,4, {255,0,127}, true },
{  25586,3, {255,0,127}, true },
{  26002,1, {255,0,127}, true },
{  26519,4, {255,0,0}, true },
{  26819,3, {255,0,0}, true },
{  27235,1, {255,0,0}, true },
		}
		
		self.staticArrows = {
			{ 0,1, {127,127,127}, true },
			{ 0,2, {127,127,127}, true },
			{ 0,3, {127,127,127}, true },
			{ 0,4, {127,127,127}, true },
		}
		
    end
}