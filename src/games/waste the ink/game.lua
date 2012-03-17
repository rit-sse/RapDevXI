return {
	standalone_difficulty = "easy",
	--Here go all of the static info values for our game
	--  Remember a comma after each entry, as we are in a table initialization
	
	--Difficulties should be a list of difficulties this game can be.
	--For Example:
	--  If your game going to be a medium difficulty, and can't
	--  be made easier or harder just make it {"medium"}
	
	--  If your game can be made to be easy or impossible,
	--  make it {"easy","impossible"}
	difficulties = {"easy","medium","hard","impossible"},
	
	--PR is how appropriate your game is. Valid values are:
	--  "child"	 approprate to show at imagine RIT
	--  "rit"	   approprate to show to other RIT students
	--  "sse"	   approprate only to show to SSE members
	--  "deans car" this game will be deleted out of the repository on Monday before anyone sees it who wasn't here
	--			  (grab your own local copy)
	PR = "child",
	
	--Keys is an indication to the user that says where to put their hands.
	--It needs to be a list with any values from:
	--  {"arrows","wasd","full keyboard","mouse","space"}
	keys = {"arrows", "space"},
	
	--The longest this game will EVER take. Note: by overriding the isDone method you can end
	--the game sooner. This is just how long until the engine kills your game and asks it for
	--a score by force.
	maxDuration = 30,
	
	--This is where you define what an actual running version of your game is.
	--The first parameter is a table you must fill in with your desired callbacks,
	--as well as any user data. Info is a table with key/values:
	--  difficulty = a value from the difficulties list defined above. You should change at least some aspect
	--			   of how your game is initialized based on this difficulty.
	--
	--  player = some string naming the current player. Don't do anything with this but display it, if even that.
	
	makeGameInstance = function(self, info)
		--Each game may choose how to scale difficulty. The template imposes a time limit
		--that is modified by the difficulty of the game
		self.times = {easy=20, medium=12, hard=10, impossible=7}
		self.time_limit = self.times[info.difficulty]

		
		
		--Callbacks

		
		self.getReady = function(self, basePath)
			--get ready is called during the splash screen.
			--The intent is to load all sounds and images during getReady

			--Concatenate basePath with any resource names. This makes your game work in both standalone
			--and the main game mode

			--DON'T START SOUNDS IN GET READY! They will begin playing during the splash screen, and
			--be stopped before your game is actually shown

			--self.image = love.graphics.newImage(basePath.."sprite.png")
			self.img = {}
			self.img.ink = love.graphics.newImage(basePath.."ink_full.png")
			self.img.holder = love.graphics.newImage(basePath.."ink_holder.png")
			self.img.dot = love.graphics.newImage(basePath.."dot.png")
			self.img.pen = love.graphics.newImage(basePath.."pen.png")

			--self.audio = love.audio.newSource(basePath.."audio.mp3")
			self.aud = {}
			self.aud.one = love.audio.newSource(basePath.."one.ogg")
			self.aud.two = love.audio.newSource(basePath.."two.ogg")
			self.aud.three = love.audio.newSource(basePath.."three.ogg")
			self.aud.four = love.audio.newSource(basePath.."four.ogg")
			self.aud.background = love.audio.newSource(basePath.."background_noise.ogg")
			self.aud.background:setLooping(true)

			--Aso set up your own initial game state here.
			self.elapsed_time = 0

			self.difficulties = {easy=5, medium=6, hard=6, impossible=7}

			self.aud_num = 1
			self.aud_num_start = 1
			self.aud_num_max = 4
			self.ink_percent = 1.0

			self.dots = {}
			self.loc = {x=0, y=0}

			self.first_update = true
		end

		self.update = function(self, dt)
			--update is called in between draws. dt is the time in seconds since the last time
			--update was called

			--here we just keep track of how much time has passed
			self.elapsed_time = self.elapsed_time+dt

			dt = dt * 35

			if self.first_update then 
				self.first_update = false
				love.audio.play(self.aud.background)
			end

			bt = love.graphics.getHeight() - 10
			rt = love.graphics.getWidth() - 10

			speed = (self.difficulties[info.difficulty] / 2)*dt

			if love.keyboard.isDown("up") then
				if self.loc.y > 0 then
					self.loc.y = self.loc.y - speed
				end
			end
			if love.keyboard.isDown("down") then
				if self.loc.y < bt then
					self.loc.y = self.loc.y + speed
				end
			end
			if love.keyboard.isDown("left") then
				if self.loc.x > 0 then
					self.loc.x = self.loc.x - speed
				end
			end
			if love.keyboard.isDown("right") then
				if self.loc.x < rt then
					self.loc.x = self.loc.x + speed
				end
			end
		end
		
		self.draw = function(self)
			btl = love.graphics.getHeight()
			tpr = love.graphics.getWidth()

			love.graphics.setColor(255,255,255)
			love.graphics.rectangle('fill', 0, 0, tpr, btl)

			--here we just put how much time is left in the upper left corner
			-- look at https://love2d.org/wiki/love.graphics for fun drawing stuff
			love.graphics.print( (self.time_limit-self.elapsed_time).."s left", 0,0)

			ink_height = 150
			ink_width = 50
			--love.graphics.draw(image, x_pos, y_pox, rotation, x_percent, y_percent)
			for index, dot in ipairs(self.dots) do
				love.graphics.draw(self.img.dot, dot.x, dot.y)
			end
			love.graphics.draw(self.img.pen, self.loc.x, self.loc.y)
			--love.graphics.rectangle('fill', 0, btl-ink_height, ink_width, ink_height)
			love.graphics.draw(self.img.ink, 0, btl-(ink_height*self.ink_percent), 0, 1, self.ink_percent)
			love.graphics.draw(self.img.holder, 0, btl-ink_height, 0, 1, 1)
		end
		
		self.isDone = function(self)
			--This can return true to have the game end sooner that the time_limit
			--set for the type of game.
	
			--we are done when we are out of time.
			return (self.elapsed_time > self.time_limit) or (self.ink_percent <= 0.0)
		end
		
		self.getScore = function(self)
			--return a number -1 to 1. anything >0 is a "passing" score

			if self.ink_percent <= 0.0 then 
				return 1
			end

			return -1 --the player always looses. 
		end
		
		self.keypressed = function(self, key)
			
			print(key.." was pressed")

			dif = self.difficulties[info.difficulty]

			half_dot = 10
			q_dot = 5

			if key == " " then
				--place ink at that location
				dot = {x=self.loc.x-half_dot, y=self.loc.y-half_dot}
				for index, dot_ in ipairs(self.dots) do
					if dot.x == dot_.x and dot.y == dot_.y then
						return
					end
				end
				self.ink_percent = self.ink_percent - (.1/dif)
				table.insert(self.dots, dot)
				self:play_sound()
			end
		end
		
		self.play_sound = function(self)
			if self.aud_num == 1 then
				love.audio.play(self.aud.one)
			end
			if self.aud_num == 2 then
				love.audio.play(self.aud.two)
			end
			if self.aud_num == 3 then
				love.audio.play(self.aud.three)
			end
			if self.aud_num == 4 then
				love.audio.play(self.aud.four)
			end

			self.aud_num = self.aud_num + 1
			if self.aud_num > self.aud_num_max then
				self.aud_num = self.aud_num_start
			end
		end

		self.keyreleased = function(self, key)
			print(key.." was released")
		end
	end
}
