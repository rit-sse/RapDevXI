return {
	standalone_difficulty = "easy",
	difficulties = {"medium"},
	PR = "child",
	keys = {"arrows"},
	maxDuration = 15,
	
	
	makeGameInstance = function(self, info)
		--Each game may choose how to scale difficulty. The template imposes a time limit
		--that is modified by the difficulty of the game
		self.time_limit = ({easy=15, medium=10, hard=8, impossible=4})[info.difficulty]
		
		self.getReady = function(self, basePath)
			self.lines = {
				{text="Hello World",char="l", cover=50,width=5, cloc = 55, target = 50},
				{text="Rap Dev!",char="p", cover=43,width=20, cloc = 48, target = 42},
				{text="SSE Rocks!",char="R", cover=66,width=16, cloc = 60, target = 66}
			}
			self.selected = 1
			self.elapsed_time = 0
			self.done = false
			self.music = love.audio.newSource(basePath.."music.mp3")
			self.play = false
		end

		self.update = function(self, dt)			
			if not self.play then
				self.play = true
				love.audio.play(self.music)
			end
		end
		
		self.draw = function(self)
			local lineHeight = 30
			love.graphics.setColor(255,255,255)
			love.graphics.print("Fix The Kern ng",10,10,0,2,2)
			love.graphics.print("i",165,10,0,2,2)
			love.graphics.print("Pres space when done",10,love.graphics.getHeight()-30,0,2,2)
			
			
			for i=1,#self.lines do
				local line = self.lines[i]
				local color = (i==self.selected) and 255 or 127
				local basey = 20
				
				love.graphics.setColor(color,color,color)
				love.graphics.print(line.text, 10, lineHeight*i+basey, 0,2,2)
				love.graphics.setColor(0,0,0)
				love.graphics.rectangle("fill",line.cover,lineHeight*i+basey,line.width, 30)
				
				
				
				love.graphics.setColor(color,0,0)
				love.graphics.print(line.char, line.cloc,lineHeight*i+basey, 0,2,2)
			end
		end
		
		
		self.getScore = function(self)
			local off = 0
			
			for i=1,#self.lines do
				off = off + math.abs(self.lines[i].cloc - self.lines[i].target)
			end
			
			if (2-off)/2 >1 then return 1 end
			if (2-off)/2 <-1 then return -1 end
			
			return (2-off)/2
		end
		
		self.keypressed = function(self, key)
			if key=='left' then
				self.lines[self.selected].cloc = self.lines[self.selected].cloc-1
			end
			if key=='right' then
				self.lines[self.selected].cloc = self.lines[self.selected].cloc+1
			end
			if key=='down' and self.selected < #self.lines then
				self.selected = self.selected+1
			end
			if key=='up' and self.selected > 1 then
				self.selected = self.selected-1
			end
			if key==' ' then
				self.done = true
			end
		end
		
		self.isDone = function(self)
			return self.done
		end
		
	end
}
