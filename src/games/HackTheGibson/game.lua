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
	keys = {"arrows"},
	
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
		self.time_limit = ({easy=10, medium=15, hard=20, impossible=30})[info.difficulty]
		
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

			-- Seed RNG
			math.randomseed(os.time())

			--Also set up your own initial game state here.
			self.elapsed_time = 0
            self.score = 1
            
            -- Player health and position/size values
            self.player = {}
            self.player.health = 3
            self.player.x = 20
            self.player.y = 200
            self.player.width = 50
            self.player.height = 100

            -- Enemy position/size values
            self.enemy = {}
            self.enemy.x = 320
            self.enemy.y = 200
            self.enemy.width = 50
            self.enemy.height = 100
            --self.enemy.bullets = {}

            -- Bounding boxes
            self.playerBoundingBox = {}
			self.playerBoundingBox.left = 0
			self.playerBoundingBox.right = 200
			self.playerBoundingBox.top = 0
			self.playerBoundingBox.bottom = 400

			self.enemyBoundingBox = {}
			self.enemyBoundingBox.left = 200
			self.enemyBoundingBox.right = 400
			self.enemyBoundingBox.top = 0
			self.enemyBoundingBox.bottom = 400

            -- Set up the background texture data structures
            self.backgroundTextures = {}
            self.backgroundQueue = {}
            
            -- self.makeBullet = function(self)
            --     local b = {}
            --     b.x = self.enemy.x
            --     b.y = self.enemy.y + 20
            --     table.insert(self.enemy.bullets, b)
            -- end

            self:getAudioReady( basePath.."audio/" )
			self:getTexturesReady( basePath.."textures/" )
            
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

			-- Loop through files of the form texn.png, where n is a number,
			-- until no more are detected.
			while love.filesystem.exists( texturePath.."tex"..i..".png" ) do
				path = texturePath.."tex"..i..".png"
				backgroundTexture = love.graphics.newImage( path )
				table.insert( self.backgroundTextures, backgroundTexture )
				i = i + 1
			end

			for i = 1, 3 do
				self.backgroundQueue[i] = {}
				self.backgroundQueue[i].image = self.backgroundTextures[i]
				self.backgroundQueue[i].x = -400 + ( 400 * ( i - 1 ) )
			end

			-- Sprites
			self.player.img = love.graphics.newImage( texturePath.."player.png" )
			self.enemy.img = love.graphics.newImage( texturePath.."enemy.png" )

		end

		self.update = function(self, dt)
			--update is called in between draws. dt is the time in seconds since the last time
			--update was called

			--here we just keep track of how much time has passed
			self.elapsed_time = self.elapsed_time + dt

			-- Start playing background audio loop
			if not self.backgroundLoopStarted then
				love.audio.play( self.backgroundLoop )
			end

			-- Move each background rectangle.
			for i = 1, 3 do
				speedMultiplier = 300
				self.backgroundQueue[i].x = self.backgroundQueue[i].x - ( speedMultiplier * dt )

				if self.backgroundQueue[i].x <= -400 then
					self.backgroundQueue[i].x = self.backgroundQueue[i].x + 800

					randomIndex = math.random( 1, #self.backgroundTextures )
					self.backgroundQueue[i].image = self.backgroundTextures[randomIndex]
				end
			end

			-- Handle player movement
			playerSpeedMod = 175
			self:handlePlayerInput( playerSpeedMod, dt )
			self:handleEntityBounding( self.player, self.playerBoundingBox )

			-- Handle AI Movement
			aiSpeedMod = 150
			self:handleAIThink( aiSpeedMod, dt )
			self:handleEntityBounding( self.enemy, self.enemyBoundingBox )

		end
		
		self.handleAIThink = function( self, aiSpeedMod, dt )
			if self.player.y > self.enemy.y then
                self.enemy.y = self.enemy.y + aiSpeedMod * dt
            end
            if self.player.y < self.enemy.y then
                self.enemy.y = self.enemy.y - aiSpeedMod * dt
            end
		end

		self.handlePlayerInput = function( self, multi, dt )
			if love.keyboard.isDown( "up" ) then
				self.player.y = self.player.y - ( multi * dt )
			end

			if love.keyboard.isDown( "down" ) then
				self.player.y = self.player.y + ( multi * dt )
			end

			if love.keyboard.isDown( "left" ) then
				self.player.x = self.player.x - ( multi * dt )
			end

			if love.keyboard.isDown( "right" ) then
				self.player.x = self.player.x + ( multi * dt )
			end
		end

		self.handleEntityBounding = function( self, entity, boundingBox )
			if entity.x < boundingBox.left then
				entity.x = boundingBox.left
			end

			if entity.x + entity.width > boundingBox.right then
				entity.x = boundingBox.right - entity.width
			end

			if entity.y < boundingBox.top then
				entity.y = boundingBox.top
			end

			if entity.y + entity.height > boundingBox.bottom then
				entity.y = boundingBox.bottom - entity.height
			end
		end

		self.draw = function(self)
			-- Draw the pretty scrolly background thing
			for i = 1, 3 do
                if self.backgroundQueue[i].x > -400 and self.backgroundQueue[i].x < 400 then
                    love.graphics.draw(self.backgroundQueue[i].image, self.backgroundQueue[i].x, 0)
                end
            end

			--here we just put how much time is left in the upper left corner
			-- look at https://love2d.org/wiki/love.graphics for fun drawing stuff
			love.graphics.print( (self.time_limit-self.elapsed_time).."s left", 0,0)

			-- Draw the player and the enemy
            love.graphics.setColorMode('replace')
            love.graphics.draw(self.player.img, self.player.x, self.player.y)
            love.graphics.draw(self.enemy.img, self.enemy.x, self.enemy.y)

            -- Draw the bullets?
            -- for i=1,#self.enemy.bullets do
            --     love.graphics.rectangle('fill', self.enemy.bullets[i].x, self.enemy.bullets[i].y)
            -- end

		end
		
		self.isDone = function(self)
			--This can return true to have the game end sooner that the time_limit
			--set for the type of game.

			--we are done when we are out of time.
			--return self.elapsed_time > self.time_limit
			return false
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
