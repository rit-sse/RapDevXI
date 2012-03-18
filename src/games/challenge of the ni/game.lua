return {
	standalone_difficulty = "impossible",
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
		self.time_limit = ({easy=30, medium=20, hard=10, impossible=5})[info.difficulty]

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
			
			self.sound = {}
			self.sound.start = love.audio.newSource(basePath.."nisound.ogg")
			self.sound.fall = love.audio.newSource(basePath.."fall.ogg")
			self.sound.hit = love.audio.newSource(basePath.."hit.mp3", 'static')

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
			self.herring.width = 53
			self.herring.height = 30
			self.herring.state = 'up'
			self.herring.speed_y = ({easy=400, medium=500, hard=800, impossible=1000})[info.difficulty]
			self.herring.speed_x = 800
			self.herring.init_angle = 0
			self.herring.angle = self.herring.init_angle
			self.herring.init_speed_angle = 10 + (self.herring.speed_y / 10)
			self.herring.speed_angle = self.herring.init_speed_angle
    
            self.branches = {}
			self.branches.img = love.graphics.newImage(basePath.."branches.png")
			self.branches.x = 150
			self.branches.y = -50
			self.branches.fall_speed = 100
			self.branches.roll_angle_speed = math.pi/4
			self.branches.roll_x_speed = 100
			self.branches.angle = 0

			self.treeChunks = {}
			local i = 1
			for i = 1, 20 do
				self.treeChunks[i] = 0
			end

			self.state = 'cutting'
            self.fallingTime = 0;
            
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
                self.fallingTime = self.fallingTime + dt
                if self.topRot <= math.pi then
                    self.topRot = self.topRot + math.pi / 2 * dt
                end
                
                if self.branches.y <= 175 then
                    self.branches.y = self.branches.y + self.branches.fall_speed * dt
                else 
                    self.branches.angle = self.branches.angle - self.branches.roll_angle_speed * dt
                    self.branches.x = self.branches.x - self.branches.roll_x_speed * dt
                end
                
                self.herring.state = 'gone'
            else
            	speed = self.herring.speed_y * dt
            	self:adjust_herring_y(speed)
			end
			
			if self.first_update then
                love.audio.play(self.sound.start)
                self.first_update = false
            end
		end

		self.adjust_herring_y = function(self, speed)
			if self.herring.y + self.herring.height >= love.graphics.getHeight() and self.herring.state == 'down' then
                self.herring.state = 'up'
            end
            if self.herring.y <= 0 and self.herring.state == 'up' then
                self.herring.state = 'down'
            end
            
            if self.herring.state == 'up' then
                self.herring.y = self.herring.y - speed
            elseif self.herring.state == 'down' then
                self.herring.y = self.herring.y + speed
            end

            if self.herring.y > love.graphics.getHeight() then
            	self.herring.y = love.graphics.getHeight() - self.herring.height
            elseif self.herring.y < 0 then
            	self.herring.y = 0
            end
		end
		
		self.throw = function(self, dt)
            speed = self.herring.speed_x * dt
            angle_speed = self.herring.speed_angle * dt
            if self.tree.x - self.herring.x - (self.herring.width / 2) <= 0 then
                spot = math.ceil(self.herring.y / 20) + 1
                if spot > 20 then
                    spot = 20
                elseif spot <= 0 then
                    spot = 1
                end
                
                print("hit chunk"..spot.." self.herring.y="..self.herring.y)
                self.treeChunks[spot] = self.treeChunks[spot] + 1
                
                self.herring.x = self.herring.init_x
                self.herring.angle = self.herring.init_angle
                
                self:adjust_herring_y(100)
                
                self.state = 'cutting'
                
                 if self.treeChunks[spot] == 4 then
                    self.fallingSegment = spot
                    self.state = 'falling'
                    self.fallingTime = 0
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
                self.herring.angle = self.herring.angle + angle_speed
            end
		end
		
		self.draw = function(self)
			--here we just put how much time is left in the upper left corner
			-- look at https://love2d.org/wiki/love.graphics for fun drawing stuff 
			love.graphics.draw(self.sky, 0, 0)

			love.graphics.print( string.format("%2.1f left", (self.time_limit-self.elapsed_time)), 0,0)


            --draw branches
            love.graphics.push()
            love.graphics.translate(self.branches.x+150, self.branches.y+120)
            love.graphics.rotate(self.branches.angle)
            love.graphics.draw(self.branches.img, -150, -100)
            love.graphics.pop()
            
            
            
			if self.state == 'cutting' or self.state == 'throwing' then
				
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
                --draw top
				love.graphics.push()
                
                love.graphics.translate(self.tree.x + self.tree.width, ((self.fallingSegment-1) * 20 + 10))
				love.graphics.rotate(self.topRot)
				
				love.graphics.drawq(self.tree.img, self.treeTop, -self.tree.width, -((self.fallingSegment-1) * 20 + 10))
				for i=1,self.fallingSegment-1 do
				    if self.treeChunks[i] > 0 then
				        love.graphics.draw(self.cracks[self.treeChunks[i]], -self.tree.width, - (10 + ((self.fallingSegment - i) * 20)))
				    end
				end
				love.graphics.drawq(self.cracks[4], self.crackTop, -self.tree.width, -10)
				
				--draw extra top
				love.graphics.push()
				love.graphics.translate(-self.tree.width, -((self.fallingSegment-1) * 20 + 10) - 400)
				love.graphics.scale(-1,1)
				love.graphics.rotate(math.pi)
				love.graphics.draw(self.tree.img, 0, -400 )
				love.graphics.pop()

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
                love.graphics.push()
                love.graphics.translate(self.herring.x, self.herring.y)
                love.graphics.rotate(self.herring.angle)
                love.graphics.draw(self.herring.img, -(self.herring.width/2), -(self.herring.height/2))
                love.graphics.pop()
            end
			
			love.graphics.draw(self.grass, 0, 360)

		end
		
		self.isDone = function(self)
			--This can return true to have the game end sooner that the time_limit
			--set for the type of game.
	
			--we are done when we are out of time.
			return self.elapsed_time > self.time_limit or self.fallingTime > 10
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
            if key == ' ' and self.state == 'cutting' then
                self.state = 'throwing'
            end

			print(key.." was pressed")
		end
		
		self.keyreleased = function(self, key)
			print(key.." was released")
		end
	end
}
