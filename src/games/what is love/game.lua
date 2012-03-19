return {
	standalone_difficulty = "easy",
	difficulties = {"easy", "medium"},
	PR = "child",
	keys = {"arrows"},
	maxDuration = 8,
	
	makeGameInstance = function(self, info)
		self.time_limit = ({easy=8, medium=8, hard=8, impossible=8})[info.difficulty]
		
		-- Callbacks
		
		self.getReady = function(self, basePath)
			self.bob = false
			self.bob_time = 0
			self.elapsed_time = 0
			self.bob_chain = ({easy = 5, medium = 10})[info.difficulty]
			
			self.back_images = {
				love.graphics.newImage(basePath.."1.png"),
				love.graphics.newImage(basePath.."2.png"),
				love.graphics.newImage(basePath.."3.png"),
				love.graphics.newImage(basePath.."4.png"),
				love.graphics.newImage(basePath.."5.png"),
				love.graphics.newImage(basePath.."6.png"),
				love.graphics.newImage(basePath.."7.png"),
				love.graphics.newImage(basePath.."8.png")
			}

			self.bob_img = love.graphics.newImage(basePath.."bob.png")

			self.key = {
				love.graphics.newImage(basePath.."right.png"),
				love.graphics.newImage(basePath.."blank.png")
			}

			self.playing = false
			self.music = love.audio.newSource(basePath.."love.mp3")
		end

		self.update = function(self, dt)
			-- Start the music
			if not self.playing then
				self.playing = true
				love.audio.play(self.music)
			end

			if self.bob then
				if self.bob_time > 0.44 then
					self.bob_time = 0
					self.bob = false
				end
				self.bob_time = self.bob_time + dt
			end

			self.elapsed_time = self.elapsed_time + dt			
		end
		
		self.draw = function(self)
			-- Draw the background
			local backImage = nil
			if self.bob then
				backImage = self.back_images[(math.floor(self.bob_time * 17) % 8 ) + 1]
			else
				backImage = self.back_images[1]
			end
			love.graphics.draw(backImage, love.graphics.getWidth() / 2 - backImage:getWidth() * 1.5 / 2,
				love.graphics.getHeight() / 2 - backImage:getHeight() * 1.5 / 2, 0, 1.5, 1.5)


			if self.bob_chain > 0 then
				-- Draw the bobs required
				for i=0,self.bob_chain - 1 do
					love.graphics.draw(self.bob_img, 10 + (i * 30), 355, 0, 1, 1)
				end

				-- Draw the arrow key
				love.graphics.draw(self.key[(math.floor(self.elapsed_time * 5) % 2) + 1], 355, 345, 0, 0.75, 0.75)
			end
			
		end
		
		self.isDone = function(self)
			return self.elapsed_time > self.time_limit
		end
		
		self.getScore = function(self)
			if self.bob_chain > 0 then
				return -self.bob_chain
			else
				return 1
			end
		end
		
		self.keypressed = function(self, key)
			if key == "right" then
				-- Trigger a head bob if one is not in motion
				if not self.bob then
					self.bob = true
				end

				-- Check if the bob was on beat
				local time = (self.elapsed_time + 0.4) % 0.48
				if time > 0.43 or time < 0.07 then
					self.bob_chain = self.bob_chain - 1
				end
			end
		end
		
		self.keyreleased = function(self, key)
			
		end
	end
}
