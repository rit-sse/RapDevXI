return {
	standalone_difficulty = "medium",
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
	keys = {"space"},
	
	--The longest this game will EVER take. Note: by overriding the isDone method you can end
	--the game sooner. This is just how long until the engine kills your game and asks it for
	--a score by force.
	maxDuration = 15,
	
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
		self.time_limit = ({easy=15, medium=10, hard=6, impossible=4})[info.difficulty]
		self.movement = ({easy=20, medium=5, hard=3, impossible=2})[info.difficulty]
		--Callbacks

		
		self.getReady = function(self, basePath)
			--get ready is called during the splash screen.
			--The intent is to load all sounds and images during getReady

			--Concatenate basePath with any resource names. This makes your game work in both standalone
			--and the main game mode

			--DON'T START SOUNDS IN GET READY! They will begin playing during the splash screen, and
			--be stopped before your game is actually shown

			--self.image = love.graphics.newImage(basePath.."sprite.png")
			--self.sound = love.sound.newSource(basePath.."sound.mp3")

			--Aso set up your own initial game state here.
			self.elapsed_time = 0
			self.victory = false
			
			self.sadbackground = love.graphics.newImage(basePath.."sadbackground.png")
			self.happybackground = love.graphics.newImage(basePath.."happybackground.png")
			self.cloud1 = love.graphics.newImage(basePath.."cloud1.png")
			self.cloud2 = love.graphics.newImage(basePath.."cloud2.png")
			
			self.cloud1_loc = {}
			self.cloud1_loc[0] = love.graphics.getWidth() * 0.03
			self.cloud1_loc[1] = love.graphics.getHeight() * 0.25
			
			self.cloud2_loc = {}
			self.cloud2_loc[0] = love.graphics.getWidth() * 0.70
			self.cloud2_loc[1] = love.graphics.getHeight() * 0.15
			
			self.victory_sound = love.audio.newSource(basePath.."tada.mp3")
			self.rain_sound = love.audio.newSource(basePath.."rain.mp3")
			self.play_victory_sound = false
			self.play_rain_sound = true

		end

		self.update = function(self, dt)
			--here we just keep track of how much time has passed
			self.elapsed_time = self.elapsed_time+dt
			
			--start the rain sound
			if self.play_rain_sound then
			  love.audio.play(self.rain_sound)
			  self.play_rain_sound = false
			end
			
			--if we won, play the victory sound
			if self.play_victory_sound then
			  --halt the rain sound 
			  if not self.play_rain_sound then
			    love.audio.stop(self.rain_sound)
			  end
			  --play victory sound and then set it to not play again
			  love.audio.play(self.victory_sound)
			  self.play_victory_sound = false
			end		
		end
		
		self.draw = function(self)			
			-- if still playing, show the sad background, otherwise 
			-- show the happy background
			if (not self.victory) then
			  love.graphics.draw(self.sadbackground, 0, 0)
			else 
			  love.graphics.draw(self.happybackground, 0, 0)
			end
			
			-- draw the clouds
			love.graphics.draw(self.cloud1, self.cloud1_loc[0], self.cloud1_loc[1])
			love.graphics.draw(self.cloud2, self.cloud2_loc[0], self.cloud2_loc[1])
		end
		
		self.isDone = function(self)
			return self.elapsed_time > self.time_limit
		end
		
		self.getScore = function(self)
			-- return a number -1 to 1. anything > 0 is a "passing" score
      if self.victory then
        return 1
      else
        return -1
      end
		end
		
		self.keypressed = function(self, key)
		  -- if the user hasn't won the game register the space keypress
		  if key == " " and not self.victory then
			  -- move the clouds
			  self.cloud1_loc[0] = self.cloud1_loc[0] - self.movement
			  self.cloud2_loc[0] = self.cloud2_loc[0] + self.movement
			  
			  -- check if the clouds are off of the screen
			  -- if so play the victory sound and end the game early
			  if self.cloud2_loc[0] > love.graphics.getWidth() then
			    self.victory = true
			    self.elapsed_time = self.time_limit - 5
			    self.play_victory_sound = true
			  end
			end
		end

	end
}
