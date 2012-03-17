return {
	standalone_difficulty = "easy",

	difficulties = {"easy","medium","hard"},
	
	PR = "child",
	
	keys = {"numbers"},
	
	maxDuration = 15,
	
	makeGameInstance = function(self, info)
		self.time_limit = 15
		self.range = ({easy={1,6}, medium={7,12}, hard={13,18}})[info.difficulty]
		self.lost = false
		self.score = 0
		
		self.getReady = function(self, basePath)
			correct = {}
			self.pNums = {}
			self.derivative = love.graphics.newImage(basePath.."derivative.png")
			for i = 1, 4 do 
				self.pNums[i] = love.graphics.newImage(basePath..i..".png")
			end
			for line in io.lines(basePath.."answers.txt") do
				table.insert(correct, line)
			end
			self.equations ={}
			for i = 1, 18 do
				self.equations[i] = {image = love.graphics.newImage(basePath.."q"..i..".png"), answer=correct[i], choices={}}
				for j = 1, 4 do
					self.equations[i].choices[j] = love.graphics.newImage(basePath.."q"..i.."-"..j..".png")
				end
			end
			self.elapsed_time = 0
			math.randomseed(os.time())
			self.cur = math.random(self.range[1], self.range[2])
			self.solved = false
		end

		self.update = function(self, dt)
			if self.elapsed_time > (self.score+1)*5  then
				self.lost = true
			elseif self.solved then
				self.cur = math.random(self.range[1], self.range[2])
				self.solved = false
			end
			self.elapsed_time = self.elapsed_time+dt			
		end
		
		self.draw = function(self)
			self:calcTotalHeight()
			x = (love.graphics.getWidth() -self.derivative:getWidth()/2)/2
			y = (love.graphics.getHeight() - self.height)/2 
			love.graphics.draw(self.derivative, x, y,0,.5,.5)
			y = y + self.derivative:getHeight()/2 + 30
			x = (love.graphics.getWidth() - self.equations[self.cur].image:getWidth())/2
			numx = x - 50
			love.graphics.draw(self.equations[self.cur].image, x, y,0,.5,.5)
			y = y + self.equations[self.cur].image:getHeight()/2 +20
			for i, pic in ipairs(self.equations[self.cur].choices) do
				love.graphics.draw(self.pNums[i], numx, y,0,.5,.5)
				love.graphics.draw(pic, x, y,0,.5,.5)
				y = y + pic:getHeight()/2 + 15
			end
			love.graphics.print( (self.time_limit-self.elapsed_time).."s left", 0,0)
		end

		self.calcTotalHeight = function(self)
			self.height = self.derivative:getHeight()/2 + self.equations[self.cur].image:getHeight()/2 +50
			for i, pic in ipairs(self.equations[self.cur].choices) do
				self.height = self.height + pic:getHeight()/2 + 15
			end
		end
		
		self.isDone = function(self)
			return self.elapsed_time > self.time_limit or self.lost or self.score == 3
		end
		
		self.getScore = function(self)
			return self.lost and -1 or 1 
		end
		
		self.keypressed = function(self, key)
			print(key.." was pressed")
			valid = false
			if key == "1" or key == "2" or key == "3" or key == "4" then
				valid = true
			end
			if valid then
				if key == self.equations[self.cur].answer then
					self.solved = true
					self.score = self.score + 1
				else
					self.lost = true
				end
			end
		end
	end
}
