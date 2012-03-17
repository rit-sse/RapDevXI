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
	keys = {"arrows"},
	
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

			--self.image = love.graphics.newImage(basePath.."sprite.png")
			--self.sound = love.audio.newSource(basePath.."sound.mp3")

			self.cracks = {
				love.graphics.newImage(basePath.."crack1.png"),
				love.graphics.newImage(basePath.."crack2.png"),
				love.graphics.newImage(basePath.."crack3.png"),
				love.graphics.newImage(basePath.."crack4.png")
			}

			self.tree = love.graphics.newImage(basePath.."tree.png")

			self.sky = love.graphics.newImage(basePath.."sky.png")

			self.grass = love.graphics.newImage(basePath.."grass.png")

			self.herring = love.graphics.newImage(basePath.."herring.png")

			self.branches = love.graphics.newImage(basePath.."branches.png")

			self.treeChunks = {}
			local i = 1
			for i = 1, 20 do
				self.treeChunks[i] = 0
			end

			self.state = 'cutting'

			--setup quads
			self.crackTop = love.graphics.newQuad(0, 0, 100, 10, 100, 20)
			self.crackBottom = love.graphics.newQuad(0, 10, 100, 10, 100, 20)

			--Aso set up your own initial game state here.
			self.elapsed_time = 0
		end

		self.update = function(self, dt)
			--update is called in between draws. dt is the time in seconds since the last time
			--update was called

			--here we just keep track of how much time has passed
			self.elapsed_time = self.elapsed_time+dt	
		end
		
		self.draw = function(self)
			--here we just put how much time is left in the upper left corner
			-- look at https://love2d.org/wiki/love.graphics for fun drawing stuff 
			love.graphics.print( (self.time_limit-self.elapsed_time).."s left", 0,0)
			love.graphics.draw(self.branches, 150, -50)

			love.graphics.draw(self.tree, 270, 0)


			if self.state == 'cutting' then
				local i = 1
				for i = 1, 20 do
					if self.treeChunks[i] > 3 then
						love.graphics.setColor(0,0,0)
						love.graphics.rectangle('fill', 270, (i-1) * 20, 100, 20)
						love.graphics.setColor(255,255,255)
					elseif self.treeChunks[i] > 0 then
						love.graphics.draw(self.cracks[self.treeChunks[i]], 270, (i-1) * 20)
					end

				end
			elseif self.state == 'falling' then
				--draw top
				--love.graphics


				--draw bottom
			end

			love.graphics.draw(self.herring, 20, 200)
			


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
			local rand = math.random(20)
			self.treeChunks[rand] = self.treeChunks[rand] + 1
			
			if self.treeChunks[rand] == 4 then
				self.fallingSegment = rand
				self.state = 'falling'
				self.treeTop = love.graphics.newQuad(0, 0, 100, rand * 20 + 10, 100, 400)
				self.treeBottom = love.graphics.newQuad(0, rand * 20 + 10, 100, 400 - (rand * 20 + 10), 100, 400)
			end

			print(key.." was pressed")
		end
		
		self.keyreleased = function(self, key)
			print(key.." was released")
		end
	end
}
