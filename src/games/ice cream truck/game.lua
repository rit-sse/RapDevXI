local truckSpeed = 300

return {
	standalone_difficulty = "hard",
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
	PR = "sse",
	
	--Keys is an indication to the user that says where to put their hands.
	--It needs to be a list with any values from:
	--  {"arrows","wasd","full keyboard","mouse","space"}
	keys = {"arrows"},
	
	--The longest this game will EVER take. Note: by overriding the isDone method you can end
	--the game sooner. This is just how long until the engine kills your game and asks it for
	--a score by force.
	maxDuration = 10,
	
	--This is where you define what an actual running version of your game is.
	--The first parameter is a table you must fill in with your desired callbacks,
	--as well as any user data. Info is a table with key/values:
	--  difficulty = a value from the difficulties list defined above. You should change at least some aspect
	--			   of how your game is initialized based on this difficulty.
	--
	--  player = some string naming the current player. Don't do anything with this but display it, if even that.
	
	makeGameInstance = function(self, info)
		
		self.getReady = function(self, basePath)
			--get ready is called during the splash screen.
			--The intent is to load all sounds and images during getReady

			--Concatenate basePath with any resource names. This makes your game work in both standalone
			--and the main game mode

			--DON'T START SOUNDS IN GET READY! They will begin playing during the splash screen, and
			--be stopped before your game is actually shown
			
			
			self.img = {}
			self.snd = {}
			self.img.truck = love.graphics.newImage(basePath.."truck.png")
			self.img.star = love.graphics.newImage(basePath.."star.png")
			self.snd.star = love.audio.newSource(basePath.."star.mp3")
			self.snd.song = love.audio.newSource(basePath.."background.mp3")
			--self.sound = love.sound.newSource(basePath.."sound.mp3")

			--Aso set up your own initial game state here.
			self.elapsed_time = 0
			
			self.truckY = 0
			
			self.speed = ({easy=1.0,medium=1.1,hard=1.5,impossible=1.9})[info.difficulty]
			
			self.starSpeed = ({easy=100,medium=125,hard=150,impossible=200})[info.difficulty]
			self.star_freq = ({easy=0.5,medium=1,hard=1.5,impossible=2.5})[info.difficulty]
			
			self.stars = {}
			self.lastStarTime = -1/self.star_freq
			
			self.hit = 0
			
			self.backgroundPlaying = false
		end

		self.update = function(self, dt)
			if not self.backgroundPlaying then
				self.backgroundPlaying = true
				love.audio.play(self.snd.song)
			end
		
		
			self.elapsed_time = self.elapsed_time+dt

			if love.keyboard.isDown("down") then
				self.truckY = self.truckY + dt*self.speed*truckSpeed
				if self.truckY > love.graphics.getHeight()-self.img.truck:getHeight() then
					self.truckY = love.graphics.getHeight()-self.img.truck:getHeight()
				end
			end
			if love.keyboard.isDown("up") then
				self.truckY = self.truckY - dt*self.speed*truckSpeed
				if self.truckY < 0 then self.truckY = 0 end
			end
			
			
			
			self:hitStars()
			if self.elapsed_time > self.lastStarTime + 1/self.star_freq then
				local maxValue = love.graphics.getHeight()-self.img.star:getHeight()
				table.insert(self.stars, { hitTime = self.elapsed_time + love.graphics.getWidth()/self.starSpeed,
				y=math.random(10*maxValue)%maxValue,
				hit=false})
				self.lastStarTime = self.elapsed_time
			end
		end
		
		self.hitStars = function(self)
			for i=1,#self.stars do
				local star = self.stars[i]
				
				if (not star.hit) and self:starX(star) < self.img.truck:getWidth() and self:starX(star)>0 
					and math.abs(star.y - self.truckY)<16
				then
					star.hit= true
					love.audio.play(self.snd.star)
					self.hit = self.hit+1
				end
				
			end
		end
		
		self.draw = function(self)
			love.graphics.setColor(127,127,127)
			love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
		
		
			love.graphics.setColor(255,255,255)
			love.graphics.draw(self.img.truck,0,self.truckY,0,1,1)
			
			for i=1,#self.stars do
				local star = self.stars[i]
				if not star.hit then
					love.graphics.draw(self.img.star,self:starX(star),star.y)
				end
			end
			
		end
		
		self.starX = function(self,star) 
			return self.img.truck:getWidth()+(star.hitTime-self.elapsed_time)*self.starSpeed*self.speed
		end
				
		self.getScore = function(self)
			local couldHaveHit = 0
			
			for i=1,#self.stars do
				if self:starX(self.stars[i]) < self.img.truck:getWidth() then
					couldHaveHit = couldHaveHit +1
				end
			end
			
			return (self.hit/couldHaveHit)*2-1

		end
		
	end
}
