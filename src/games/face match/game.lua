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
	PR = "rit",
	
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
		self.time_limit = ({easy=15, medium=10, hard=8, impossible=4})[info.difficulty]
		
		--Callbacks

		
		self.getReady = function(self, basePath)
			--get ready is called during the splash screen.
			--The intent is to load all sounds and images during getReady

			--Concatenate basePath with any resource names. This makes your game work in both standalone
			--and the main game mode

			--DON'T START SOUNDS IN GET READY! They will begin playing during the splash screen, and
			--be stopped before your game is actually shown

			--Load all the faces
			self.faces = {
				love.graphics.newImage(basePath.."faces/megusta.png"),
				love.graphics.newImage(basePath.."faces/okay.png"),
				love.graphics.newImage(basePath.."faces/derp.png")
			}

			--Setup all the face quads
			self.faceQuads = {
				love.graphics.newQuad(0, 0, 300, 100, 300, 300),
				love.graphics.newQuad(0, 100, 300, 100, 300, 300),
				love.graphics.newQuad(0, 200, 300, 100, 300, 300)
			}

			--Setup vars for movement of faces
			self.topDelta = 400
			self.topPos = 0

			self.midDelta = 500
			self.midPos = 0

			self.bottomDelta = 600
			self.bottomPos = 0

			--state will be one of {'directions', 'spinTMB', 'stoppingT', 'spinMB',
			-- 'stoppingM', 'spinB', 'stoppingB', 'end'}
			self.state = 'spinTMB'

			--self.image = love.graphics.newImage(basePath.."sprite.png")
			--self.sound = love.sound.newSource(basePath.."sound.mp3")

			--Aso set up your own initial game state here.
			self.elapsed_time = 0
		end

		self.update = function(self, dt)
			--update is called in between draws. dt is the time in seconds since the last time
			--update was called

			--here we just keep track of how much time has passed
			self.elapsed_time = self.elapsed_time+dt
			self.topPos = (self.topPos + (self.topDelta * dt)) % 1200
			self.midPos = (self.midPos + (self.midDelta * dt)) % 1200
			self.bottomPos = (self.bottomPos + (self.bottomDelta * dt)) % 1200
		end
		
		self.draw = function(self)
			--here we just put how much time is left in the upper left corner
			-- look at https://love2d.org/wiki/love.graphics for fun drawing stuff
			love.graphics.print( (self.time_limit-self.elapsed_time).."s left", 0,0)
			love.graphics.setBackgroundColor(150, 150, 150)

			--Draw top sections
			love.graphics.drawq(self.faces[1], self.faceQuads[1], self.topPos + 50, 50)
			love.graphics.drawq(self.faces[2], self.faceQuads[1], self.topPos - 400 + 50, 50)
			love.graphics.drawq(self.faces[3], self.faceQuads[1], self.topPos - 800 + 50, 50)
			love.graphics.drawq(self.faces[1], self.faceQuads[1], self.topPos - 1200 + 50, 50)

			--Draw mid sections
			love.graphics.drawq(self.faces[1], self.faceQuads[2], -self.midPos + 50, 150)
			love.graphics.drawq(self.faces[2], self.faceQuads[2], -self.midPos + 400 + 50, 150)
			love.graphics.drawq(self.faces[3], self.faceQuads[2], -self.midPos + 800 + 50, 150)
			love.graphics.drawq(self.faces[1], self.faceQuads[2], -self.midPos + 1200 + 50, 150)

			--Draw bottom sections
			love.graphics.drawq(self.faces[1], self.faceQuads[3], self.bottomPos + 50, 250)
			love.graphics.drawq(self.faces[2], self.faceQuads[3], self.bottomPos - 400 + 50, 250)
			love.graphics.drawq(self.faces[3], self.faceQuads[3], self.bottomPos - 800 + 50, 250)
			love.graphics.drawq(self.faces[1], self.faceQuads[3], self.bottomPos - 1200 + 50, 250)

			--love.graphics.drawq(self.faces[2], self.faceQuads[1], 50, 50)
			--love.graphics.drawq(self.faces[1], self.faceQuads[2], 50, 150)
			--love.graphics.drawq(self.faces[3], self.faceQuads[3], 50, 250)
		end
		
		self.isDone = function(self)
			--This can return true to have the game end sooner that the time_limit
			--set for the type of game.
	
			--we are done when we are out of time.
			return self.elapsed_time > self.time_limit
		end
		
		self.getScore = function(self)
			--return a number -1 to 1. anything >0 is a "passing" score

			return -1 --the player always looses. 
		end
		
		self.keypressed = function(self, key)
			if key == ' ' then
				if self.state == 'spinTMB' then
					--local topTarget = Math.floor(self.topPos / 400) 
					--self.topPos = 
					self.state = 'stoppingT'
				elseif self.state == 'spinMB' then
					self.state = 'stoppingM'
				elseif self.state == 'spinB' then
					self.state = 'stoppingB'
				end
			end
			print(key.." was pressed")
		end
		
		self.keyreleased = function(self, key)
			print(key.." was released")
		end
	end
}
