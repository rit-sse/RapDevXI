return {
	standalone_difficulty = "easy",
	difficulties = {"easy", "medium", "hard"},
	PR = "rit",
	keys = {"arrows", "space"},
	maxDuration = 15,
	
	makeGameInstance = function(self, info)
		self.time_limit = ({easy=6.5, medium=7.5, hard=7.5, impossible=8})[info.difficulty]
		
		-- Callbacks
		
		self.getReady = function(self, basePath)
			self.elapsed_time = 0

			-- Set difficulty settings
			self.rows = ({easy=2, medium=3, hard=3, impossible=4})[info.difficulty]
			self.columns = ({easy=4, medium=4, hard=5, impossible=5})[info.difficulty]

			-- Initialize the flowerbed to 0 steps per square
			self.flowerbed = {}
			for i=1,self.columns do
				self.flowerbed[i] = {}
				for j=1,self.rows do
					self.flowerbed[i][j] = 0
				end
			end

			-- Load the audio
			self.music = love.audio.newSource(basePath.."sunlight.mp3")
			self.playing = false

			-- Load the background images
			self.flowerimg = love.graphics.newImage(basePath.."flowers.png")
			self.dirtimg = love.graphics.newImage(basePath.."dirt.png")
			self.skyimg = love.graphics.newImage(basePath.."sky.png")

			-- Set up the player
			self.guy = {}
			self.guy.x = 175
			self.guy.y = 300
			self.guy.curImg = 1
			self.guy.imgs = {
				love.graphics.newImage(basePath.."tiptoe1.png"),
				love.graphics.newImage(basePath.."tiptoe2.png")
			}
		end

		self.update = function(self, dt)
			-- Start the music!
			if not self.playing then
				self.playing = true
				love.audio.play(self.music)
			end

			-- Move the guy
			self.moving = false
			speed = 150.0 * dt
			if love.keyboard.isDown("up") then
				if self.guy.y + 90 > 275 then
					self.guy.y = self.guy.y - speed
				end
				self.moving = true
			end
			if love.keyboard.isDown("down") then
				if self.guy.y + 90 < 400 then
					self.guy.y = self.guy.y + speed
				end
				self.moving = true
			end
			if love.keyboard.isDown("left") then
				if self.guy.x + 25 > 0 then
					self.guy.x = self.guy.x - speed
				end
				self.moving = true
			end
			if love.keyboard.isDown("right") then
				if self.guy.x + 32 < 400 then
					self.guy.x = self.guy.x + speed
				end
				self.moving = true
			end

			-- Update the guy image
			if self.moving then
				self.guy.curImg = (math.floor(self.elapsed_time * 5) % 2) + 1
			end

			self.elapsed_time = self.elapsed_time + dt			
		end
		
		self.draw = function(self)
			love.graphics.draw(self.skyimg, 0, 0, 0, 1, 1)

			-- Draw the ground images
			for i=1,self.columns do
				for j=1,self.rows do
					local curQuad = love.graphics.newQuad(
						(i-1) * (400 / self.columns), (j-1) * (125 / self.rows),
						(400 / self.columns), (125 / self.rows), 400, 125)

					-- Draw a dirt or flower tile based on number of steps
					if self.flowerbed[i][j] < 1 then
						love.graphics.drawq(self.flowerimg, curQuad,
								(i-1) * (400 / self.columns),
								275 + ((j-1) * (125 / self.rows)), 0, 1, 1)
					else
						love.graphics.drawq(self.dirtimg, curQuad,
								(i-1) * (400 / self.columns),
								275 + ((j-1) * (125 / self.rows)), 0, 1, 1)
					end
				end
			end

			-- Draw the guy
			love.graphics.draw(self.guy.imgs[self.guy.curImg], self.guy.x, self.guy.y, 0, 1, 1)

			love.graphics.print(string.format("%2.1fs left", (self.time_limit-self.elapsed_time)), 0, 0)
		end
		
		self.isDone = function(self)
			return self.elapsed_time > self.time_limit
		end
		
		self.getScore = function(self)
			local crushed = true
			for i=1,self.columns do
				for j=1,self.rows do
					if self.flowerbed[i][j] == 0 then
						crushed = false
					end
				end
			end

			if crushed then
				return 1
			else
				return -1
			end
		end
		
		self.keypressed = function(self, key)
			if key == ' ' then
				local tileX = math.floor((self.guy.x + 10) / (400 / self.columns)) + 1
				local tileY = math.floor((self.guy.y + 90 - 275) / (125 / self.rows)) + 1

				if tileX < 1 then tileX = 1 end
				if tileX > self.columns then tileX = self.columns end
				if tileY < 1 then tileY = 1 end
				if tileY > self.rows then tileY = self.rows end

				if tileX >= 1 and tileX <= self.columns and
					tileY >= 1 and tileY <= self.rows then

					-- Increase the tile step count
					self.flowerbed[tileX][tileY] = self.flowerbed[tileX][tileY] + 1
				end
			end
		end
		
		self.keyreleased = function(self, key)
			
		end
	end
}
