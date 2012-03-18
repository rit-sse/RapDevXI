return {
	standalone_difficulty = "easy",
	difficulties = {"easy", "medium", "hard", "impossible"},
	PR = "child",
	keys = {"space"},
	maxDuration = 6,
	
	makeGameInstance = function(self, info)

		-- Callbacks

		self.getReady = function(self, basePath)
			-- Difficulty parameters
			self.toastVel = ({easy = 275.0, medium = 275.0, hard = 275.0,
				impossible = 185.0})[info.difficulty]
			self.toastAcel = ({easy = 500.0, medium = 500.0, hard = 500.0,
				impossible = 0})[info.difficulty]
			self.toastType = ({easy = "normal", medium = "bite",
				hard = "eaten", impossible = "eaten"})[info.difficulty]


			-- Load audio clips
			self.popup = love.audio.newSource(basePath.."pop.mp3")
			self.music = love.audio.newSource(basePath.."flea.mp3")
			self.playing = false

			-- Scale all the graphics
			self.scale = 4

			self.elapsed_time = 0
			self.timeout = 0
			
			self.launched = false
			self.caught = false
			self.done = false

			-- Determine the toast launch time
			math.randomseed(os.time())
			self.launch_time = math.random(1.0, 1.75)

			-- Set up the background
			self.background = love.graphics.newImage(basePath.."background.png")
			self.background:setFilter("nearest", "nearest")
			
			-- Set up the toast
			self.toast = {}
			self.toast.x = 37
			self.toast.y = 66
			self.toast.yVel = 0
			self.toast.img = love.graphics.newImage(basePath.."toast.png")
			self.toast.img:setFilter("nearest", "nearest")
			self.toast.bite = {}
			self.toast.bite.img = love.graphics.newImage(basePath.."toast-bite.png")
			self.toast.bite.img:setFilter("nearest", "nearest")
			self.toast.eaten = {}
			self.toast.eaten.img = love.graphics.newImage(basePath.."toast-eaten.png")
			self.toast.eaten.img:setFilter("nearest", "nearest")

			-- Set up the toaster
			self.toaster = {}
			self.toaster.x = 16
			self.toaster.y = 61
			self.toaster.img = love.graphics.newImage(basePath.."toaster.png")
			self.toaster.img:setFilter("nearest", "nearest")
			self.toaster.on = true

			self.toaster.handle = {}
			self.toaster.handle.x = 68
			self.toaster.handle.y = 85
			self.toaster.handle.yVel = 0

			self.toaster.light = {}
			self.toaster.light.x = 63
			self.toaster.light.y = 86

			-- Set up the hand
			self.hand = {}
			self.hand.img = love.graphics.newImage(basePath.."hand.png")
			self.hand.img:setFilter("nearest", "nearest")
			self.hand.x = 70
			self.hand.y = 44
			self.hand.thumb_up = true
			
			self.hand.thmu = {}
			self.hand.thmu.img = love.graphics.newImage(basePath.."thumb-up.png")
			self.hand.thmu.img:setFilter("nearest", "nearest")
			self.hand.thmu.x = 11
			self.hand.thmu.y = -4

			self.hand.thmd = {}
			self.hand.thmd.img = love.graphics.newImage(basePath.."thumb-down.png")
			self.hand.thmd.img:setFilter("nearest", "nearest")
			self.hand.thmd.x = 11
			self.hand.thmd.y = 0
		end

		self.update = function(self, dt)
			-- Start the music!
			if not self.playing then
				self.playing = true
				love.audio.play(self.music)
			end

			-- Determine when to launch the toast
			if not self.launched and self.elapsed_time > self.launch_time then
				love.audio.play(self.popup)
				self.launched = true
				self.toast.yVel = self.toastVel
				self.toaster.handle.yVel = 100.0
				self.toaster.on = false
			end

			-- Update the toast position
			if not self.done and self.launched and not self.caught then
				self.toast.y = self.toast.y - (self.toast.yVel * dt)
				self.toast.yVel = self.toast.yVel - (self.toastAcel * dt)

				-- Check if the toast has gone back into the toaster
				if self.toast.y > 66 then
					self.toast.y = 66
					self.toast.yVel = 0

					-- Quit in just a litte bit
					self.timeout = 0.75
					self.done = true

				-- Check if the toast has gone off the screen in impossible mode
				elseif self.toastAcel == 0 and self.toast.y < -23 then
					self.toast.yVel = 0

					-- Quit in just a little bit
					self.timeout = 0.75
					self.done = true
				end
			end

			-- Update the toaster handle position
			if self.toaster.handle.yVel > 0 then
				self.toaster.handle.y = self.toaster.handle.y - (self.toaster.handle.yVel * dt)

				-- Stop the handle when its reached the top
				if self.toaster.handle.y < 74 then
					self.toaster.handle.y = 74
					self.toaster.handle.yVel = 0
				end
			end

			-- Update the timeout if needed
			if self.timeout > 0 then
				self.timeout = self.timeout - dt
				
				-- Quit when timeout is complete
				if self.timeout < 0 then
					self.timeout = 0
				end
			end

			-- Keep track of how much time has passed
			self.elapsed_time = self.elapsed_time + dt			
		end
		
		self.draw = function(self)
			-- Draw the background
			love.graphics.draw(self.background, 0, 0, 0, self.scale, self.scale, 0, 0)

			-- Draw the hand base
			love.graphics.draw(self.hand.img, self.hand.x * self.scale,
				self.hand.y * self.scale, 0, self.scale, self.scale, 0, 0)

			-- Draw the toast
			if self.toastType == "normal" then
				love.graphics.draw(self.toast.img, self.toast.x * self.scale,
					self.toast.y * self.scale, 0, self.scale, self.scale, 0, 0)
			elseif self.toastType == "bite" then
				love.graphics.draw(self.toast.bite.img, self.toast.x * self.scale,
					self.toast.y * self.scale, 0, self.scale, self.scale, 0, 0)
			elseif self.toastType == "eaten" then
				love.graphics.draw(self.toast.eaten.img, self.toast.x * self.scale,
					self.toast.y * self.scale, 0, self.scale, self.scale, 0, 0)
			end

			-- Draw the thumb
			if self.hand.thumb_up then
				love.graphics.draw(self.hand.thmu.img,
					(self.hand.x + self.hand.thmu.x) * self.scale,
					(self.hand.y + self.hand.thmu.y) * self.scale,
					0, self.scale, self.scale, 0, 0)
			else
				love.graphics.draw(self.hand.thmd.img,
					(self.hand.x + self.hand.thmd.x) * self.scale,
					(self.hand.y + self.hand.thmd.y) * self.scale,
					0, self.scale, self.scale, 0, 0)
			end

			-- Draw the toaster
			love.graphics.draw(self.toaster.img, self.toaster.x * self.scale,
				self.toaster.y * self.scale, 0, self.scale, self.scale, 0, 0)
			love.graphics.setColor(0, 0, 0)

			-- Draw the toaster handle
			love.graphics.rectangle("fill", self.toaster.handle.x * self.scale,
				self.toaster.handle.y * self.scale, 2 * self.scale, self.scale)

			-- Draw the toaster light
			if self.toaster.on then
				love.graphics.setColor(255, 147, 60)
			else
				love.graphics.setColor(148, 79, 30)
			end
			love.graphics.rectangle("fill", self.toaster.light.x * self.scale,
				self.toaster.light.y * self.scale, 2 * self.scale, self.scale)
		end
		
		self.isDone = function(self)
			return (self.done and self.timeout == 0)
		end
		
		self.getScore = function(self)
			if self.caught then
				return 1
			else
				return -1
			end
		end
		
		self.keypressed = function(self, key)
			-- Attempt to catch the toast if space is pressed
			if key == ' ' then
				-- Extend the arm
				self.hand.x = 42

				-- Check to see if we caught the toast!
				if (self.toastType == "normal" and self.toast.y >= 23
									and self.toast.y <= 51) or
					(self.toastType == "bite" and self.toast.y >= 23
									and self.toast.y <= 42) or
					(self.toastType == "eaten" and self.toast.y >= 23
									and self.toast.y <= 36) then
					
					-- Close the thumb, stop the toast movement
					self.toast.yVel = 0
					self.caught = true
					self.done = true
					self.timeout = 0.75
				end

				self.hand.thumb_up = false
			end

			if key == 'a' then
				self.hand.thumb_up = not self.hand.thumb_up
			end
		end
		
		self.keyreleased = function(self, key)
			
		end
	end
}
