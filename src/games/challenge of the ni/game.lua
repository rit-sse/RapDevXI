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
		self.time_limit = ({easy=30, medium=30, hard=30, impossible=30})[info.difficulty]
		
		--Callbacks

		
		self.getReady = function(self, basePath)

			math.randomseed(os.time())
			--get ready is called during the splash screen.
			--The intent is to load all sounds and images during getReady

			--Concatenate basePath with any resource names. This makes your game work in both standalone
			--and the main game mode

			--DON'T START SOUNDS IN GET READY! They will begin playing during the splash screen, and
			--be stopped before your game is actually shown

			--self.image = love.graphics.newImage(basePath.."sprite.png")
			--self.sound = love.audio.newSource(basePath.."sound.mp3")
			
			self.sound = {}
			self.sound.start = love.audio.newSource(basePath.."nisound.ogg")
			self.sound.fall = love.audio.newSource(basePath.."fall.mp3")
			self.sound.hit = love.audio.newSOurce(basePath.."hit.mp3")

			self.cracks = {
				love.graphics.newImage(basePath.."crack1.png"),
				love.graphics.newImage(basePath.."crack2.png"),
				love.graphics.newImage(basePath.."crack3.png"),
				love.graphics.newImage(basePath.."crack4.png")
			}

            self.tree = {}
			self.tree.img = love.graphics.newImage(basePath.."tree.png")
			self.tree.x = 270
			self.tree.y = 0
			self.tree.width = 100
			self.tree.height = 400

			self.sky = love.graphics.newImage(basePath.."sky.png")

			self.grass = love.graphics.newImage(basePath.."grass.png")

            self.herring = {}
			self.herring.img = love.graphics.newImage(basePath.."herring.png")
			self.herring.init_x = 20
			self.herring.init_y = 200
			self.herring.x = self.herring.init_x
			self.herring.y = self.herring.init_y
			self.herring.width = 80
			self.herring.height = 80
			self.herring.state = 'up'
			self.herring.speed_y = ({easy=300, medium=500, hard=700, impossible=900})[info.difficulty]
			self.herring.speed_x = 800
    
            self.branches = {}
			self.branches.img = love.graphics.newImage(basePath.."branches.png")
			self.branches.x = 150
			self.branches.y = -50

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
			
			self.first_update = true
		end

		self.update = function(self, dt)
			--update is called in between draws. dt is the time in seconds since the last time
			--update was called

			--here we just keep track of how much time has passed
			self.elapsed_time = self.elapsed_time+dt	
			
			if self.state == 'throwing' then
                self:throw(dt)
            elseif self.state == 'falling' then
                self.topRot = self.topRot + math.pi / 2 * dt
                
                self.herring.state = 'gone'
            else
                if self.herring.y + self.herring.height >= love.graphics.getHeight() and self.herring.state == 'down' then
                    self.herring.state = 'up'
                end
                if self.herring.y <= 0 and self.herring.state == 'up' then
                    self.herring.state = 'down'
                end
                
                speed = self.herring.speed_y * dt
                if self.herring.state == 'up' then
                    self.herring.y = self.herring.y - speed
                elseif self.herring.state == 'down' then
                    self.herring.y = self.herring.y + speed
                end
			end
			
			if self.first_update then
                love.audio.play(self.sound.start)
                self.first_update = false
            end
		end
		
		self.throw = function(self, dt)
            speed = self.herring.speed_x * dt
            if self.tree.x - self.herring.x - (self.herring.width / 2) <= 0 then
                spot = math.ceil(self.herring.y / 20) + 1
                print("hit chunk"..spot.." self.herring.y="..self.herring.y)
                self.treeChunks[spot] = self.treeChunks[spot] + 1
                
                self.herring.x = self.herring.init_x
                
                self.state = 'cutting'
                
                 if self.treeChunks[spot] == 4 then
                    self.fallingSegment = spot
                    self.state = 'falling'
                    self.treeTop = love.graphics.newQuad(0, 0, 100, (spot-1) * 20 + 10, self.tree.width, self.tree.height)
                    self.treeBottom = love.graphics.newQuad(0, (spot-1) * 20 + 10, 100, 400 - ((spot-1) * 20 + 10), self.tree.width, self.tree.height)
                    self.topRot = 0
                end
                
                love.audio.play(self.sound.hit)
                if self.state == 'falling' then
                    love.audio.play(self.sound.fall)
                end
            else
                self.herring.x = self.herring.x + speed
            end
		end
		
		self.draw = function(self)
			--here we just put how much time is left in the upper left corner
			-- look at https://love2d.org/wiki/love.graphics for fun drawing stuff 
			love.graphics.draw(self.sky, 0, 0)

			love.graphics.print( (self.time_limit-self.elapsed_time).."s left", 0,0)


			if self.state == 'cutting' or self.state == 'throwing' then
				love.graphics.draw(self.branches.img, 150, -50)
				love.graphics.draw(self.tree.img, self.tree.x, self.tree.y)
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
				love.graphics.push()
                
                love.graphics.translate(self.tree.x + self.tree.width, ((self.fallingSegment-1) * 20 + 10))
				love.graphics.rotate(self.topRot)
				
				
				--love.graphics.translate(, (self.fallingSegment * 20))
				
				
				
				--draw top
				love.graphics.drawq(self.tree.img, self.treeTop, -self.tree.width, -((self.fallingSegment-1) * 20 + 10))
				for i=1,self.fallingSegment-1 do
				    if self.treeChunks[i] > 0 then
				        love.graphics.draw(self.cracks[self.treeChunks[i]], -self.tree.width, - (10 + ((self.fallingSegment - i) * 20)))
				    end
				end
				love.graphics.drawq(self.cracks[4], self.crackTop, -self.tree.width, -10)

				love.graphics.pop()


				--draw bottom
				love.graphics.drawq(self.tree.img, self.treeBottom, self.tree.x, (self.fallingSegment * 20) - 10)
				love.graphics.drawq(self.cracks[4], self.crackBottom, self.tree.x, (self.fallingSegment * 20) - 10)
				for i = self.fallingSegment+1, 20 do
				    if self.treeChunks[i] > 0 then
				        love.graphics.draw(self.cracks[self.treeChunks[i]], 270, (i-1) * 20)
				    end
				end
            end

            if not (self.herring.state == 'gone') then
                love.graphics.draw(self.herring.img, self.herring.x, self.herring.y)
            end
			
			love.graphics.draw(self.grass, 0, 360)

		end
		
		self.isDone = function(self)
			--This can return true to have the game end sooner that the time_limit
			--set for the type of game.
	
			--we are done when we are out of time.
			return self.elapsed_time > self.time_limit
		end
		
		self.getScore = function(self)
			--return a number -1 to 1. anything >0 is a "passing" score

            if self.state == 'falling' then
                return 1
            else
                return -1
            end
		end
		
		self.keypressed = function(self, key)
            if key == ' ' then
                self.state = 'throwing'
            end

			print(key.." was pressed")
		end
		
		self.keyreleased = function(self, key)
			print(key.." was released")
		end
	end
}
