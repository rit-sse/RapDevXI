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
			--self.sound = love.sound.newSource(basePath.."sound.mp3")

			self:getAudioReady( basePath.."audio/" )
			self:getTexturesReady( basePath.."textures/" )

			--Also set up your own initial game state here.
			self.elapsed_time = 0
            self.score = 1
            self.player = {}
            --self.player.img = love.graphics.newImage("...") --todo
            self.playerX = 20
            self.playerY = 200

            self.enemy = {}
            --self.enemy.img = love.graphics.newImage("...") --todo
            self.enemyX = 320
            self.enemyY = 200
            self.enemy.bullets = {}
            
            self.makeBullet = function(self)
                local b = {}
                b.x = self.enemyX
                b.y = self.enemyY + 20
                table.insert(self.enemy.bullets, b)
            end
            
		end

		self.getAudioReady = function( self, audioPath )
			--Looping audio
			self.backgroundLoopStarted= false
			self.backgroundLoop = love.audio.newSource( audioPath.."voodoo_loop.ogg" )
			self.backgroundLoop:setLooping( true )
		end

		self.getTexturesReady = function( self, texturePath )
			-- Background textures
			i = 1

			while love.filesystem.exists( texturePath.."tex"..i..".png" ) do
				local backgroundTexture = texturePath.."tex"..i..".png"
				print( backgroundTexture )
				i = i + 1
			end

			-- Sprites
		end

		self.update = function(self, dt)
			--update is called in between draws. dt is the time in seconds since the last time
			--update was called

			if not self.backgroundLoopStarted then
				love.audio.play( self.backgroundLoop )
			end

			--here we just keep track of how much time has passed
			self.elapsed_time = self.elapsed_time+dt

            --enemy AI
            if self.playerY > self.enemyY then
                self.enemyY = self.enemyY + 10*dt
            else
                self.enemyY = self.enemyY - 10*dt
            end


		end
		
		self.draw = function(self)
			--here we just put how much time is left in the upper left corner
			-- look at https://love2d.org/wiki/love.graphics for fun drawing stuff
			love.graphics.print( (self.time_limit-self.elapsed_time).."s left", 0,0)
            love.graphics.setColorMode('replace')
            love.graphics.draw(self.player.img, self.playerX, self.playerY)
            love.graphics.draw(self.enemy.img, self.enemyX, self.enemyY)

            for i=1,#self.enemy.bullets do
                love.graphics.rectangle('fill', self.enemy.bullets[i].x, self.enemy.bullets[i].y)
            end

            for i=1,#self.bkgdQueue do
                if self.bkgdQueue[i].x < 400 then
                    love.graphics.draw(self.bkgdQueue[i].img, self.bkgdQueue[i].x, 0)
                end
            end

		end
		
		self.isDone = function(self)
			--This can return true to have the game end sooner that the time_limit
			--set for the type of game.

			--we are done when we are out of time.
			return self.elapsed_time > self.time_limit
		end
		
		self.getScore = function(self)
			--return a number -1 to 1. anything >0 is a "passing" score
            return self.score
		end
		
		self.keypressed = function(self, key)
			
			print(key.." was pressed")
		end
		
		self.keyreleased = function(self, key)
			print(key.." was released")
		end
	end
}
